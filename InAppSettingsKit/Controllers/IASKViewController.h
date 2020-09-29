//
//  IASKAppSettingsViewController.h
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

@class IASKSettingsReader;
@protocol IASKSettingsStore;

// protocol all IASK view controllers implement
@protocol IASKViewController <NSObject>

@property (nonatomic, strong, nullable) IASKSettingsReader* settingsReader;
@property (nonatomic, strong, nonnull) id<IASKSettingsStore> settingsStore;
@property (nonatomic, copy, nullable) void (^childPaneHandler)(BOOL doneEditing);
@property (nonatomic, weak, nullable) UIViewController<IASKViewController> *listParentViewController;

@optional
@property (nonatomic, weak, nullable) id currentFirstResponder;

@end
