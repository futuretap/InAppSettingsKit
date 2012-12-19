//
//  IASSettingsStoreUserDefaultsTests.m
//  IASSettingsStoreUserDefaultsTests
//
//  Created by Stephan Diederich on 19.12.12.
//  Copyright (c) 2012 InAppSettingsKit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "IASKSettingsStoreUserDefaults.h"

@interface IASSettingsStoreUserDefaultsTests : SenTestCase

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
    STAssertEqualObjects(myObject, store.defaults, @"custom defaults not stored");
}

- (void)testStoreUsesStandardDefaults {
    IASKSettingsStoreUserDefaults* store = [[IASKSettingsStoreUserDefaults alloc] init];
    STAssertEqualObjects([NSUserDefaults standardUserDefaults], store.defaults, @"custom defaults not stored");
}

@end
