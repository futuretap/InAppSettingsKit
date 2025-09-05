//
//  IASKTextViewCell.m
//
//  Copyright (c) 2009-2020:
//  Luc Vandal, Edovia Inc., http://www.edovia.com
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//  All rights reserved.
//
//  It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz,
//  as the original authors of this code. You can give credit in a blog post, a tweet or on
//  a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

#import <UIKit/UIKit.h>

#import "IASKTextViewCell.h"
#import "IASKSettingsReader.h"
#import "IASKTextView.h"

@implementation IASKTextViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;

		IASKTextView *textView = [[IASKTextView alloc] initWithFrame:CGRectZero];
		textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		textView.scrollEnabled = NO;
		textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
		textView.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:textView];

		self.textView = textView;
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	UIEdgeInsets padding = self.layoutMargins;
	padding.left -= self.textView.textContainer.lineFragmentPadding;
	padding.right -= self.textView.textContainer.lineFragmentPadding;
	padding.top -= self.textView.textContainer.lineFragmentPadding;
	padding.bottom -= self.textView.textContainer.lineFragmentPadding;
	
	self.textView.frame = UIEdgeInsetsInsetRect(self.bounds, padding);
}

@end
