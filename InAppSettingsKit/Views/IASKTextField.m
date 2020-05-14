//
//  IASKTextField.m
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

#import "IASKTextField.h"
#import "IASKSpecifier.h"

@interface IASKTextField ()
@property (strong, nonatomic, nullable, readwrite) NSString *oldText;
@end

@implementation IASKTextField

- (void)setSpecifier:(IASKSpecifier *)specifier {
	_specifier = specifier;
	self.secureTextEntry = specifier.isSecure;
	self.keyboardType = specifier.keyboardType;
	self.autocapitalizationType = specifier.autocapitalizationType;
	self.autocorrectionType = specifier.isSecure ? UITextAutocorrectionTypeNo : specifier.autoCorrectionType;
	self.textAlignment = specifier.textAlignment;
	self.placeholder = specifier.placeholder;
	self.adjustsFontSizeToFitWidth = specifier.adjustsFontSizeToFitWidth;
	if (specifier.isAddSpecifier) {
		self.returnKeyType = UIReturnKeyDone;
	}
	if (@available(iOS 10.0, *)) {
		self.textContentType = specifier.textContentType;
	}
}

- (BOOL)becomeFirstResponder {
	BOOL result = [super becomeFirstResponder];
	if (result) {
		self.oldText = self.text;
	}
	return result;
}

- (void)shake {
	self.transform = CGAffineTransformMakeTranslation(20.f, 0.f);
	[UIView animateWithDuration:0.4f
						  delay:0.0f
		 usingSpringWithDamping:0.2f
		  initialSpringVelocity:1.0f
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
		self.transform = CGAffineTransformIdentity;
	} completion:nil];
}

@end
