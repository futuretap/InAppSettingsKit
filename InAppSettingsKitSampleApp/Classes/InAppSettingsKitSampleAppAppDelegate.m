//
//  InAppSettingsKitSampleAppAppDelegate.m
//  InAppSettingsKitSampleApp
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009-2010:
//  Luc Vandal, Edovia Inc., http://www.edovia.com
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//  Manuel "StuFF mc" Carrasco Molina, http://www.pomcast.biz
//  All rights reserved.
// 
//  It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz, 
//  as the original authors of this code. You can give credit in a blog post, a tweet or on 
//  a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//
//	Settings Icon (also used in App Icon) thanks to http://glyphish.com/ 

#import "InAppSettingsKitSampleAppAppDelegate.h"

@implementation InAppSettingsKitSampleAppAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  // add  the viewController from the storyboard
  UIStoryboard *storyboardWithSettings = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
  UIViewController *storyboardViewControllerWithSettings = [storyboardWithSettings instantiateInitialViewController];
  _tabBarController.viewControllers = [_tabBarController.viewControllers arrayByAddingObject: storyboardViewControllerWithSettings];
	[_window addSubview:_tabBarController.view];
}

@end
