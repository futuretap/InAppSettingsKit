//
//  IASKColor.m
//  InAppSettingsKit
//
//  Created by valvoline on 17/09/2019.
//  Copyright © 2019 InAppSettingsKit. All rights reserved.
//

#import "IASKColor.h"

@implementation IASKColor

+ (UIColor *)iaskPlaceholderColor {
	if (@available(iOS 13.0, *)) {
		return UIColor.placeholderTextColor;
	} else {
		return UIColor.systemGrayColor;
	}
}

@end
