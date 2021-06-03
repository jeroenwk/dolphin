// Copyright 2021 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#import "DOLATVSwitchCell.h"

@implementation DOLATVSwitchCell

@synthesize on;
@synthesize enabled;

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  self.stateLabel = [[UILabel alloc] init];
  [self.stateLabel setText:@"Off"];
  [self.stateLabel setTextAlignment:NSTextAlignmentRight];
  [self.stateLabel setTextColor:[UIColor secondaryLabelColor]];
  [self.stateLabel setTranslatesAutoresizingMaskIntoConstraints:false];
  
  [self.contentView addSubview:self.stateLabel];
  
  NSLayoutConstraint* trailingConstraint = [NSLayoutConstraint constraintWithItem:self.stateLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailingMargin multiplier:1 constant:0];
  NSLayoutConstraint* leadingConstraint = [NSLayoutConstraint constraintWithItem:self.stateLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeadingMargin multiplier:1 constant:0];
  NSLayoutConstraint* topConstraint = [NSLayoutConstraint constraintWithItem:self.stateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
  NSLayoutConstraint* bottomConstraint = [NSLayoutConstraint constraintWithItem:self.stateLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
  
  [self addConstraints:@[ trailingConstraint, leadingConstraint, topConstraint, bottomConstraint ]];
  
  self->enabled = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
  
  if (selected && self->enabled)
  {
    [self setOn:!self.isOn];
  }
}

- (void)setOn:(BOOL)on
{
  self->on = on;

  if (self->on)
  {
    [self.stateLabel setText:@"On"];
  }
  else
  {
    [self.stateLabel setText:@"Off"];
  }
  
  if (self.callback)
  {
    self.callback();
  }
}

- (void)setOn:(BOOL)on animated:(BOOL)animated
{
  [self setOn:on];
}

@end
