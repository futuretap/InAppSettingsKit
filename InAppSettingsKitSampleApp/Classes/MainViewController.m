//
//  MainViewController.m
//  InAppSettingsKitSampleApp
//
//  Copyright (c) 2009-2020:
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



// Superseded by MainViewController.swift
// Code no longer compiled / in target, left here just for reference.



#import "MainViewController.h"

#import <MessageUI/MessageUI.h>

#import <InAppSettingsKit/IASKSettingsReader.h>
#import <InAppSettingsKit/IASKAppSettingsViewController.h>

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
        appSettingsViewController.cellLayoutMarginsFollowReadableWidth = NO;
		appSettingsViewController.delegate = self;
		[self settingDidChange:nil];
	}
	return appSettingsViewController;
}

- (IBAction)showSettingsPush:(id)sender {
	//[viewController setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
	// But we encourage you no to uncomment. Thank you!
	self.appSettingsViewController.showDoneButton = NO;
	self.appSettingsViewController.navigationItem.rightBarButtonItem = nil;
	[self.navigationController pushViewController:self.appSettingsViewController animated:YES];
}

- (IBAction)showSettingsModal:(id)sender {
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
    //[viewController setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
    // But we encourage you not to uncomment. Thank you!
    self.appSettingsViewController.showDoneButton = YES;
	[self presentViewController:aNavController animated:YES completion:nil];
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

- (void)awakeFromNib {
	[super awakeFromNib];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];

	self.tabAppSettingsViewController = (id)[self.tabBarController.viewControllers.lastObject topViewController];
	[self settingDidChange:nil];
	
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSettingsPopover:)];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	IASKAppSettingsViewController *settingsViewController = (id)((UINavigationController*)segue.destinationViewController).topViewController;
	settingsViewController.delegate = self;
	
	[self settingDidChange:nil];
}

#pragma mark -
#pragma mark IASKAppSettingsViewControllerDelegate protocol
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
	
	// your code here to reconfigure the app for changed settings
}

// optional delegate methods for handling regex validation
- (BOOL)settingsViewController:(IASKAppSettingsViewController *)sender
 validationFailureForSpecifier:(IASKSpecifier *)specifier
					 textField:(IASKTextField *)field
				 previousValue:(NSString *)prevValue {
	BOOL defaultBehaviour = YES;
	if ([field.specifier.key isEqual: @"RegexValidation2"]) {
		defaultBehaviour = NO;
		field.textColor  = UIColor.redColor;
	}
	return defaultBehaviour;
}

- (void)settingsViewController:(IASKAppSettingsViewController *)sender
 validationSuccessForSpecifier:(IASKSpecifier *)specifier
					 textField:(IASKTextField *)field {
	if (@available(iOS 13.0, *)) {
		field.textColor = UIColor.labelColor;
	} else {
		field.textColor = UIColor.blackColor;
	}
}

// optional delegate method for handling mail sending result
- (BOOL)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
shouldPresentMailComposeViewController:(MFMailComposeViewController*)mailComposeViewController
				  forSpecifier:(IASKSpecifier*) specifier {
	if ([specifier.key isEqualToString:@"mail_dynamic_subject"]) {
		[mailComposeViewController setSubject:NSDate.date.description];
	}
	return YES;
}

