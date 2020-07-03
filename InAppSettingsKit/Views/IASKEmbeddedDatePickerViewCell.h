//
//  IASKEmbeddedDatePickerViewCell.h
//  InAppSettingsKit
//
//  Created by Ortwin Gentz on 02.07.20.
//  Copyright © 2020 InAppSettingsKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IASKDatePickerViewCell.h"

@interface IASKEmbeddedDatePickerViewCell : UITableViewCell
@property (nonatomic, nonnull) UILabel *titleLabel;
@property (nonatomic, nonnull) IASKDatePicker *datePicker;
@end
