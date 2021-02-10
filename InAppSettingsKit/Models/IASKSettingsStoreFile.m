//
//  IASKSettingsStoreFile.m
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

#import "IASKSettingsStoreFile.h"

@interface IASKSettingsStoreFile()
@property (nonatomic, strong) NSMutableDictionary *dict;
@property (nonatomic, copy, readwrite) NSString* filePath;
@end

@implementation IASKSettingsStoreFile

- (id)initWithPath:(NSString*)path {
    if((self = [super init])) {
		self.filePath = path;
		self.dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
		if (!self.dict) {
			self.dict = NSMutableDictionary.dictionary;
        }
    }
    return self;
}

- (void)setObject:(id)value forKey:(NSString *)key {
	[self.dict setObject:value forKey:key];
}

- (id)objectForKey:(NSString *)key {
	return [self.dict objectForKey:key];
}

- (BOOL)synchronize {
	return [self.dict writeToFile:self.filePath atomically:YES];
}

@end
