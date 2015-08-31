//
//  IASKAppSettingsSplitViewController.m
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009:
//  Luc Vandal, Edovia Inc., http://www.edovia.com
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//  All rights reserved.
//
//  It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz,
//  as the original authors of this code. You can give credit in a blog post, a tweet or on
//  a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

#import "IASKAppSettingsSplitViewController.h"

#import "IASKSettingsReader.h"

// Custom UINavigationController to be used in the detail view controller in order to support iOS < 8
@interface IASKAppSettingsDetailNavigationController : UINavigationController<UISplitViewControllerDelegate>

@end

@implementation IASKAppSettingsDetailNavigationController

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
  return NO;
}

@end

@interface IASKAppSettingsSplitViewController ()

@end

@implementation IASKAppSettingsSplitViewController {
  IASKAppSettingsViewController *_settingsViewController;
  UINavigationController *_masterNavigationViewController;
  UINavigationController *_detailNavigationViewController;
}

- (instancetype)init
{
  return [self initWithSettingsViewController:[[IASKAppSettingsViewController alloc] init]];
}

- (instancetype)initWithSettingsViewController:(IASKAppSettingsViewController *)settingsViewController {
  self = [super init];
  if (self) {
    _settingsViewController = settingsViewController;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _masterNavigationViewController = [[UINavigationController alloc] initWithRootViewController:_settingsViewController];

  // Show both master & detail view in portrait mode on iPad
  if ([self respondsToSelector:@selector(preferredDisplayMode)]) {            // >= iOS 8
    _detailNavigationViewController = [[UINavigationController alloc] init];
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
  } else {                                                                    // < iOS 8
    _detailNavigationViewController = [[IASKAppSettingsDetailNavigationController alloc] init];
    self.delegate = (IASKAppSettingsDetailNavigationController *)_detailNavigationViewController;
    _settingsViewController.masterViewControllerDelegate = self;
  }

  self.viewControllers = @[_masterNavigationViewController, _detailNavigationViewController];
}

#pragma mark - IASKSettingsMasterViewDelegate - required for pre iOS 8

- (void)showDetailViewController:(UIViewController *)viewController {
  _detailNavigationViewController.viewControllers = @[viewController];
}

@end
