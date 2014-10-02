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
@property (nonatomic, assign) CGSize keyboardSize;

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
    self.keyboardSize = CGSizeMake(0, 0);
    
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

- (void)viewWillDisappear:(BOOL)animated {
    [self.textView resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewDidDisappear:animated];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.textView scrollRangeToVisible:[self.textView selectedRange]];
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

// save the current keyboard size (based on http://stackoverflow.com/a/7183223/401329), or set to 0 if keyboard is dismissed
- (void)resizeTableViewOnKeyboardNotification:(NSNotification*)notif {
	if ([notif.name isEqualToString:UIKeyboardWillHideNotification]) {
        self.keyboardSize = CGSizeMake(0, 0);
	} else {
        NSDictionary* userInfo = [notif userInfo];
        CGRect keyboardEndFrame;
        [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
        self.keyboardSize = keyboardEndFrame.size;
    }
    
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (CGFloat)44.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //automatically resize cell for text, but keep header and footer text visible
    CGFloat textHeight = [self.textView contentSize].height + [self.textView contentOffset].y;
    CGFloat tableHeight = self.tableView.frame.size.height;
    tableHeight -= [self heightCoveredByKeyboardOfSize:self.keyboardSize];
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

// based on http://stackoverflow.com/questions/13806282/how-can-i-find-portion-of-my-view-which-isnt-covered-by-the-keyboard-uimodalpr
- (CGFloat)heightCoveredByKeyboardOfSize:(CGSize)keyboardSize
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect frameInWindow = [self.view convertRect:self.view.bounds toView:nil];
    CGRect windowBounds = self.view.window.bounds;
    
    CGFloat keyboardTop;
    CGFloat heightCoveredByKeyboard;
    
    //Determine height of the view covered by the keyboard relative to current rotation
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)) {
        
        switch (orientation) {
            case UIInterfaceOrientationLandscapeLeft:
                keyboardTop = windowBounds.size.width - keyboardSize.width;
                heightCoveredByKeyboard = CGRectGetMaxX(frameInWindow) - keyboardTop;
                break;
            case UIInterfaceOrientationLandscapeRight:
                keyboardTop = windowBounds.size.width - keyboardSize.width;
                heightCoveredByKeyboard = windowBounds.size.width - frameInWindow.origin.x - keyboardTop;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                keyboardTop = windowBounds.size.height - keyboardSize.height;
                heightCoveredByKeyboard = windowBounds.size.height - frameInWindow.origin.y - keyboardTop;
                break;
            default:
                keyboardTop = windowBounds.size.height - keyboardSize.height;
                heightCoveredByKeyboard = CGRectGetMaxY(frameInWindow) - keyboardTop;
                break;
        }
    } else {
        //Apple switched the window bounds to match orientation in iOS8
        keyboardTop = windowBounds.size.height - keyboardSize.height;
        heightCoveredByKeyboard = windowBounds.size.height - frameInWindow.origin.y - keyboardTop;

    }
    
    return MAX(0.0f,heightCoveredByKeyboard);
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
