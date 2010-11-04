//
//  IASKSettingsWriter.m
//  Porthole
//
//  Created by Marc-Etienne M.Léveillé on 10-11-04.
//  Copyright 2010 Edovia. All rights reserved.
//

#import "IASKSettingsWriter.h"

@implementation IASKAbstractSettingsWriter

- (void)setObject:(id)value forKey:(NSString*)key {
    [NSException raise:@"Unimplemented"
                format:@"setObject:forKey: must be implemented in subclasses of IASKAbstractSettingsWriter"];
}

- (id)objectForKey:(NSString*)key {
    [NSException raise:@"Unimplemented"
                format:@"objectForKey: must be implemented in subclasses of IASKAbstractSettingsWriter"];
    return nil;
}

- (void)setBool:(BOOL)value forKey:(NSString*)key {
    [self setObject:[NSNumber numberWithBool:value] forKey:key];
}

- (void)setFloat:(float)value forKey:(NSString*)key {
    [self setObject:[NSNumber numberWithFloat:value] forKey:key];
}

- (void)setInteger:(int)value forKey:(NSString*)key {
    [self setObject:[NSNumber numberWithInt:value] forKey:key];
}

- (void)setDouble:(double)value forKey:(NSString*)key {
    [self setObject:[NSNumber numberWithDouble:value] forKey:key];
}

- (BOOL)boolForKey:(NSString*)key {
    return [[self objectForKey:key] boolValue];
}

- (float)floatForKey:(NSString*)key {
    return [[self objectForKey:key] floatValue];
}
- (int)integerForKey:(NSString*)key {
    return [[self objectForKey:key] intValue];
}

- (double)doubleForKey:(NSString*)key {
    return [[self objectForKey:key] doubleValue];
}

- (BOOL)synchronize {
    return NO;
}

@end