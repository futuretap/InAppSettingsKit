//
//  IASKTextView.m
//  InAppSettingsKit
//
//  Created by Robert La Ferla on 9/17/15.
//  Copyright (c) 2015 InAppSettingsKit. All rights reserved.
//

#import "IASKTextView.h"

@implementation IASKTextView

- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self != nil) {
        self.numberOfLines = 3;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
