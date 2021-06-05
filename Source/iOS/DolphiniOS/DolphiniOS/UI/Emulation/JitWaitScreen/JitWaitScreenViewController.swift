// Copyright 2021 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

import Foundation

@objc class JitWaitScreenViewController : UIViewController
{
  @objc weak var delegate: JitWaitScreenDelegate?
  var been_cancelled = false
  
  override func viewDidLoad()
  {
    DOLJitManager.shared().attemptToAcquireJit { error in
      DispatchQueue.main.async {
        if (error != .none)
        {
          let alert = UIAlertController.init(title: "Failed", message: "DolphiniOS failed to acquire JIT: \(error)", preferredStyle: .alert)
          alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { action in
            if (self.been_cancelled)
            {
              return
            }
            
            self.didFinishAcquisition(result: false)
          }))
          
          self.present(alert, animated: true, completion: nil)
        }
        else
        {
          if (self.been_cancelled)
          {
            return
          }
          
          self.didFinishAcquisition(result: true)
        }
      }
    }
  }
  
  @IBAction func cancelPressed(_ sender: Any)
  {
    self.been_cancelled = true
    
    self.didFinishAcquisition(result: false)
  }
  
  func didFinishAcquisition(result: Bool)
  {
    self.delegate?.DidFinishJitAcquisition(result: result, sender: self)
  }
  
}
