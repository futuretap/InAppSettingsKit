//
//	IASKSettingsReader.m
//	InAppSettingsKit
//
//	Copyright (c) 2009-2020:
//	Luc Vandal, Edovia Inc., http://www.edovia.com
//	Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//	All rights reserved.
//
//	It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz,
//	as the original authors of this code. You can give credit in a blog post, a tweet or on
//	a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//	This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

#import "IASKSettingsReader.h"
#import "IASKSpecifier.h"
#import "IASKSettingsStore.h"

NSString * const IASKSettingChangedNotification = @"IASKAppSettingChangedNotification";

#pragma mark -
@interface NSArray (IASKAdditions)
- (id)iaskObjectAtIndex:(NSUInteger)index;
@end

@implementation IASKSettingsReader

- (nonnull id)initWithFile:(nonnull NSString*)file bundle:(nonnull NSBundle*)bundle {
    if ((self = [super init])) {
        _applicationBundle = bundle;
        
        NSString* plistFilePath = [self locateSettingsFile:file];
        NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
		NSAssert(settingsDictionary, @"invalid settings plist");
		_settingsDictionary = settingsDictionary;
        
        //store the bundle which we'll need later for getting localizations
		NSString* settingsBundlePath = plistFilePath.stringByDeletingLastPathComponent;
		NSBundle *settingsBundle = [NSBundle bundleWithPath:settingsBundlePath];
		NSAssert(settingsBundle, @"invalid settings bundle");
		_settingsBundle = settingsBundle;
        
        // Look for localization file
        NSString *localizationTable = [_settingsDictionary objectForKey:@"StringsTable"];
        if (!localizationTable) {
            // Look for localization file using filename
			localizationTable = [plistFilePath.stringByDeletingPathExtension // removes '.plist'
								 .stringByDeletingPathExtension // removes potential '.inApp'
								 .lastPathComponent // strip absolute path
								 stringByReplacingOccurrencesOfString:[self platformSuffixForInterfaceIdiom:[[UIDevice currentDevice] userInterfaceIdiom]] withString:@""]; // removes potential '~device' (~ipad, ~iphone)
			if ([self.settingsBundle pathForResource:localizationTable ofType:@"strings"] == nil) {
                // Could not find the specified localization: use default
                localizationTable = @"Root";
            }
        }
		self.localizationTable = localizationTable ?: @"Root";
		
        self.showPrivacySettings = NO;
        NSArray *privacyRelatedInfoPlistKeys = @[@"NSBluetoothPeripheralUsageDescription", @"NSCalendarsUsageDescription", @"NSCameraUsageDescription", @"NSContactsUsageDescription", @"NSLocationAlwaysAndWhenInUseUsageDescription", @"NSLocationAlwaysUsageDescription", @"NSLocationUsageDescription", @"NSLocationWhenInUseUsageDescription", @"NSMicrophoneUsageDescription", @"NSMotionUsageDescription", @"NSPhotoLibraryAddUsageDescription", @"NSPhotoLibraryUsageDescription", @"NSRemindersUsageDescription", @"NSHealthShareUsageDescription", @"NSHealthUpdateUsageDescription"];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        if ([file isEqualToString:@"Root"]) {
            for (NSString* key in privacyRelatedInfoPlistKeys) {
                if (infoDictionary[key]) {
                    self.showPrivacySettings = YES;
                    break;
                }
            }
        }
        if (self.settingsDictionary) {
            [self _reinterpretBundle:self.settingsDictionary];
        }
    }
    return self;
}

- (nonnull id)initWithFile:(nonnull NSString*)file {
    return [self initWithFile:file bundle:[NSBundle mainBundle]];
}

- (id)init {
    return [self initWithFile:@"Root"];
}

- (void)setHiddenKeys:(NSSet *)anHiddenKeys {
    if (_hiddenKeys != anHiddenKeys) {
        _hiddenKeys = anHiddenKeys;
        
        if (self.settingsDictionary) {
            [self _reinterpretBundle:self.settingsDictionary];
        }
    }
}

