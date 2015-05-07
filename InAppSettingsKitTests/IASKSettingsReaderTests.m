//
//  IASKSettingsReaderTests.m
//  InAppSettingsKit
//
//  Created by Stephan Diederich on 19.12.12.
//  Copyright (c) 2012 InAppSettingsKit. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "IASKSettingsReader.h"
#import "IASKSpecifier.h"

@interface IASKSettingsReaderTests : XCTestCase {
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
  XCTAssertTrue(exists, @"Settings missing from tests");
}

#pragma mark - initializers
- (void) testDesignatedInitializerSetsBundle {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Root"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];

  XCTAssertEqualObjects(reader.applicationBundle, [NSBundle bundleForClass:[self class]], @"Bundle not set");
}

- (void) testShorthandInitializerSetsMainBundle {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithFile:@"Root"];
  XCTAssertEqualObjects(reader.applicationBundle, [NSBundle mainBundle], @"Bundle not set");
}

- (void) testSettingsReaderOpensTestBundle {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Root"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];
  XCTAssertEqualObjects([reader.settingsBundle bundlePath], settingsBundlePath, @"Paths don't match. Failed to locate test bundle");
}

- (void) testSettingsReaderFindsDeviceDependentPlist {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Root"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];
  
  NSString* platfformSuffix = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? @"pad" : @"phone";
  NSString* plistName = [reader locateSettingsFile:@"Root"];
  XCTAssertTrue([plistName rangeOfString:platfformSuffix].location != NSNotFound, @"Paths don't match. Failed to locate test bundle");
}

- (void) testSettingsReaderFindsAdvancedPlist {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Advanced"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];
  XCTAssertEqualObjects([reader.settingsDictionary objectForKey:@"Title"],
                       @"ADVANCED_TITLE",
                       @"Advanced file not found");
}

- (void) testSettingsReaderSortsByLocalizedKey {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Root"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];
    IASKSpecifier *multiSpecifier = [reader specifierForKey:@"mulValue"];
    XCTAssertTrue([multiSpecifier displaySortedByTitle]);
    XCTAssertEqualObjects([multiSpecifier multipleValues], (@[@"0", @"6", @"1", @"4", @"5", @"7", @"3", @"9", @"8", @"10", @"2"]));
}

- (void) testSettingsReaderFailsToSortMalformedMultiValueEntries {
    XCTAssertThrows([[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Malformed"
                                                        applicationBundle:[NSBundle bundleForClass:[self class]]]);
}

#pragma mark - parsing
- (void) testSettingsReaderInterpretsAdvancedSettings {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Advanced"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];
  XCTAssertEqual(reader.numberOfSections, 4,
                       @"Failed to read correct number of sections");
  XCTAssertEqual([reader numberOfRowsForSection:0], 1,
                 @"Failed to read correct number of rows");
  XCTAssertEqual([reader numberOfRowsForSection:1], 1,
                 @"Failed to read correct number of rows");
  XCTAssertEqual([reader numberOfRowsForSection:2], 1,
                 @"Failed to read correct number of rows");
  XCTAssertEqual([reader numberOfRowsForSection:3], 3,
                 @"Failed to read correct number of rows");
}

#pragma mark - helpers
- (void) testPlattformSuffix {
  IASKSettingsReader* reader = [IASKSettingsReader new];
  XCTAssertEqualObjects([reader platformSuffixForInterfaceIdiom:UIUserInterfaceIdiomPad],
                       @"~ipad", @"Must match");
  XCTAssertEqualObjects([reader platformSuffixForInterfaceIdiom:UIUserInterfaceIdiomPhone],
                       @"~iphone", @"Must match");
  
}

#pragma mark - hidden keys
- (void) testSettingsReaderHidesHiddenKeys {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Advanced"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];
  [reader setHiddenKeys:[NSSet setWithObjects:@"AutoConnectLogin", @"AutoConnectPassword", nil]];
  XCTAssertEqual([reader numberOfRowsForSection:3], 1, @"Wrong number of rows. Key not hidden");
}

- (void) testSettingsReaderShowsHiddenKeys {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Advanced"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];
  [reader setHiddenKeys:[NSSet setWithObjects:@"AutoConnectLogin", nil]];
  [reader setHiddenKeys:nil];
  XCTAssertEqual([reader numberOfRowsForSection:3], 3, @"Wrong number of rows. Key not unhidden");
}

- (void) testSettingsReaderHidesGroupKeys {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Advanced"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];
  [reader setHiddenKeys:[NSSet setWithObjects:@"AutoConnectLogin", @"AutoConnectPassword", @"AutoConnect", @"DynamicCellHidingGroup", nil]];
  XCTAssertEqual([reader numberOfSections], 3, @"Wrong number of rows. Key not hidden");
}


@end
