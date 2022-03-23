//
//  IASKAppSettingsWebViewController.h
//  InAppSettingsKit
//
//  Copyright (c) 2010:
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

#import "IASKAppSettingsWebViewController.h"
#import "IASKSettingsReader.h"
#import "IASKSpecifier.h"

@interface IASKAppSettingsWebViewController()
@property (nullable, nonatomic, strong, readwrite) WKWebView *webView;
@property (nonatomic, strong, readwrite) NSURL *url;
@end

@implementation IASKAppSettingsWebViewController

- (id)initWithFile:(NSString*)urlString specifier:(IASKSpecifier*)specifier {
    if ((self = [super init])) {
        NSURL *url = [NSURL URLWithString:urlString];
		if (!url.scheme) {
			NSString *path = [NSBundle.mainBundle pathForResource:urlString.stringByDeletingPathExtension ofType:urlString.pathExtension];
			url = path ? [NSURL fileURLWithPath:path] : nil;
        }
		self.customTitle = [specifier localizedObjectForKey:kIASKChildTitle];
		self.title = self.customTitle ? : specifier.title;
		if (!url) {
			return nil;
		}
		self.url = url;
	}
	return self;
}

- (void)loadView {
    self.webView = [[WKWebView alloc] init];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.navigationDelegate = self;
    
    self.view = self.webView;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
#if TARGET_OS_MACCATALYST
	activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
#else
	activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
#endif
	[activityIndicatorView startAnimating];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
	[self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
	self.navigationItem.rightBarButtonItem = nil;
	[self.webView evaluateJavaScript:@"document.title" completionHandler:^(id result, NSError *error) {
		NSString* title = (NSString*)result;
		self.title = self.customTitle.length ? self.customTitle : title;
	}];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler NS_EXTENSION_UNAVAILABLE("Uses APIs (i.e UIApplication.sharedApplication) not available for use in App Extensions.") {
	NSURL* newURL = navigationAction.request.URL;

	// intercept mailto URL and send it to an in-app Mail compose view instead
	if ([[newURL scheme] isEqualToString:@"mailto"]) {
		[self handleMailto:newURL];
		decisionHandler(WKNavigationActionPolicyCancel);
		return;
	}

	// open inline if host is the same, otherwise, pass to the system
	if (![newURL host] || ![self.url host] || [[newURL host] isEqualToString:(NSString *)[self.url host]]) {
		decisionHandler(WKNavigationActionPolicyAllow);
		return;
	}

	IASK_IF_IOS11_OR_GREATER([UIApplication.sharedApplication openURL:newURL options:@{} completionHandler:nil];);
	IASK_IF_PRE_IOS11([UIApplication.sharedApplication openURL:newURL];);
	decisionHandler(WKNavigationActionPolicyCancel);
}

- (void)handleMailto:(NSURL*)mailToURL NS_EXTENSION_UNAVAILABLE("Uses APIs (i.e UIApplication.sharedApplication) not available for use in App Extensions.") {
	NSArray *rawURLparts = [[mailToURL resourceSpecifier] componentsSeparatedByString:@"?"];
	if (rawURLparts.count > 2 || !MFMailComposeViewController.canSendMail) {
		return; // invalid URL or can't send mail
	}

	MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
	mailViewController.mailComposeDelegate = self;

	NSMutableArray *toRecipients = [NSMutableArray array];
	NSString *defaultRecipient = [rawURLparts objectAtIndex:0];
	if (defaultRecipient.length) {
		[toRecipients addObject:defaultRecipient];
	}

	if (rawURLparts.count == 2) {
		NSString *queryString = [rawURLparts objectAtIndex:1];

		NSArray *params = [queryString componentsSeparatedByString:@"&"];
		for (NSString *param in params) {
			NSArray *keyValue = [param componentsSeparatedByString:@"="];
			if (keyValue.count != 2) {
				continue;
			}
			NSString *key = [[keyValue objectAtIndex:0] lowercaseString];
			NSString *value = [keyValue objectAtIndex:1];

			value =  CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault,
																				  (CFStringRef)value,
																				  CFSTR("")));

			if ([key isEqualToString:@"subject"]) {
				[mailViewController setSubject:value];
			}

			if ([key isEqualToString:@"body"]) {
				[mailViewController setMessageBody:value isHTML:NO];
			}

			if ([key isEqualToString:@"to"]) {
				[toRecipients addObjectsFromArray:[value componentsSeparatedByString:@","]];
			}

			if ([key isEqualToString:@"cc"]) {
				NSArray *recipients = [value componentsSeparatedByString:@","];
				[mailViewController setCcRecipients:recipients];
			}

			if ([key isEqualToString:@"bcc"]) {
				NSArray *recipients = [value componentsSeparatedByString:@","];
				[mailViewController setBccRecipients:recipients];
			}
		}
	}

	[mailViewController setToRecipients:toRecipients];

	mailViewController.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
	mailViewController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
	mailViewController.navigationBar.titleTextAttributes =  self.navigationController.navigationBar.titleTextAttributes;
#if !TARGET_OS_MACCATALYST
	UIStatusBarStyle savedStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
#endif
	[self presentViewController:mailViewController animated:YES completion:^{
#if !TARGET_OS_MACCATALYST
		[UIApplication sharedApplication].statusBarStyle = savedStatusBarStyle;
#endif
	}];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
