//
//  IASKTextView.m
//
//  Copyright (c) 2009-2015:
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

#import "IASKTextView.h"
#import "IASKColor.h"
#import "IASKSpecifier.h"


@implementation IASKTextView {
	BOOL _shouldDrawPlaceholder;
}


#pragma mark NSObject

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}


#pragma mark UIView

- (void)configure {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateShouldDrawPlaceholder) name:UITextViewTextDidChangeNotification object:self];
	
	_shouldDrawPlaceholder = NO;
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self configure];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self configure];
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	if (_shouldDrawPlaceholder && self.font) {
		[_placeholder drawAtPoint:CGPointMake(5.0, 8.0) withAttributes:@{NSFontAttributeName: (UIFont *)self.font, NSForegroundColorAttributeName: IASKColor.iaskPlaceholderColor}];
	}
}


#pragma mark Setters

- (void)setText:(NSString *)string {
	[super setText:string];
	[self updateShouldDrawPlaceholder];
}


- (void)setPlaceholder:(NSString *)string {
	if ([string isEqual:_placeholder]) {
		return;
	}
	
	_placeholder = string;
	
	self.accessibilityLabel = self.placeholder;
	[self updateShouldDrawPlaceholder];
}

- (void)setFrame:(CGRect)frame {
	super.frame = frame;
	[self setNeedsDisplay];
}

#pragma mark Private Methods

- (void)updateShouldDrawPlaceholder {
	BOOL prev = _shouldDrawPlaceholder;
	_shouldDrawPlaceholder = self.placeholder && self.text.length == 0;
	
	if (prev != _shouldDrawPlaceholder) {
		[self setNeedsDisplay];
	}
}

@end
