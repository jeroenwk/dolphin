// Copyright 2019 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#import <GameController/GameController.h>

#import <MetalKit/MetalKit.h>

#import "NKitWarningNoticeViewController.h"

#import <UIKit/UIKit.h>

#import "Core/Boot/Boot.h"

#import "DiscIO/Enums.h"

#if TARGET_OS_TV
#import "DolphinATV-Swift.h"
#else
#import "DolphiniOS-Swift.h"
#endif

#import "EAGLView.h"

#import "UICommon/GameFile.h"

typedef NS_ENUM(NSUInteger, DOLTopBarPullDownMode) {
  DOLTopBarPullDownModeSwipe = 0,
  DOLTopBarPullDownModeButton,
  DOLTopBarPullDownModeAlwaysVisible,
  DOLTopBarPullDownModeAlwaysHidden
};

NS_ASSUME_NONNULL_BEGIN

@interface EmulationViewController : UIViewController <NKitWarningNoticeDelegate>
{
  @public std::unique_ptr<BootParameters> m_boot_parameters;
#if !TARGET_OS_TV
  @public std::vector<std::pair<int, TCView*>> m_controllers;
#endif
}

@property (weak, nonatomic) IBOutlet MTKView* m_metal_view;
@property (weak, nonatomic) IBOutlet EAGLView* m_eagl_view;

#if !TARGET_OS_TV
@property (weak, nonatomic) IBOutlet TCView* m_gc_pad;
@property (weak, nonatomic) IBOutlet TCView* m_wii_normal_pad;
@property (weak, nonatomic) IBOutlet TCView* m_wii_sideways_pad;
@property (weak, nonatomic) IBOutlet TCView* m_wii_classic_pad;
#endif

@property (strong, nonatomic) IBOutlet NSLayoutConstraint* m_metal_bottom_constraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* m_metal_half_constraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* m_eagl_bottom_constraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* m_eagl_half_constraint;

#if !TARGET_OS_TV
@property (strong, nonatomic) IBOutlet UIScreenEdgePanGestureRecognizer* m_edge_pan_recognizer;
#endif

@property (weak, nonatomic) IBOutlet UINavigationItem* m_navigation_item;
@property (weak, nonatomic) IBOutlet UIButton* m_pull_down_button;

@property(nonatomic) bool m_did_show_nkit_warning;
@property(nonatomic) bool m_nkit_warning_dismissed;
@property(nonatomic) bool m_emulation_started;
@property(nonatomic) bool m_memory_warning_shown_for_session;
@property(nonatomic) UIView* m_renderer_view;
@property(nonatomic) bool m_is_wii;
@property(nonatomic) bool m_is_homebrew;
@property(nonatomic) DiscIO::Region m_ipl_region;
@property(nonatomic) int m_ts_active_port;
@property(nonatomic) DOLTopBarPullDownMode m_pull_down_mode;
@property(nonatomic) NSTimer* m_pull_down_button_timer;
@property(nonatomic) NSUInteger m_pull_down_button_visibility_left;
#if !TARGET_OS_TV
@property(weak, nonatomic) TCView* m_ts_active_view;
#endif
@property(nonatomic) UIBarButtonItem* m_stop_button;
@property(nonatomic) UIBarButtonItem* m_pause_button;
@property(nonatomic) UIBarButtonItem* m_play_button;

- (void)RunningTitleUpdated;
#if !TARGET_OS_TV
- (void)PopulatePortDictionary;
- (void)ChangeVisibleTouchControllerToPort:(int)port;
#endif

@end

NS_ASSUME_NONNULL_END
