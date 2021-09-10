//
//  IASKSpecifier.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IASKSettingsReader;

/**
 Represents one element of a preferences schema file
 */

@interface IASKSpecifier : NSObject

#pragma mark - Generic
- (id)initWithSpecifier:(NSDictionary*)specifier;

@property (nonatomic, strong, readonly) NSDictionary *specifierDict;
@property (nullable, nonatomic, weak) IASKSettingsReader *settingsReader;

/** Settings schema: `Key`
@discussion This is mandatory for almost all specifiers except Group, OpenURL, Button, MailCompose, CustomView, and the ItemSpecifier of ListGroup.
 */
@property (nullable, nonatomic, copy) NSString *key;

/// Settings schema: `Title`
@property (nullable, nonatomic, copy) NSString *title;

/// Settings schema: `IASKSubtitle`
@property (nullable, nonatomic, copy, readonly) NSString *subtitle;

// internal: Whether or not this setting has a subtitle.
@property (nonatomic, readonly) BOOL hasSubtitle;

// internal: Returns the subtitle for the current value of the setting
- (nullable NSString*)subtitleForValue:(nullable id)value;

@property (nonatomic, copy, readonly) NSString *type;
@property (nullable, nonatomic, strong, readonly) id defaultValue;
@property (nullable, nonatomic, strong, readonly) id defaultStringValue;
@property (nullable, nonatomic, copy, readonly) NSString *footerText;

/** Settings schema: `IASKCellImage`
 @discussion All element types (except sliders which already have a `MinimumValueImage`) support an icon image on the left side of the cell. You can specify the image name in an optional `IASKCellImage` attribute. The ".png" or "@2x.png" suffix is automatically appended and will be searched in the project. Optionally, you can add an image with suffix "Highlighted.png" or "Highlighted@2x.png" to the project and it will be automatically used as a highlight image when the cell is selected (for Buttons and ChildPanes).
*/
@property (nullable, nonatomic, strong, readonly) UIImage *cellImage;
@property (nullable, nonatomic, strong, readonly) UIImage *highlightedCellImage;
@property (nullable, nonatomic, strong, readonly) NSArray *userInterfaceIdioms;
@property (nonatomic, readonly) BOOL adjustsFontSizeToFitWidth;
@property (nonatomic, readonly) NSTextAlignment textAlignment;

- (nullable NSString*)localizedObjectForKey:(NSString*)key;
- (nullable NSString*)titleForCurrentValue:(nullable id)currentValue;


#pragma mark - Sliders
/// Settings schema: `MinimumValue`
@property (nonatomic, readonly) float minimumValue;

/// Settings schema: `MaximumValue`
@property (nonatomic, readonly) float maximumValue;

/// Settings schema: `MinimumValueImage`
@property (nullable, nonatomic, copy, readonly) NSString *minimumValueImage;

/// Settings schema: `MaximumValueImage`
@property (nullable, nonatomic, copy, readonly) NSString *maximumValueImage;


#pragma mark - Switches
/// Settings schema: `TrueValue`
@property (nullable, nonatomic, strong, readonly) id trueValue;

/// Settings schema: `FalseValue`
@property (nullable, nonatomic, strong, readonly) id falseValue;

typedef NS_ENUM(NSUInteger, IASKToggleStyle) {
	IASKToggleStyleSwitch,
	IASKToggleStyleCheckmark,
};

/** Settings schema: `IASKToggleStyle`, values: `Switch` (default) or `Checkmark`
 @discussion Specifies if the switch uses the default UISwitch style or an accessoryType checkmark.
 */
@property (nonatomic, readonly) IASKToggleStyle toggleStyle;

@property (nonatomic, readonly) BOOL defaultBoolValue;


/*!
 @group Text Fields and Views
*/
#pragma mark - Text Fields and Views
/// Settings schema: `IsSecure`
@property (nonatomic, readonly) BOOL isSecure;

/// Settings schema: `KeyboardType`, values: `Alphabet` (default), `NumbersAndPunctuation`, `NumberPad`, `DecimalPad`, `PhonePad`, `NamePhonePad`, `AsciiCapable`, `URL`, `EmailAddress`
@property (nonatomic, readonly) UIKeyboardType keyboardType;

/// Settings schema: `AutocapitalizationType`, values: `None` (default), `Sentences`, `Words`, `AllCharacters`,
@property (nonatomic, readonly) UITextAutocapitalizationType autocapitalizationType;

/// Settings schema: `AutocorrectionType`, values: `Default` (default), `No`, `Yes`
@property (nonatomic, readonly) UITextAutocorrectionType autoCorrectionType;

/// Settings schema: `IASKPlaceholder`
@property (nullable, nonatomic, copy, readonly) NSString *placeholder;

/** Settings schema: `IASKTextContentType`
 @discussion The plist values correspond to the naming of the UIKit constants, e.g. for `UITextContentTypeAddressCityAndState` use the value `AddressCityAndState`.
 */
