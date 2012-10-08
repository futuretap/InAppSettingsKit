//
//  Created by Jan Chaloupecky on 10/5/12.
//


#import "IASKSettingStoreMemory.h"


@implementation IASKSettingStoreMemory {

}
@synthesize existingMemorySettingStore = _existingMemorySettingStore;


- (id)initWithUserPrefArrayId:(NSString *)userPrefArrayId backendSettingStore:(id <IASKSettingsStore>)backendSettingStore {
    self = [super init];
    if (self) {
        _userPrefArrayId = [userPrefArrayId copy];
        _backendSettingStore = [backendSettingStore retain];
        _newMemorySettingStoreDict = [[NSMutableDictionary alloc] init];
    }

    return self;
}

+ (id)objectWithUserPrefArrayId:(NSString *)userPrefArrayId backendSettingStore:(id <IASKSettingsStore>)backendSettingStore {
    return [[[IASKSettingStoreMemory alloc] initWithUserPrefArrayId:userPrefArrayId backendSettingStore:backendSettingStore] autorelease];
}

- (void)dealloc {
    [_backendSettingStore release]; _backendSettingStore = nil;
    [_userPrefArrayId release]; _userPrefArrayId = nil;
    [_newMemorySettingStoreDict release]; _newMemorySettingStoreDict = nil;
    [_existingMemorySettingStore release]; _existingMemorySettingStore = nil;
    [super dealloc];
}



// set the new values to a new dict
- (void)setObject:(id)value forKey:(NSString*)key {
    [_newMemorySettingStoreDict setObject:value forKey:key];
}

// read the values from the old one
- (id)objectForKey:(NSString*)key {
    return [_newMemorySettingStoreDict objectForKey:key];
}


- (void)setExistingMemorySettingStore:(NSDictionary *)existingMemorySettingStore {
    if (_existingMemorySettingStore != existingMemorySettingStore) {
        [existingMemorySettingStore retain];
        [_existingMemorySettingStore release];
        _existingMemorySettingStore = existingMemorySettingStore;

        // we copy the values to our R/W dict

        [_newMemorySettingStoreDict release];
        _newMemorySettingStoreDict = [_existingMemorySettingStore mutableCopy];
    }
}


- (BOOL)synchronize {

    NSArray * _backEndArray = [_backendSettingStore objectForKey:_userPrefArrayId];

    if (!_backEndArray) {
        _backEndArray = [[NSArray alloc] init];
        [_backEndArray autorelease];
    }

    NSAssert([_backEndArray isKindOfClass:[NSArray class]], @"Backend store object for key %@ must be an NSArray", _userPrefArrayId);



    NSMutableArray * mutableArray = [_backEndArray mutableCopy];


    NSUInteger idx  =  NSNotFound;
    // if already exist, remove old dict from array
    if (_existingMemorySettingStore) {
        // this is why we need the exact object that was being edited. The object must be the same so that we can remove it.
        idx = [mutableArray indexOfObject:_existingMemorySettingStore];
    }

    if(idx != NSNotFound) {
        [mutableArray removeObject:_existingMemorySettingStore];
        [mutableArray insertObject:_newMemorySettingStoreDict atIndex:idx];

    } else{
        // add the new one
        [mutableArray addObject:_newMemorySettingStoreDict];
    }







    // todo publish key changed

    [_backendSettingStore setObject:mutableArray forKey:_userPrefArrayId];

    [mutableArray release];


    return [_backendSettingStore synchronize];

}





@end