- (void)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
		 mailComposeController:(MFMailComposeViewController *)controller
		   didFinishWithResult:(MFMailComposeResult)result
						 error:(NSError *)error {
       
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
- (CGFloat)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
		 heightForHeaderInSection:(NSInteger)section
						specifier:(nonnull IASKSpecifier *)specifier {
    NSString *key = [settingsViewController.settingsReader keyForSection:section];
    if ([key isEqualToString:@"IASKLogo"]) {
        return [UIImage imageNamed:@"Icon.png"].size.height + 25;
    } else if ([key isEqualToString:@"IASKCustomHeaderStyle"]) {
        return 55.f;
    }
    return 0;
}

- (UIView *)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
			viewForHeaderInSection:(NSInteger)section
						 specifier:(nonnull IASKSpecifier *)specifier {
    NSString *key = [settingsViewController.settingsReader keyForSection:section];
    if ([key isEqualToString:@"IASKLogo"]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon.png"]];
        imageView.contentMode = UIViewContentModeCenter;
        return imageView;
    } else if ([key isEqualToString:@"IASKCustomHeaderStyle"]) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
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

- (NSString *)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
			 titleForHeaderInSection:(NSInteger)section
						   specifier:(nonnull IASKSpecifier *)specifier {
    NSString *key = [settingsViewController.settingsReader keyForSection:section];
    if ([key isEqualToString:@"CUSTOM_HEADER_FOOTER"]) {
        return @"Custom header title";
    }
    return nil;
}

- (CGFloat)settingsViewController:(id<IASKViewController>)settingsViewController
		 heightForFooterInSection:(NSInteger)section
						specifier:(nonnull IASKSpecifier *)specifier {
    NSString *key = [settingsViewController.settingsReader keyForSection:section];
    if ([key isEqualToString:@"IASKLogo"]) {
        return [UIImage imageNamed:@"Icon.png"].size.height + 25;
    }
    return 0;
}

- (UIView *)settingsViewController:(id<IASKViewController>)settingsViewController
			viewForFooterInSection:(NSInteger)section
						 specifier:(nonnull IASKSpecifier *)specifier {
    NSString *key = [settingsViewController.settingsReader keyForSection:section];
    if ([key isEqualToString:@"IASKLogo"]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon.png"]];
        imageView.contentMode = UIViewContentModeCenter;
        return imageView;
    }
    return nil;
}

- (NSString *)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
			 titleForFooterInSection:(NSInteger)section
						   specifier:(nonnull IASKSpecifier *)specifier {
    NSString *key = [settingsViewController.settingsReader keyForSection:section];
    if ([key isEqualToString:@"CUSTOM_HEADER_FOOTER"]) {
        return @"Custom footer title";
    }
    return nil;
}

- (CGFloat)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
			   heightForSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.key isEqualToString:@"customCell"]) {
		return 44*3;
	}
	return UITableViewAutomaticDimension;
}

- (UITableViewCell*)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
						  cellForSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.parentSpecifier.key isEqualToString:@"accounts"]) {
		UITableViewCell *cell = [settingsViewController.tableView dequeueReusableCellWithIdentifier:@"accountCell"];
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"accountCell"];
		}
		NSDictionary *dict = [self.appSettingsViewController.settingsStore objectForSpecifier:specifier];
		cell.textLabel.text = dict[@"username"];
		cell.detailTextLabel.text = dict[@"email"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return cell;
	}
	CustomViewCell *cell = (CustomViewCell*)[settingsViewController.tableView dequeueReusableCellWithIdentifier:(id)specifier.key];
	
	if (!cell) {
		cell = (CustomViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"CustomViewCell" 
															   owner:self 
															 options:nil] objectAtIndex:0];
	}
	cell.textView.text= [[NSUserDefaults standardUserDefaults] objectForKey:(id)specifier.key] != nil ?
	 [[NSUserDefaults standardUserDefaults] objectForKey:(id)specifier.key] : [specifier defaultStringValue];
	cell.textView.delegate = self;
	[cell setNeedsLayout];
	return cell;
}

- (NSArray *)settingsViewController:(IASKAppSettingsViewController*)sender valuesForSpecifier:(IASKSpecifier *)specifier {
	if ([specifier.key isEqualToString:@"countryCode"]) {
		return [NSLocale ISOCountryCodes];
	}
	return @[];
}

- (NSArray *)settingsViewController:(IASKAppSettingsViewController*)sender titlesForSpecifier:(IASKSpecifier *)specifier {
	if ([specifier.key isEqualToString:@"countryCode"]) {
		NSMutableArray *countryNames = NSMutableArray.array;
		for (NSString *countryCode in [NSLocale ISOCountryCodes]) {
			[countryNames addObject:(id)[NSLocale.currentLocale displayNameForKey:NSLocaleCountryCode value:countryCode]];
		}
		return countryNames;
	}
	return @[];
}

