//
//  IASKDatePicker.h
//  InAppSettingsKit
//
//  Created by Ortwin Gentz on 04.05.20.
//  Copyright (c) 2009-2020:
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//

#import <UIKit/UIKit.h>
@class IASKSpecifier;

@interface IASKDatePicker : UIDatePicker
@property (strong, nonatomic, nonnull) IASKSpecifier *specifier;
@property (nonatomic, getter=isEditing) BOOL editing;
@end

