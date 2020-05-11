//
//  IASKAppSettingsViewController.h
//  InAppSettingsKit
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

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import <InAppSettingsKit/IASKSettingsStore.h>
#import <InAppSettingsKit/IASKViewController.h>
#import <InAppSettingsKit/IASKSpecifier.h>
#import <InAppSettingsKit/IASKTextField.h>

NS_ASSUME_NONNULL_BEGIN

@class IASKSettingsReader;
@class IASKAppSettingsViewController;

@protocol IASKSettingsDelegate <UITableViewDelegate>

/** called when the settings view controller was dismissed by tapping the Done button or performing `-dismiss:`.
 @param settingsViewController the settingsViewController
 @discussion Note that this callback is not performed if IASK was presented by pushing it onto a navigation controller.
 */
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)settingsViewController;

@optional
#pragma mark - Section header customization
/** customize the header of the specified section of the table view
 @param settingsViewController the settingsViewController
 @param section An index number identifying the section of the tableView
 @param specifier the specifier containing the key of the element
 */
- (nullable NSString*)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
					 titleForHeaderInSection:(NSInteger)section
								   specifier:(IASKSpecifier*)specifier;

/** Asks the delegate for the height to use for the header of a particular section.
 @param settingsViewController the settingsViewController
 @param section An index number identifying the section of the tableView
 @param specifier the specifier containing the key of the element
 @discussion Use this method to specify the height of custom header views returned by your `tableView:viewForHeaderInSection:specifier: method.
 */
- (CGFloat)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
		 heightForHeaderInSection:(NSInteger)section
						specifier:(IASKSpecifier*)specifier;

/** Asks the delegate for a view object to display in the header of the specified section of the table view.
 @param settingsViewController the settingsViewController
 @param section An index number identifying the section of the tableView
 @param specifier the specifier containing the key of the element
 @discussion Use this method to return a custom view for your header. If you implement this method, you must also implement the `tableView:heightForFooterInSection:` method to specify the height of your custom view.
 */
- (nullable UIView*)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
					viewForHeaderInSection:(NSInteger)section
								 specifier:(IASKSpecifier*)specifier;

#pragma mark - Section footer customization
/** customize the footer of the specified section of the table view
@param settingsViewController the settingsViewController
@param section An index number identifying the section of the tableView
@param specifier the specifier containing the key of the element
*/
- (nullable NSString*)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
					 titleForFooterInSection:(NSInteger)section
								   specifier:(IASKSpecifier*)specifier;

/** Asks the delegate for the height to use for the footer of a particular section.
@param settingsViewController the settingsViewController
@param section An index number identifying the section of the tableView
@param specifier the specifier containing the key of the element
@discussion Use this method to specify the height of custom footer views returned by your `tableView:viewForFooterInSection:specifier: method.
*/
- (CGFloat) settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
		  heightForFooterInSection:(NSInteger)section
						 specifier:(IASKSpecifier*)specifier;

/** Asks the delegate for a view object to display in the footer of the specified section of the table view.
@param settingsViewController the settingsViewController
@param section An index number identifying the section of the tableView
@param specifier the specifier containing the key of the element
@discussion Use this method to return a custom view for your footer. If you implement this method, you must also implement the `tableView:heightForFooterInSection:` method to specify the height of your custom view.
*/
- (nullable UIView *)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
					 viewForFooterInSection:(NSInteger)section
								  specifier:(IASKSpecifier*)specifier;


#pragma mark - Custom Views
/** Asks the delegate for the height to use for a custom view element
 @param settingsViewController the settingsViewController
 @param specifier the specifier containing the key of the element
 @return A nonnegative floating-point value (or `UITableViewAutomaticDimension`) that specifies the height (in points) that row should be.
 @discussion Use this method to specify the height of custom views (`IASKCustomView`) returned by your `tableView:cellForSpecifier: method. If this method is not implemented, `UITableViewAutomaticDimension` is returned.
*/
- (CGFloat)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
			   heightForSpecifier:(IASKSpecifier*)specifier;

/** Returns the table cell for the specified custom view element (`IASKCustomView`)
 @param settingsViewController the settingsViewController
 @param specifier the specifier containing the key of the element
 @return The cell of the table, or nil if the cell is not visible or the specifier is not found.
 */
