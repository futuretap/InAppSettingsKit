//
//  IASKSpecifier.m
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

#import "IASKSpecifier.h"
#import "IASKSettingsReader.h"
#import "IASKAppSettingsWebViewController.h"

@interface IASKSpecifier ()

@property (nonnull, nonatomic, strong, readwrite) NSDictionary *specifierDict;
@property (nullable, nonatomic, strong, readwrite) IASKSpecifier *parentSpecifier;
@property (nonatomic, strong) NSDictionary  *multipleValuesDict;
@property (nullable, nonatomic, copy, readwrite) NSString *radioGroupValue;
@property (nonatomic, readwrite) NSUInteger itemIndex;

@end

@implementation IASKSpecifier

- (id)initWithSpecifier:(NSDictionary*)specifier {
	NSAssert(specifier[kIASKType], @"specifier type missing");
	if ((self = [super init])) {
		self.specifierDict = specifier;

        if ([self isMultiValueSpecifierType]) {
            [self updateMultiValuesDict];
        }
    }
    return self;
}

- (id)initWithSpecifier:(NSDictionary *)specifier radioGroupValue:(NSString *)radioGroupValue {
	if ((self = [self initWithSpecifier:specifier])) {
		self.radioGroupValue = radioGroupValue;
	}
    return self;
}

- (BOOL)isMultiValueSpecifierType {
    static NSArray *types = nil;
    if (!types) {
        types = @[kIASKPSMultiValueSpecifier, kIASKPSTitleValueSpecifier, kIASKPSRadioGroupSpecifier];
    }
    return [types containsObject:[self type]];
}

- (void)updateMultiValuesDict {
    NSArray *values = [_specifierDict objectForKey:kIASKValues];
    NSArray *titles = [_specifierDict objectForKey:kIASKTitles];
	[self setMultipleValuesDictValues:values titles:titles];
}

- (void)setMultipleValuesDictValues:(NSArray*)values titles:(NSArray*)titles {
    NSArray *shortTitles = [_specifierDict objectForKey:kIASKShortTitles];
    NSArray *iconNames = [_specifierDict objectForKey:kIASKIconNames];
    NSMutableDictionary *multipleValuesDict = [NSMutableDictionary new];
   
    if (values) {
        [multipleValuesDict setObject:values forKey:kIASKValues];
    }
	
    if (titles) {
        [multipleValuesDict setObject:titles forKey:kIASKTitles];
    }

    if (shortTitles.count) {
        [multipleValuesDict setObject:shortTitles forKey:kIASKShortTitles];
    }

    if (iconNames.count) {
        [multipleValuesDict setObject:iconNames forKey:kIASKIconNames];
    }

    [self setMultipleValuesDict:multipleValuesDict];
}

