// Copyright 2021 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

import Foundation

class JitAcqusitionService : NSObject, UIApplicationDelegate
{
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool
  {
    DOLJitManager.shared().attemptToAcquireJit { DOLJitError in
      // Discard this result - we just need to attempt acquiring JIT for now.
      // It's fine if we fail.
      return
    }
    
    return true
  }
}
