//
//  IASKSettingsReader.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kIASKPreferenceSpecifiers             @"PreferenceSpecifiers"
#define kIASKCellImage                        @"IASKCellImage"

#define kIASKItemSpecifier                    @"ItemSpecifier"
#define kIASKAddSpecifier					  @"AddSpecifier"
#define kIASKDeletable					  	  @"Deletable"
#define kIASKType                             @"Type"
#define kIASKTitle                            @"Title"
#define kIASKFooterText                       @"FooterText"
#define kIASKKey                              @"Key"
#define kIASKFile                             @"File"
#define kIASKDefaultValue                     @"DefaultValue"
#define kIASKDisplaySortedByTitle             @"DisplaySortedByTitle"
#define kIASKMinimumValue                     @"MinimumValue"
#define kIASKMaximumValue                     @"MaximumValue"
#define kIASKTrueValue                        @"TrueValue"
#define kIASKFalseValue                       @"FalseValue"
#define kIASKIsSecure                         @"IsSecure"
#define KIASKKeyboardType                     @"KeyboardType"
#define kIASKAutocapitalizationType           @"AutocapitalizationType"
#define kIASKAutoCorrectionType               @"AutocorrectionType"
#define kIASKValues                           @"Values"
#define kIASKTitles                           @"Titles"
#define kIASKIconNames                        @"IconNames"
#define kIASKShortTitles                      @"ShortTitles"
#define kIASKSupportedUserInterfaceIdioms     @"SupportedUserInterfaceIdioms"
#define kIASKSubtitle                         @"IASKSubtitle"
#define kIASKPlaceholder                      @"IASKPlaceholder"
#define kIASKViewControllerClass              @"IASKViewControllerClass"
#define kIASKViewControllerSelector           @"IASKViewControllerSelector"
#define kIASKViewControllerStoryBoardFile     @"IASKViewControllerStoryBoardFile"
#define kIASKViewControllerStoryBoardId       @"IASKViewControllerStoryBoardId"
#define kIASKSegueIdentifier                  @"IASKSegueIdentifier"
#define kIASKDatePickerMode                   @"DatePickerMode"
#define kIASKDatePickerModeTime               @"Time"
#define kIASKDatePickerModeDate               @"Date"
#define kIASKDatePickerModeDateAndTime        @"DateAndTime"
#define kIASKDatePickerStyle                  @"DatePickerStyle"
#define kIASKDatePickerStyleCompact           @"Compact"
#define kIASKDatePickerStyleInline            @"Inline"
#define kIASKDatePickerStyleWheels            @"Wheels"
#define kIASKDatePickerMinuteInterval         @"MinuteInterval"
#define kIASKMailComposeToRecipents           @"IASKMailComposeToRecipents"
#define kIASKMailComposeCcRecipents           @"IASKMailComposeCcRecipents"
#define kIASKMailComposeBccRecipents          @"IASKMailComposeBccRecipents"
#define kIASKMailComposeSubject               @"IASKMailComposeSubject"
#define kIASKMailComposeBody                  @"IASKMailComposeBody"
#define kIASKMailComposeBodyIsHTML            @"IASKMailComposeBodyIsHTML"
#define kIASKKeyboardAlphabet                 @"Alphabet"
#define kIASKKeyboardNumbersAndPunctuation    @"NumbersAndPunctuation"
#define kIASKKeyboardNumberPad                @"NumberPad"
#define kIASKKeyboardDecimalPad               @"DecimalPad"
#define kIASKKeyboardPhonePad                 @"PhonePad"
#define kIASKKeyboardNamePhonePad             @"NamePhonePad"
#define kIASKKeyboardASCIICapable             @"AsciiCapable"
#define kIASKTextContentTypeName              @"Name"
#define kIASKTextContentTypeNamePrefix        @"NamePrefix"
#define kIASKTextContentTypeGivenName         @"GivenName"
#define kIASKTextContentTypeMiddleName        @"MiddleName"
#define kIASKTextContentTypeFamilyName        @"FamilyName"
#define kIASKTextContentTypeNameSuffix        @"NameSuffix"
#define kIASKTextContentTypeNickname          @"Nickname"
#define kIASKTextContentTypeJobTitle          @"JobTitle"
#define kIASKTextContentTypeOrganizationName  @"OrganizationName"
#define kIASKTextContentTypeLocation          @"Location"
#define kIASKTextContentTypeFullStreetAddress @"FullStreetAddress"
#define kIASKTextContentTypeStreetAddressLine1 @"StreetAddressLine1"
#define kIASKTextContentTypeStreetAddressLine2 @"StreetAddressLine2"
#define kIASKTextContentTypeAddressCity       @"AddressCity"
#define kIASKTextContentTypeAddressState      @"AddressState"
#define kIASKTextContentTypeAddressCityAndState @"AddressCityAndState"
#define kIASKTextContentTypeSublocality       @"Sublocality"
#define kIASKTextContentTypeCountryName       @"CountryName"
#define kIASKTextContentTypePostalCode        @"PostalCode"
#define kIASKTextContentTypeTelephoneNumber   @"TelephoneNumber"
#define kIASKTextContentTypeEmailAddress      @"EmailAddress"
#define kIASKTextContentTypeURL               @"URL"
#define kIASKTextContentTypeCreditCardNumber  @"CreditCardNumber"
#define kIASKTextContentTypeUsername          @"Username"
#define kIASKTextContentTypePassword          @"Password"
#define kIASKTextContentTypeNewPassword       @"NewPassword"
#define kIASKTextContentTypeOneTimeCode       @"OneTimeCode"
#define KIASKKeyboardURL                      @"URL"
#define kIASKKeyboardEmailAddress             @"EmailAddress"
#define kIASKAutoCapNone                      @"None"
#define kIASKAutoCapSentences                 @"Sentences"
#define kIASKAutoCapWords                     @"Words"
#define kIASKAutoCapAllCharacters             @"AllCharacters"
#define kIASKAutoCorrDefault                  @"Default"
#define kIASKAutoCorrNo                       @"No"
#define kIASKAutoCorrYes                      @"Yes"
#define kIASKMinimumValueImage                @"MinimumValueImage"
#define kIASKMaximumValueImage                @"MaximumValueImage"
#define kIASKAdjustsFontSizeToFitWidth        @"IASKAdjustsFontSizeToFitWidth"
#define kIASKTextContentType                  @"IASKTextContentType"
#define kIASKTextLabelAlignment               @"IASKTextAlignment"
#define kIASKTextLabelAlignmentLeft           @"IASKUITextAlignmentLeft"
#define kIASKTextLabelAlignmentCenter         @"IASKUITextAlignmentCenter"
#define kIASKTextLabelAlignmentRight          @"IASKUITextAlignmentRight"
#define kIASKTextLabelAlignmentNatural        @"IASKUITextAlignmentNatural"
#define kIASKToggleStyle                      @"IASKToggleStyle"
#define kIASKToggleStyleCheckmark             @"Checkmark"
#define kIASKToggleStyleSwitch                @"Switch"
#define kIASKQuickMultiValueSelection         @"IASKQuickMultiValueSelection"

