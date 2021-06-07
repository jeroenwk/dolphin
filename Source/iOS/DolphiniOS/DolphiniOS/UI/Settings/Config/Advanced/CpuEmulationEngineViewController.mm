// Copyright 2020 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#import "CpuEmulationEngineViewController.h"

#if TARGET_OS_TV
#import "DolphinATV-Swift.h"
#else
#import "DolphiniOS-Swift.h"
#endif

#import "Core/Config/MainSettings.h"
#import "Core/ConfigManager.h"
#import "Core/PowerPC/PowerPC.h"

@interface CpuEmulationEngineViewController ()

@end

@implementation CpuEmulationEngineViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
  return PowerPC::AvailableCPUCores().size();
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
  PowerPC::CPUCore core = PowerPC::AvailableCPUCores()[indexPath.row];
  
  CpuEmulationEngineCell* cell = [tableView dequeueReusableCellWithIdentifier:@"engine_cell"];
  
  NSString* engineName;
  switch (core)
  {
    case PowerPC::CPUCore::Interpreter:
      engineName = @"Interpreter (slowest)";
      break;
    case PowerPC::CPUCore::CachedInterpreter:
      engineName = @"Cached Interpreter (slower)";
      break;
    case PowerPC::CPUCore::JIT64:
      engineName = @"JIT Recompiler for x86-64 (recommended)";
      break;
    case PowerPC::CPUCore::JITARM64:
      engineName = @"JIT Recompiler for ARM64 (recommended)";
      break;
    default:
      engineName = @"Unknown";
      break;
  }
  
  [cell.engineLabel setText:DOLocalizedString(engineName)];
  
  if (core == SConfig::GetInstance().cpu_core)
  {
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
  }
  
  return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
  PowerPC::CPUCore current_core = SConfig::GetInstance().cpu_core;
  PowerPC::CPUCore new_core = PowerPC::AvailableCPUCores()[indexPath.row];
  
  if (current_core != new_core)
  {
    NSInteger currentIndex = -1;
    for (NSInteger i = 0; i < PowerPC::AvailableCPUCores().size(); i++)
    {
      if (PowerPC::AvailableCPUCores()[i] == current_core)
      {
        currentIndex = i;
      }
    }
    
    if (currentIndex != -1)
    {
      UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]];
      [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    UITableViewCell* new_cell = [tableView cellForRowAtIndexPath:indexPath];
    [new_cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    SConfig::GetInstance().cpu_core = new_core;
    Config::SetBaseOrCurrent(Config::MAIN_CPU_CORE, new_core);
    
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"did_deliberately_change_cpu_core"];
  }
  
  [tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end
