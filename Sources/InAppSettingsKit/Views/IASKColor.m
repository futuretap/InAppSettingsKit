//
//  IASKColor.m
//  InAppSettingsKit
//
//  Created by valvoline on 17/09/2019.
//  Copyright (c) 2019-2020:
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
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
