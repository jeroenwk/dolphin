// Copyright 2021 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#import <Foundation/Foundation.h>

// Use forward declaration here instead of the Swift header to avoid a build failure
@class DOLCancellationToken;

typedef NS_ENUM(NSUInteger, DOLJitType)
{
  DOLJitTypeNone,
  DOLJitTypeDebugger,
  DOLJitTypeAllowUnsigned,
  DOLJitTypePTrace,
  DOLJitTypeNotRestricted
};

typedef NS_ENUM(NSUInteger, DOLJitError)
{
  DOLJitErrorNone,
  DOLJitErrorNotArm64e, // on NJB iOS 14.2+, need arm64e
  DOLJitErrorImproperlySigned, // on NJB iOS 14.2+, need correct code directory version and flags set
  DOLJitErrorNeedUpdate, // iOS not supported
  DOLJitErrorWorkaroundRequired, // NJB iOS 14.4+ broke the JIT hack
  DOLJitErrorGestaltFailed, // an error occurred with loading MobileGestalt
  DOLJitErrorJailbreakdFailed, // an error occurred with contacting jailbreakd
  DOLJitErrorCsdbgdFailed // an error occurred with contacting csdbgd
};

extern NSString* const DOLJitAcquiredNotification;

NS_ASSUME_NONNULL_BEGIN

@interface DOLJitManager : NSObject

+ (DOLJitManager*)sharedManager;

- (void)attemptToAcquireJitOnStartup;
- (void)attemptToAcquireJitByRemoteDebuggerUsingCancellationToken:(DOLCancellationToken*)token;
- (DOLJitType)jitType;
- (bool)appHasAcquiredJit;
- (DOLJitError)getJitErrorType;
- (void)setAuxillaryError:(NSString*)error;
- (nullable NSString*)getAuxiliaryError;

@end

NS_ASSUME_NONNULL_END