- (void)sortIfNeeded {
    if (self.displaySortedByTitle) {
        NSArray *values = self.multipleValues ?: [_specifierDict objectForKey:kIASKValues];
        NSArray *titles = self.multipleTitles ?: [_specifierDict objectForKey:kIASKTitles];
        NSArray *shortTitles = self.multipleShortTitles ?: [_specifierDict objectForKey:kIASKShortTitles];
        NSArray *iconNames = self.multipleIconNames ?: [_specifierDict objectForKey:kIASKIconNames];

        NSAssert(values.count == titles.count, @"Malformed multi-value specifier found in settings bundle. Number of values and titles differ.");
        NSAssert(shortTitles == nil || shortTitles.count == values.count, @"Malformed multi-value specifier found in settings bundle. Number of short titles and values differ.");
        NSAssert(iconNames == nil || iconNames.count == values.count, @"Malformed multi-value specifier found in settings bundle. Number of icon names and values differ.");

        NSMutableDictionary *multipleValuesDict = [NSMutableDictionary new];

        NSMutableArray *temporaryMappingsForSort = [NSMutableArray arrayWithCapacity:titles.count];

        static NSString *const titleKey = @"title";
        static NSString *const shortTitleKey = @"shortTitle";
        static NSString *const localizedTitleKey = @"localizedTitle";
        static NSString *const iconNamesKey = @"iconNamesKey";
        static NSString *const valueKey = @"value";

        IASKSettingsReader *strongSettingsReader = self.settingsReader;
        [titles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *localizedTitle = [strongSettingsReader titleForId:obj];
            [temporaryMappingsForSort addObject:@{titleKey : obj,
                                                  valueKey : values[idx],
                                                  localizedTitleKey : localizedTitle,
                                                  shortTitleKey : (shortTitles[idx] ?: [NSNull null]),
                                                  iconNamesKey : (iconNames[idx] ?: [NSNull null]),
                                                  }];
        }];
        
        NSArray *sortedTemporaryMappings = [temporaryMappingsForSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *localizedTitle1 = obj1[localizedTitleKey];
            NSString *localizedTitle2 = obj2[localizedTitleKey];

            if ([localizedTitle1 isKindOfClass:[NSString class]] && [localizedTitle2 isKindOfClass:[NSString class]]) {
                return [localizedTitle1 localizedCompare:localizedTitle2];
            } else {
                return NSOrderedSame;
            }
        }];
        
        NSMutableArray *sortedTitles = [NSMutableArray arrayWithCapacity:sortedTemporaryMappings.count];
        NSMutableArray *sortedShortTitles = [NSMutableArray arrayWithCapacity:sortedTemporaryMappings.count];
        NSMutableArray *sortedValues = [NSMutableArray arrayWithCapacity:sortedTemporaryMappings.count];
        NSMutableArray *sortedIconNames = [NSMutableArray arrayWithCapacity:sortedTemporaryMappings.count];

        [sortedTemporaryMappings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *mapping = obj;
            sortedTitles[idx] = (NSString *)mapping[titleKey];
            sortedValues[idx] = (id)mapping[valueKey];
            if (mapping[shortTitleKey] != [NSNull null]) {
                sortedShortTitles[idx] = (id)mapping[shortTitleKey];
            }
            if (mapping[iconNamesKey] != [NSNull null]) {
                sortedIconNames[idx] = (id)mapping[iconNamesKey];
            }
        }];
        titles = [sortedTitles copy];
        values = [sortedValues copy];
        shortTitles = [sortedShortTitles copy];
        iconNames = [iconNames copy];
        
        if (values) {
            [multipleValuesDict setObject:values forKey:kIASKValues];
        }
        
        if (titles) {
            [multipleValuesDict setObject:titles forKey:kIASKTitles];
        }
        
        if (shortTitles.count) {
            [multipleValuesDict setObject:shortTitles forKey:kIASKShortTitles];
        }

        if (iconNames.count) {
            [multipleValuesDict setObject:iconNames forKey:kIASKIconNames];
        }

        [self setMultipleValuesDict:multipleValuesDict];
    }
}

- (BOOL)displaySortedByTitle {
    return [[_specifierDict objectForKey:kIASKDisplaySortedByTitle] boolValue];
}

- (NSString*)localizedObjectForKey:(NSString*)key {
	IASKSettingsReader *settingsReader = self.settingsReader;
	return [settingsReader titleForId:[_specifierDict objectForKey:key]];
}

- (NSString*)title {
    return [self localizedObjectForKey:kIASKTitle];
}

- (BOOL)hasSubtitle {
	return [_specifierDict objectForKey:kIASKSubtitle] != nil;
}

- (NSString*)subtitle {
	return [self subtitleForValue:nil];
}

- (NSString*)subtitleForValue:(id)value {
	id subtitleValue = [_specifierDict objectForKey:kIASKSubtitle];
	if ([subtitleValue isKindOfClass:[NSDictionary class]]) {
		id subtitleForValue = nil;
		if (value != nil) {
			subtitleForValue = [(NSDictionary*) subtitleValue objectForKey:value];
		}
		if (subtitleForValue == nil) {
			subtitleForValue = [(NSDictionary*) subtitleValue objectForKey:@"__default__"];
		}
		IASKSettingsReader *settingsReader = self.settingsReader;
		return [settingsReader titleForId:subtitleForValue];
	}
	return [self localizedObjectForKey:kIASKSubtitle];
}

- (NSString *)placeholder {
    return [self localizedObjectForKey:kIASKPlaceholder];
}

- (NSString*)footerText {
    return [self localizedObjectForKey:kIASKFooterText];
}

- (Class)viewControllerClass {
    [IASKAppSettingsWebViewController class]; // make sure this is linked into the binary/library
	NSString *classString = [_specifierDict objectForKey:kIASKViewControllerClass];
	return classString ? ([self classFromString:classString] ?: [NSNull class]) : nil;
}

