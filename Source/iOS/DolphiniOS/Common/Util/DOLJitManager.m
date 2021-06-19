// Copyright 2021 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#import "DOLJitManager.h"

@import AltKit;

#import <dlfcn.h>

#if TARGET_OS_TV
#import "DolphinATV-Swift.h"
#else
#import "DolphiniOS-Swift.h"
#endif

#import "CodeSignatureUtils.h"
#import "DebuggerUtils.h"

NSString* const DOLJitAcquiredNotification = @"me.oatmealdome.dolphinios.jit-acquired";
NSString* const DOLJitAltJitFailureNotification = @"me.oatmealdome.dolphinios.jit-altjit-failure";

@implementation DOLJitManager
{
  DOLJitType _m_jit_type;
  DOLJitError _m_jit_error;
  NSString* _m_aux_error;
  bool _m_has_acquired_jit;
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
    _m_has_acquired_jit = false;
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

- (DOLJitError)canAcquireJitByUnsigned
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

- (void)attemptToAcquireJitOnStartup
{
#if TARGET_OS_SIMULATOR
  // We're running on macOS, so JITs aren't restricted.
  self->_m_jit_type = DOLJitTypeNotRestricted;
#elif defined(NONJAILBROKEN)
  if (@available(iOS 14.4, *))
  {
    self->_m_jit_type = DOLJitTypeDebugger;
  }
  else if (@available(iOS 14.2, *))
  {
    DOLJitError error = [self canAcquireJitByUnsigned];
    if (error == DOLJitErrorNone)
    {
      self->_m_jit_type = DOLJitTypeAllowUnsigned;
    }
    else
    {
      self->_m_jit_type = DOLJitTypeDebugger;
    }
  }
  else if (@available(iOS 14, *))
  {
    self->_m_jit_type = DOLJitTypeDebugger;
  }
  else if (@available(iOS 13.5, *))
  {
    self->_m_jit_type = DOLJitTypePTrace;
  }
  else
  {
    self->_m_jit_type = DOLJitTypeDebugger;
  }
#else // jailbroken
  self->_m_jit_type = DOLJitTypeDebugger;
#endif
  
  switch (self->_m_jit_type)
  {
    case DOLJitTypeDebugger:
#ifdef NONJAILBROKEN
      self->_m_has_acquired_jit = IsProcessDebugged();
#else
      // Check for jailbreakd (Chimera, Electra, Odyssey...)
      if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/run/jailbreakd.pid"])
      {
        self->_m_has_acquired_jit = SetProcessDebuggedWithJailbreakd();
      }
      else
      {
        self->_m_has_acquired_jit = SetProcessDebuggedWithDaemon();
      }
#endif
      break;
    case DOLJitTypeAllowUnsigned:
    case DOLJitTypeNotRestricted:
      self->_m_has_acquired_jit = true;
      
      break;
    case DOLJitTypePTrace:
      SetProcessDebuggedWithPTrace();
      
      self->_m_has_acquired_jit = true;
      
      break;
    case DOLJitTypeNone: // should never happen
      break;
  }
}

- (void)attemptToAcquireJitByWaitingForDebuggerUsingCancellationToken:(DOLCancellationToken*)token
{
  if (self->_m_jit_type != DOLJitTypeDebugger)
  {
    return;
  }
  
  if (self->_m_has_acquired_jit)
  {
    return;
  }
  
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
    while (!IsProcessDebugged())
    {
      if ([token isCancelled])
      {
        return;
      }
      
      sleep(1);
    }
    
    self->_m_has_acquired_jit = true;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DOLJitAcquiredNotification object:self];
  });
}

- (void)attemptToAcquireJitByAltJIT
{
  if (self->_m_jit_type != DOLJitTypeDebugger)
  {
    return;
  }
  
  if (self->_m_has_acquired_jit)
  {
    return;
  }
  
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
    [[ALTServerManager sharedManager] startDiscovering];
    
    [[ALTServerManager sharedManager] autoconnectWithCompletionHandler:^(ALTServerConnection* connection, NSError* error) {
      if (error)
      {
        [[NSNotificationCenter defaultCenter] postNotificationName:DOLJitAltJitFailureNotification object:self userInfo:@{
          @"nserror": error
        }];
      }
      
      [connection enableUnsignedCodeExecutionWithCompletionHandler:^(bool success, NSError* error)
       {
        if (success)
        {
          [[ALTServerManager sharedManager] stopDiscovering];
          
          // Don't post a notification here, since attemptToAcquireJitByWaitingForDebuggerUsingCancellationToken
          // will do it for us.
        }
        else
        {
          [[NSNotificationCenter defaultCenter] postNotificationName:DOLJitAltJitFailureNotification object:self userInfo:@{
            @"nserror": error
          }];
        }
        
        [connection disconnect];
      }];
    }];
  });
}

- (DOLJitType)jitType
{
  return _m_jit_type;
}

- (bool)appHasAcquiredJit
{
  return _m_has_acquired_jit;
}

- (DOLJitError)getJitErrorType
{
  return self->_m_jit_error;
}

- (void)setAuxillaryError:(NSString*)error
{
  self->_m_aux_error = error;
}

- (nullable NSString*)getAuxiliaryError
{
  return self->_m_aux_error;
}

@end
