//
//  IASKPSToggleSwitchSpecifierViewCell.h
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

#import <UIKit/UIKit.h>

@class IASKSwitch;

@interface IASKPSToggleSwitchSpecifierViewCell : UITableViewCell {
    UILabel *_label;
    IASKSwitch *_toggle;
}

@property (nonatomic, assign) IBOutlet UILabel *label;
@property (nonatomic, assign) IBOutlet IASKSwitch *toggle;

@end
