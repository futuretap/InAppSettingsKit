//
//  IASKSettingsReaderTests.m
//  InAppSettingsKit
//
//  Created by Stephan Diederich on 19.12.12.
//  Copyright (c) 2012-2020:
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
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
	IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithFile:@"Root"
																   bundle:[NSBundle bundleForClass:[self class]]];
	
	XCTAssertEqualObjects(reader.applicationBundle, [NSBundle bundleForClass:[self class]], @"Bundle not set");
}

- (void) testSettingsReaderOpensTestBundle {
	IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithFile:@"Root"
																   bundle:[NSBundle bundleForClass:[self class]]];
	XCTAssertEqualObjects([reader.settingsBundle bundlePath], settingsBundlePath, @"Paths don't match. Failed to locate test bundle");
}

- (void) testSettingsReaderFindsDeviceDependentPlist {
	IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithFile:@"Root"
																   bundle:[NSBundle bundleForClass:[self class]]];
	
	NSString* platfformSuffix = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? @"pad" : @"phone";
	NSString* plistName = [reader locateSettingsFile:@"Root"];
	XCTAssertTrue([plistName rangeOfString:platfformSuffix].location != NSNotFound, @"Paths don't match. Failed to locate test bundle");
}

- (void) testSettingsReaderFindsAdvancedPlist {
	IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithFile:@"Advanced"
																   bundle:[NSBundle bundleForClass:[self class]]];
	XCTAssertEqualObjects([reader.settingsDictionary objectForKey:@"Title"],
						  @"ADVANCED_TITLE",
						  @"Advanced file not found");
}

- (void) testSettingsReaderSortsByLocalizedKey {
	IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithFile:@"Root"
																   bundle:[NSBundle bundleForClass:[self class]]];
	IASKSpecifier *multiSpecifier = [reader specifierForKey:@"mulValue"];
	XCTAssertTrue([multiSpecifier displaySortedByTitle]);
	XCTAssertEqualObjects([multiSpecifier multipleValues], (@[@"0", @"6", @"1", @"4", @"5", @"7", @"3", @"9", @"8", @"10", @"2"]));
}

- (void) testSettingsReaderLocalizedNumberTitles {
	IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithFile:@"Complete"
																   bundle:[NSBundle bundleForClass:[self class]]];
	IASKSpecifier *multiSpecifier = [reader specifierForKey:@"mulValueWithNumbers"];
	
	NSNumberFormatter* formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterNoStyle];
	
	XCTAssertEqualObjects([multiSpecifier multipleTitles], (@[@(0), @(1), @(2), @(3)]));
	XCTAssertEqualObjects([multiSpecifier titleForCurrentValue:@(3)], [formatter stringFromNumber:@(3)]);
}

- (void) testSettingsReaderSubtitles {
	IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithFile:@"Complete"
																   bundle:[NSBundle bundleForClass:[self class]]];
	IASKSpecifier *noSubtitleSpecifier = [reader specifierForKey:@"toggle_boolean"];
	XCTAssertFalse([noSubtitleSpecifier hasSubtitle], @"Expected no subtitle");
	XCTAssertNil([noSubtitleSpecifier subtitle], @"Failed to read the subtitle: Got subtitle, expected none");
	
	IASKSpecifier *subtitleSpecifier = [reader specifierForKey:@"toggle_boolean_subtitle"];
	XCTAssertTrue([subtitleSpecifier hasSubtitle], @"Expected a subtitle");
	XCTAssertEqualObjects([subtitleSpecifier subtitle], @"with subtitle", @"Failed to read the correct subtitle");
	
	
	IASKSpecifier *valueAwareSubtitleSpecifier = [reader specifierForKey:@"toggle_boolean_value_aware_subtitle"];
	XCTAssertTrue([valueAwareSubtitleSpecifier hasSubtitle], @"Expected a subtitle");
	XCTAssertNil([valueAwareSubtitleSpecifier subtitle], @"Expected no default subtitle");
	XCTAssertEqualObjects([valueAwareSubtitleSpecifier subtitleForValue:@"YES"], @"with value aware subtitle (yes)", @"Failed to read the correct subtitle for the toggle 'YES' state");
	XCTAssertEqualObjects([valueAwareSubtitleSpecifier subtitleForValue:@"NO"], @"with value aware subtitle (no)", @"Failed to read the correct subtitle for the toggle 'NO' state");
	
	IASKSpecifier *valueAwareSubtitleAndDefaultSpecifier = [reader specifierForKey:@"fruit"];
	XCTAssertTrue([valueAwareSubtitleAndDefaultSpecifier hasSubtitle], @"Expected a subtitle");
	XCTAssertEqualObjects([valueAwareSubtitleAndDefaultSpecifier subtitle], @"Some fruit", @"Failed to read the correct default subtitle for no value");
	XCTAssertEqualObjects([valueAwareSubtitleAndDefaultSpecifier subtitleForValue:@"UNKNOWN"], @"Some fruit", @"Failed to read the correct default subtitle for an unspecified value");
	XCTAssertEqualObjects([valueAwareSubtitleAndDefaultSpecifier subtitleForValue:@"Banana"], @"Yellow fruit", @"Failed to read the correct default subtitle for a specified value");
}

- (void) testSettingsReaderFailsToSortMalformedMultiValueEntries {
	XCTAssertThrows([[IASKSettingsReader alloc] initWithFile:@"Malformed"
													  bundle:[NSBundle bundleForClass:self.class]]);
}

#pragma mark - parsing
- (void) testSettingsReaderInterpretsAdvancedSettings {
	IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithFile:@"Advanced"
																   bundle:[NSBundle bundleForClass:[self class]]];
	XCTAssertEqual(reader.numberOfSections, 4,
				   @"Failed to read correct number of sections");
	XCTAssertEqual([reader numberOfRowsInSection:0], 1,
				   @"Failed to read correct number of rows");
	XCTAssertEqual([reader numberOfRowsInSection:1], 1,
				   @"Failed to read correct number of rows");
	XCTAssertEqual([reader numberOfRowsInSection:2], 1,
				   @"Failed to read correct number of rows");
	XCTAssertEqual([reader numberOfRowsInSection:3], 3,
				   @"Failed to read correct number of rows");
}

#pragma mark - hidden keys
- (void) testSettingsReaderHidesHiddenKeys {
	IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithFile:@"Advanced"
																   bundle:[NSBundle bundleForClass:[self class]]];
	[reader setHiddenKeys:[NSSet setWithObjects:@"AutoConnectLogin", @"AutoConnectPassword", nil]];
	XCTAssertEqual([reader numberOfRowsInSection:3], 1, @"Wrong number of rows. Key not hidden");
}

- (void) testSettingsReaderShowsHiddenKeys {
	IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithFile:@"Advanced"
																   bundle:[NSBundle bundleForClass:[self class]]];
	[reader setHiddenKeys:[NSSet setWithObjects:@"AutoConnectLogin", nil]];
	[reader setHiddenKeys:nil];
	XCTAssertEqual([reader numberOfRowsInSection:3], 3, @"Wrong number of rows. Key not unhidden");
}

- (void) testSettingsReaderHidesGroupKeys {
	IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithFile:@"Advanced"
																   bundle:[NSBundle bundleForClass:[self class]]];
	[reader setHiddenKeys:[NSSet setWithObjects:@"AutoConnectLogin", @"AutoConnectPassword", @"AutoConnect", @"DynamicCellHidingGroup", nil]];
	XCTAssertEqual([reader numberOfSections], 3, @"Wrong number of rows. Key not hidden");
}


@end
