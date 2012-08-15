//
//  IASKTextEditorViewController.m
//  http://www.inappsettingskit.com
//
//  Created by Lin Junjie on 13/8/12.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

#define kTextViewIdealHeight	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 44.f*4 : 44.f*3
#define kCellValue				@"kCellValue"

#import "IASKTextEditorViewController.h"

#import "IASKSpecifier.h"
#import "IASKSettingsReader.h"
#import "IASKSettingsStoreUserDefaults.h"

#import "IASKTextViewCell.h"

@interface IASKTextEditorViewController() {
	UITableView *_tableView;
	UITextView *_textView;
}
@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, assign) UITextView *textView;
@end

@implementation IASKTextEditorViewController

@synthesize tableView = _tableView;
@synthesize textView = _textView;
@synthesize currentSpecifier = _currentSpecifier;
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
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
	_tableView.allowsSelection = NO;
    
    self.view = _tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    if (_currentSpecifier) {
        [self setTitle:[_currentSpecifier title]];
    }
    
    if (_tableView) {
        [_tableView reloadData];
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


- (void)dealloc {
	[_textView release], _textView = nil;
    [_currentSpecifier release], _currentSpecifier = nil;
	[_settingsReader release], _settingsReader = nil;
    [_settingsStore release], _settingsStore = nil;
	[_tableView release], _tableView = nil;
    [super dealloc];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat tableHeight = tableView.frame.size.height;
	CGFloat idealHeight = kTextViewIdealHeight;

	if (tableHeight >= idealHeight) {
		return idealHeight;
	}
	
	CGFloat fittingHeight = ceilf(0.85 * tableView.frame.size.height);
	return fittingHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [self.currentSpecifier footerText];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IASKTextViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:kCellValue];
	
    if (!cell) {
        cell = [[[IASKTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellValue] autorelease];
		
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
}

@end
