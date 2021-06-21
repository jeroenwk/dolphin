// Copyright 2021 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

import Foundation

@objc enum DOLTopBarPullDownMode: Int
{
  case swipe = 0
  case button = 1
  case alwaysVisible = 2
  case alwaysHidden = 3
}
