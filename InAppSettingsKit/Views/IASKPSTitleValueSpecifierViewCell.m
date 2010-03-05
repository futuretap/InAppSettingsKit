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
	
	CGFloat viewWidth =  [self.textLabel superview].frame.size.width;
	
	// set the left title label frame
	CGFloat labelWidth = [self.textLabel sizeThatFits:CGSizeZero].width;
	labelWidth = MIN(labelWidth, viewWidth - kIASKMinValueWidth - kIASKPaddingLeft - kIASKSpacing -kIASKPaddingRight);
	CGRect labelFrame = self.textLabel.frame;
	labelFrame.origin.x = kIASKPaddingLeft;
	labelFrame.size.width = labelWidth;
	labelFrame.size.height -= 2;
	self.textLabel.frame = labelFrame;
	
	// set the right value label frame
	if (self.detailTextLabel.text.length) {
		CGRect valueFrame = self.detailTextLabel.frame;
		valueFrame.origin.x = kIASKPaddingLeft + labelWidth + kIASKSpacing;
		valueFrame.size.width = viewWidth - valueFrame.origin.x - kIASKPaddingRight;
		valueFrame.size.height -= 2;
		self.detailTextLabel.frame = valueFrame;
	}
}

@end
