//
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
//  IASKSettingsStoreiCloud.m
//  Copyright (c) 2012:
//  Mark Rickert, Mohawk Apps, LLC., http://www.mohawkapps.com
//  All rights reserved.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

#import "IASKSettingsStoreiCloud.h"

@interface IASKSettingsStoreiCloud ()
-(BOOL) iCloudEnabled;
@end

@implementation IASKSettingsStoreiCloud

- (void)setBool:(BOOL)value forKey:(NSString*)key {
    if([self iCloudEnabled])
        [[NSUbiquitousKeyValueStore defaultStore] setBool:value forKey:key];

    [super setBool:value forKey:key];
}

- (void)setFloat:(float)value forKey:(NSString*)key {
    if([self iCloudEnabled])
        [[NSUbiquitousKeyValueStore defaultStore] setObject:[NSNumber numberWithFloat:value] forKey:key];

    [super setFloat:value forKey:key];
}

- (void)setDouble:(double)value forKey:(NSString*)key {
    if([self iCloudEnabled])
        [[NSUbiquitousKeyValueStore defaultStore] setDouble:value forKey:key];

    [super setDouble:value forKey:key];
}

- (void)setInteger:(int)value forKey:(NSString*)key {
    if([self iCloudEnabled])
        [[NSUbiquitousKeyValueStore defaultStore] setObject:[NSNumber numberWithInt:value] forKey:key];

    [super setInteger:value forKey:key];
}

- (void)setObject:(id)value forKey:(NSString*)key {
    if([self iCloudEnabled])
        [[NSUbiquitousKeyValueStore defaultStore] setObject:value forKey:key];

    [super setObject:value forKey:key];
}

- (BOOL)boolForKey:(NSString*)key {
    if([self iCloudEnabled])
        return [[NSUbiquitousKeyValueStore defaultStore] boolForKey:key];
    else
        return [super boolForKey:key];
}

- (float)floatForKey:(NSString*)key {
    if([self iCloudEnabled])
        return [[[NSUbiquitousKeyValueStore defaultStore] objectForKey:key] floatValue];
    else 
        return [super floatForKey:key];
}

- (double)doubleForKey:(NSString*)key {
    if([self iCloudEnabled])
        return [[NSUbiquitousKeyValueStore defaultStore] doubleForKey:key];
    else
        return [super doubleForKey:key];
}

- (int)integerForKey:(NSString*)key {
    if([self iCloudEnabled])
        return [[[NSUbiquitousKeyValueStore defaultStore] objectForKey:key] intValue];
    else
        return [super integerForKey:key];
}

- (id)objectForKey:(NSString*)key {
    if([self iCloudEnabled])
        return [[NSUbiquitousKeyValueStore defaultStore] objectForKey:key];
    else
        return [super objectForKey:key];
}

- (BOOL)synchronize {
    BOOL synchronized;
    
    if([self iCloudEnabled])
        synchronized = [[NSUbiquitousKeyValueStore defaultStore] synchronize];
        
    synchronized = [super synchronize];

    return synchronized;
}

-(BOOL) iCloudEnabled
{
    if(NSClassFromString(@"NSUbiquitousKeyValueStore")) { // is iOS 5?
        
        if([NSUbiquitousKeyValueStore defaultStore]) {  // is iCloud enabled
            return YES;
        }
    }
    return NO;
}

@end