- (void)setSelectedSpecifier:(IASKSpecifier *)selectedSpecifier {
	if (_selectedSpecifier != selectedSpecifier) {
		_selectedSpecifier = selectedSpecifier;
		[self _reinterpretBundle:self.settingsDictionary];
	}
}

- (void)setShowPrivacySettings:(BOOL)showPrivacySettings {
	if (_showPrivacySettings != showPrivacySettings) {
		_showPrivacySettings = showPrivacySettings;
		[self _reinterpretBundle:self.settingsDictionary];
	}
}

- (NSArray*)privacySettingsSpecifiers {
	NSMutableDictionary *dict = [@{kIASKTitle: NSLocalizedStringFromTableInBundle(@"Privacy", @"IASKLocalizable", self.iaskBundle, @"Privacy cell: title"),
								   kIASKKey: @"IASKPrivacySettingsCellKey",
								   kIASKType: kIASKOpenURLSpecifier,
								   kIASKFile: UIApplicationOpenSettingsURLString,
								   } mutableCopy];
	NSString *subtitle = NSLocalizedStringFromTableInBundle(@"Open in Settings app", @"IASKLocalizable", self.iaskBundle, @"Privacy cell: subtitle");
	if (subtitle.length) {
		dict [kIASKSubtitle] = subtitle;
	}
	
	return @[@[[[IASKSpecifier alloc] initWithSpecifier:@{kIASKKey: @"IASKPrivacySettingsHeaderKey", kIASKType: kIASKPSGroupSpecifier}],
			   [[IASKSpecifier alloc] initWithSpecifier:dict]]];
}

- (NSBundle*)iaskBundle {
#ifdef SWIFTPM_MODULE_BUNDLE
	return SWIFTPM_MODULE_BUNDLE;
#endif
	
	NSURL *inAppSettingsBundlePath = [[NSBundle bundleForClass:[self class]] URLForResource:@"InAppSettingsKit" withExtension:@"bundle"];
	NSBundle *bundle;
	
	if (inAppSettingsBundlePath) {
		bundle = [NSBundle bundleWithURL:inAppSettingsBundlePath];
	} else {
		bundle = [NSBundle mainBundle];
	}
	
	return bundle;
}

- (void)_reinterpretBundle:(NSDictionary*)settingsBundle {
    NSArray *preferenceSpecifiers	= [settingsBundle objectForKey:kIASKPreferenceSpecifiers];
    NSMutableArray *dataSource		= [NSMutableArray array];
	
    if (self.showPrivacySettings) {
        [dataSource addObjectsFromArray:self.privacySettingsSpecifiers];
    }

	BOOL ignoreItemsInThisSection = NO;
    for (NSDictionary *specifierDictionary in preferenceSpecifiers) {
        IASKSpecifier *newSpecifier = [[IASKSpecifier alloc] initWithSpecifier:specifierDictionary];
        newSpecifier.settingsReader = self;
        [newSpecifier sortIfNeeded];

        if (![newSpecifier.userInterfaceIdioms containsObject:@([[UIDevice currentDevice] userInterfaceIdiom])]) {
            // All specifiers without a matching idiom are ignored in the iOS Settings app, so we will do likewise here.
            // Some specifiers may be seen as containing other elements, such as groups, but the iOS settings app will not ignore the perceived content of those unless their own supported idioms do not fit.
            continue;
        }

        if ([@[kIASKPSGroupSpecifier, kIASKPSRadioGroupSpecifier, kIASKListGroupSpecifier] containsObject:newSpecifier.type]) {
			
			if (newSpecifier.key && [self.hiddenKeys containsObject:(id)newSpecifier.key]) {
				ignoreItemsInThisSection = YES;
				continue;
			}
			ignoreItemsInThisSection = NO;

			///create a brand new array with the specifier above and an empty array
            NSMutableArray *newArray = [NSMutableArray array];
            [newArray addObject:newSpecifier];
            [dataSource addObject:newArray];
			
            if ([newSpecifier.type isEqualToString:kIASKPSRadioGroupSpecifier]) {
                for (NSString *value in newSpecifier.multipleValues) {
                    IASKSpecifier *valueSpecifier =
                        [[IASKSpecifier alloc] initWithSpecifier:specifierDictionary radioGroupValue:value];
                    valueSpecifier.settingsReader = self;
                    [valueSpecifier sortIfNeeded];
                    [newArray addObject:valueSpecifier];
                }
            }
		} else {
			if (ignoreItemsInThisSection || (newSpecifier.key && [self.hiddenKeys containsObject:(id)newSpecifier.key])) {
				continue;
			}

            if (dataSource.count == 0 || (dataSource.count == 1 && self.showPrivacySettings)) {
                [dataSource addObject:[NSMutableArray array]];
            }
            
            [(NSMutableArray*)dataSource.lastObject addObject:newSpecifier];
			
			if ([newSpecifier isEqual:self.selectedSpecifier]) {
				[(NSMutableArray*)dataSource.lastObject addObject:newSpecifier.editSpecifier];
			}
        }
    }
    [self setDataSource:dataSource];
}

