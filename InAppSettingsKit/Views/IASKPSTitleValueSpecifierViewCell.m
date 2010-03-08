//
//  IASKPSTitleValueSpecifierViewCell.m
//  InAppSettingsKitSampleApp
//
//  Created by Ortwin Gentz on 04.03.10.
//  Copyright 2010 FutureTap. All rights reserved.
//

#import "IASKPSTitleValueSpecifierViewCell.h"
#import "IASKSettingsReader.h"


@implementation IASKPSTitleValueSpecifierViewCell

- (void)layoutSubviews {
	// left align the value if the title is empty
	if (!self.textLabel.text.length) {
		self.textLabel.text = self.detailTextLabel.text;
		self.detailTextLabel.text = nil;
		if ([self.reuseIdentifier isEqualToString:kIASKPSMultiValueSpecifier]) {
			self.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
			self.textLabel.textColor = self.detailTextLabel.textColor;
		}
	}
	[super layoutSubviews];
	
	CGSize viewSize =  [self.textLabel superview].frame.size;
	
	// set the left title label frame
	CGFloat labelWidth = [self.textLabel sizeThatFits:CGSizeZero].width;
	labelWidth = MIN(labelWidth, viewSize.width - kIASKMinValueWidth - kIASKPaddingLeft - kIASKSpacing -kIASKPaddingRight);
	CGRect labelFrame = CGRectMake(kIASKPaddingLeft, 0, labelWidth, viewSize.height -2);
	self.textLabel.frame = labelFrame;
	
	// set the right value label frame
	if (self.detailTextLabel.text.length) {
		CGRect valueFrame = CGRectMake(kIASKPaddingLeft + labelWidth + kIASKSpacing,
									   0,
									   viewSize.width - (kIASKPaddingLeft + labelWidth + kIASKSpacing) - kIASKPaddingRight,
									   viewSize.height -2);
		self.detailTextLabel.frame = valueFrame;
	}
}

@end
