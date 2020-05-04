//
//  IASKDatePickerViewCell.h
//  InAppSettingsKit
//
//  Created by Ortwin Gentz on 04.05.20.
//  Copyright © 2020 InAppSettingsKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IASKDatePicker.h"

@interface IASKDatePickerViewCell : UITableViewCell
@property (nonatomic, nonnull) IASKDatePicker *datePicker;
@end
