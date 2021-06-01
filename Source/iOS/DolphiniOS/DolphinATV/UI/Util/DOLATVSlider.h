// Copyright 2021 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DOLATVSlider : UIControl

@property(nonatomic) float value;

- (void)setValue:(float)value animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
