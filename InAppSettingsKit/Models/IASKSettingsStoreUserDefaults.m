//
//  IASKSettingsStoreUserDefaults.m
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

#import "IASKSettingsStoreUserDefaults.h"

@interface IASKSettingsStoreUserDefaults ()

@property (nonatomic, strong, readwrite) NSUserDefaults* defaults;

@end

@implementation IASKSettingsStoreUserDefaults

- (id)initWithUserDefaults:(NSUserDefaults *)defaults {
    self = [super init];
    if( self ) {
        _defaults = defaults;
    }
    return self;
}

- (id)init {
    return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (void)setObject:(id)value forKey:(NSString*)key {
	[self.defaults setObject:value forKey:key];
}

- (id)objectForKey:(NSString*)key {
	return [self.defaults objectForKey:key];
}

- (BOOL)synchronize {
    return [self.defaults synchronize];
}

@end