- (Class)classFromString:(NSString *)className {
    Class class = NSClassFromString(className);
    if (!class) {
        // if the class doesn't exist as a pure Obj-C class then try to retrieve it as a Swift class.
        NSString *appName = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSString *classStringName = [NSString stringWithFormat:@"_TtC%lu%@%lu%@", (unsigned long)appName.length, appName, (unsigned long)className.length, className];
        class = NSClassFromString(classStringName);
    }
    return class;
}

- (SEL)viewControllerSelector {
    NSString *selector = [_specifierDict objectForKey:kIASKViewControllerSelector];
    return selector ? NSSelectorFromString(selector) : nil;
}

- (NSString*)viewControllerStoryBoardFile {
	return [_specifierDict objectForKey:kIASKViewControllerStoryBoardFile];
}

- (NSString*)viewControllerStoryBoardID {
	return [_specifierDict objectForKey:kIASKViewControllerStoryBoardId];
}

- (NSString*)segueIdentifier {
    return [_specifierDict objectForKey:kIASKSegueIdentifier];
}

- (NSString*)key {
    return [_specifierDict objectForKey:kIASKKey];
}

- (NSString*)type {
    return (id)[_specifierDict objectForKey:kIASKType];
}

- (NSString*)titleForCurrentValue:(id)currentValue {
	NSArray *values = [self multipleValues];
	NSArray *titles = [self multipleShortTitles] ?: self.multipleTitles;
	if (!titles) {
        titles = [self multipleTitles];
	}
	if (values.count != titles.count) {
		return nil;
	}
    NSInteger keyIndex = [values indexOfObject:currentValue];
	if (keyIndex == NSNotFound) {
		return nil;
	}
	@try {
		IASKSettingsReader *strongSettingsReader = self.settingsReader;
		return [strongSettingsReader titleForId:[titles objectAtIndex:keyIndex]];
	}
	@catch (NSException * e) {}
	return nil;
}

- (NSInteger)multipleValuesCount {
    return [[_multipleValuesDict objectForKey:kIASKValues] count];
}

- (NSArray*)multipleValues {
    return [_multipleValuesDict objectForKey:kIASKValues];
}

- (NSArray*)multipleTitles {
    return [_multipleValuesDict objectForKey:kIASKTitles];
}

- (NSArray *)multipleIconNames {
    return [_multipleValuesDict objectForKey:kIASKIconNames];
}

- (NSArray*)multipleShortTitles {
    return [_multipleValuesDict objectForKey:kIASKShortTitles];
}

- (NSString*)file {
    return [_specifierDict objectForKey:kIASKFile];
}

- (id)defaultValue {
    return [_specifierDict objectForKey:kIASKDefaultValue];
}

- (id)defaultStringValue {
    return [[_specifierDict objectForKey:kIASKDefaultValue] description];
}

- (BOOL)defaultBoolValue {
	id defaultValue = [self defaultValue];
	if ([defaultValue isEqual:[self trueValue]]) {
		return YES;
	}
	if ([defaultValue isEqual:[self falseValue]]) {
		return NO;
	}
	return [defaultValue boolValue];
}

- (id)trueValue {
    return [_specifierDict objectForKey:kIASKTrueValue];
}

- (id)falseValue {
    return [_specifierDict objectForKey:kIASKFalseValue];
}

- (float)minimumValue {
    return [[_specifierDict objectForKey:kIASKMinimumValue] floatValue];
}

- (float)maximumValue {
    return [[_specifierDict objectForKey:kIASKMaximumValue] floatValue];
}

- (NSString*)minimumValueImage {
    return [_specifierDict objectForKey:kIASKMinimumValueImage];
}

- (NSString*)maximumValueImage {
    return [_specifierDict objectForKey:kIASKMaximumValueImage];
}

- (BOOL)isSecure {
    return [[_specifierDict objectForKey:kIASKIsSecure] boolValue];
}

- (UIKeyboardType)keyboardType {
    if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardAlphabet]) {
        return UIKeyboardTypeDefault;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardNumbersAndPunctuation]) {
        return UIKeyboardTypeNumbersAndPunctuation;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardNumberPad]) {
        return UIKeyboardTypeNumberPad;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardPhonePad]) {
        return UIKeyboardTypePhonePad;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardNamePhonePad]) {
        return UIKeyboardTypeNamePhonePad;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardASCIICapable]) {
        return UIKeyboardTypeASCIICapable;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardDecimalPad]) {
		return UIKeyboardTypeDecimalPad;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:KIASKKeyboardURL]) {
        return UIKeyboardTypeURL;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardEmailAddress]) {
        return UIKeyboardTypeEmailAddress;
    }
    return UIKeyboardTypeDefault;
}

