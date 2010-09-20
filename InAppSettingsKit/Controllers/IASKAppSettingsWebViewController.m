//
//  IASKAppSettingsWebViewController.h
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

#import "IASKAppSettingsWebViewController.h"

@implementation IASKAppSettingsWebViewController

@synthesize webView;
@synthesize sourceFileURL = _sourceFileURL;
@synthesize baseURL = _baseURL;
@synthesize contentString = _contentString;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil sourceFileURL:(NSURL*)aSourceFileURL baseURL:(NSURL*)aBaseURL;
{
  if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    return nil;
  }
  
  [self setSourceFileURL:aSourceFileURL];
  [self setBaseURL:aBaseURL];
  
  return self;
}

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil;
{
  return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil sourceFileURL:nil baseURL:nil];
}

- (void)dealloc;
{
  [webView release];
  [_sourceFileURL release];
  [_baseURL release];
  [_contentString release];
  [super dealloc];
}

#pragma mark -

- (void)viewDidLoad;
{
  [[self view] setBackgroundColor:[UIColor colorWithWhite:0.750 alpha:1.000]];
  
  [webView setOpaque:NO];
  [webView setBackgroundColor:[UIColor colorWithWhite:0.750 alpha:1.000]];

  for (id subview in [webView subviews]) {
    if ([[subview class] isSubclassOfClass:[UIScrollView class]]) {
      [subview setBackgroundColor:[UIColor colorWithWhite:0.750 alpha:1.000]];
      break;
    }
  }
  
  [self setContentString:[[NSString alloc] initWithContentsOfURL:[self sourceFileURL] encoding:NSUTF8StringEncoding error:nil]];
  [self setContentString:[[self contentString] stringByReplacingOccurrencesOfString:@"%version%" withString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
  [webView loadHTMLString:[self contentString] baseURL:[self baseURL]];
}

- (void)viewDidUnload;
{
  [super viewDidUnload];
  _sourceFileURL = nil;
  _baseURL = nil;
  _contentString = nil;
}

@end
