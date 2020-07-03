//
//  IASKEmbeddedDatePickerViewCell.m
//  InAppSettingsKit
//
//  Created by Ortwin Gentz on 02.07.20.
//  Copyright © 2020 InAppSettingsKit. All rights reserved.
//

#import "IASKEmbeddedDatePickerViewCell.h"
#import "IASKDatePicker.h"

@implementation IASKEmbeddedDatePickerViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.titleLabel = [[UILabel alloc] init];
		self.datePicker = [[IASKDatePicker alloc] init];

		self.contentView.preservesSuperviewLayoutMargins = YES;
		[self.contentView addSubview:self.titleLabel];
		[self.contentView addSubview:self.datePicker];
		[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeadingMargin multiplier:1.0 constant:0].active = YES;
		[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.datePicker attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10].active = YES;
		[NSLayoutConstraint constraintWithItem:self.datePicker attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailingMargin multiplier:1.0 constant:0].active = YES;

		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[picker]-4-|" options:0 metrics:nil views:@{@"picker": self.datePicker}]];
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[label]-4-|" options:0 metrics:nil views:@{@"label": self.titleLabel}]];
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
		self.datePicker.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return self;
}

@end
