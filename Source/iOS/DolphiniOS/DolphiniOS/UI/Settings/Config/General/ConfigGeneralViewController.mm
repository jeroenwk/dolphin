// Copyright 2020 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#import "ConfigGeneralViewController.h"

#import "Core/Config/MainSettings.h"
#import "Core/ConfigManager.h"
#import "Core/Core.h"
#import "Core/DolphinAnalytics.h"

#ifdef ANALYTICS
#import <FirebaseAnalytics/FirebaseAnalytics.h>
#import <FirebaseCrashlytics/FirebaseCrashlytics.h>
#endif

@interface ConfigGeneralViewController ()

@end

@implementation ConfigGeneralViewController

// Skipped settings:
// "Show Current Game on Discord" - no Discord integration on iOS
// "Auto Update Settings" (all) - auto-update not supported with Cydia

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  SConfig& config = SConfig::GetInstance();
  [self.m_dual_core_switch setOn:config.bCPUThread];
  [self.m_cheats_switch setOn:config.bEnableCheats];
  [self.m_mismatched_region_switch setOn:config.bOverrideRegionSettings];
  [self.m_change_discs_switch setOn:Config::Get(Config::MAIN_AUTO_DISC_CHANGE)];
  [self.m_statistics_switch setOn:Config::GetBase(Config::MAIN_ANALYTICS_ENABLED)];
  
  bool running = Core::GetState() != Core::State::Uninitialized;
  [self.m_dual_core_switch setEnabled:!running];
  [self.m_cheats_switch setEnabled:!running];
  [self.m_mismatched_region_switch setEnabled:!running];
  
#ifdef DEBUG
  [self.m_statistics_switch setEnabled:false];
#endif
  
#if TARGET_OS_TV
  CELL_SWITCH_CHANGED(self.m_dual_core_switch, DualCoreChanged);
  CELL_SWITCH_CHANGED(self.m_cheats_switch, EnableCheatsChanged);
  CELL_SWITCH_CHANGED(self.m_mismatched_region_switch, MismatchedRegionChanged);
  CELL_SWITCH_CHANGED(self.m_change_discs_switch, ChangeDiscsChanged);
  CELL_SWITCH_CHANGED(self.m_statistics_switch, StatisticsChanged);
#endif
}

- (IBAction)DualCoreChanged:(id)sender
{
  bool on = [self.m_dual_core_switch isOn];
  SConfig::GetInstance().bCPUThread = on;
  Config::SetBaseOrCurrent(Config::MAIN_CPU_THREAD, on);
}

- (IBAction)EnableCheatsChanged:(id)sender
{
  bool on = [self.m_cheats_switch isOn];
  SConfig::GetInstance().bEnableCheats = on;
  Config::SetBaseOrCurrent(Config::MAIN_ENABLE_CHEATS, on);
}

- (IBAction)MismatchedRegionChanged:(id)sender
{
  bool on = [self.m_mismatched_region_switch isOn];
  SConfig::GetInstance().bOverrideRegionSettings = on;
  Config::SetBaseOrCurrent(Config::MAIN_OVERRIDE_REGION_SETTINGS, on);
}

- (IBAction)ChangeDiscsChanged:(id)sender
{
  Config::SetBase(Config::MAIN_AUTO_DISC_CHANGE, [self.m_change_discs_switch isOn]);
}

- (IBAction)StatisticsChanged:(id)sender
{
  bool enable_analytics = [self.m_statistics_switch isOn];
  
  Config::SetBaseOrCurrent(Config::MAIN_ANALYTICS_ENABLED, enable_analytics);
  DolphinAnalytics::Instance().ReloadConfig();
  
#ifdef ANALYTICS
  [FIRAnalytics setAnalyticsCollectionEnabled:enable_analytics];
  [[FIRCrashlytics crashlytics] setCrashlyticsCollectionEnabled:enable_analytics];
#endif
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
  if (indexPath.section == 1 && indexPath.row == 1)
  {
    DolphinAnalytics::Instance().GenerateNewIdentity();
    DolphinAnalytics::Instance().ReloadConfig();
#ifdef ANALYTICS
    [FIRAnalytics resetAnalyticsData];
#endif
    [[NSUserDefaults standardUserDefaults] setObject:[[NSArray alloc] init] forKey:@"unique_games"];
    
    UIAlertController* alert_controller = [UIAlertController alertControllerWithTitle:DOLocalizedString(@"Identity Generation") message:DOLocalizedString(@"New identity generated.") preferredStyle:UIAlertControllerStyleAlert];
    [alert_controller addAction:[UIAlertAction actionWithTitle:DOLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert_controller animated:true completion:nil];
  }
  
  [self.tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end