- (BOOL)_sectionHasHeading:(NSInteger)section {
    return [self headerSpecifierForSection:section] != nil;
}

/// Returns the specifier describing the section's header, or nil if there is no header.
- (nullable IASKSpecifier*)headerSpecifierForSection:(NSInteger)section {
    IASKSpecifier *specifier = [[self.dataSource iaskObjectAtIndex:section] iaskObjectAtIndex:kIASKSectionHeaderIndex];
    if ([specifier.type isEqualToString:kIASKPSGroupSpecifier]
		|| [specifier.type isEqualToString:kIASKListGroupSpecifier]
        || [specifier.type isEqualToString:kIASKPSRadioGroupSpecifier]) {
        return specifier;
    }
    return nil;
}

- (NSInteger)numberOfSections {
    return self.dataSource.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    int headingCorrection = [self _sectionHasHeading:section] ? 1 : 0;
    
	IASKSpecifier *headerSpecifier = [[[self dataSource] iaskObjectAtIndex:section] iaskObjectAtIndex:kIASKSectionHeaderIndex];
	if ([headerSpecifier.type isEqualToString:kIASKListGroupSpecifier]) {
		NSInteger numberOfRows = [self.settingsStore arrayForSpecifier:headerSpecifier].count;
	
		if (headerSpecifier.addSpecifier) {
			numberOfRows++;
		}
		return numberOfRows;
	}

	return ((NSArray*)[self.dataSource iaskObjectAtIndex:section]).count - headingCorrection;
}

- (nullable IASKSpecifier*)specifierForIndexPath:(nonnull NSIndexPath*)indexPath {
    int headingCorrection = [self _sectionHasHeading:indexPath.section] ? 1 : 0;
	IASKSpecifier *specifier;
	
	IASKSpecifier *headerSpecifier = [self headerSpecifierForSection:indexPath.section];
	
	if (headerSpecifier != nil && [headerSpecifier.type isEqualToString:kIASKListGroupSpecifier]) {
		NSInteger numberOfRows = [self.settingsStore arrayForSpecifier:headerSpecifier].count;
		
		if (indexPath.row < numberOfRows) {
			specifier = [headerSpecifier itemSpecifierForIndex:indexPath.row];
		} else if (headerSpecifier.addSpecifier != nil) {
			specifier = headerSpecifier.addSpecifier;
		}
	} else {
		specifier = [[[self dataSource] iaskObjectAtIndex:indexPath.section] iaskObjectAtIndex:(indexPath.row+headingCorrection)];
	}
	
    specifier.settingsReader = self;
    return specifier;
}