- (UITextAutocapitalizationType)autocapitalizationType {
    if ([[_specifierDict objectForKey:kIASKAutocapitalizationType] isEqualToString:kIASKAutoCapNone]) {
        return UITextAutocapitalizationTypeNone;
    }
    else if ([[_specifierDict objectForKey:kIASKAutocapitalizationType] isEqualToString:kIASKAutoCapSentences]) {
        return UITextAutocapitalizationTypeSentences;
    }
    else if ([[_specifierDict objectForKey:kIASKAutocapitalizationType] isEqualToString:kIASKAutoCapWords]) {
        return UITextAutocapitalizationTypeWords;
    }
    else if ([[_specifierDict objectForKey:kIASKAutocapitalizationType] isEqualToString:kIASKAutoCapAllCharacters]) {
        return UITextAutocapitalizationTypeAllCharacters;
    }
    return UITextAutocapitalizationTypeNone;
}

- (UITextAutocorrectionType)autoCorrectionType {
    if ([[_specifierDict objectForKey:kIASKAutoCorrectionType] isEqualToString:kIASKAutoCorrDefault]) {
        return UITextAutocorrectionTypeDefault;
    }
    else if ([[_specifierDict objectForKey:kIASKAutoCorrectionType] isEqualToString:kIASKAutoCorrNo]) {
        return UITextAutocorrectionTypeNo;
    }
    else if ([[_specifierDict objectForKey:kIASKAutoCorrectionType] isEqualToString:kIASKAutoCorrYes]) {
        return UITextAutocorrectionTypeYes;
    }
    return UITextAutocorrectionTypeDefault;
}

- (nullable UITextContentType)textContentType {
	NSMutableDictionary *dict;
	if (@available(iOS 10.0, *)) {
		dict = @{kIASKTextContentTypeName: UITextContentTypeName,
				 kIASKTextContentTypeNamePrefix: UITextContentTypeNamePrefix,
				 kIASKTextContentTypeGivenName: UITextContentTypeGivenName,
				 kIASKTextContentTypeMiddleName: UITextContentTypeMiddleName,
				 kIASKTextContentTypeFamilyName: UITextContentTypeFamilyName,
				 kIASKTextContentTypeNameSuffix: UITextContentTypeNameSuffix,
				 kIASKTextContentTypeNickname: UITextContentTypeNickname,
				 kIASKTextContentTypeJobTitle: UITextContentTypeJobTitle,
				 kIASKTextContentTypeOrganizationName: UITextContentTypeOrganizationName,
				 kIASKTextContentTypeLocation: UITextContentTypeLocation,
				 kIASKTextContentTypeFullStreetAddress: UITextContentTypeFullStreetAddress,
				 kIASKTextContentTypeStreetAddressLine1: UITextContentTypeStreetAddressLine1,
				 kIASKTextContentTypeStreetAddressLine2: UITextContentTypeStreetAddressLine2,
				 kIASKTextContentTypeAddressCity: UITextContentTypeAddressCity,
				 kIASKTextContentTypeAddressState: UITextContentTypeAddressState,
				 kIASKTextContentTypeAddressCityAndState: UITextContentTypeAddressCityAndState,
				 kIASKTextContentTypeSublocality: UITextContentTypeSublocality,
				 kIASKTextContentTypeCountryName: UITextContentTypeCountryName,
				 kIASKTextContentTypePostalCode: UITextContentTypePostalCode,
				 kIASKTextContentTypeTelephoneNumber: UITextContentTypeTelephoneNumber,
				 kIASKTextContentTypeEmailAddress: UITextContentTypeEmailAddress,
				 kIASKTextContentTypeURL: UITextContentTypeURL,
				 kIASKTextContentTypeCreditCardNumber: UITextContentTypeCreditCardNumber}.mutableCopy;
	}
	if (@available(iOS 11.0, *)) {
		[dict addEntriesFromDictionary:@{kIASKTextContentTypeUsername: UITextContentTypeUsername,
										 kIASKTextContentTypePassword: UITextContentTypePassword}];
	}
	if (@available(iOS 12.0, *)) {
		[dict addEntriesFromDictionary:@{kIASKTextContentTypeNewPassword: UITextContentTypeNewPassword,
										 kIASKTextContentTypeOneTimeCode: UITextContentTypeOneTimeCode}];
	}
	NSString *value = [_specifierDict objectForKey:kIASKTextContentType];
	if (value.length > 1) {
		// also accept Swift form (e.g. "telephoneNumber" instead of "TelephoneNumber")
		NSString *firstChar = [value substringToIndex:1].uppercaseString;
		value = [value stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstChar];
	}
	return value ? [dict objectForKey:value] : nil;
}

