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
#define kIASKToggleStyle                      @"IASKToggleStyle"
#define kIASKToggleStyleCheckmark             @"Checkmark"
#define kIASKToggleStyleSwitch                @"Switch"

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

extern NSString * const IASKSettingChangedNotification;
#define kIASKAppSettingChanged                IASKSettingChangedNotification

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

#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 843.00
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1129.150000
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_11_0
#define kCFCoreFoundationVersionNumber_iOS_11_0 1429.150000
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_14_0
#define kCFCoreFoundationVersionNumber_iOS_14_0 1740.0
#endif

#ifdef __IPHONE_11_0
#define IASK_IF_IOS11_OR_GREATER(...) \
if (@available(iOS 11.0, *)) \
{ \
__VA_ARGS__ \
}

#define IASK_IF_PRE_IOS11(...) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"") \
if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_11_0) \
{ \
__VA_ARGS__ \
} \
_Pragma("clang diagnostic pop")
#else
#define IASK_IF_IOS11_OR_GREATER(...)
#define IASK_IF_PRE_IOS11(...)
#endif

#ifdef __IPHONE_14_0
#define IASK_IF_IOS14_OR_GREATER(...) \
if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_14_0) \
{ \
__VA_ARGS__ \
}
#else
#define IASK_IF_IOS14_OR_GREATER(...)
#endif

@class IASKSpecifier;
@protocol IASKSettingsStore;

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
- (id)initWithFile:(NSString*)file bundle:(NSBundle*)bundle;

/** convenience initializer
 calls initWithFile where applicationBundle is set to NSBundle.mainBundle
 @param file   settings file name without the ".plist" suffix
 */
- (id)initWithFile:(NSString*)file;

@property (nonatomic, readonly) NSInteger numberOfSections;
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

