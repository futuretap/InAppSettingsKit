//
//  Created by Jan Chaloupecky on 10/5/12.
//


#import <Foundation/Foundation.h>
#import "IASKSettingsStore.h"


@interface IASKSettingStoreMemory : IASKAbstractSettingsStore {

    NSMutableDictionary *_newMemorySettingStoreDict;

    NSString * _userPrefArrayId;

}


@property (nonatomic, retain) id<IASKSettingsStore> backendSettingStore;
@property(nonatomic, retain) NSDictionary *existingMemorySettingStore;


- (id)initWithUserPrefArrayId:(NSString *)userPrefArrayId backendSettingStore:(id <IASKSettingsStore>)backendSettingStore;

+ (id)objectWithUserPrefArrayId:(NSString *)userPrefArrayId backendSettingStore:(id <IASKSettingsStore>)backendSettingStore;


@end