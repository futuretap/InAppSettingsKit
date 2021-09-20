//
//  IASKSettingsStore.m
//
//  Copyright (c) 2010:
//  Luc Vandal, Edovia Inc., http://www.edovia.com
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//  Marc-Etienne M.Léveillé, Edovia Inc., http://www.edovia.com
//  All rights reserved.
// 
//  It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz, 
//  as the original authors of this code. You can give credit in a blog post, a tweet or on 
//  a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

#import "IASKSettingsStore.h"
#import "IASKSettingsReader.h"
#import "IASKSpecifier.h"

@implementation IASKAbstractSettingsStore

- (void)setObject:(id)value forKey:(NSString*)key {
	@throw [NSException exceptionWithName:NSGenericException reason:@"setObject:forKey: must be implemented in subclasses of IASKAbstractSettingsStore" userInfo:nil];
}

- (id)objectForKey:(NSString*)key {
	@throw [NSException exceptionWithName:NSGenericException reason:@"objectForKey: must be implemented in subclasses of IASKAbstractSettingsStore" userInfo:nil];
}

- (void)setObject:(id)value forSpecifier:(IASKSpecifier*)specifier {
	if (!value) {
		[self removeObjectWithSpecifier:specifier];
		return;
	}
	if (specifier.parentSpecifier) {
		if (specifier.isAddSpecifier) {
			[self addObject:value forSpecifier:specifier];
			return;
		}
		NSMutableArray *array = ([self arrayForSpecifier:(id)specifier.parentSpecifier] ?: @[]).mutableCopy;
		if (array.count <= specifier.itemIndex) {
			return;
		}
		NSObject *object = array[specifier.itemIndex];
		if (![value isKindOfClass:NSDictionary.class] && [object isKindOfClass:NSDictionary.class] && [object respondsToSelector:@selector(mutableCopy)]) {
			object = [object mutableCopy];
			[object setValue:value forKey:(id)specifier.key];
		} else {
			object = value;
		}
		array[specifier.itemIndex] = object;
		[self setObject:array forSpecifier:(id)specifier.parentSpecifier];
		return;
	}
	if (specifier.key) {
		[self setObject:value forKey:(id)specifier.key];
	}
}

- (id)objectForSpecifier:(IASKSpecifier*)specifier {
	if (specifier.parentSpecifier) {
		NSArray *array = [self arrayForSpecifier:(id)specifier.parentSpecifier] ?: @[];
		if (array.count <= specifier.itemIndex) {
			return nil;
		}
		NSDictionary *value = array[specifier.itemIndex];
		return specifier.key && [value valueForKey:(id)specifier.key] ? [value valueForKey:(id)specifier.key] : value;
	}

	return specifier.key ? [self objectForKey:(id)specifier.key] : nil;
}

- (void)setBool:(BOOL)value forSpecifier:(IASKSpecifier*)specifier {
    [self setObject:[NSNumber numberWithBool:value] forSpecifier:specifier];
}

- (void)setFloat:(float)value forSpecifier:(IASKSpecifier*)specifier {
    [self setObject:[NSNumber numberWithFloat:value] forSpecifier:specifier];
}

- (void)setInteger:(NSInteger)value forSpecifier:(IASKSpecifier*)specifier {
    [self setObject:[NSNumber numberWithInteger:value] forSpecifier:specifier];
}

- (void)setDouble:(double)value forSpecifier:(IASKSpecifier*)specifier {
    [self setObject:[NSNumber numberWithDouble:value] forSpecifier:specifier];
}

- (BOOL)boolForSpecifier:(IASKSpecifier*)specifier {
    return [[self objectForSpecifier:specifier] boolValue];
}

- (float)floatForSpecifier:(IASKSpecifier*)specifier {
    return [[self objectForSpecifier:specifier] floatValue];
}

- (NSInteger)integerForSpecifier:(IASKSpecifier*)specifier {
    return [[self objectForSpecifier:specifier] integerValue];
}

- (double)doubleForSpecifier:(IASKSpecifier*)specifier {
    return [[self objectForSpecifier:specifier] doubleValue];
}

- (void)setArray:(NSArray*)array forSpecifier:(IASKSpecifier*)specifier {
	[self setObject:array forSpecifier:specifier];
}

- (NSArray*)arrayForSpecifier:(IASKSpecifier*)specifier {
	NSArray *array = [self objectForSpecifier:specifier];
	return [array isKindOfClass:NSArray.class] ? array : @[];
}

- (void)addObject:(NSObject*)object forSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.parentSpecifier.type isEqualToString:kIASKListGroupSpecifier]) {
		NSMutableArray *array = [self arrayForSpecifier:(id)specifier.parentSpecifier].mutableCopy;
		[array addObject:object];
		[self setArray:array forSpecifier:(id)specifier.parentSpecifier];
	}
}

- (void)removeObjectWithSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.parentSpecifier.type isEqualToString:kIASKListGroupSpecifier]) {
		NSMutableArray *array = [self arrayForSpecifier:(id)specifier.parentSpecifier].mutableCopy;
		[array removeObjectAtIndex:specifier.itemIndex];
		[self setArray:array forSpecifier:(id)specifier.parentSpecifier];
	}
}

- (BOOL)synchronize {
    return NO;
}

@end
