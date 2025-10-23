//
//  UIColor+IASKAdditions.h
//  InAppSettingsKit
//
//  Created by Ortwin Gentz on 2025-10-23.
//  Copyright 2025 FutureTap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor(IASKAdditions)
+ (nullable UIColor*)iaskColorWithHexString:(nullable NSString *)stringToConvert;
@end
