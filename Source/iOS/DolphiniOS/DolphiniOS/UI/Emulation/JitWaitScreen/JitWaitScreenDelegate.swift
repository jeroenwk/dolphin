// Copyright 2021 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

import Foundation

@objc protocol JitWaitScreenDelegate : AnyObject
{
  func DidFinishJitAcquisition(result: Bool, sender: Any)
}
