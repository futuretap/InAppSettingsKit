//
//  IASKDatePicker.m
//  InAppSettingsKit
//
//  Created by Danny Shmueli on 1/10/14.
//  Copyright (c) 2014 InAppSettingsKit. All rights reserved.
//

#import "IASKDatePicker.h"

@interface IASKDatePicker ()

@property (nonatomic, readonly) BOOL isLocalLanguageRTL;
@property (nonatomic, readonly) NSString *dateFormatAccordingToRTL;
@property (nonatomic, readonly) BOOL isDatePickerModeDateOnly;
@end


@implementation IASKDatePicker


-(NSString *)formattedDate
{
	if (!self.date)
		return @"";
    
    NSDateFormatter *dateFormatter = self.dateFormatter ? self.dateFormatter : [self makeDateFormatter];
    return [dateFormatter stringFromDate:self.date];
}

#pragma mark - Private Getters
-(BOOL)isLocalLanguageRTL
{
    return [NSLocale characterDirectionForLanguage:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]] == NSLocaleLanguageDirectionRightToLeft;
}

-(NSString *)dateFormatAccordingToRTL
{
    return self.isLocalLanguageRTL ? @"yy MMM dd" : @"MMM dd yy";
}

-(BOOL)isDatePickerModeDateOnly
{
    return self.datePickerMode == UIDatePickerModeDate;
}

#pragma mark Private Methods
-(NSDateFormatter *)makeDateFormatter
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = self.isDatePickerModeDateOnly ? self.dateFormatAccordingToRTL :  @"HH:mm";
    return dateFormatter;

}
@end
