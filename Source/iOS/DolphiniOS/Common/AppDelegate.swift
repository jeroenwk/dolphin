// Copyright 2021 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

import Foundation

@objc class AppDelegate: UIResponder, UIApplicationDelegate
{
  var window: UIWindow?
  
  var services: [UIApplicationDelegate] =
  [
    // Put services here in order of initialization
    JitAcqusitionService()
  ]
  
  override init()
  {
    // Add the legacy delegate with window property set
    let legacyDelegate: AppDelegateLegacy = AppDelegateLegacy()
    legacyDelegate.window = window
    
    services.append(legacyDelegate)
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool
  {
    if (UserDefaults.standard.bool(forKey: "is_killed"))
    {
      let alertWindow = UIWindow.init(frame: UIScreen.main.bounds)
      alertWindow.rootViewController = KilledBuildNoticeViewController.init(nibName: "KilledBuildNotice", bundle: nil)
      alertWindow.makeKeyAndVisible()
    
      self.window = alertWindow
      
      return true
    }
    
    var returnedResult: Bool = true
    
    for service in services
    {
      let result = service.application?(application, didFinishLaunchingWithOptions: launchOptions) ?? true
      
      if (!result)
      {
        returnedResult = false
      }
    }
    
    return returnedResult;
  }
  
  func applicationWillTerminate(_ application: UIApplication)
  {
    for service in services
    {
      service.applicationWillTerminate?(application)
    }
  }
  
  func applicationDidBecomeActive(_ application: UIApplication)
  {
    for service in services
    {
      service.applicationDidBecomeActive?(application)
    }
  }
  
  func applicationWillResignActive(_ application: UIApplication)
  {
    for service in services
    {
      service.applicationWillResignActive?(application)
    }
  }
  
  func applicationDidEnterBackground(_ application: UIApplication)
  {
    for service in services
    {
      service.applicationDidEnterBackground?(application)
    }
  }
  
  func applicationDidReceiveMemoryWarning(_ application: UIApplication)
  {
    for service in services
    {
      service.applicationDidReceiveMemoryWarning?(application)
    }
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
  {
    var returnedResult: Bool = true
    
    for service in services
    {
      let result = service.application?(app, open: url, options: options) ?? true
      
      if (!result)
      {
        returnedResult = false
      }
    }
    
    return returnedResult;
  }
  
}
