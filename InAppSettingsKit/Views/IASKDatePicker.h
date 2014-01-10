//
//  IASKDatePicker.h
//  InAppSettingsKit
//
//  Created by Danny Shmueli on 1/10/14.
//  Copyright (c) 2014 InAppSettingsKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IASKDatePicker : UIDatePicker

@property (nonatomic, strong) NSIndexPath *inIndexPath;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly) NSString *formattedDate;

@end
