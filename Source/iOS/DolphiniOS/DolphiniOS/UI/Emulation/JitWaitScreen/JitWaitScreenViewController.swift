// Copyright 2021 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

import Foundation

@objc class JitWaitScreenViewController : UIViewController
{
  @objc weak var delegate: JitWaitScreenDelegate?
  var cancellation_token = DOLCancellationToken()
  
  override func viewDidLoad()
  {
    DOLJitManager.shared().attemptToAcquireJitByRemoteDebugger(using: cancellation_token)
  }
  
  func jitAcquired()
  {
    self.delegate?.DidFinishJitAcquisition(result: true, sender: self)
  }
  
  @IBAction func cancelPressed(_ sender: Any)
  {
    self.cancellation_token.cancel()
    
    self.delegate?.DidFinishJitAcquisition(result: false, sender: self)
  }
  
}
