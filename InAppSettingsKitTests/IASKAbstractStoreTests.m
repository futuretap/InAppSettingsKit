//
//  IASKAbstractStoreTests.m
//  InAppSettingsKit
//
//  Created by Stephan Diederich on 19.12.12.
//  Copyright (c) 2012 InAppSettingsKit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
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


@interface IASKAbstractStoreTests : SenTestCase {
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
    
    STAssertEqualObjects(@"MyKey", store.lastKey, @"Key not used or set");
    STAssertEqualObjects([NSNumber numberWithBool:YES], store.lastValue, @"Value not set");
}

-(void)testAbstractStoreCallsSetObjectForFloat {
    [store setFloat:.12f forKey:@"MyKey1"];
    
    STAssertEqualObjects(@"MyKey1", store.lastKey, @"Key not used or set");
    STAssertEqualsWithAccuracy(.12f, [store.lastValue floatValue], .001f, @"Value not set");
}

-(void)testAbstractStoreCallsSetObjectForInteger {
    [store setInteger:23 forKey:@"MyKey"];
    
    STAssertEqualObjects(@"MyKey", store.lastKey, @"Key not used or set");
    STAssertEquals(23, [store.lastValue integerValue], @"Value not set");
}

-(void)testAbstractStoreCallsSetObjectForDouble {
    [store setDouble:23. forKey:@"MyKey"];
    
    STAssertEqualObjects(@"MyKey", store.lastKey, @"Key not used or set");
    STAssertEqualsWithAccuracy(23., [store.lastValue doubleValue], .001, @"Value not set");
}

-(void)testAbstractStoreCallsGetObjectForDouble {
    STAssertNil(store.lastKey, @"Should be nil");
    [store doubleForKey:@"MyKey"];
    STAssertEquals(store.lastKey, @"MyKey", @"objectforKey not called");
}

-(void)testAbstractStoreCallsGetObjectForFloat {
    STAssertNil(store.lastKey, @"Should be nil");
    [store floatForKey:@"MyKey"];
    STAssertEquals(store.lastKey, @"MyKey", @"objectforKey not called");
}
-(void)testAbstractStoreCallsGetObjectForInteger {
    STAssertNil(store.lastKey, @"Should be nil");
    [store integerForKey:@"MyKey"];
    STAssertEquals(store.lastKey, @"MyKey", @"objectforKey not called");
}
-(void)testAbstractStoreCallsGetObjectForBool {
    STAssertNil(store.lastKey, @"Should be nil");
    [store boolForKey:@"MyKey"];
    STAssertEquals(store.lastKey, @"MyKey", @"objectforKey not called");
}

@end
