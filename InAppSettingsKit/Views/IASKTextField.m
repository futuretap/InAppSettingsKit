//
//  IASKTextField.m
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009:
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


@implementation IASKTextField

- (void)shake {
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.duration     = 0.1;
	animation.repeatCount  = 2;
	animation.autoreverses = true;
	animation.fromValue    = [NSValue valueWithCGPoint: CGPointMake(self.center.x - 10, self.center.y)];
	animation.toValue      = [NSValue valueWithCGPoint: CGPointMake(self.center.x + 10, self.center.y)];
	[self.layer addAnimation:animation forKey:@"position"];
}

@end