- (UIImage *)cellImage {
    NSString *imageName = [_specifierDict objectForKey:kIASKCellImage];
    if( imageName.length == 0 )
        return nil;
    
    return [UIImage imageNamed:imageName];
}

- (UIImage *)highlightedCellImage {
    NSString *imageName = [[_specifierDict objectForKey:kIASKCellImage ] stringByAppendingString:@"Highlighted"];
    if( imageName.length == 0 )
        return nil;

    return [UIImage imageNamed:imageName];
}

- (BOOL)adjustsFontSizeToFitWidth {
	NSNumber *boxedResult = [_specifierDict objectForKey:kIASKAdjustsFontSizeToFitWidth];
	return (boxedResult == nil) || [boxedResult boolValue];
}

- (NSTextAlignment)textAlignment
{
    if (self.hasSubtitle || [[_specifierDict objectForKey:kIASKTextLabelAlignment] isEqualToString:kIASKTextLabelAlignmentLeft]) {
        return NSTextAlignmentLeft;
    } else if ([[_specifierDict objectForKey:kIASKTextLabelAlignment] isEqualToString:kIASKTextLabelAlignmentCenter]) {
        return NSTextAlignmentCenter;
    } else if ([[_specifierDict objectForKey:kIASKTextLabelAlignment] isEqualToString:kIASKTextLabelAlignmentRight]) {
        return NSTextAlignmentRight;
    }
    if ([self.type isEqualToString:kIASKButtonSpecifier] && !self.cellImage) {
		return NSTextAlignmentCenter;
	} else if ([@[kIASKPSMultiValueSpecifier, kIASKPSTitleValueSpecifier, kIASKTextViewSpecifier, kIASKDatePickerSpecifier] containsObject:self.type]) {
		return NSTextAlignmentRight;
	}
	return NSTextAlignmentLeft;
}

- (NSArray *)userInterfaceIdioms {
    NSMutableDictionary *idiomMap = [NSMutableDictionary dictionaryWithDictionary:
                                     @{
                                         @"Phone": @(UIUserInterfaceIdiomPhone),
                                         @"Pad": @(UIUserInterfaceIdiomPad),
                                     }];
    if (@available(iOS 14.0, *)) {
        idiomMap[@"Mac"] = @(UIUserInterfaceIdiomMac);
    }
    
    NSArray *idiomStrings = _specifierDict[kIASKSupportedUserInterfaceIdioms];
    if (idiomStrings.count == 0) {
        return [idiomMap allValues];
    }
    NSMutableArray *idioms = [NSMutableArray new];
    for (NSString *idiomString in idiomStrings) {
        id idiom = idiomMap[idiomString];
        if (idiom != nil){
            [idioms addObject:idiom];
        }
    }
    return idioms;
}

- (IASKSpecifier*)itemSpecifierForIndex:(NSUInteger)index {
	NSDictionary *specifierDictionary = [_specifierDict objectForKey:kIASKItemSpecifier];
    IASKSpecifier *itemSpecifier = [[IASKSpecifier alloc] initWithSpecifier:specifierDictionary];
	itemSpecifier.parentSpecifier = self;
	itemSpecifier.itemIndex = index;
	BOOL validType = [@[kIASKPSTitleValueSpecifier, kIASKPSChildPaneSpecifier, kIASKPSTextFieldSpecifier, kIASKPSMultiValueSpecifier, kIASKButtonSpecifier, kIASKCustomViewSpecifier] containsObject:itemSpecifier.type];
	NSAssert(validType, @"unsupported AddSpecifier Type");
	return validType ? itemSpecifier : nil;
}

