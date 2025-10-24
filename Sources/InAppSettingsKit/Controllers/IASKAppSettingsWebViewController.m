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
#import "UIColor+IASKAdditions.h"

@interface IASKAppSettingsWebViewController()
@property (nullable, nonatomic, strong, readwrite) WKWebView *webView;
@property (nonatomic, strong, readwrite) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong, readwrite) UIProgressView *progressView;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIBarButtonItem *forwardButton;
@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, readwrite) BOOL showProgress;
@property (nonatomic, readwrite) BOOL showNavigationalButtons;
@property (nonatomic, readwrite) BOOL hideBottomBar;
@end

@implementation IASKAppSettingsWebViewController

- (id)initWithFile:(NSString*)urlString specifier:(IASKSpecifier*)specifier {
    if ((self = [super init])) {
        NSURL *url = [NSURL URLWithString:urlString];
        if (!url.scheme) {
            NSString *path = [NSBundle.mainBundle pathForResource:urlString.stringByDeletingPathExtension
                                                           ofType:urlString.pathExtension];
            url = path ? [NSURL fileURLWithPath:path] : nil;
        }
        if (!url) {
            return nil;
        }
        self.url = url;
        
        // Optional features (Booleans default to `NO` when not in the *.plist):
        self.customTitle = [specifier localizedObjectForKey:kIASKChildTitle];
        self.title = self.customTitle ? : specifier.title;
        self.showProgress = [[specifier.specifierDict objectForKey:kIASKWebViewShowProgress] boolValue];
        self.showNavigationalButtons = [[specifier.specifierDict objectForKey:kIASKWebViewShowNavigationalButtons] boolValue];
        self.hideBottomBar = [[specifier.specifierDict objectForKey:kIASKWebViewHideBottomBar] boolValue];
    }
    return self;
}

- (WKWebViewConfiguration*)webViewConfiguration {
    // Create a configuration for the webView, which sets the subset of properties that Interface Builder in Xcode (version 15.4) shows when adding a WKWebView. The Xcode titles are put in the comments:
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.suppressesIncrementalRendering = NO;                          // Display: Incremental Rendering
    configuration.allowsAirPlayForMediaPlayback = YES;                          // Media: AirPlay
    configuration.allowsInlineMediaPlayback = YES;                              // Media: Inline Playback
    configuration.allowsPictureInPictureMediaPlayback = YES;                    // Media: Picture-in-Picture
    configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;    // Interaction: For Audio/Video Playback -> Disable automatic start explicitly, since the video will be presented fullscreen after page load.
    configuration.dataDetectorTypes = WKDataDetectorTypeAll;                    // Data Detectors: All
    if (@available(iOS 14.0, *)) {
        configuration.defaultWebpagePreferences.allowsContentJavaScript = YES;  // JavaScript: Enabled
    }
    else {
        configuration.preferences.javaScriptEnabled = YES;                      // Deprecated since iOS 14.0
    }
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;       // JavaScript: Can Auto-open Windows -> Disable explicitly for security reasons.
    return configuration;
}

