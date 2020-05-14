//
//  IASKAppSettingsWebViewController.h
//  InAppSettingsKit
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

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <WebKit/WebKit.h>
@class IASKSpecifier;

NS_ASSUME_NONNULL_BEGIN

@interface IASKAppSettingsWebViewController : UIViewController <WKNavigationDelegate, MFMailComposeViewControllerDelegate>

- (nullable id)initWithFile:(NSString*)htmlFileName specifier:(IASKSpecifier*)specifier;

@property (nullable, nonatomic, strong, readonly) WKWebView *webView;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nullable, nonatomic, strong) NSString *customTitle;

@end

NS_ASSUME_NONNULL_END