- (BOOL)isItemSpecifier {
	return self.parentSpecifier && !self.isAddSpecifier;
}

- (IASKSpecifier*)addSpecifier {
	NSDictionary *specifierDictionary = [_specifierDict objectForKey:kIASKAddSpecifier];
	if (specifierDictionary == nil) {
		return nil;
	}
	IASKSpecifier *addSpecifier = [[IASKSpecifier alloc] initWithSpecifier:specifierDictionary];
	addSpecifier.parentSpecifier = self;
	addSpecifier.itemIndex = NSUIntegerMax;
	BOOL validType = [@[kIASKPSChildPaneSpecifier, kIASKPSTextFieldSpecifier, kIASKPSMultiValueSpecifier, kIASKButtonSpecifier, kIASKCustomViewSpecifier] containsObject:addSpecifier.type];
	NSAssert(validType, @"unsupported AddSpecifier Type");
	return validType ? addSpecifier : nil;
}

- (BOOL)isAddSpecifier {
	return self.itemIndex == NSUIntegerMax;
}

- (BOOL)deletable {
    return [[_specifierDict objectForKey:kIASKDeletable] boolValue];
}

- (IASKSpecifier*)editSpecifier {
	NSMutableDictionary *dict = _specifierDict.mutableCopy;
	if ([self.type isEqualToString:kIASKDatePickerSpecifier]) {
		dict[kIASKType] = kIASKDatePickerControl;
	}
	return [[IASKSpecifier alloc] initWithSpecifier:dict];
}

- (id)valueForKey:(NSString *)key {
	return [_specifierDict objectForKey:key];
}

- (void)setKey:(NSString *)key {
	[_specifierDict setValue:key forKey:kIASKKey];
}

- (void)setTitle:(NSString *)key {
	[_specifierDict setValue:key forKey:kIASKTitle];
}

- (UIDatePickerMode)datePickerMode {
	NSDictionary *dict = @{kIASKDatePickerModeTime: @(UIDatePickerModeTime),
						   kIASKDatePickerModeDate: @(UIDatePickerModeDate)};
	NSString *string = [_specifierDict objectForKey:kIASKDatePickerMode];
	NSNumber *value = dict[string];
	return value == nil ? UIDatePickerModeDateAndTime : value.integerValue;
}

- (UIDatePickerStyle)datePickerStyle {
	NSDictionary *dict = @{kIASKDatePickerStyleCompact: @(UIDatePickerStyleCompact),
						   kIASKDatePickerStyleWheels: @(UIDatePickerStyleWheels)};
	if (@available(iOS 14.0, *)) {
		IASK_IF_IOS14_OR_GREATER(
		 dict = @{kIASKDatePickerStyleCompact: @(UIDatePickerStyleCompact),
				  kIASKDatePickerStyleWheels: @(UIDatePickerStyleWheels),
				  kIASKDatePickerStyleInline: @(UIDatePickerStyleInline)};
		);
	}
	NSString *string = [_specifierDict objectForKey:kIASKDatePickerStyle];
	NSNumber *value = dict[string];
	return value == nil ? UIDatePickerStyleWheels : value.integerValue;
}

- (BOOL)embeddedDatePicker {
	BOOL embeddedDatePicker = NO;
	if (@available(iOS 14.0, *)) {
		IASK_IF_IOS14_OR_GREATER(
		 embeddedDatePicker = [self.type isEqualToString:kIASKDatePickerSpecifier] &&
		 (self.datePickerStyle == UIDatePickerStyleCompact || (self.datePickerStyle == UIDatePickerStyleInline && self.datePickerMode == UIDatePickerModeTime));
        );
	}
	return embeddedDatePicker;
}

- (NSInteger)datePickerMinuteInterval {
	return [_specifierDict[kIASKDatePickerMinuteInterval] integerValue] ?: 1;
}

- (IASKToggleStyle)toggleStyle {
	return [_specifierDict[kIASKToggleStyle] isEqualToString:kIASKToggleStyleCheckmark] ? IASKToggleStyleCheckmark : IASKToggleStyleSwitch;
}

- (BOOL)isEqual:(IASKSpecifier*)specifier {
	if (specifier.class != self.class) {
		return NO;
	}
	
	return specifier == self || [specifier.key isEqual:self.key];
}
@end
