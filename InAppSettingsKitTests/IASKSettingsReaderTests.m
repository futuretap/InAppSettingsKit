//
//  IASKSettingsReaderTests.m
//  InAppSettingsKit
//
//  Created by Stephan Diederich on 19.12.12.
//  Copyright (c) 2012 InAppSettingsKit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "IASKSettingsReader.h"

@interface IASKSettingsReaderTests : SenTestCase {
  NSString* settingsBundlePath;
}
@end


@implementation IASKSettingsReaderTests
- (void)setUp {
  [super setUp];
  
  settingsBundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Settings.bundle" ofType:nil];
}

- (void)tearDown {
  // Tear-down code here.
  
  [super tearDown];
}

- (void) testSetup {
  BOOL isDirectory = NO;
  BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:settingsBundlePath isDirectory:&isDirectory];
  STAssertTrue(exists, @"Settings missing from tests");
}

#pragma mark - initializers
- (void) testDesignatedInitializerSetsBundle {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Root"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];

  STAssertEqualObjects(reader.applicationBundle, [NSBundle bundleForClass:[self class]], @"Bundle not set");
}

- (void) testShorthandInitializerSetsMainBundle {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithFile:@"Root"];
  STAssertEqualObjects(reader.applicationBundle, [NSBundle mainBundle], @"Bundle not set");
}

- (void) testSettingsReaderOpensTestBundle {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Root"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];
  STAssertEqualObjects([reader.settingsBundle bundlePath], settingsBundlePath, @"Paths don't match. Failed to locate test bundle");
}

- (void) testSettingsReaderFindsDeviceDependentPlist {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Root"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];
  
  NSString* platfformSuffix = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? @"pad" : @"phone";
  NSString* plistName = [reader locateSettingsFile:@"Root"];
  STAssertTrue([plistName rangeOfString:platfformSuffix].location != NSNotFound, @"Paths don't match. Failed to locate test bundle");
}

- (void) testSettingsReaderFindsAdvancedPlist {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Advanced"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];
  STAssertEqualObjects([reader.settingsDictionary objectForKey:@"Title"],
                       @"ADVANCED_TITLE",
                       @"Advanced file not found");
}

#pragma mark - parsing
- (void) testSettingsReaderInterpretsAdvancedSettings {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Advanced"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];
  STAssertEquals(reader.numberOfSections, 4,
                       @"Failed to read correct number of sections");
  STAssertEquals([reader numberOfRowsForSection:0], 1,
                 @"Failed to read correct number of rows");
  STAssertEquals([reader numberOfRowsForSection:1], 1,
                 @"Failed to read correct number of rows");
  STAssertEquals([reader numberOfRowsForSection:2], 1,
                 @"Failed to read correct number of rows");
  STAssertEquals([reader numberOfRowsForSection:3], 3,
                 @"Failed to read correct number of rows");
}

#pragma mark - helpers
- (void) testPlattformSuffix {
  IASKSettingsReader* reader = [IASKSettingsReader new];
  STAssertEqualObjects([reader platformSuffixForInterfaceIdiom:UIUserInterfaceIdiomPad],
                       @"~ipad", @"Must match");
  STAssertEqualObjects([reader platformSuffixForInterfaceIdiom:UIUserInterfaceIdiomPhone],
                       @"~iphone", @"Must match");
  
}

#pragma mark - hidden keys
- (void) testSettingsReaderHidesHiddenKeys {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Advanced"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];
  [reader setHiddenKeys:[NSSet setWithObjects:@"AutoConnectLogin", @"AutoConnectPassword", nil]];
  STAssertEquals([reader numberOfRowsForSection:3], 1, @"Wrong number of rows. Key not hidden");
}

- (void) testSettingsReaderShowsHiddenKeys {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Advanced"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];
  [reader setHiddenKeys:[NSSet setWithObjects:@"AutoConnectLogin", nil]];
  [reader setHiddenKeys:nil];
  STAssertEquals([reader numberOfRowsForSection:3], 3, @"Wrong number of rows. Key not unhidden");
}

- (void) testSettingsReaderHidesGroupKeys {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Advanced"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];
  [reader setHiddenKeys:[NSSet setWithObjects:@"AutoConnectLogin", @"AutoConnectPassword", @"AutoConnect", @"DynamicCellHidingGroup", nil]];
  STAssertEquals([reader numberOfSections], 3, @"Wrong number of rows. Key not hidden");
}


@end
