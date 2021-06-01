// Copyright 2020 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfigAdvancedViewController : UITableViewController

@property (weak, nonatomic) IBOutlet DOLSwitch* m_mmu_switch;
@property (weak, nonatomic) IBOutlet DOLSwitch* m_overclock_switch;
@property (weak, nonatomic) IBOutlet DOLSlider* m_overclock_slider;
@property (weak, nonatomic) IBOutlet UILabel *m_overclock_label;

@end

NS_ASSUME_NONNULL_END
