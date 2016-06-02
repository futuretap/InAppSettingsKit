//
//  IASKAbstractStoreTests.m
//  InAppSettingsKit
//
//  Created by Stephan Diederich on 19.12.12.
//  Copyright (c) 2012 InAppSettingsKit. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IASKSettingsStore.h"

@interface CustomStore : IASKAbstractSettingsStore { }

@property (nonatomic, assign) id lastValue;
@property (nonatomic, assign) NSString* lastKey;

@end

@implementation CustomStore

- (void)setObject:(id)value forKey:(NSString *)key {
    self.lastKey = key;
    self.lastValue = value;
}

- (id)objectForKey:(NSString *)key {
    self.lastKey = key;
    return nil;
}

@end


@interface IASKAbstractStoreTests : XCTestCase {
    CustomStore* store;
}
@end


@implementation IASKAbstractStoreTests
- (void)setUp {
    [super setUp];
    
    store = [CustomStore new];
}

- (void)tearDown {
    store = nil;
    
    [super tearDown];
}

-(void)testAbstractStoreCallsSetObjectForBool {
    [store setBool:YES forKey:@"MyKey"];
    
    XCTAssertEqualObjects(@"MyKey", store.lastKey, @"Key not used or set");
    XCTAssertEqualObjects([NSNumber numberWithBool:YES], store.lastValue, @"Value not set");
}

-(void)testAbstractStoreCallsSetObjectForFloat {
    [store setFloat:.12f forKey:@"MyKey1"];
    
    XCTAssertEqualObjects(@"MyKey1", store.lastKey, @"Key not used or set");
    XCTAssertEqualWithAccuracy(.12f, [store.lastValue floatValue], .001f, @"Value not set");
}

-(void)testAbstractStoreCallsSetObjectForInteger {
    [store setInteger:23 forKey:@"MyKey"];
    
    XCTAssertEqualObjects(@"MyKey", store.lastKey, @"Key not used or set");
    XCTAssertEqual(23, [store.lastValue integerValue], @"Value not set");
}

-(void)testAbstractStoreCallsSetObjectForDouble {
    [store setDouble:23. forKey:@"MyKey"];
    
    XCTAssertEqualObjects(@"MyKey", store.lastKey, @"Key not used or set");
    XCTAssertEqualWithAccuracy(23., [store.lastValue doubleValue], .001, @"Value not set");
}

-(void)testAbstractStoreCallsGetObjectForDouble {
    XCTAssertNil(store.lastKey, @"Should be nil");
    [store doubleForKey:@"MyKey"];
    XCTAssertEqual(store.lastKey, @"MyKey", @"objectforKey not called");
}

-(void)testAbstractStoreCallsGetObjectForFloat {
    XCTAssertNil(store.lastKey, @"Should be nil");
    [store floatForKey:@"MyKey"];
    XCTAssertEqual(store.lastKey, @"MyKey", @"objectforKey not called");
}
-(void)testAbstractStoreCallsGetObjectForInteger {
    XCTAssertNil(store.lastKey, @"Should be nil");
    [store integerForKey:@"MyKey"];
    XCTAssertEqual(store.lastKey, @"MyKey", @"objectforKey not called");
}
-(void)testAbstractStoreCallsGetObjectForBool {
    XCTAssertNil(store.lastKey, @"Should be nil");
    [store boolForKey:@"MyKey"];
    XCTAssertEqual(store.lastKey, @"MyKey", @"objectforKey not called");
}

@end