@property (nullable, nonatomic, copy, readonly) UITextContentType textContentType;

/*!
 @group Radio Groups
*/
#pragma mark - Radio Groups
/// A specifier for one entry in a radio group preceeded by a radio group specifier.
- (id)initWithSpecifier:(NSDictionary*)specifier
		radioGroupValue:(NSString*)radioGroupValue;
@property (nullable, nonatomic, copy, readonly) NSString *radioGroupValue;


/*!
 @group Multi Values
*/
#pragma mark - Multi Values
@property (nonatomic, readonly) NSInteger multipleValuesCount;
@property (nullable, nonatomic, strong, readonly) NSArray *multipleValues;
@property (nullable, nonatomic, strong, readonly) NSArray *multipleTitles;
@property (nullable, nonatomic, strong, readonly) NSArray *multipleIconNames;
@property (nonatomic, readonly) BOOL displaySortedByTitle;
- (void)setMultipleValuesDictValues:(NSArray*)values titles:(NSArray*)titles;
- (void)sortIfNeeded;

/*!
 @group Child Panes
*/
#pragma mark - Child Panes
@property (nullable, nonatomic, copy, readonly) NSString *file;

/** Settings schema: `IASKViewControllerClass`
 @discussion The child pane is displayed by instantiating a UIViewController subclass of the specified class and initializing it using the init method specified in @see viewControllerSelector
 */
@property (nullable, nonatomic, readonly) Class viewControllerClass;
/** Settings schema: `IASKViewControllerSelector`
@discussion The selector must have two arguments: an `NSString` argument for the file name in the Settings bundle and the `IASKSpecifier`. The custom view controller is then pushed onto the navigation stack. See the sample app for more details.
*/
@property (nullable, nonatomic, readonly) SEL viewControllerSelector;

/** Settings schema: `IASKViewControllerStoryBoardFile`
 @discussion When using @see viewControllerStoryBoardID to reference the child view controller from a storyboard, this specifies the storyboard file.
 */
@property (nullable, nonatomic, copy, readonly) NSString *viewControllerStoryBoardFile;

/** Settings schema: `IASKViewControllerStoryBoardId`
 @discussion References the child view controller from a storyboard. If `IASKViewControllerStoryBoardFile` is not specified, the main storyboard (`UIMainStoryboardFile` in Info.plist) is used.
 */
@property (nullable, nonatomic, copy, readonly) NSString *viewControllerStoryBoardID;

/** Settings schema: `IASKSegueIdentifier`
@discussion References the child view controller from a storyboard segue. Requires that `IASKAppSettingsViewController` is loaded from a storyboard as well.
 */
@property (nullable, nonatomic, copy, readonly) NSString *segueIdentifier;


/*!
 @group List Groups
*/
#pragma mark - List Groups

/// The specifier of the enclosing list group. Only defined for `ItemSpecifier` or `AddSpecifier`.
@property (nullable, nonatomic, strong, readonly) IASKSpecifier *parentSpecifier;

/** Returns the item specifier of a list group
 @param index the index into the array of items
 @discussion Note that for the `ItemSpecifier` the `Key` parameter is optional. If the key is set, accessing the store with `objectForSpecifier:` returns the keyed element of the item dictionary. If the key is not set, the whole dictionary is returned. Note that the item content can also be of scalar type when items are added using a text field, a slider or toggle.
 */
- (nullable IASKSpecifier*)itemSpecifierForIndex:(NSUInteger)index;

/// The item index of a list group `itemSpecifier`. Only defined for the parent list group specifier.
@property (nonatomic, readonly) NSUInteger itemIndex;

@property (nonatomic, readonly) BOOL isItemSpecifier;

/// The specifier for the "Add…" item at the end of a list group allowing to add new items. Only defined for the parent list group specifier.
@property (nullable, nonatomic, strong, readonly) IASKSpecifier *addSpecifier;

@property (nonatomic, readonly) BOOL isAddSpecifier;

/// Specifies if the item cells of a list group are deletable via swipe.
@property (nonatomic, readonly) BOOL deletable;


/*!
 @group Date Picker
*/
#pragma mark - Date Picker

/// Settings schema: `DatePickerMode` with values `Date`, `Time`, and `DateAndTime` (default)
@property (nonatomic, readonly) UIDatePickerMode datePickerMode;

/// Settings schema: `DatePickerStyle` with values `Compact` (default), `Inline`, and `Wheels`
@property (nonatomic, readonly) UIDatePickerStyle datePickerStyle API_AVAILABLE(ios(13.4));

/// Settings schema: `MinuteInterval` with an integer value (default: 1)
@property (nonatomic, readonly) NSInteger datePickerMinuteInterval;

// internal: the date picker doesn't expand/collapse (datePickerStyle is `Compact`)
@property (nonatomic, readonly) BOOL embeddedDatePicker;

// internal: represents the actual date picker cell below the title cell
@property (nonatomic, strong, readonly) IASKSpecifier *editSpecifier;


@end

NS_ASSUME_NONNULL_END
