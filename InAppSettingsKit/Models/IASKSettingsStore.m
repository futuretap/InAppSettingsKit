//
//  IASKSettingsStore.m
//  http://www.inappsettingskit.com
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

@implementation IASKAbstractSettingsStore

- (void)setObject:(id)value forKey:(NSString*)key {
	@throw [NSException exceptionWithName:NSGenericException reason:@"setObject:forKey: must be implemented in subclasses of IASKAbstractSettingsStore" userInfo:nil];
}

- (id)objectForKey:(NSString*)key {
	@throw [NSException exceptionWithName:NSGenericException reason:@"objectForKey: must be implemented in subclasses of IASKAbstractSettingsStore" userInfo:nil];
}

- (void)setObject:(id)value forSpecifier:(IASKSpecifier*)specifier {
	if (specifier.parentSpecifier) {
		if (specifier.isAddSpecifier) {
			[self addObject:value forSpecifier:specifier];
			return;
		}
		NSMutableArray *array = ([self arrayForSpecifier:specifier.parentSpecifier] ?: @[]).mutableCopy;
		if (array.count <= specifier.itemIndex) {
			return;
		}
		NSObject *object = [array[specifier.itemIndex] mutableCopy];
		if ([value isKindOfClass:NSDictionary.class] || ![object isKindOfClass:NSDictionary.class]) {
			object = value;
		} else {
			[object setValue:value forKey:specifier.key];
		}
		array[specifier.itemIndex] = object;
		[self setObject:array forSpecifier:specifier.parentSpecifier];
		return;
	}
	[self setObject:value forKey:specifier.key];
}

- (id)objectForSpecifier:(IASKSpecifier*)specifier {
	if (specifier.parentSpecifier) {
		NSArray *array = [self arrayForSpecifier:specifier.parentSpecifier] ?: @[];
		if (array.count <= specifier.itemIndex) {
			return nil;
		}
		NSDictionary *value = array[specifier.itemIndex];
		return [value isKindOfClass:NSDictionary.class] && specifier.key ? value[specifier.key] : value;
	}

	return [self objectForKey:specifier.key];
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

- (NSArray *)arrayForSpecifier:(IASKSpecifier*)specifier {
	NSArray *array = [self objectForSpecifier:specifier];
	return [array isKindOfClass:NSArray.class] ? array : nil;
}

- (void)addObject:(NSObject*)object forSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.parentSpecifier.type isEqualToString:kIASKListGroupSpecifier]) {
		NSMutableArray *array = [NSMutableArray arrayWithArray:[self objectForSpecifier:specifier.parentSpecifier]];
		[array addObject:object];
		[self setArray:array forSpecifier:specifier.parentSpecifier];
	}
}

- (void)removeObjectWithSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.parentSpecifier.type isEqualToString:kIASKListGroupSpecifier]) {
		NSMutableArray *array = [NSMutableArray arrayWithArray:[self objectForSpecifier:specifier.parentSpecifier]];
		[array removeObjectAtIndex:specifier.itemIndex];
		[self setArray:array forSpecifier:specifier.parentSpecifier];
	}
}

- (BOOL)synchronize {
    return NO;
}

@end
