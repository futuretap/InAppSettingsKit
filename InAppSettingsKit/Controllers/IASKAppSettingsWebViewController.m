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
@synthesize sourceFileName = _sourceFileName;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil htmlFileName:(NSString*)htmlFileName;
{
  if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    return nil;
  }
  
  [self setSourceFileName:htmlFileName];
  
  return self;
}

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil;
{
  return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil htmlFileName:nil];
}

- (void)dealloc;
{
  [webView release];
  [_sourceFileName release];
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
  
  NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:[[self sourceFileName] stringByDeletingPathExtension] ofType:[[self sourceFileName] pathExtension]]];
  NSString *fileContents = [[NSString alloc] initWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];
  [webView loadHTMLString:fileContents baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
  [fileContents release], fileContents = nil;
  [fileURL release], fileURL = nil;
}

- (void)viewDidUnload;
{
  [super viewDidUnload];
  _sourceFileName = nil;
}

@end