- (nullable NSIndexPath*)indexPathForKey:(NSString *)key {
    for (NSUInteger sectionIndex = 0; sectionIndex < self.dataSource.count; sectionIndex++) {
        NSArray *section = [self.dataSource iaskObjectAtIndex:sectionIndex];
        for (NSInteger rowIndex = 0; (NSUInteger)rowIndex < section.count; rowIndex++) {
            IASKSpecifier *specifier = (IASKSpecifier*)[section objectAtIndex:rowIndex];
            if ([specifier isKindOfClass:[IASKSpecifier class]] && [specifier.key isEqualToString:key]) {
                NSInteger headingCorrection = [self _sectionHasHeading:sectionIndex] ? 1 : 0;
                NSUInteger correctedRowIndex = MAX(0, rowIndex - headingCorrection);
                return [NSIndexPath indexPathForRow:correctedRowIndex inSection:sectionIndex];
            }
        }
    }
    return nil;
}

- (nullable IASKSpecifier*)specifierForKey:(NSString*)key {
    for (NSArray *specifiers in _dataSource) {
        for (id sp in specifiers) {
            if ([sp isKindOfClass:[IASKSpecifier class]]) {
                if ([[sp key] isEqualToString:key]) {
                    return sp;
                }
            }
        }
    }
    return nil;
}

- (nullable NSString*)titleForSection:(NSInteger)section {
    return [self titleForId:[self headerSpecifierForSection:section].title];
}

- (nullable NSString*)keyForSection:(NSInteger)section {
    return [self headerSpecifierForSection:section].key;
}

- (nullable NSString*)footerTextForSection:(NSInteger)section {
    return [self titleForId:[self headerSpecifierForSection:section].footerText];
}

- (nullable NSString*)titleForId:(nullable NSObject*)titleId {
	if ([titleId isKindOfClass:NSNumber.class]) {
		NSNumber* numberTitleId = (NSNumber*)titleId;
		NSNumberFormatter* formatter = [NSNumberFormatter new];
		[formatter setNumberStyle:NSNumberFormatterNoStyle];
		return [formatter stringFromNumber:numberTitleId];
	} else if ([titleId isKindOfClass:NSString.class]) {
		NSString* stringTitleId = (NSString*)titleId;
		return [self.settingsBundle localizedStringForKey:stringTitleId value:stringTitleId table:self.localizationTable];
	} else {
		return nil;
	}
}

- (NSDictionary*)gatherDefaultsLimitedToEditableFields:(BOOL)limitedToEditableFields {
	NSMutableDictionary *dictionary = NSMutableDictionary.dictionary;
	[self gatherDefaultsInDictionary:dictionary limitedToEditableFields:limitedToEditableFields apply:NO];
	return dictionary;
}

- (void)applyDefaultsToStore {
	[self gatherDefaultsInDictionary:nil limitedToEditableFields:YES apply:YES];
}

- (void)gatherDefaultsInDictionary:(NSMutableDictionary*)dictionary limitedToEditableFields:(BOOL)limitedToEditableFields apply:(BOOL)apply {
	NSArray *editableTypes = @[kIASKPSToggleSwitchSpecifier, kIASKPSMultiValueSpecifier, kIASKPSRadioGroupSpecifier, kIASKPSSliderSpecifier, kIASKPSTextFieldSpecifier, kIASKTextViewSpecifier, kIASKCustomViewSpecifier, kIASKDatePickerSpecifier];
	for (NSArray *section in self.dataSource) {
		for (IASKSpecifier *specifier in section) {
			if (specifier.key && specifier.defaultValue && (!limitedToEditableFields || [editableTypes containsObject:specifier.type])) {
				if (apply && ![self.settingsStore objectForSpecifier:specifier]) {
					[self.settingsStore setObject:specifier.defaultValue forSpecifier:specifier];
				}
				[dictionary setObject:(id)specifier.defaultValue forKey:(id)specifier.key];
			}
			if ([specifier.type isEqualToString:kIASKPSChildPaneSpecifier] && specifier.file) {
				IASKSettingsReader *childReader = [[IASKSettingsReader alloc] initWithFile:(id)specifier.file];
				childReader.settingsStore = self.settingsStore;
				[childReader gatherDefaultsInDictionary:dictionary limitedToEditableFields:limitedToEditableFields apply:apply];
			}
		}
	}
}

