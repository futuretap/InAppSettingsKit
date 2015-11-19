//
//  MainViewController.m
//  InAppSettingsKitSampleApp
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009-2010:
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

#import "MainViewController.h"

#import <MessageUI/MessageUI.h>

#ifdef USES_IASK_STATIC_LIBRARY
  #import "InAppSettingsKit/IASKSettingsReader.h"
  #import "InAppSettingsKit/IASKAppSettingsSplitViewController.h"
#else
  #import "IASKSettingsReader.h"
  #import "IASKAppSettingsSplitViewController.h"
#endif

#import "CustomViewCell.h"

@interface MainViewController()<UIPopoverControllerDelegate>
- (void)settingDidChange:(NSNotification*)notification;

@property (nonatomic) UIPopoverController* currentPopoverController;

@end

@implementation MainViewController

@synthesize appSettingsViewController, tabAppSettingsViewController;

- (IASKAppSettingsViewController*)appSettingsViewController {
	if (!appSettingsViewController) {
		appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
		appSettingsViewController.delegate = self;
		BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoConnect"];
		appSettingsViewController.hiddenKeys = enabled ? nil : [NSSet setWithObjects:@"AutoConnectLogin", @"AutoConnectPassword", nil];
	}
	return appSettingsViewController;
}

- (IBAction)showSettingsPush:(id)sender {
  //[viewController setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
  // But we encourage you no to uncomment. Thank you!
  self.appSettingsViewController.showDoneButton = NO;
  self.appSettingsViewController.navigationItem.rightBarButtonItem = nil;

  // A UISplitViewController can't be pushed onto a UINavigationController. We could use the same trick as the one we
  // use in showSettingsModal: by placing it in a container view controller, but this doesn't quite work as the enclosing
  // UINavigationController doesn't play nice with the UINavigationControllers in the master & detail view controllers.
  // Therefore, if we're pushing onto an existing navigation stack we'll have to display the IASKAppSettingsViewController
  // directly and not use a split view in large size class mode.
  [self.navigationController pushViewController:self.appSettingsViewController animated:YES];
}

- (IBAction)showSettingsModal:(id)sender {
  //[viewController setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
  // But we encourage you not to uncomment. Thank you!
  self.appSettingsViewController.showDoneButton = YES;

  UIViewController *viewController;

  BOOL ios8 = NO;
  IASK_IF_IOS8_OR_GREATER(ios8 = YES;)
  if (ios8 || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    IASKAppSettingsSplitViewController *splitViewController = [[IASKAppSettingsSplitViewController alloc] initWithSettingsViewController:self.appSettingsViewController];
    if (ios8) {
      viewController = splitViewController;
    } else { // Pre iOS 8 a UISplitViewController can't be displayed modally so we place it in a container view controller
      viewController = [[UIViewController alloc] init];
      [viewController addChildViewController:splitViewController];
      [viewController.view addSubview:splitViewController.view];
      [splitViewController didMoveToParentViewController:viewController];
    }
  } else {
    viewController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
  }
  [self presentViewController:viewController animated:YES completion:nil];
}

- (void)showSettingsPopover:(id)sender {
	if(self.currentPopoverController) {
    [self dismissCurrentPopover];
		return;
	}
  
	self.appSettingsViewController.showDoneButton = NO;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navController];
	popover.delegate = self;
	[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
	self.currentPopoverController = popover;
}

- (void)awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];
	BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoConnect"];
	self.tabAppSettingsViewController.hiddenKeys = enabled ? nil : [NSSet setWithObjects:@"AutoConnectLogin", @"AutoConnectPassword", nil];

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSettingsPopover:)];
	}

  // Add settings tab
  NSMutableArray *viewControllers = [self.tabBarController.viewControllers mutableCopy];
  IASKAppSettingsViewController *settingsViewController = [[IASKAppSettingsViewController alloc] init];
  settingsViewController.showDoneButton = NO;

  UIViewController *settingsTabBarViewController;
  BOOL ios8 = NO;
  IASK_IF_IOS8_OR_GREATER(ios8 = YES;)
  if (ios8 || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    settingsTabBarViewController = [[IASKAppSettingsSplitViewController alloc] initWithSettingsViewController:settingsViewController];
  } else {
    settingsTabBarViewController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
  }
  settingsTabBarViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"20-gear2"] selectedImage:[UIImage imageNamed:@"20-gear2Highlighted"]];
  [viewControllers addObject:settingsTabBarViewController];
  self.tabBarController.viewControllers = viewControllers;
}

