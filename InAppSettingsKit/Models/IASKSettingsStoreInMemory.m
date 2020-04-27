//
//  IASKSettingsStoreInMemory.m
//  InAppSettingsKit
//
//  Created by Costantino Pistagna on 24/04/2020.
//  Copyright © 2020 InAppSettingsKit. All rights reserved.
//

#import "IASKSettingsStoreInMemory.h"

@implementation IASKSettingsStoreInMemory

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if ((self = [super init])) {
		self.dictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    }
    return self;
}

- (void)setObject:(id)value forKey:(NSString*)key {
    [self.dictionary setObject:value forKey:key];
}

- (id)objectForKey:(NSString*)key {
    return [self.dictionary objectForKey:key];
}

- (BOOL)synchronize {
	return NO;
}

@end
