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
		self.datePicker = [[IASKDatePicker alloc] init];

		self.contentView.preservesSuperviewLayoutMargins = YES;
		[self.contentView addSubview:self.datePicker];

		NSMutableDictionary *views = @{@"picker": self.datePicker}.mutableCopy;
		if (self.textLabel) {
			views[@"label"] = self.textLabel;
		}
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[label]-(>=16)-[picker(50@100)]-|" options:0 metrics:nil views:views]];
		[self.textLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
		[self.datePicker setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[picker]-4-|" options:0 metrics:nil views:@{@"picker": self.datePicker}]];
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[label]-4-|" options:0 metrics:nil views:views]];
		self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
		self.datePicker.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return self;
}

@end
