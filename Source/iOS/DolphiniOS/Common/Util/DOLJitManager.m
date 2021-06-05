// Copyright 2021 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#import "DOLJitManager.h"

#import <dlfcn.h>

#import "CodeSignatureUtils.h"
#import "DebuggerUtils.h"

@implementation DOLJitManager
{
  DOLJitType _m_jit_type;
  DOLJitError _m_jit_error;
  NSString* _m_aux_error;
}

+ (DOLJitManager*)sharedManager
{
  static dispatch_once_t _once_token = 0;
  static DOLJitManager* _shared_manager = nil;
  
  dispatch_once(&_once_token, ^{
    _shared_manager = [[self alloc] init];
  });
  
  return _shared_manager;
}

- (id)init
{
  if ((self = [super init]))
  {
    _m_jit_type = DOLJitTypeNone;
    _m_jit_error = DOLJitErrorNone;
    _m_aux_error = nil;
  }
  
  return self;
}

- (NSString*)getCpuArchitecture
{
  // Query MobileGestalt for the CPU architecture
  void* gestalt_handle = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_LAZY);
  if (!gestalt_handle)
  {
    return nil;
  }
  
  typedef NSString* (*MGCopyAnswer_ptr)(NSString*);
  MGCopyAnswer_ptr MGCopyAnswer = (MGCopyAnswer_ptr)dlsym(gestalt_handle, "MGCopyAnswer");
  
  if (!MGCopyAnswer)
  {
    return nil;
  }
  
  NSString* cpu_architecture = MGCopyAnswer(@"k7QIBwZJJOVw+Sej/8h8VA"); // "CPUArchitecture"
  
  dlclose(gestalt_handle);
  
  return cpu_architecture;
}

- (DOLJitError)acquireJitByAllowUnsigned
{
  NSString* cpu_architecture = [self getCpuArchitecture];
  
  if (cpu_architecture == nil)
  {
    return DOLJitErrorGestaltFailed;
  }
  else if (![cpu_architecture isEqualToString:@"arm64e"])
  {
    return DOLJitErrorNotArm64e;
  }
  else if (!HasValidCodeSignature())
  {
    return DOLJitErrorImproperlySigned;
  }
  
  return DOLJitErrorNone;
}

- (void)attemptToAcquireJitWithCallback:(nullable void(^)(DOLJitError))callback
{
  void(^jit_acquisition_succeeded)(DOLJitType) = ^(DOLJitType type) {
    self->_m_jit_type = type;
    self->_m_jit_error = DOLJitErrorNone;
    
    if (callback)
    {
      callback(DOLJitErrorNone);
    }
  };
  
  void(^jit_acquisition_failed)(DOLJitError) = ^(DOLJitError error) {
    self->_m_jit_type = DOLJitTypeNone;
    self->_m_jit_error = error;
    
    if (callback)
    {
      callback(error);
    }
  };
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    if (IsProcessDebugged())
    {
      jit_acquisition_succeeded(DOLJitTypeDebugger);
      return;
    }
    
#if TARGET_OS_SIMULATOR
    jit_acquisition_succeeded(DOLJitTypeDebugger);
    return;
#endif
    
#ifdef NONJAILBROKEN
    if (@available(iOS 14.4, *))
    {
      // TODO
      jit_acquisition_failed(DOLJitErrorWorkaroundRequired);
    }
    else if (@available(iOS 14.2, *))
    {
      DOLJitError error = [self acquireJitByAllowUnsigned];
      if (error == DOLJitErrorNone)
      {
        jit_acquisition_succeeded(DOLJitTypeAllowUnsigned);
      }
      else
      {
        jit_acquisition_failed(error);
      }
      
      // TODO: attempt by remote debugger
    }
    else if (@available(iOS 14, *))
    {
      // TODO: attempt by remote debugger
      
      jit_acquisition_failed(DOLJitErrorNeedUpdate);
    }
    else if (@available(iOS 13.5, *))
    {
      SetProcessDebuggedWithPTrace();
      
      jit_acquisition_succeeded(DOLJitTypePTrace);
    }
    else
    {
      // TODO: attempt by remote debugger
      
      jit_acquisition_failed(DOLJitErrorNeedUpdate);
    }
#else // jailbroken
    bool success = false;
    
    // Check for jailbreakd (Chimera, Electra, Odyssey...)
    NSFileManager* file_manager = [NSFileManager defaultManager];
    if ([file_manager fileExistsAtPath:@"/var/run/jailbreakd.pid"])
    {
      success = SetProcessDebuggedWithJailbreakd();
      if (success)
      {
        jit_acquisition_succeeded(DOLJitTypeDebugger);
      }
      else
      {
        jit_acquisition_failed(DOLJitErrorJailbreakdFailed);
      }
    }
    else
    {
      success = SetProcessDebuggedWithDaemon();
      if (success)
      {
        jit_acquisition_succeeded(DOLJitTypeDebugger);
      }
      else
      {
        jit_acquisition_failed(DOLJitErrorCsdbgdFailed);
      }
    }
#endif
  });
}

- (DOLJitType)jitType
{
  return _m_jit_type;
}

- (bool)appHasAcquiredJit
{
  return _m_jit_type != DOLJitTypeNone;
}

- (DOLJitError)getJitErrorType
{
  return self->_m_jit_error;
}

- (void)setAuxillaryError:(NSString*)error
{
  self->_m_aux_error = error;
}

- (NSString*)getAuxiliaryError
{
  return self->_m_aux_error;
}

@end
