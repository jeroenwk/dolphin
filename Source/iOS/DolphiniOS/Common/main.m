// Copyright 2019 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#if TARGET_OS_TV
#import "DolphinATV-Swift.h"
#else
#import "DolphiniOS-Swift.h"
#endif

#import "DOLJitManager.h"

#import <UIKit/UIKit.h>

int main(int argc, char* argv[])
{
  @autoreleasepool
  {
    [[DOLJitManager sharedManager] attemptToAcquireJitWithCallback:nil];
  }
  
  NSString* appDelegateClassName;
  @autoreleasepool
  {
    // Setup code that might create autoreleased objects goes here.
    appDelegateClassName = NSStringFromClass([AppDelegate class]);
  }
  return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
