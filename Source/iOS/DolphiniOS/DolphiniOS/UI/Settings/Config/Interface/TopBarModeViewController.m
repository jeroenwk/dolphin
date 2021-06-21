// Copyright 2020 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#import "TopBarModeViewController.h"

#define ROW_TO_MODE(x) x + 1
#define MODE_TO_ROW(x) x - 1

@interface TopBarModeViewController ()

@end

@implementation TopBarModeViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  NSInteger mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"top_bar_pull_down_mode"];
  UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:MODE_TO_ROW(mode) inSection:0]];
  [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
  NSInteger mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"top_bar_pull_down_mode"];
  if (MODE_TO_ROW(mode) != indexPath.row)
  {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:MODE_TO_ROW(mode) inSection:0]];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    UITableViewCell* new_cell = [tableView cellForRowAtIndexPath:indexPath];
    [new_cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    [[NSUserDefaults standardUserDefaults] setInteger:ROW_TO_MODE(indexPath.row) forKey:@"top_bar_pull_down_mode"];
  }
  
  [tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end
