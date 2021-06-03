// Copyright 2021 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#import <UIKit/UIKit.h>

typedef void(^ChangedCallback)(void);

#define CELL_SWITCH_CHANGED(x, y) x.callback = ^{ [self y:nil]; }

NS_ASSUME_NONNULL_BEGIN

@interface DOLATVSwitchCell : UITableViewCell

@property (nonatomic) UILabel* stateLabel;

@property(nonatomic, getter=isOn, setter=setOn:) BOOL on;

@property(nonatomic, getter=isEnabled, setter=setEnabled:) BOOL enabled;

@property (nonatomic) ChangedCallback callback;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
