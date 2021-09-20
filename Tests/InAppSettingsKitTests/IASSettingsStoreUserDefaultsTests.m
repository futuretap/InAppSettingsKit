//
//  IASSettingsStoreUserDefaultsTests.m
//  IASSettingsStoreUserDefaultsTests
//
//  Created by Stephan Diederich on 19.12.12.
//  Copyright (c) 2012-2020:
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//

#import <XCTest/XCTest.h>
#import "IASKSettingsStoreUserDefaults.h"

@interface IASSettingsStoreUserDefaultsTests : XCTestCase

@end

@implementation IASSettingsStoreUserDefaultsTests

- (void)setUp {
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testStoreSetsCustomDefaults {
    id myObject = [NSObject new];
    IASKSettingsStoreUserDefaults* store = [[IASKSettingsStoreUserDefaults alloc] initWithUserDefaults:myObject];
    XCTAssertEqualObjects(myObject, store.defaults, @"custom defaults not stored");
}

- (void)testStoreUsesStandardDefaults {
    IASKSettingsStoreUserDefaults* store = [[IASKSettingsStoreUserDefaults alloc] init];
    XCTAssertEqualObjects([NSUserDefaults standardUserDefaults], store.defaults, @"custom defaults not stored");
}

@end
