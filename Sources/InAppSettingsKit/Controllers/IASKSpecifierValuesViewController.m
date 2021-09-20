//
//  IASKSpecifierValuesViewController.m
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

#import "IASKSpecifierValuesViewController.h"
#import "IASKSpecifier.h"
#import "IASKSettingsReader.h"
#import "IASKMultipleValueSelection.h"

#define kCellValue      @"kCellValue"

@interface IASKSpecifierValuesViewController()
@property (nonnull, nonatomic, strong) IASKSpecifier *currentSpecifier;
@property (nonatomic, strong) IASKMultipleValueSelection *selection;
@property (nonatomic) BOOL didFirstLayout;
@end

@implementation IASKSpecifierValuesViewController

@synthesize settingsReader = _settingsReader;
@synthesize settingsStore = _settingsStore;
@synthesize childPaneHandler = _childPaneHandler;
@synthesize listParentViewController;

- (id)initWithSpecifier:(IASKSpecifier*)specifier {
	if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
		self.currentSpecifier = specifier;
	};
	return self;
}

- (id)initWithSpecifier:(IASKSpecifier*)specifier style:(UITableViewStyle)style {
	if ((self = [super initWithStyle:style])) {
		self.currentSpecifier = specifier;
	};
	return self;
}

- (void)setSettingsStore:(id <IASKSettingsStore>)settingsStore {
	self.selection = [[IASKMultipleValueSelection alloc] initWithSettingsStore:settingsStore tableView:self.tableView specifier:self.currentSpecifier section:0];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
    if (self.currentSpecifier) {
		self.title = self.currentSpecifier.title;
		IASK_IF_IOS11_OR_GREATER(self.navigationItem.largeTitleDisplayMode = self.title.length ? UINavigationItemLargeTitleDisplayModeAutomatic : UINavigationItemLargeTitleDisplayModeNever;);
    }
    
    if (self.tableView) {
		self.selection.tableView = self.tableView;
		[self.tableView reloadData];

		// Make sure the currently checked item is visible
		[self.tableView scrollToRowAtIndexPath:self.selection.checkedIndexPath
							  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	}
	self.didFirstLayout = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    self.selection.tableView = nil;
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	if (!self.didFirstLayout) {
		self.didFirstLayout = YES;
		[self.tableView scrollToRowAtIndexPath:self.selection.checkedIndexPath
							  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
		[self.tableView flashScrollIndicators];
	}
}

#pragma mark -
#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.currentSpecifier multipleValuesCount];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [self.currentSpecifier footerText];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell   = [tableView dequeueReusableCellWithIdentifier:kCellValue];
	NSArray *titles         = self.currentSpecifier.multipleTitles;
	NSArray *iconNames      = self.currentSpecifier.multipleIconNames;
	
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellValue];
    }

    [self.selection updateSelectionInCell:cell indexPath:indexPath];
	UIColor *textColor = [UILabel appearanceWhenContainedInInstancesOfClasses:@[UITableViewCell.class]].textColor;
	if (textColor == nil) {
		textColor = [UILabel appearance].textColor;
	}
	cell.textLabel.textColor = textColor;
    
    @try {
        [[cell textLabel] setText:[self.settingsReader titleForId:[titles objectAtIndex:indexPath.row]]];
        if ((NSInteger)iconNames.count > indexPath.row) {
            NSString *iconName = iconNames[indexPath.row];
            // This tries to read the image from the main bundle. As this is currently not supported in
            // system settings, this should be the correct behaviour. (Idea: abstract away and try different
            // paths?)
            UIImage *image = [UIImage imageNamed:iconName];
            cell.imageView.image = image;
        }
    }
    @catch (NSException * e) {}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.selection selectRowAtIndexPath:indexPath];
}

@end
