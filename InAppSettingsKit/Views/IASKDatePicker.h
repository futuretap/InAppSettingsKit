//
//  IASKDatePicker.h
//  InAppSettingsKit
//
//  Created by Ortwin Gentz on 04.05.20.
//  Copyright © 2020 InAppSettingsKit. All rights reserved.
//

#import "IASKSpecifier.h"

@interface IASKDatePicker : UIDatePicker
@property (strong, nonatomic, nullable) IASKSpecifier *specifier;
@end

