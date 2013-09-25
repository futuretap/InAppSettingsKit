//
//  MainViewController.h
//  InAppSettingsKitSampleApp
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009-2010:
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

#if USES_IASK_STATIC_LIBRARY
  #import "InAppSettingsKit/IASKAppSettingsViewController.h"
#else
  #import "IASKAppSettingsViewController.h"
#endif

@interface MainViewController : UIViewController <IASKSettingsDelegate, UITextViewDelegate> { 
    IASKAppSettingsViewController *appSettingsViewController;
    IASKAppSettingsViewController *tabAppSettingsViewController;
}

@property (nonatomic, retain) IASKAppSettingsViewController *appSettingsViewController;
@property (nonatomic, retain) IBOutlet IASKAppSettingsViewController *tabAppSettingsViewController;

- (IBAction)showSettingsPush:(id)sender;
- (IBAction)showSettingsModal:(id)sender;

@end
