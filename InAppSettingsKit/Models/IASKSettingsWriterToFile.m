//
//  IASKSettingsWriterToFile.m
//  Porthole
//
//  Created by Marc-Etienne M.Léveillé on 10-11-04.
//  Copyright 2010 Edovia. All rights reserved.
//

#import "IASKSettingsWriterToFile.h"


@implementation IASKSettingsWriterToFile

- (id)initWithPath:(NSString*)path {
    if([super init]) {
        _filePath = [path retain];
        _dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        if(_dict == nil) {
            _dict = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)dealloc {
    [_dict release];
    [_filePath release];
    [super dealloc];
}


- (void)setObject:(id)value forKey:(NSString *)key {
    [_dict setObject:value forKey:key];
}

- (id)objectForKey:(NSString *)key {
    return [_dict objectForKey:key];
}

- (BOOL)synchronize {
    return [_dict writeToFile:_filePath atomically:YES];
}

@end
