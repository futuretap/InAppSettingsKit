//
//  IASKDatePickerViewCell.m
//  InAppSettingsKit
//
//  Created by Ortwin Gentz on 04.05.20.
//  Copyright © 2020 InAppSettingsKit. All rights reserved.
//

#import "IASKDatePickerViewCell.h"

@implementation IASKDatePickerViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.datePicker = [[IASKDatePicker alloc] init];
		[self.contentView addSubview:self.datePicker];
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[picker]-0-|" options:0 metrics:nil views:@{@"picker": self.datePicker}]];
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[picker]-0-|" options:0 metrics:nil views:@{@"picker": self.datePicker}]];
	}
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	self.datePicker.frame = self.bounds;
}

@end
