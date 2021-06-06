// Copyright 2021 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

import Foundation

@objc class JitWaitScreenViewController : UIViewController
{
  @objc weak var delegate: JitScreenDelegate?
  var cancellation_token = DOLCancellationToken()
  
  override func viewDidLoad()
  {
    NotificationCenter.default.addObserver(self, selector: #selector(jitAcquired), name: NSNotification.Name.DOLJitAcquired, object: nil)
    
    DOLJitManager.shared().attemptToAcquireJitByRemoteDebugger(using: cancellation_token)
  }
  
  @objc func jitAcquired(notification: Notification)
  {
    DispatchQueue.main.async {
      self.delegate?.DidFinishJitScreen(result: true, sender: self)
    }
  }
  
  @IBAction func cancelPressed(_ sender: Any)
  {
    self.cancellation_token.cancel()
    
    self.delegate?.DidFinishJitScreen(result: false, sender: self)
  }
  
}