- (nullable __kindof UITableViewCell*)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
											cellForSpecifier:(IASKSpecifier*)specifier;

/** Tells the delegate that the specified custom view (`IASKCustomView`) element is now selected.
 @param settingsViewController the settingsViewController
 @param specifier the specifier containing the key of the selected element
 */
 - (void)settingsViewController:(IASKAppSettingsViewController*)settingsViewController
   didSelectCustomViewSpecifier:(IASKSpecifier*)specifier;

#pragma mark - Mail Composition
/** Tells the delegate that the specified custom view (`IASKCustomView`) element is now selected.
 @param settingsViewController the settingsViewController
 @param mailComposeViewController the mail compose view controller being presented
 @param specifier the specifier containing the key of the element
 @return Return NO to prevent presenting the mail compose view controller, YES otherwise.
 @discussion You may customize `mailComposeViewController` before it is being presented.
*/
- (BOOL)settingsViewController:(UITableViewController<IASKViewController>*)settingsViewController
shouldPresentMailComposeViewController:(MFMailComposeViewController*)mailComposeViewController
				  forSpecifier:(IASKSpecifier*) specifier;

/** Tells the delegate that the user wants to dismiss the mail composition view.
 @param settingsViewController the settingsViewController
 @param mailComposeViewController the mail compose view controller being dismissed
 @param result The result of the user’s action
 @param error If an error occurred, this parameter contains an error object with information about the type of failure.
 @see `-[MFMailComposeViewControllerDelegate mailComposeController:didFinishWithResult:error:]`
*/
- (void)settingsViewController:(UITableViewController<IASKViewController>*) settingsViewController
		 mailComposeController:(MFMailComposeViewController*)mailComposeViewController
		   didFinishWithResult:(MFMailComposeResult)result
						 error:(nullable NSError*)error;

#pragma mark - Custom MultiValues
/** Ask the delegate to provide dynamic values for a MultiValue element
 @param settingsViewController the settingsViewController
 @param specifier the specifier containing the key of the selected element
 @return an array of values (either of type `NSString` or `NSNumber`)
 @discussion the returned array overrides any values specified in the static schema plist
*/
- (NSArray*)settingsViewController:(IASKAppSettingsViewController*)settingsViewController
				valuesForSpecifier:(IASKSpecifier*)specifier;

/** Ask the delegate to provide dynamic titles for a MultiValue element
 @param settingsViewController the settingsViewController
 @param specifier the specifier containing the key of the selected element
 @return an array of titles
 @discussion the returned array overrides any titles specified in the static schema plist
*/
- (NSArray*)settingsViewController:(IASKAppSettingsViewController*)settingsViewController
				titlesForSpecifier:(IASKSpecifier*)specifier;

#pragma mark - Button
/** Tells the delegate that the specified button (`IASKButton`) element is now selected.
@param settingsViewController the settingsViewController
@param specifier the specifier containing the key of the selected button
*/
- (void)settingsViewController:(IASKAppSettingsViewController*)settingsViewController
	  buttonTappedForSpecifier:(IASKSpecifier*)specifier;

#pragma mark - Validation
typedef NS_ENUM(NSUInteger, IASKValidationResult) {
	IASKValidationResultOk,
	IASKValidationResultFailed,
	IASKValidationResultFailedWithShake,
};
/** validate user input in text fields
 @param settingsViewController the settingsViewController
 @param specifier the specifier containing the key of the element
 @param textField the textField, a `UITextField` subclass
 @param previousValue the text before the text field became first responder
 @param replacement replacement string that will be set if the result is not Ok.
 @return Only on `IASKValidationResultOk`, the input is accepted and stored. `IASKValidationResultFailed` does not alter indicate the failure to the user (it's up to the developer to style the text red or something similar). `IASKValidationResultFailedWithShake` performs a shake animation to indicate the validation error.
 */
- (IASKValidationResult)settingsViewController:(IASKAppSettingsViewController*)settingsViewController
							 validateSpecifier:(IASKSpecifier*)specifier
									 textField:(IASKTextField*)textField
								 previousValue:(nullable NSString*)previousValue
								   replacement:(NSString* _Nonnull __autoreleasing *_Nullable)replacement;

