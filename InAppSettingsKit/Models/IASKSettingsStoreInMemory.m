//
//  IASKSettingsStoreInMemory.m
//  InAppSettingsKit
//
//  Created by Costantino Pistagna on 24/04/2020.
//  Copyright © 2020 InAppSettingsKit. All rights reserved.
//

#import "IASKSettingsStoreInMemory.h"

@interface IASKSettingsStoreInMemory ()

@property (nonatomic, retain, readwrite) NSMutableDictionary* dict;

@end

@implementation IASKSettingsStoreInMemory

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if( self ) {
		_dict = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    }
    return self;
}

- (void)setBool:(BOOL)value forKey:(NSString*)key {
	[_dict setValue:@(value) forKey:key];
}

- (void)setFloat:(float)value forKey:(NSString*)key {
	[_dict setValue:@(value) forKey:key];
}

- (void)setDouble:(double)value forKey:(NSString*)key {
	[_dict setValue:@(value) forKey:key];
}

- (void)setInteger:(NSInteger)value forKey:(NSString*)key {
	[_dict setValue:@(value) forKey:key];
}

- (void)setObject:(id)value forKey:(NSString*)key {
	[_dict setObject:value forKey:key];
}

- (BOOL)boolForKey:(NSString*)key {
	return [[_dict valueForKey:key] boolValue];
}

- (float)floatForKey:(NSString*)key {
	return [[_dict valueForKey:key] floatValue];
}

- (double)doubleForKey:(NSString*)key {
	return [[_dict valueForKey:key] doubleValue];
}

- (NSInteger)integerForKey:(NSString*)key {
	return [[_dict valueForKey:key] integerValue];
}

- (id)objectForKey:(NSString*)key {
	return [_dict objectForKey:key];
}

- (void)setObjects:(NSArray *)value forKey:(NSString*)key {
	[_dict setObject:value forKey:key];
}

- (NSArray *)objectsForKey:(NSString *)key {
	return [[_dict objectForKey:key] isKindOfClass:[NSArray class]] ? [_dict objectForKey:key] : nil;
}

- (BOOL)synchronize {
	return NO;
}

- (NSInteger)numberOfRowsForKeySpecifier:(NSString *)key {
	return 0;
}


@end
