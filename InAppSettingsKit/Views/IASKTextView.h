//
//  IASKTextView.h
//  InAppSettingsKit
//
//  Created by Robert La Ferla on 9/17/15.
//  Copyright (c) 2015 InAppSettingsKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IASKTextView : UITextView

@property (nonatomic, copy) NSString *key;
@property (nonatomic, assign) NSUInteger numberOfLines;
@end
