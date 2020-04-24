//
//  IASKSettingsStoreInMemory.h
//  InAppSettingsKit
//
//  Created by Costantino Pistagna on 24/04/2020.
//  Copyright © 2020 InAppSettingsKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <InAppSettingsKit/IASKSettingsStore.h>


/** implementation of IASKSettingsStore that uses InMemory NSDictionary
*/
@interface IASKSettingsStoreInMemory : NSObject<IASKSettingsStore>

///designated initializer
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
