//
//  IASKSettingsReader.m
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

#import "IASKSettingsReader.h"
#import "IASKSpecifier.h"

@interface IASKSettingsReader (private)
- (void)_reinterpretBundle:(NSDictionary*)settingsBundle;
- (BOOL)_sectionHasHeading:(NSInteger)section;
@end

@implementation IASKSettingsReader

@synthesize path=_path,
bundleFolder=_bundleFolder,
settingsBundle=_settingsBundle, 
dataSource=_dataSource;

- (id)init {
	return [self initWithFile:@"Root"];
}

- (id)initWithFile:(NSString*)file {
    if ((self=[super init])) {
		[self setBundleFolder:kIASKBundleFolderAlt];
		// Generate the settings bundle path
		NSString *path = [self bundlePath];
		
		// Try both bundle folders
		for (int i=0;i<2;i++) {			
			[self setPath:[path stringByAppendingPathComponent:[file stringByAppendingString:@".inApp.plist"]]];
			[self setSettingsBundle:[NSDictionary dictionaryWithContentsOfFile:[self path]]];
			if (!self.settingsBundle) {
				[self setPath:[path stringByAppendingPathComponent:[file stringByAppendingString:@".plist"]]];
				[self setSettingsBundle:[NSDictionary dictionaryWithContentsOfFile:[self path]]];
			}
			if (self.settingsBundle)
				break;
			[self setBundleFolder:kIASKBundleFolder];
			path = [self bundlePath];
		}
        _bundle = [[NSBundle bundleWithPath:path] retain];
        
        if (_settingsBundle) {
            [self _reinterpretBundle:_settingsBundle];
        }
    }
    return self;
}

- (void)dealloc {
    [_path release];
    [_settingsBundle release];
    [_dataSource release];
    [_bundle release];
    [super dealloc];
}

- (void)_reinterpretBundle:(NSDictionary*)settingsBundle {
    NSArray *preferenceSpecifiers   = [settingsBundle objectForKey:kIASKPreferenceSpecifiers];
    NSInteger sectionCount          = -1;
    NSMutableArray *dataSource      = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSDictionary *specifier in preferenceSpecifiers) {
        if ([(NSString*)[specifier objectForKey:kIASKType] isEqualToString:kIASKPSGroupSpecifier]) {
            NSMutableArray *newArray = [[NSMutableArray alloc] init];
            
            [newArray addObject:specifier];
            [dataSource addObject:newArray];
            [newArray release];
            sectionCount++;
        }
        else {
            if (sectionCount == -1) {
                NSMutableArray *newArray = [[NSMutableArray alloc] init];
				[dataSource addObject:newArray];
				[newArray release];
				sectionCount++;
			}

            IASKSpecifier *newSpecifier = [[IASKSpecifier alloc] initWithSpecifier:specifier];
            [(NSMutableArray*)[dataSource objectAtIndex:sectionCount] addObject:newSpecifier];
            [newSpecifier release];
        }
    }
    [self setDataSource:dataSource];
}

- (BOOL)_sectionHasHeading:(NSInteger)section {
    return [[[[self dataSource] objectAtIndex:section] objectAtIndex:0] isKindOfClass:[NSDictionary class]];
}

- (NSInteger)numberOfSections {
    return [[self dataSource] count];
}

- (NSInteger)numberOfRowsForSection:(NSInteger)section {
    int headingCorrection = [self _sectionHasHeading:section] ? 1 : 0;
    return [(NSArray*)[[self dataSource] objectAtIndex:section] count] - headingCorrection;
}

- (IASKSpecifier*)specifierForIndexPath:(NSIndexPath*)indexPath {
    int headingCorrection = [self _sectionHasHeading:indexPath.section] ? 1 : 0;
    
    IASKSpecifier *specifier = [[[self dataSource] objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row+headingCorrection)];
 	specifier.settingsReader = self;
 	return specifier;
}

- (IASKSpecifier*)specifierForKey:(NSString*)key {
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

- (NSString*)titleForSection:(NSInteger)section {
    if ([self _sectionHasHeading:section]) {
        NSDictionary *dict = [[[self dataSource] objectAtIndex:section] objectAtIndex:kIASKSectionHeaderIndex];
        return [_bundle localizedStringForKey:[dict objectForKey:kIASKTitle] value:[dict objectForKey:kIASKTitle] table:@"Root"];
    }
    return nil;
}

- (NSString*)titleForStringId:(NSString*)stringId {
    return [_bundle localizedStringForKey:stringId value:stringId table:@"Root"];
}

- (NSString*)bundlePath {
    NSString *libDirectory  = [[NSBundle mainBundle] bundlePath];
    return [libDirectory stringByAppendingPathComponent:_bundleFolder];
}

- (NSString*)pathForImageNamed:(NSString*)image {
    return [[self bundlePath] stringByAppendingPathComponent:image];
}

@end