- (void)loadView {
    // Set up the main view
    self.view = [[UIView alloc] init];
    
    // Ensure to define the default background color for the margins, otherwise those will be black:
    if (@available(iOS 13.0, *)) {
		self.view.backgroundColor = UIColor.systemBackgroundColor;
    } else {
		// Fallback on earlier versions:
		self.view.backgroundColor = UIColor.whiteColor;
	}
    
    // Define default activity indicator:
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    self.activityIndicatorView.hidesWhenStopped = YES;
#if TARGET_OS_MACCATALYST || (defined(TARGET_OS_VISION) && TARGET_OS_VISION)
    self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
#else
    if (@available(iOS 13.0, *)) {
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
    } else {
        // Fallback on earlier versions:
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
#endif
    
    // Initialize UIProgressView:
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.progress = 0.0;
    self.progressView.hidden = YES; // Will be shown by observer when enabled
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO; // Disable autoresizing mask for layout constraints
    
    // Create UIBarButtonItems with SF Symbols:
    if (@available(iOS 13.0, *)) {
        self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"chevron.backward"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(goBack)];
    }
    else {
        // Fallback on earlier versions:
        self.backButton = [[UIBarButtonItem alloc] initWithTitle:@" < "
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(goBack)];
    }
    
    if (@available(iOS 13.0, *)) {
        self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"chevron.forward"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(goForward)];
    }
    else {
        // Fallback on earlier versions:
        self.forwardButton = [[UIBarButtonItem alloc] initWithTitle:@" > "
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(goForward)];
    }
    
    // Initially disable the buttons:
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    
    // Only add buttons when `IASKWebViewShowNavigationalButtons` is enabled:
	NSMutableArray *barButtons = NSMutableArray.array;
	if (self.showNavigationalButtons) {
		// Add bar buttons for navigation:
		[barButtons addObjectsFromArray:@[self.forwardButton, self.backButton]];
	}
	if (!self.showProgress) {
		// Add default activity indicator when `IASKWebViewShowProgress` is disabled:
		UIBarButtonItem *activityBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
		IASK_IF_IOS26_OR_GREATER
		(
			activityBarButtonItem.hidesSharedBackground = YES;
			[barButtons addObject:UIBarButtonItem.fixedSpaceItem];
		 )
		[barButtons addObject:activityBarButtonItem];
	}
	self.navigationItem.rightBarButtonItems = barButtons;
    
    if (self.hideBottomBar) {
		// Hide the tab bar when this view is pushed:
        self.hidesBottomBarWhenPushed = YES;
    }
	
	self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Initialize the webView with the configuration in an empty frame (size will be updated in `-viewWillLayoutSubviews` after constraints have been added):
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:self.webViewConfiguration];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;                // Disable autoresizing mask for layout constraints
    self.webView.navigationDelegate = self;
    
    // Set other Xcode Interface Builder properties directly on webView:
    self.webView.allowsBackForwardNavigationGestures = YES;                     // Interaction: Back/Forward Gestures
    if (@available(iOS 16.0, *)) {
        self.webView.findInteractionEnabled = YES;                              // Interaction: Find & Replace
    }
    self.webView.allowsLinkPreview = YES;                                       // Display: Link Preview
	
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    
    [NSLayoutConstraint activateConstraints:@[
		[self.webView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
		[self.webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
		[self.webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
		[self.webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],

		// Create constraints to set progressView to the top of the webView:
		[self.progressView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.progressView.leadingAnchor constraintEqualToAnchor:self.webView.leadingAnchor],
        [self.progressView.trailingAnchor constraintEqualToAnchor:self.webView.trailingAnchor]
    ]];
    
    // Enable progress observer depending on `IASKWebViewShowProgress`:
    if (self.showProgress) {
        // Observe the `estimatedProgress` property of WKWebView:
        [self.webView addObserver:self
                       forKeyPath:@"estimatedProgress"
                          options:NSKeyValueObservingOptionNew
                          context:nil];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.webView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	if (@available(iOS 15.0, *)) {
		self.webView.underPageBackgroundColor = UIColor.systemBackgroundColor;
	}

    // Load URL:
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}


#pragma mark - Helper methods

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
#if !TARGET_OS_MACCATALYST && (!defined(TARGET_OS_VISION) || !TARGET_OS_VISION)
    UIStatusBarStyle savedStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
#endif
    [self presentViewController:mailViewController animated:YES completion:^{
#if !TARGET_OS_MACCATALYST && (!defined(TARGET_OS_VISION) || !TARGET_OS_VISION)
        [UIApplication sharedApplication].statusBarStyle = savedStatusBarStyle;
#endif
    }];
}

// This method is called whenever the observed properties change.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        // Update the progress view with the current progress:
        self.progressView.progress = self.webView.estimatedProgress;
        
        // Hide the progress bar when loading is complete:
        if (self.webView.estimatedProgress >= 1.0) {
            // Some pages load very fast without progress updates, so the update to 100% is never observed. Hence hide progress view after 0.2 s:
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.progressView setHidden:YES];
            });
        }
        else {
            [self.progressView setHidden:NO];
        }
    }
}

