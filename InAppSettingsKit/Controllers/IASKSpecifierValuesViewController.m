//
//  IASKSpecifierValuesViewController.m
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

#import "IASKSpecifierValuesViewController.h"
#import "IASKSpecifier.h"
#import "IASKSettingsReader.h"

#define kCellValue      @"kCellValue"

@implementation IASKSpecifierValuesViewController

@synthesize currentSpecifier=_currentSpecifier;
@synthesize checkedItem=_checkedItem;
@synthesize settingsReader = _settingsReader;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


/*- (void)viewDidLoad {
    [super viewDidLoad];
}*/

- (void)viewWillAppear:(BOOL)animated {
    if (_currentSpecifier) {
        [self setTitle:[_currentSpecifier title]];
    }
    
    if (_tableView) {
        [_tableView reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [_currentSpecifier release];
	[_settingsReader release];
	_settingsReader = nil;

    [super dealloc];
}


#pragma mark -
#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_currentSpecifier multipleValuesCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell   = [tableView dequeueReusableCellWithIdentifier:kCellValue];
    NSArray *values         = [_currentSpecifier multipleValues];
    NSArray *titles         = [_currentSpecifier multipleTitles];

    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellValue] autorelease];
    }

    if ([[NSUserDefaults standardUserDefaults] objectForKey:[_currentSpecifier key]] ?
		[[[NSUserDefaults standardUserDefaults] objectForKey:[_currentSpecifier key]] isEqual:[values objectAtIndex:indexPath.row]] :
		[[_currentSpecifier defaultValue] isEqual:[values objectAtIndex:indexPath.row]]) {
        [self setCheckedItem:indexPath];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }

	@try {
		[[cell textLabel] setText:[self.settingsReader titleForStringId:[titles objectAtIndex:indexPath.row]]];
	}
	@catch (NSException * e) {}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == [self checkedItem]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    NSArray *values         = [_currentSpecifier multipleValues];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    [[tableView cellForRowAtIndexPath:[self checkedItem]] setAccessoryType:UITableViewCellAccessoryNone];
    [self setCheckedItem:indexPath];

    [[NSUserDefaults standardUserDefaults] setObject:[values objectAtIndex:indexPath.row] forKey:[_currentSpecifier key]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged object:[_currentSpecifier key]];
}


@end
