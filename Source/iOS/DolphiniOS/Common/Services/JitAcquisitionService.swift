// Copyright 2021 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

import Foundation

class JitAcqusitionService : NSObject, UIApplicationDelegate
{
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool
  {
    DOLJitManager.shared().attemptToAcquireJitOnStartup()
    
    return true
  }
}