- (void)updateNavigationButtons {
	// Enable or disable the buttons based on whether the webView can go back/forward:
	self.backButton.enabled = self.webView.canGoBack;
	self.forwardButton.enabled = self.webView.canGoForward;
}


#pragma mark - User Interaction

- (void)goBack {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (void)goForward {
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}


#pragma mark - WKNavigationDelegate

// Tells the delegate that navigation from the main frame has started.
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    // Show progress:
    [self.activityIndicatorView startAnimating];
}

// Tells the delegate that navigation is complete.
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // Stop and hide default indicator and update title:
    [self.activityIndicatorView stopAnimating];
    [self.webView evaluateJavaScript:@"document.title" completionHandler:^(id result, NSError *error) {
        self.title = self.customTitle.length ? self.customTitle : result;
    }];
    
	if (@available(iOS 15.0, *)) {
		NSString *javascript = @"function getThemeColorAsHex() {\n"
		"    const themeColorMeta = document.querySelector('meta[name=\"theme-color\"]');\n"
		"    if (!themeColorMeta) {\n"
		"        return null;\n"
		"    }\n"
		"    \n"
		"    const color = themeColorMeta.content;\n"
		"    \n"
		"    const temp = document.createElement('div');\n"
		"    temp.style.color = color;\n"
		"    document.body.appendChild(temp);\n"
		"    \n"
		"    const computedColor = window.getComputedStyle(temp).color;\n"
		"    document.body.removeChild(temp);\n"
		"    \n"
		"    const match = computedColor.match(/rgba?\\((\\d+),\\s*(\\d+),\\s*(\\d+)(?:,\\s*([\\d.]+))?\\)/);\n"
		"    \n"
		"    if (!match) {\n"
		"        return color; // Fallback: Originalwert zurückgeben\n"
		"    }\n"
		"    \n"
		"    const r = parseInt(match[1]);\n"
		"    const g = parseInt(match[2]);\n"
		"    const b = parseInt(match[3]);\n"
		"    const a = match[4] ? parseFloat(match[4]) : 1;\n"
		"    \n"
		"    const toHex = (num) => num.toString(16).padStart(2, '0');\n"
		"    \n"
		"    const alphaHex = Math.round(a * 255).toString(16).padStart(2, '0');\n"
		"    return `${toHex(r)}${toHex(g)}${toHex(b)}${alphaHex}`;\n"
		"}\n"
		"getThemeColorAsHex()";

		[self.webView evaluateJavaScript:javascript completionHandler: ^(id result, NSError *error) {
			UIColor *color = [UIColor iaskColorWithHexString:result];
			self.webView.underPageBackgroundColor = color;
		}];
	}

	// Update button states when loading finishes:
    [self updateNavigationButtons];
}

// Asks the delegate for permission to navigate to new content based on the specified action information.
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler NS_EXTENSION_UNAVAILABLE("Uses APIs (i.e UIApplication.sharedApplication) not available for use in App Extensions.") {
    NSURL* newURL = navigationAction.request.URL;
    
    // Intercept mailto URL scheme and send it to an in-app Mail compose view instead:
    if ([newURL.scheme isEqualToString:@"mailto"]) {
        [self handleMailto:newURL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // Allow loading of any http(s) and file requests:
    if ([@[@"http", @"https", @"file"] containsObject:newURL.scheme]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    // For any other URL scheme, let the system find an appropriate app to open the URL:
    [UIApplication.sharedApplication openURL:newURL
                                     options:@{}
                           completionHandler:nil];
    decisionHandler(WKNavigationActionPolicyCancel);
}

// Tells the delegate that an error occurred during navigation.
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self updateNavigationButtons];
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