#pragma mark - View Lifecycle
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if(self.currentPopoverController) {
		[self dismissCurrentPopover];
	}
}

- (void) dismissCurrentPopover {
	[self.currentPopoverController dismissPopoverAnimated:YES];
	self.currentPopoverController = nil;
}

#pragma mark -
#pragma mark IASKAppSettingsViewControllerDelegate protocol
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
	
	// your code here to reconfigure the app for changed settings
}

// optional delegate method for handling mail sending result
- (void)settingsViewController:(id<IASKViewController>)settingsViewController mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
       
    if ( error != nil ) {
        // handle error here
    }
    
    if ( result == MFMailComposeResultSent ) {
        // your code here to handle this result
    }
    else if ( result == MFMailComposeResultCancelled ) {
        // ...
    }
    else if ( result == MFMailComposeResultSaved ) {
        // ...
    }
    else if ( result == MFMailComposeResultFailed ) {
        // ...
    }
}
- (CGFloat)settingsViewController:(id<IASKViewController>)settingsViewController
                        tableView:(UITableView *)tableView 
        heightForHeaderForSection:(NSInteger)section {
  NSString* key = [settingsViewController.settingsReader keyForSection:section];
	if ([key isEqualToString:@"IASKLogo"]) {
		return [UIImage imageNamed:@"Icon.png"].size.height + 25;
	} else if ([key isEqualToString:@"IASKCustomHeaderStyle"]) {
		return 55.f;    
  }
	return 0;
}

- (UIView *)settingsViewController:(id<IASKViewController>)settingsViewController
                         tableView:(UITableView *)tableView 
               viewForHeaderForSection:(NSInteger)section {
  NSString* key = [settingsViewController.settingsReader keyForSection:section];
	if ([key isEqualToString:@"IASKLogo"]) {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon.png"]];
		imageView.contentMode = UIViewContentModeCenter;
		return imageView;
	} else if ([key isEqualToString:@"IASKCustomHeaderStyle"]) {
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor redColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.numberOfLines = 0;
    label.font = [UIFont boldSystemFontOfSize:16.f];
    
    //figure out the title from settingsbundle
    label.text = [settingsViewController.settingsReader titleForSection:section];
    
    return label;
  }
	return nil;
}

- (CGFloat)tableView:(UITableView*)tableView heightForSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.key isEqualToString:@"customCell"]) {
		return 44*3;
	}
	return 0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForSpecifier:(IASKSpecifier*)specifier {
	CustomViewCell *cell = (CustomViewCell*)[tableView dequeueReusableCellWithIdentifier:specifier.key];
	
	if (!cell) {
		cell = (CustomViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"CustomViewCell" 
															   owner:self 
															 options:nil] objectAtIndex:0];
	}
	cell.textView.text= [[NSUserDefaults standardUserDefaults] objectForKey:specifier.key] != nil ? 
	 [[NSUserDefaults standardUserDefaults] objectForKey:specifier.key] : [specifier defaultStringValue];
	cell.textView.delegate = self;
	[cell setNeedsLayout];
	return cell;
}

#pragma mark kIASKAppSettingChanged notification
- (void)settingDidChange:(NSNotification*)notification {
	if ([notification.object isEqual:@"AutoConnect"]) {
		IASKAppSettingsViewController *activeController = self.tabBarController.selectedIndex ? self.tabAppSettingsViewController : self.appSettingsViewController;
		BOOL enabled = (BOOL)[[notification.userInfo objectForKey:@"AutoConnect"] intValue];
		[activeController setHiddenKeys:enabled ? nil : [NSSet setWithObjects:@"AutoConnectLogin", @"AutoConnectPassword", nil] animated:YES];
	}
}

#pragma mark UITextViewDelegate (for CustomViewCell)
- (void)textViewDidChange:(UITextView *)textView {
    [[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"customCell"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged object:@"customCell"];
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.currentPopoverController = nil;
}

#pragma mark -
- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.key isEqualToString:@"ButtonDemoAction1"]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Demo Action 1 called" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	} else if ([specifier.key isEqualToString:@"ButtonDemoAction2"]) {
		NSString *newTitle = [[[NSUserDefaults standardUserDefaults] objectForKey:specifier.key] isEqualToString:@"Logout"] ? @"Login" : @"Logout";
		[[NSUserDefaults standardUserDefaults] setObject:newTitle forKey:specifier.key];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	self.appSettingsViewController = nil;
}

@end