#define kIASKPSGroupSpecifier                 @"PSGroupSpecifier"
#define kIASKListGroupSpecifier	              @"IASKListGroupSpecifier"
#define kIASKPSToggleSwitchSpecifier          @"PSToggleSwitchSpecifier"
#define kIASKPSMultiValueSpecifier            @"PSMultiValueSpecifier"
#define kIASKPSRadioGroupSpecifier            @"PSRadioGroupSpecifier"
#define kIASKPSSliderSpecifier                @"PSSliderSpecifier"
#define kIASKPSTitleValueSpecifier            @"PSTitleValueSpecifier"
#define kIASKPSTextFieldSpecifier             @"PSTextFieldSpecifier"
#define kIASKPSChildPaneSpecifier             @"PSChildPaneSpecifier"
#define kIASKTextViewSpecifier                @"IASKTextViewSpecifier"
#define kIASKOpenURLSpecifier                 @"IASKOpenURLSpecifier"
#define kIASKButtonSpecifier                  @"IASKButtonSpecifier"
#define kIASKMailComposeSpecifier             @"IASKMailComposeSpecifier"
#define kIASKCustomViewSpecifier              @"IASKCustomViewSpecifier"
#define kIASKDatePickerSpecifier              @"IASKDatePickerSpecifier"
#define kIASKDatePickerControl                @"IASKDatePickerControl"

// IASKChildTitle can be set if IASKViewControllerClass is set to IASKAppSettingsWebViewController.
// If IASKChildTitle is set, the navigation title is fixed to it; otherwise, the title value is used and is overridden by the HTML title tag
// as soon as the web page is loaded; if IASKChildTitle is set to the empty string, the title is not shown on push but _will_ be replaced by
// the HTML title as soon as the page is loaded. The value of IASKChildTitle is localizable.
#define kIASKChildTitle                       @"IASKChildTitle"

/*
 IASKWebViewShowProgress can be set if IASKViewControllerClass is set to IASKAppSettingsWebViewController.
 If IASKWebViewShowProgress is set, it will replace the default activity indicator on the Navigation Bar by a progress bar just below the Navigation Bar, which dynamically updates according to the `estimatedProgress` property of WKWebView.
 */
#define kIASKWebViewShowProgress              @"IASKWebViewShowProgress"

/*
 IASKWebViewHideBottomBar can be set if IASKViewControllerClass is set to IASKAppSettingsWebViewController.
 If IASKWebViewHideBottomBar is set, it will hide the toolbar at the bottom of the screen when the IASKAppSettingsWebViewController is pushed on to a navigation controller. This will present the WKWebView full screen and prevents situations where the user can navigate the tab bar while the IASKAppSettingsWebViewController stays still present.
 */
