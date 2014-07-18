//
//  IASKTextEditorViewController.m
//  http://www.inappsettingskit.com
//
//  Created by Lin Junjie on 13/8/12.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

#define kHeaderHeight           20.f
#define kCellValue				@"kCellValue"

#import "IASKTextEditorViewController.h"

#import "IASKSpecifier.h"
#import "IASKSettingsReader.h"
#import "IASKSettingsStoreUserDefaults.h"

#import "IASKTextViewCell.h"

@interface IASKTextEditorViewController()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation IASKTextEditorViewController

//From IASKViewController protocol
@synthesize settingsReader = _settingsReader;
@synthesize settingsStore = _settingsStore;

- (id<IASKSettingsStore>)settingsStore {
    if(_settingsStore == nil) {
        _settingsStore = [[IASKSettingsStoreUserDefaults alloc] init];
    }
    return _settingsStore;
}

- (void)loadView
{
	[super loadView];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
	self.tableView.allowsSelection = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view = self.tableView;

}

- (void)viewWillAppear:(BOOL)animated {
    if (self.currentSpecifier) {
        [self setTitle:[self.currentSpecifier title]];
    }
    
    if (self.tableView) {
        [self.tableView reloadData];
    }
	
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
	
	[notifCenter addObserver:self
					selector:@selector(resizeTableViewOnKeyboardNotification:)
						name:UIKeyboardWillShowNotification
					  object:nil];
	
	[notifCenter addObserver:self
					selector:@selector(resizeTableViewOnKeyboardNotification:)
						name:UIKeyboardWillHideNotification
					  object:nil];

	[notifCenter addObserver:self
					selector:@selector(updateTextViewWithStoredValue)
						name:NSUserDefaultsDidChangeNotification
					  object:[NSUserDefaults standardUserDefaults]];
	
	[self.textView becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewDidDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark -
#pragma mark Keyboard showing/hiding methods to adjust UITextView

// http://stackoverflow.com/a/7183223/401329
- (void)resizeTableViewOnKeyboardNotification:(NSNotification*)notif {
	
    NSDictionary* userInfo = [notif userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
	
	[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
	
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
	
    CGRect newFrame = self.view.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
	
	CGFloat heightAdjustment = keyboardFrame.size.height;

	// Account for tabbar if any. Tabbar will be hidden by
	// the keyboard, so we should add the height of tabbar
	// back into the total visible height
	UITabBarController* tabBarController = self.navigationController.tabBarController;
	
	if (tabBarController) {
		heightAdjustment -=
		tabBarController.tabBar.frame.size.height;
	}
	
	if ([notif.name isEqualToString:UIKeyboardWillHideNotification]) {
		heightAdjustment = heightAdjustment * -1;
	}
	
    newFrame.size.height -= heightAdjustment;
    self.view.frame = newFrame;

	// Update the height of the text view cell row
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
	
    [UIView commitAnimations];
    [self.textView scrollRangeToVisible:[self.textView selectedRange]];
}


#pragma mark - Updating of value, notifications

- (void)updateTextViewWithStoredValue {
	NSString *storedValue =
	[self.settingsStore objectForKey:self.currentSpecifier.key];
	
	NSString *finalString =
	storedValue ? storedValue : [self.currentSpecifier defaultStringValue];
	
	if (![self.textView.text isEqualToString:finalString])
		self.textView.text = finalString;

}

#pragma mark -
#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 1.0;
    } else {
        return self.tableView.sectionHeaderHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //automatically resize cell for text, but keep header and footer text visible
    CGFloat textHeight = [self.textView contentSize].height;
    CGFloat tableHeight = self.tableView.frame.size.height;
    tableHeight -= self.tableView.contentInset.top;
    tableHeight -= 2 * self.tableView.sectionFooterHeight;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        tableHeight -= 2;
    } else {
        tableHeight -= 2 * self.tableView.sectionHeaderHeight;
    }
    
    if (textHeight > tableHeight) {
        textHeight = tableHeight;
    }
    return textHeight;

}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [self.currentSpecifier footerText];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IASKTextViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:kCellValue];
	
    if (!cell) {
        cell = [[IASKTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellValue];
		
		self.textView = cell.textView;
		self.textView.delegate = self;

    }
	
	[self updateTextViewWithStoredValue];
	
    return cell;
}

- (CGSize)contentSizeForViewInPopover {
    return [[self view] sizeThatFits:CGSizeMake(320, 2000)];
}

#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [self.settingsStore setObject:textView.text forKey:self.currentSpecifier.key];
	[self.settingsStore synchronize];
    [[NSNotificationCenter defaultCenter]
	 postNotificationName:kIASKAppSettingChanged
	 object:self.currentSpecifier.key
	 userInfo:[NSDictionary dictionaryWithObject:textView.text
										  forKey:self.currentSpecifier.key]
	 ];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end