- (nonnull NSString*)pathForImageNamed:(nonnull NSString*)image {
	return image ? [self.settingsBundle.bundlePath stringByAppendingPathComponent:(id)image] : @"";
}

- (NSString *)platformSuffixForInterfaceIdiom:(UIUserInterfaceIdiom) interfaceIdiom {
    switch (interfaceIdiom) {
        case UIUserInterfaceIdiomPad: return @"~ipad";
        case UIUserInterfaceIdiomPhone: return @"~iphone";
		default: return @"~iphone";
    }
}

- (NSString *)file:(NSString *)file
        withBundle:(NSString *)bundle
            suffix:(NSString *)suffix
         extension:(NSString *)extension {
    
	bundle = [self.applicationBundle pathForResource:bundle ofType:nil];
    file = [file stringByAppendingFormat:@"%@%@", suffix, extension];
    return [bundle stringByAppendingPathComponent:file];
}

- (NSString *)locateSettingsFile: (NSString *)file {
    static NSString* const kIASKBundleFolder = @"Settings.bundle";
    static NSString* const kIASKBundleFolderAlt = @"InAppSettings.bundle";
    
    static NSString* const kIASKBundleLocaleFolderExtension = @".lproj";

    // The file is searched in the following order:
    //
    // InAppSettings.bundle/FILE~DEVICE.inApp.plist
    // InAppSettings.bundle/FILE.inApp.plist
    // InAppSettings.bundle/FILE~DEVICE.plist
    // InAppSettings.bundle/FILE.plist
    // Settings.bundle/FILE~DEVICE.inApp.plist
    // Settings.bundle/FILE.inApp.plist
    // Settings.bundle/FILE~DEVICE.plist
    // Settings.bundle/FILE.plist
    //
    // where DEVICE is either "iphone" or "ipad" depending on the current
    // interface idiom.
    //
    // Settings.app uses the ~DEVICE suffixes since iOS 4.0.  There are some
    // differences from this implementation:
    // - For an iPhone-only app running on iPad, Settings.app will not use the
    //	 ~iphone suffix.  There is no point in using these suffixes outside
    //	 of universal apps anyway.
    // - This implementation uses the device suffixes on iOS 3.x as well.
    // - also check current locale (short only)
    
    NSArray *settingsBundleNames = @[kIASKBundleFolderAlt, kIASKBundleFolder];
    
    NSArray *extensions = @[@".inApp.plist", @".plist"];
    
    NSArray *plattformSuffixes = @[[self platformSuffixForInterfaceIdiom:[[UIDevice currentDevice] userInterfaceIdiom]],
                                   @""];
    
    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    NSArray *languageFolders = @[[ (preferredLanguages.count ? [preferredLanguages objectAtIndex:0] : @"en") stringByAppendingString:kIASKBundleLocaleFolderExtension],
                                 @""];

    
    NSString *path = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (NSString *settingsBundleName in settingsBundleNames) {
        for (NSString *extension in extensions) {
            for (NSString *platformSuffix in plattformSuffixes) {
                for (NSString *languageFolder in languageFolders) {
                    path = [self file:file
                           withBundle:[settingsBundleName stringByAppendingPathComponent:languageFolder]
                               suffix:platformSuffix
                            extension:extension];
                    if ([fileManager fileExistsAtPath:path]) {
                        goto exitFromNestedLoop;
                    }
                }
            }
        }
    }
    
exitFromNestedLoop:
    return path;
}

@end

@implementation NSArray (IASKAdditions)

- (id)iaskObjectAtIndex:(NSUInteger)index {
    if (index >= self.count) return nil;
    return self[index];
}

@end
