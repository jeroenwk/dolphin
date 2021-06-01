// Copyright 2021 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DOLATVSwitch : UIControl

@property(nonatomic, getter=isOn) BOOL on;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
