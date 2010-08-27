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

@class IASKSettingsReader;
@class IASKAppSettingsViewController;

@protocol IASKSettingsDelegate
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender;
@end


@interface IASKAppSettingsViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate> {
	id<IASKSettingsDelegate>  _delegate;
    IBOutlet UITableView    *_tableView;
    
    NSMutableArray          *_viewList;
    NSIndexPath             *_currentIndexPath;
	NSIndexPath				*_topmostRowBeforeKeyboardWasShown;
	
	IASKSettingsReader		*_settingsReader;
	NSString				*_file;
	
	id                      _currentFirstResponder;
    
    BOOL                    _showCreditsFooter;
    BOOL                    _showDoneButton;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSIndexPath   *currentIndexPath;
@property (nonatomic, retain) IASKSettingsReader *settingsReader;
@property (nonatomic, copy) NSString *file;
@property (nonatomic, retain) id currentFirstResponder;
@property (nonatomic, assign) BOOL showCreditsFooter;
@property (nonatomic, assign) BOOL showDoneButton;

- (IBAction)dismiss:(id)sender;

// subclassing: optionally override these methods to customize appearance and functionality
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