#define kIASKWebViewHideBottomBar             @"IASKWebViewHideBottomBar"

/*
 IASKWebViewShowNavigationalButtons can be set if IASKViewControllerClass is set to IASKAppSettingsWebViewController.
 If IASKWebViewShowNavigationalButtons is set, it will show navigational buttons on the right side of the Navigation Bar. Their enable state will update dynamically based on the navigation history of the WKWebView.
 */
#define kIASKWebViewShowNavigationalButtons   @"IASKWebViewShowNavigationalButtons"

extern NSString * const IASKSettingChangedNotification;
#define kIASKAppSettingChanged                IASKSettingChangedNotification
#define kIASKInternalAppSettingChanged        @"IASKInternalSettingChangedNotification"

#define kIASKSectionHeaderIndex               0

#define kIASKSliderImageGap                   10

#define kIASKSpacing                          8
#define kIASKMinLabelWidth                    97
#define kIASKMaxLabelWidth                    240
#define kIASKMinValueWidth                    35
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#define kIASKPaddingLeft                      (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1 ? 15 : 9)
#else
#define kIASKPaddingLeft                      9
#endif
#define kIASKPaddingRight                     10
#define kIASKHorizontalPaddingGroupTitles     19
#define kIASKVerticalPaddingGroupTitles       15

#define kIASKLabelFontSize                    17
#define kIASKgrayBlueColor                    [UIColor colorWithRed:0.318f green:0.4f blue:0.569f alpha:1.f]

#define kIASKMinimumFontSize                  12.0f


@class IASKSpecifier;
@protocol IASKSettingsStore;

@protocol IASKSettingsReaderDelegate <NSObject>
- (nullable NSArray<NSString*>*)titlesForSpecifier:(IASKSpecifier*)specifier;
- (nullable NSArray*)valuesForSpecifier:(IASKSpecifier*)specifier;
@end

/** settings reader transform iOS's settings plist files
 to the IASKSpecifier model objects.
 Besides that, it also hides the complexity of finding
 the 'proper' Settings.bundle
 */
@interface IASKSettingsReader : NSObject

/** designated initializer
 searches for a settings bundle that contains a plist with the specified fileName that must
 be contained in the given bundle
 @param file   settings file name without the ".plist" suffix
 @param bundle bundle that contains a plist with the specified file
  */
- (id)initWithFile:(NSString*)file bundle:(NSBundle*)bundle delegate:(nullable id<IASKSettingsReaderDelegate>)delegate;

/** convenience initializer
 calls initWithFile where applicationBundle is set to NSBundle.mainBundle
 @param file   settings file name without the ".plist" suffix
 */
- (id)initWithFile:(NSString*)file;

@property (nonatomic, readonly) NSInteger numberOfSections;
@property (nonatomic, nullable, weak) id<IASKSettingsReaderDelegate> delegate;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (nullable IASKSpecifier*)specifierForIndexPath:(NSIndexPath*)indexPath;
- (nullable IASKSpecifier*)headerSpecifierForSection:(NSInteger)section;
- (nullable NSIndexPath*)indexPathForKey:(NSString*)key;
- (nullable IASKSpecifier*)specifierForKey:(NSString*)key;
- (nullable NSString*)titleForSection:(NSInteger)section;
- (nullable NSString*)keyForSection:(NSInteger)section;
- (nullable NSString*)footerTextForSection:(NSInteger)section;
- (nullable NSString*)titleForId:(nullable NSObject*)titleId;
- (NSString*)pathForImageNamed:(NSString*)image;
- (nullable NSString*)locateSettingsFile:(NSString *)file;

/** recursively go through all specifiers of the file/sub-files and gather default values
 @param limitedToEditableFields limit the gathering to default values of specifiers that can be edited by the user (e.g.
PSToggleSwitchSpecifier, PSTextFieldSpecifier).
 */
- (NSDictionary<NSString *,id> *)gatherDefaultsLimitedToEditableFields:(BOOL)limitedToEditableFields;

/// recursively go through all specifiers of the file/sub-files and populate the store with the specified default values
- (void)applyDefaultsToStore;

/// the main application bundle. most often NSBundle.mainBundle
@property (nonatomic, readonly) NSBundle *applicationBundle;

/// the actual settings bundle
@property (nonatomic, readonly) NSBundle *settingsBundle;

/// the actual settings plist, parsed into a dictionary
@property (nonatomic, readonly) NSDictionary *settingsDictionary;

@property (nonatomic, strong) NSString *localizationTable;
@property (nonatomic, readonly) NSBundle *iaskBundle;
@property (nonatomic, strong) NSArray *dataSource;
@property (nullable, nonatomic, strong) NSSet *hiddenKeys;
@property (nonatomic) BOOL showPrivacySettings;
@property (nullable, nonatomic, weak) id<IASKSettingsStore> settingsStore;
@property (nullable, nonatomic, strong) IASKSpecifier *selectedSpecifier; // currently used for date picker

@end

NS_ASSUME_NONNULL_END

