//
//  IASKSettingsStore.h
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

#import <Foundation/Foundation.h>
@class IASKSpecifier;

NS_ASSUME_NONNULL_BEGIN

/** protocol that needs to be implemented from a settings store
 */
@protocol IASKSettingsStore <NSObject>
@required
- (void)setBool:(BOOL)value forSpecifier:(IASKSpecifier*)specifier;
- (void)setFloat:(float)value forSpecifier:(IASKSpecifier*)specifier;
- (void)setDouble:(double)value forSpecifier:(IASKSpecifier*)specifier;
- (void)setInteger:(NSInteger)value forSpecifier:(IASKSpecifier*)specifier;
- (void)setObject:(nullable id)value forSpecifier:(IASKSpecifier*)specifier;
- (BOOL)boolForSpecifier:(IASKSpecifier*)specifier;
- (float)floatForSpecifier:(IASKSpecifier*)specifier;
- (double)doubleForSpecifier:(IASKSpecifier*)specifier;
- (NSInteger)integerForSpecifier:(IASKSpecifier*)specifier;
- (nullable id)objectForSpecifier:(IASKSpecifier*)specifier;
- (BOOL)synchronize; // Write settings to a permanant storage. Returns YES on success, NO otherwise
- (void)setArray:(NSArray*)array forSpecifier:(IASKSpecifier*)specifier;
- (NSArray*)arrayForSpecifier:(IASKSpecifier*)specifier;
- (void)addObject:(NSObject*)object forSpecifier:(IASKSpecifier*)specifier;
- (void)removeObjectWithSpecifier:(IASKSpecifier*)specifier;
@optional
- (void)setObject:(id)value forKey:(NSString*)key;
- (nullable id)objectForKey:(NSString*)key;
@end


/** default implementation of the IASKSettingsStore protocol

 Subclassing notes:
 To implement your own store, either implement the @optional methods setObject:forKey: and objectForKey: (without calling super) or implement all @required methods (without calling super or the @optional methods).
 
 IASKAbstractSettingsStore implements all @required methods by calling objectForKey: and setObject:forKey:. However, objectForKey: and setObject:forKey: itself are not implemented and raise an exception.
 */
@interface IASKAbstractSettingsStore : NSObject <IASKSettingsStore>

@end

NS_ASSUME_NONNULL_END
