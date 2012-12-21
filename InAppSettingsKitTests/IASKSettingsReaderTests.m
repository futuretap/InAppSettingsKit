//
//  IASKSettingsReaderTests.m
//  InAppSettingsKit
//
//  Created by Stephan Diederich on 19.12.12.
//  Copyright (c) 2012 InAppSettingsKit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "IASKSettingsReader.h"

@interface IASKSettingsReaderTests : SenTestCase {
  NSString* settingsBundlePath;
}
@end


@implementation IASKSettingsReaderTests
- (void)setUp {
  [super setUp];
  
  settingsBundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Settings.bundle/Root.plist" ofType:nil];
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

- (void) testDesignatedInitializerSetsBundle {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Root"
                                                                   applicationBundle:[NSBundle bundleForClass:[self class]]];

  STAssertEqualObjects(reader.applicationBundle, [NSBundle bundleForClass:[self class]], @"Bundle not set");
}

- (void) testShorthandInitializerSetsMainBundle {
  IASKSettingsReader* reader = [[IASKSettingsReader alloc] initWithFile:@"Root"];
  STAssertEqualObjects(reader.applicationBundle, [NSBundle mainBundle], @"Bundle not set");
}

@end
