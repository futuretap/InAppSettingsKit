//
//  IASKDatePicker.m
//  InAppSettingsKit
//
//  Created by Danny Shmueli on 1/10/14.
//  Copyright (c) 2014 InAppSettingsKit. All rights reserved.
//

#import "IASKDatePicker.h"

@implementation IASKDatePicker

-(NSString *)formattedDate
{
	if (!self.date)
		return @"";
    
	BOOL isDeviceLanguageRTL =[NSLocale characterDirectionForLanguage:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]] == NSLocaleLanguageDirectionRightToLeft;
    
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.locale = [NSLocale currentLocale];
    
    if (self.datePickerMode == UIDatePickerModeDate)
    {
        dateFormatter.dateFormat = isDeviceLanguageRTL ? @"yyyy MMMM dd" : @"MMMM dd yyyy";
    }
    else
    {
        dateFormatter.dateFormat = @"HH:mm";
    }
    return [dateFormatter stringFromDate:self.date];
}

@end