- (BOOL)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController childPaneIsValidForSpecifier:(IASKSpecifier *)specifier
			 contentDictionary:(NSMutableDictionary *)contentDictionary {
	if ([specifier.parentSpecifier.key isEqualToString:@"accounts"]) {
		if (contentDictionary[@"email"] == nil) {
			contentDictionary[@"email"] = @"foo@bar.com";
		}
		return [contentDictionary[@"username"] length] > 1 && [contentDictionary[@"password"] length] > 3
		&& ([contentDictionary[@"roleUser"] boolValue] || [contentDictionary[@"roleEditor"] boolValue] || [contentDictionary[@"roleAdmin"] boolValue]);
	}
	return YES;
}

- (NSDate *)settingsViewController:(IASKAppSettingsViewController*)sender dateForSpecifier:(IASKSpecifier*)specifier {
	id value = [sender.settingsStore objectForSpecifier:specifier];
	if ([specifier.key isEqualToString:@"time"]) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		df.dateStyle = NSDateFormatterNoStyle;
		df.timeStyle = NSDateFormatterShortStyle;
		return [df dateFromString:value] ?: NSDate.date;
	}
	return value;
}

- (NSString *)settingsViewController:(IASKAppSettingsViewController *)sender datePickerTitleForSpecifier:(IASKSpecifier *)specifier {
	NSDate *date = [sender.settingsStore objectForSpecifier:specifier];
	if ([specifier.key isEqualToString:@"date"]) {
		return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
	} else if ([specifier.key isEqualToString:@"dateAndTime"]) {
		return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
	} else if ([specifier.key isEqualToString:@"time"]) {
		return (id)date;
	}
	return nil;
}

- (void)settingsViewController:(IASKAppSettingsViewController*)sender setDate:(NSDate *)date forSpecifier:(IASKSpecifier *)specifier {
	if ([specifier.key isEqualToString:@"time"]) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		df.dateStyle = NSDateFormatterNoStyle;
		df.timeStyle = NSDateFormatterShortStyle;
		[sender.settingsStore setObject:[df stringFromDate:date] forSpecifier:specifier];
		return;
	}
	[sender.settingsStore setObject:date forSpecifier:specifier];
}


#pragma mark kIASKAppSettingChanged notification
- (void)settingDidChange:(NSNotification*)notification {
	NSMutableSet *hiddenKeys = NSMutableSet.set;
	BOOL autoConnect = [NSUserDefaults.standardUserDefaults boolForKey:@"AutoConnect"];
	if (!autoConnect) {
		[hiddenKeys addObjectsFromArray:@[@"AutoConnectLogin", @"AutoConnectPassword", @"loginOptions"]];
	}
	BOOL showAccounts = [NSUserDefaults.standardUserDefaults boolForKey:@"ShowAccounts"];
	if (!showAccounts) {
		[hiddenKeys addObjectsFromArray:@[@"accounts"]];
	}

	[self.appSettingsViewController setHiddenKeys:hiddenKeys animated:YES];
	[self.tabAppSettingsViewController setHiddenKeys:hiddenKeys animated:YES];
}

#pragma mark UITextViewDelegate (for CustomViewCell)
- (void)textViewDidChange:(UITextView *)textView {
    [[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"customCell"];
	[[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged object:self userInfo:@{@"customCell" : textView.text}];
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.currentPopoverController = nil;
}

#pragma mark -
- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.key isEqualToString:@"ButtonDemoAction1"]) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Demo Action 1 called" message:nil preferredStyle:UIAlertControllerStyleAlert];
		[alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"InAppSettingsKit") style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}]];
		[sender presentViewController:alert animated:YES completion:nil];
	} else if ([specifier.key isEqualToString:@"ButtonDemoAction2"]) {
		NSString *newTitle = [[[NSUserDefaults standardUserDefaults] objectForKey:(id)specifier.key] isEqualToString:@"Logout"] ? @"Login" : @"Logout";
		[[NSUserDefaults standardUserDefaults] setObject:newTitle forKey:(id)specifier.key];
	}
}

@end
