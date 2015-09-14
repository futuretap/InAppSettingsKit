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

@property (readonly, nonatomic) UINavigationController *detailNavigationViewController;
@end

@implementation IASKAppSettingsSplitViewController {
  IASKAppSettingsViewController *_masterSettingsViewController;
  UINavigationController *_masterNavigationViewController;
}

- (instancetype)init
{
  return [self initWithSettingsViewController:[[IASKAppSettingsViewController alloc] init]];
}

- (instancetype)initWithSettingsViewController:(IASKAppSettingsViewController *)settingsViewController {
  self = [super init];
  if (self) {
    _masterSettingsViewController = settingsViewController;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _masterNavigationViewController = [[UINavigationController alloc] initWithRootViewController:_masterSettingsViewController];
  UINavigationController *detailNavigationViewController;

  // Show both master & detail view in portrait mode on iPad
  if ([self respondsToSelector:@selector(preferredDisplayMode)]) {            // >= iOS 8
    detailNavigationViewController = [[UINavigationController alloc] init];
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    self.delegate = self;
  } else {                                                                    // < iOS 8
    detailNavigationViewController = [[IASKAppSettingsDetailNavigationController alloc] init];
    self.delegate = (IASKAppSettingsDetailNavigationController *)detailNavigationViewController;
    _masterSettingsViewController.masterViewControllerDelegate = self;
  }

  self.viewControllers = @[_masterNavigationViewController, detailNavigationViewController];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];
}

- (UINavigationController *)detailNavigationViewController {
  if (self.viewControllers.count == 2) {
      return (UINavigationController *)self.viewControllers[1];
  }

  return nil;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kIASKAppSettingChanged object:nil];
}

#pragma mark -
#pragma mark UISplitViewControllerDelegate

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController {
  if (_masterNavigationViewController.viewControllers.count == 1 &&
      [_masterSettingsViewController.delegate respondsToSelector:@selector(initialDetailViewControllerForSettingsViewController:)]) {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[_masterSettingsViewController.delegate initialDetailViewControllerForSettingsViewController:_masterSettingsViewController]];
    navigationController.navigationBar.tintColor = _masterSettingsViewController.navigationController.navigationBar.tintColor;
    navigationController.navigationBar.translucent = _masterSettingsViewController.navigationController.navigationBar.translucent;
    return navigationController;
  }

  return nil;
}

#pragma mark -
#pragma mark kIASKAppSettingChanged notification

- (void)settingDidChange:(NSNotification*)notification {
  [_masterSettingsViewController.tableView reloadData];
}

#pragma mark -
#pragma mark IASKSettingsMasterViewDelegate - required for pre iOS 8

- (void)showDetailViewController:(UIViewController *)viewController {
  self.detailNavigationViewController.viewControllers = @[viewController];
}

@end
