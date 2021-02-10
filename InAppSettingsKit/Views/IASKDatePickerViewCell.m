//
//  IASKDatePickerViewCell.m
//  InAppSettingsKit
//
//  Created by Ortwin Gentz on 04.05.20.
//  Copyright (c) 2009-2020:
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//

#import "IASKDatePickerViewCell.h"
#import "IASKDatePicker.h"

@implementation IASKDatePickerViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.datePicker = [[IASKDatePicker alloc] init];
		[self.contentView addSubview:self.datePicker];
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[picker]-0-|" options:0 metrics:nil views:@{@"picker": self.datePicker}]];
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[picker]-0-|" options:0 metrics:nil views:@{@"picker": self.datePicker}]];
		self.datePicker.translatesAutoresizingMaskIntoConstraints = NO;
	}
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	self.datePicker.frame = self.bounds;
}

@end
