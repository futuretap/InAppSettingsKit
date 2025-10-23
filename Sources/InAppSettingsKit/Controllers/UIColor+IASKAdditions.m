//
//  UIColor+IASKAdditions.m
//  InAppSettingsKit
//
//  Created by Ortwin Gentz on 2025-10-23.
//  Copyright 2025 FutureTap. All rights reserved.
//

#import "UIColor+IASKAdditions.h"

@implementation UIColor(IASKAdditions)

// Returns a UIColor for an RGBA string

+ (UIColor* _Nullable)iaskColorWithHexString:(NSString *)stringToConvert {
	if (![stringToConvert isKindOfClass:NSString.class] || stringToConvert.length != 8) return nil;
	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
	unsigned hex;
	if (![scanner scanHexInt:&hex] || stringToConvert.length != 8) return nil;

	int r = (hex >> 24) & 0xFF;
	int g = (hex >> 16) & 0xFF;
	int b = (hex >> 8) & 0xFF;
	int a = (hex) & 0xFF;
	
	return [UIColor colorWithRed:r / 255.0f
						   green:g / 255.0f
							blue:b / 255.0f
						   alpha:a / 255.0f];
}

@end
