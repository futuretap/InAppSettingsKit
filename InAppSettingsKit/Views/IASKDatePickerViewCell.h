//
//  IASKDatePickerViewCell.h
//  InAppSettingsKit
//
//  Created by Ortwin Gentz on 04.05.20.
//  Copyright (c) 2009-2020:
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//

#import <UIKit/UIKit.h>
#import "IASKDatePicker.h"

@interface IASKDatePickerViewCell : UITableViewCell
@property (nonatomic, nonnull) IASKDatePicker *datePicker;
@end