#pragma mark - List group child view controller validation
/** Validate the child pane to add a new list group item
 @param settingsViewController the settingsViewController
 @param specifier the specifier containing the key of the element
 @param contentDictionary a dictionary with the keys and the user-supplied input
 @return If NO is returned, the "Done" button in the navigation bar is disabled. If YES is returned, the button is enabled allowing the user to "submit" the child pane and add a new list group item.
  */
- (BOOL)settingsViewController:(IASKAppSettingsViewController*)settingsViewController
  childPaneIsValidForSpecifier:(IASKSpecifier*)specifier
			 contentDictionary:(NSMutableDictionary*)contentDictionary;

#pragma mark - Date Picker
/// Implement this if you store the date/time in a custom format other than as `NSDate` object. Called when the user starts editing a date/time by selecting the title cell above the date/time picker.
- (NSDate*)settingsViewController:(IASKAppSettingsViewController*)settingsViewController
				 dateForSpecifier:(IASKSpecifier*)specifier;

/// Implement this to customize the displayed value in the title cell above the date/time picker.
- (nullable NSString*)settingsViewController:(IASKAppSettingsViewController*)settingsViewController
				 datePickerTitleForSpecifier:(IASKSpecifier*)specifier;

/// Implement this if you store the date/time in a custom format other than an `NSDate` object. Called when the user changes the date/time value using the picker.
- (void)settingsViewController:(IASKAppSettingsViewController*)settingsViewController
					   setDate:(NSDate*)date
				  forSpecifier:(IASKSpecifier*)specifier;
@end


@interface IASKAppSettingsViewController : UITableViewController <IASKViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate>

/// the delegate to customize IASK’s behavior. Propagated to child view controllers.
@property (nonatomic, assign) IBOutlet id<IASKSettingsDelegate> delegate;

/** base name of the settings plist file (default: `Root`)
 @discussion IASK automatically checks for specific or custom inApp plists according to this order (`DEVICE` being a placeholder for "iphone" on iPhone and "ipad" on iPad):
 @code
 - InAppSettings.bundle/FILE~DEVICE.inApp.plist
 - InAppSettings.bundle/FILE.inApp.plist
 - InAppSettings.bundle/FILE~DEVICE.plist
 - InAppSettings.bundle/FILE.plist
 - Settings.bundle/FILE~DEVICE.inApp.plist
 - Settings.bundle/FILE.inApp.plist
 - Settings.bundle/FILE~DEVICE.plist
 - Settings.bundle/FILE.plist
*/
@property (nonatomic, copy) NSString *file;

/// Whether a footer giving credit to InAppSettingsKit is shown
@property (nonatomic, assign) BOOL showCreditsFooter;

/// Whether a Done button is displayed as the rightBarButtonItem for the root level
@property (nonatomic, assign) IBInspectable BOOL showDoneButton;

/** Suppress showing the privacy settings cell
@discussion if NO, IASK inspects the Info.plist for privacy related key and shows the cell linking to the system settings for the app, if needed. If YES, a privacy cell is never displayed.
*/
@property (nonatomic) IBInspectable BOOL neverShowPrivacySettings;

/// Sets the same parameter on the tableView of the root and all child view controllers
@property (nonatomic) IBInspectable BOOL cellLayoutMarginsFollowReadableWidth;

/// Synchronizes the settings store, e.g. calls `-[NSUserDefaults synchronize]` in case of the default store.
- (void)synchronizeSettings;

/// dismiss the settings view controller
- (IBAction)dismiss:(id)sender;

/// a set of element `Key`s that are hidden. Propagated to child view controllers.
@property (nonatomic, strong) NSSet *hiddenKeys;

/** hide a set of element `Key`s
 @param hiddenKeys a set of element `Key`s that are hidden
 @param animated Specify YES if you want to animate the change in visibility or NO if you want the changes to appear immediately.
 @discussion Propagated to child view controllers.
 */
- (void)setHiddenKeys:(NSSet*)hiddenKeys animated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
