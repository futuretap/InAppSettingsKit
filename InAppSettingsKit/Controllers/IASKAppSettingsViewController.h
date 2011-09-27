//
//  IASKAppSettingsViewController.h
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

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "IASKSettingsStore.h"

@class IASKSettingsReader;
@class IASKAppSettingsViewController;
@class IASKSpecifier;

@protocol IASKSettingsDelegate
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender;
@optional
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderForKey:(NSString*)key;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderForKey:(NSString*)key;

- (CGFloat)tableView:(UITableView*)tableView heightForSpecifier:(IASKSpecifier*)specifier;
- (UITableViewCell*)tableView:(UITableView*)tableView cellForSpecifier:(IASKSpecifier*)specifier;

- (NSString*)mailComposeBody;
- (UIViewController<MFMailComposeViewControllerDelegate>*)viewControllerForMailComposeView;
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;

- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForKey:(NSString*)key;
@end


@interface IASKAppSettingsViewController : UITableViewController <UITextFieldDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate> {
	id<IASKSettingsDelegate>  _delegate;
    
    NSMutableArray          *_viewList;
    NSIndexPath             *_currentIndexPath;
	
	IASKSettingsReader		*_settingsReader;
    id<IASKSettingsStore>  _settingsStore;
	NSString				*_file;
	
	id                      _currentFirstResponder;
    
    BOOL                    _showCreditsFooter;
    BOOL                    _showDoneButton;
}

@property (nonatomic, assign) IBOutlet id delegate;
@property (nonatomic, retain) IASKSettingsReader *settingsReader;
@property (nonatomic, retain) id<IASKSettingsStore> settingsStore;
@property (nonatomic, copy) NSString *file;
@property (nonatomic, assign) BOOL showCreditsFooter;
@property (nonatomic, assign) BOOL showDoneButton;

- (void)synchronizeSettings;
- (IBAction)dismiss:(id)sender;

@end
