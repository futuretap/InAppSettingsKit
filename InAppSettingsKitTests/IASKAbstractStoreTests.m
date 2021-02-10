//
//  IASKAbstractStoreTests.m
//  InAppSettingsKit
//
//  Created by Stephan Diederich on 19.12.12.
//  Copyright (c) 2012-2020:
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//

#import <XCTest/XCTest.h>
#import "IASKSettingsStore.h"
#import "IASKSettingsReader.h"
#import "IASKSpecifier.h"

@interface CustomStore : IASKAbstractSettingsStore { }

@property (nonatomic, strong) id lastValue;
@property (nonatomic, strong) NSString* lastKey;

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
	IASKSpecifier *specifier = [[IASKSpecifier alloc] initWithSpecifier:@{kIASKKey: @"MyKey", kIASKType: @"PSTextFieldSpecifier"}];
    [store setBool:YES forSpecifier:specifier];
    
    XCTAssertEqualObjects(@"MyKey", store.lastKey, @"Key not used or set");
    XCTAssertEqualObjects([NSNumber numberWithBool:YES], store.lastValue, @"Value not set");
}

-(void)testAbstractStoreCallsSetObjectForFloat {
	IASKSpecifier *specifier = [[IASKSpecifier alloc] initWithSpecifier:@{kIASKKey: @"MyKey1", kIASKType: @"PSTextFieldSpecifier"}];
    [store setFloat:.12f forSpecifier:specifier];
    
    XCTAssertEqualObjects(@"MyKey1", store.lastKey, @"Key not used or set");
    XCTAssertEqualWithAccuracy(.12f, [store.lastValue floatValue], .001f, @"Value not set");
}

-(void)testAbstractStoreCallsSetObjectForInteger {
	IASKSpecifier *specifier = [[IASKSpecifier alloc] initWithSpecifier:@{kIASKKey: @"MyKey", kIASKType: @"PSTextFieldSpecifier"}];
    [store setInteger:23 forSpecifier:specifier];
    
    XCTAssertEqualObjects(@"MyKey", store.lastKey, @"Key not used or set");
    XCTAssertEqual(23, [store.lastValue integerValue], @"Value not set");
}

-(void)testAbstractStoreCallsSetObjectForDouble {
	IASKSpecifier *specifier = [[IASKSpecifier alloc] initWithSpecifier:@{kIASKKey: @"MyKey", kIASKType: @"PSTextFieldSpecifier"}];
	[store setDouble:23. forSpecifier:specifier];
    
    XCTAssertEqualObjects(@"MyKey", store.lastKey, @"Key not used or set");
    XCTAssertEqualWithAccuracy(23., [store.lastValue doubleValue], .001, @"Value not set");
}

-(void)testAbstractStoreCallsGetObjectForDouble {
    XCTAssertNil(store.lastKey, @"Should be nil");
	IASKSpecifier *specifier = [[IASKSpecifier alloc] initWithSpecifier:@{kIASKKey: @"MyKey", kIASKType: @"PSTextFieldSpecifier"}];
	[store doubleForSpecifier:specifier];
    XCTAssertEqual(store.lastKey, @"MyKey", @"objectforKey not called");
}

-(void)testAbstractStoreCallsGetObjectForFloat {
    XCTAssertNil(store.lastKey, @"Should be nil");
	IASKSpecifier *specifier = [[IASKSpecifier alloc] initWithSpecifier:@{kIASKKey: @"MyKey", kIASKType: @"PSTextFieldSpecifier"}];
	[store floatForSpecifier:specifier];
    XCTAssertEqual(store.lastKey, @"MyKey", @"objectforKey not called");
}
-(void)testAbstractStoreCallsGetObjectForInteger {
    XCTAssertNil(store.lastKey, @"Should be nil");
	IASKSpecifier *specifier = [[IASKSpecifier alloc] initWithSpecifier:@{kIASKKey: @"MyKey", kIASKType: @"PSTextFieldSpecifier"}];
	[store integerForSpecifier:specifier];
    XCTAssertEqual(store.lastKey, @"MyKey", @"objectforKey not called");
}
-(void)testAbstractStoreCallsGetObjectForBool {
    XCTAssertNil(store.lastKey, @"Should be nil");
	IASKSpecifier *specifier = [[IASKSpecifier alloc] initWithSpecifier:@{kIASKKey: @"MyKey", kIASKType: @"PSTextFieldSpecifier"}];
    [store boolForSpecifier:specifier];
    XCTAssertEqual(store.lastKey, @"MyKey", @"objectforKey not called");
}

@end
