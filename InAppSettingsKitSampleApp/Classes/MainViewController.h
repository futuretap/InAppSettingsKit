//
//  MainViewController.h
//  InAppSettingsKitSampleApp
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



// Superseded by MainViewController.swift
// Code no longer compiled / in target, left here just for reference.



#import <InAppSettingsKit/IASKAppSettingsViewController.h>

@interface MainViewController : UIViewController <IASKSettingsDelegate, UITextViewDelegate>

@property (nonatomic, retain) IASKAppSettingsViewController *appSettingsViewController;
@property (nonatomic, retain) IBOutlet IASKAppSettingsViewController *tabAppSettingsViewController;

- (IBAction)showSettingsPush:(id)sender;
- (IBAction)showSettingsModal:(id)sender;

@end
