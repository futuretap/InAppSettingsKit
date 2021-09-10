//
//  IASKSettingsStoreInMemory.h
//  InAppSettingsKit
//
//  Created by Costantino Pistagna on 24/04/2020.
//  Copyright (c) 2009-2020:
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//

#import <Foundation/Foundation.h>

#import "IASKSettingsStore.h"

NS_ASSUME_NONNULL_BEGIN

/** implementation of IASKSettingsStore that uses InMemory NSDictionary
*/
@interface IASKSettingsStoreInMemory : IASKAbstractSettingsStore

@property (nonatomic, strong, readwrite) NSMutableDictionary* dictionary;

///designated initializer
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
