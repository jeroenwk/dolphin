// Copyright 2020 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#ifdef ANALYTICS

#import "AnalyticsNoticeViewController.h"

#import "Core/Config/MainSettings.h"
#import "Core/ConfigManager.h"

#import <FirebaseAnalytics/FirebaseAnalytics.h>

@interface AnalyticsNoticeViewController ()

@end

@implementation AnalyticsNoticeViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)HandleResponse:(bool)response
{
  Config::SetBaseOrCurrent(Config::MAIN_ANALYTICS_PERMISSION_ASKED, true);
  Config::SetBaseOrCurrent(Config::MAIN_ANALYTICS_ENABLED, response);
  
  [FIRAnalytics setAnalyticsCollectionEnabled:response];
  [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)OptInPressed:(id)sender
{
  [self HandleResponse:true];
}

- (IBAction)OptOutPressed:(id)sender
{
  [self HandleResponse:false];
}

@end

#endif // ANALYTICS
