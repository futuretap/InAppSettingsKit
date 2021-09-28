//
//  IASKAppSettingsViewController.m
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


#import "IASKAppSettingsViewController.h"
#import "IASKSwitch.h"
#import "IASKDatePicker.h"
#import "IASKTextView.h"
#import "IASKSettingsReader.h"
#import "IASKMultipleValueSelection.h"
#import "IASKSettingsStoreUserDefaults.h"
#import "IASKSpecifier.h"
#import "IASKSlider.h"
#import "IASKEmbeddedDatePickerViewCell.h"
#import "IASKPSTextFieldSpecifierViewCell.h"
#import "IASKTextField.h"
#import "IASKTextViewCell.h"
#import "IASKPSSliderSpecifierViewCell.h"
#import "IASKSpecifierValuesViewController.h"
#import "IASKSettingsStoreInMemory.h"

#if !__has_feature(objc_arc)
#error "IASK needs ARC"
#endif

static NSString *kIASKCredits = @"Powered by InAppSettingsKit"; // Leave this as-is!!!

#define kIASKSpecifierValuesViewControllerIndex       0
#define kIASKSpecifierChildViewControllerIndex        1

#define kIASKCreditsViewWidth                         285

CGRect IASKCGRectSwap(CGRect rect);

@interface IASKAppSettingsViewController () <UITextViewDelegate>

@property (nonatomic, weak) UIViewController *currentChildViewController;
@property (nonatomic, strong) NSMutableDictionary *rowHeights;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic) BOOL reloadDisabled;
@property (nonatomic, strong) NSArray *selections; /// The selected index for every group (in case it's a radio group).

- (void)synchronizeSettings;
- (void)userDefaultsDidChange;
- (void)reload;
@end

@implementation IASKAppSettingsViewController
//synthesize properties from protocol
@synthesize settingsReader = _settingsReader;
@synthesize settingsStore = _settingsStore;
@synthesize file = _file;
@synthesize childPaneHandler = _childPaneHandler;
@synthesize currentFirstResponder = _currentFirstResponder;
@synthesize listParentViewController;

#pragma mark accessors
- (IASKSettingsReader*)settingsReader {
	if (!_settingsReader) {
		_settingsReader = [[IASKSettingsReader alloc] initWithFile:self.file];
		if (self.neverShowPrivacySettings) {
			_settingsReader.showPrivacySettings = NO;
		}
	}
	_settingsReader.settingsStore = self.settingsStore;
	return _settingsReader;
}

- (void)setSettingsStore:(id<IASKSettingsStore>)settingsStore {
	_settingsStore = settingsStore;
	_settingsReader.settingsStore = _settingsStore;
	
	// Workaround for PSRadioGroupSpecifier's in List Groups
	for (IASKMultipleValueSelection *selection in _selections) {
		if (![selection isEqual:[NSNull null]]) {
			selection.settingsStore = _settingsStore;
		}
	}
}

- (id<IASKSettingsStore>)settingsStore {
	if (!_settingsStore) {
		_settingsStore = [[IASKSettingsStoreUserDefaults alloc] init];
	}
	return _settingsStore;
}

- (NSString*)file {
	if (!_file) {
		self.file = @"Root";
	}
	return _file;
}

- (void)setFile:(NSString *)file {
    _file = [file copy];
    self.tableView.contentOffset = CGPointMake(0, -self.tableView.contentInset.top);
    self.settingsReader = nil; // automatically initializes itself
    if (!_reloadDisabled) {
		[self.tableView reloadData];
		[self createSelections];
	}
}

- (void)createSelections {
	NSMutableArray *sectionSelection = [NSMutableArray new];
	for (int section = 0; section < _settingsReader.numberOfSections; section++) {
		IASKSpecifier *specifier = [self.settingsReader headerSpecifierForSection:section];
		if ([specifier.type isEqualToString:kIASKPSRadioGroupSpecifier]) {
			IASKMultipleValueSelection *selection = [[IASKMultipleValueSelection alloc] initWithSettingsStore:self.settingsStore tableView:self.tableView specifier:specifier section:section];
			[sectionSelection addObject:selection];
		} else {
			[sectionSelection addObject:[NSNull null]];
		}
	}
	_selections = sectionSelection;
}

#pragma mark standard view controller methods
- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style {
    if (style == UITableViewStylePlain) {
        NSLog(@"WARNING: only \"grouped\" table view styles are supported by InAppSettingsKit.");
    }
    if ((self = [super initWithStyle:style])) {
		[self configure];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (nibNameOrNil) {
		NSLog (@"%@ is now deprecated, we are moving away from nibs.", NSStringFromSelector(_cmd));
		self = [super initWithStyle:UITableViewStyleGrouped];
	} else {
		self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	}
	if (self) {
		[self configure];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self configure];
		_showDoneButton = NO;
	}
	return self;
}

- (void)configure {
	_reloadDisabled = NO;
	_showDoneButton = YES;
	_showCreditsFooter = YES; // display credits for InAppSettingsKit creators
    self.clearsSelectionOnViewWillAppear = false;
	self.rowHeights = [NSMutableDictionary dictionary];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.cellLayoutMarginsFollowReadableWidth = self.cellLayoutMarginsFollowReadableWidth;
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapToEndEdit:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGesture];

	if (_showDoneButton) {
		UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																					target:self
																					action:@selector(dismiss:)];
		self.navigationItem.rightBarButtonItem = buttonItem;
	}
	
	if (!self.title) {
		self.title = NSLocalizedString(@"Settings", @"");
	}
}

- (void)viewWillAppear:(BOOL)animated {
	NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
	self.tintColor = self.view.tintColor;
	
	[super viewWillAppear:animated];
	
	[self.tableView reloadData]; // values might have changed in the meantime

	if (selectedIndexPath) {
		[self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
			// Do nothing. We're only interested in the completion handler.
		} completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
			if (![context isCancelled]) {
				// don't deselect if the user cancelled the interactive pop gesture
				[self.tableView deselectRowAtIndexPath:selectedIndexPath animated:animated];
			}
		}];
		
		// reloadData destroys the selection at the end of the runloop.
		// So select again in the next runloop.
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
		});
	}
	
	NSNotificationCenter *dc = NSNotificationCenter.defaultCenter;
	[dc addObserver:self selector:@selector(didChangeSettingViaIASK:) name:kIASKAppSettingChanged object:nil];
	if ([self.settingsStore isKindOfClass:[IASKSettingsStoreUserDefaults class]]) {
		IASKSettingsStoreUserDefaults *udSettingsStore = (id)self.settingsStore;
		[dc addObserver:self selector:@selector(userDefaultsDidChange) name:NSUserDefaultsDidChangeNotification object:udSettingsStore.defaults];
		[self userDefaultsDidChange]; // force update in case of changes while we were hidden
	}
}

- (void)viewDidAppear:(BOOL)animated NS_EXTENSION_UNAVAILABLE("Uses APIs (i.e UIApplication.sharedApplication) not available for use in App Extensions.") {
	[super viewDidAppear:animated];

	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
	[dc addObserver:self selector:@selector(synchronizeSettings) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
	[dc addObserver:self selector:@selector(reload) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
	[dc addObserver:self selector:@selector(synchronizeSettings) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
}

- (void)viewWillDisappear:(BOOL)animated {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];

	// hide the keyboard
    [self.currentFirstResponder resignFirstResponder];
	
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated NS_EXTENSION_UNAVAILABLE("Uses APIs (i.e UIApplication.sharedApplication) not available for use in App Extensions.") {
	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
	if ([self.settingsStore isKindOfClass:[IASKSettingsStoreUserDefaults class]]) {
		IASKSettingsStoreUserDefaults *udSettingsStore = (id)self.settingsStore;
		[dc removeObserver:self name:NSUserDefaultsDidChangeNotification object:udSettingsStore.defaults];
		[dc removeObserver:self name:kIASKAppSettingChanged object:self];
	}
	[dc removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
	[dc removeObserver:self name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
	[dc removeObserver:self name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];

	[super viewDidDisappear:animated];
}

- (void)setHiddenKeys:(NSSet *)theHiddenKeys {
	[self setHiddenKeys:theHiddenKeys animated:NO];
}


- (void)setHiddenKeys:(NSSet*)theHiddenKeys animated:(BOOL)animated {
    if (_hiddenKeys != theHiddenKeys) {
        NSSet *oldHiddenKeys = _hiddenKeys;
        _hiddenKeys = theHiddenKeys;
        
        if (animated) {			
            NSMutableSet *showKeys = [NSMutableSet setWithSet:oldHiddenKeys];
            [showKeys minusSet:theHiddenKeys];
            
            NSMutableSet *hideKeys = [NSMutableSet setWithSet:theHiddenKeys];
            [hideKeys minusSet:oldHiddenKeys];
            
            // calculate rows to be deleted
            NSMutableArray *hideIndexPaths = [NSMutableArray array];
            NSMutableIndexSet *hideSections = [NSMutableIndexSet indexSet];
            for (NSString *key in hideKeys) {
				NSIndexPath *indexPath = [self.settingsReader indexPathForKey:key];
				if (indexPath) {
					IASKSpecifier *specifier = [self.settingsReader specifierForKey:key];
					if (specifier == [self.settingsReader headerSpecifierForSection:indexPath.section]) {
						[hideSections addIndex:indexPath.section];
					} else {
						[hideIndexPaths addObject:indexPath];
					}
				}
				if ([self.settingsReader.selectedSpecifier.key isEqualToString:key]) {
					[hideIndexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
				}
			}
            
            // calculate sections to be deleted
            for (NSInteger section = 0; section < [self numberOfSectionsInTableView:self.tableView ]; section++) {
				NSInteger rowsInSection = 0;
				if ([hideSections containsIndex:section]) {
					continue;
				}
                for (NSIndexPath *indexPath in hideIndexPaths) {
                    if (indexPath.section == section) {
                        rowsInSection++;
                    }
                }
                if (rowsInSection && rowsInSection >= [self.settingsReader numberOfRowsInSection:section]) {
                    [hideSections addIndex:section];
                }
            }
			
            // set the datasource
            self.settingsReader.hiddenKeys = theHiddenKeys;
            
            
            // calculate rows to be inserted
            NSMutableArray *showIndexPaths = [NSMutableArray array];
            NSMutableIndexSet *showSections = [NSMutableIndexSet indexSet];
            for (NSString *key in showKeys) {
                NSIndexPath *indexPath = [self.settingsReader indexPathForKey:key];
                if (indexPath) {
					IASKSpecifier *specifier = [self.settingsReader specifierForKey:key];
					if (specifier == [self.settingsReader headerSpecifierForSection:indexPath.section]) {
						[showSections addIndex:indexPath.section];
					} else {
						[showIndexPaths addObject:indexPath];
					}
                }
				if ([self.settingsReader.selectedSpecifier.key isEqualToString:key]) {
					[showIndexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
				}
            }
            
            // calculate sections to be inserted
            for (NSInteger section = 0; section < [self.settingsReader numberOfSections]; section++) {
				if ([showSections containsIndex:section]) {
					continue;
				}
                NSInteger rowsInSection = 0;
                for (NSIndexPath *indexPath in showIndexPaths) {
                    if (indexPath.section == section) {
                        rowsInSection++;
                    }
                }
                if (rowsInSection && rowsInSection >= [self.settingsReader numberOfRowsInSection:section]) {
                    [showSections addIndex:section];
                }
			}
			
			if (hideSections.count || hideIndexPaths.count || showSections.count || showIndexPaths.count) {
				[self.tableView beginUpdates];
				UITableViewRowAnimation rowAnimation = animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone;
				UITableViewRowAnimation sectionAnimation = animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone;
				if (hideSections.count) {
					[self.tableView deleteSections:hideSections withRowAnimation:sectionAnimation];
				}
				if (hideIndexPaths.count) {
					[self.tableView deleteRowsAtIndexPaths:hideIndexPaths withRowAnimation:rowAnimation];
				}
				if (showSections.count) {
					[self.tableView insertSections:showSections withRowAnimation:sectionAnimation];
				}
				if (showIndexPaths.count) {
					[self.tableView insertRowsAtIndexPaths:showIndexPaths withRowAnimation:rowAnimation];
				}
				[self.tableView endUpdates];
			}
		} else {
			self.settingsReader.hiddenKeys = theHiddenKeys;
			if (!_reloadDisabled) [self.tableView reloadData];
		}
	}
	UIViewController *childViewController = _currentChildViewController;
    if([childViewController respondsToSelector:@selector(setHiddenKeys:animated:)]) {
        [(id)childViewController setHiddenKeys:theHiddenKeys animated:animated];
    }
}

- (void)setNeverShowPrivacySettings:(BOOL)neverShowPrivacySettings {
	_neverShowPrivacySettings = neverShowPrivacySettings;
	self.settingsReader = nil;
	[self reload];
}

- (void)setCellLayoutMarginsFollowReadableWidth:(BOOL)cellLayoutMarginsFollowReadableWidth {
    _cellLayoutMarginsFollowReadableWidth = cellLayoutMarginsFollowReadableWidth;
	self.tableView.cellLayoutMarginsFollowReadableWidth = cellLayoutMarginsFollowReadableWidth;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark Actions

- (IBAction)dismiss:(id)sender {
	[self.settingsStore synchronize];
	
	if (self.delegate && [self.delegate conformsToProtocol:@protocol(IASKSettingsDelegate)]) {
		[self.delegate settingsViewControllerDidEnd:self];
	}
}

- (void)toggledValue:(IASKSwitch*)sender {
	[self setSpecifier:sender.specifier on:sender.isOn];
}

- (void)setSpecifier:(IASKSpecifier*)specifier on:(BOOL)on {
	if (on) {
		if (specifier.trueValue) {
			[self.settingsStore setObject:specifier.trueValue forSpecifier:specifier];
        } else {
            [self.settingsStore setBool:YES forSpecifier:specifier];
        }
	}
	else {
		if (specifier.falseValue) {
			[self.settingsStore setObject:specifier.falseValue forSpecifier:specifier];
		} else {
			[self.settingsStore setBool:NO forSpecifier:specifier];
		}
	}
	NSString* key = specifier.key;
	if (key != nil) {
		NSIndexPath* indexPath = [_settingsReader indexPathForKey:key];
		UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
		cell.detailTextLabel.text = [specifier subtitleForValue:on ? @"YES" : @"NO"];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged
														object:self
													  userInfo:@{(id)specifier.key: [self.settingsStore objectForSpecifier:specifier] ?: NSNull.null}];
}

- (void)sliderChangedValue:(id)sender {
	IASKSlider *slider = (IASKSlider*)sender;
	[self.settingsStore setFloat:slider.value forSpecifier:slider.specifier];
	[[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged
														object:self
													  userInfo:@{(id)slider.specifier.key: @(slider.value)}];
}

- (void)datePickerChangedValue:(IASKDatePicker*)datePicker {
	datePicker.editing = YES;
	if ([self.delegate respondsToSelector:@selector(settingsViewController:setDate:forSpecifier:)]) {
		[self.delegate settingsViewController:self setDate:datePicker.date forSpecifier:datePicker.specifier];
	} else {
		[self.settingsStore setObject:datePicker.date forSpecifier:datePicker.specifier];
	}
	datePicker.editing = NO;
}

#pragma mark -
#pragma mark UITableView Functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.settingsReader numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.settingsReader numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
	if ([specifier.type isEqualToString:kIASKTextViewSpecifier]) {
		CGFloat height = (CGFloat)[self.rowHeights[(id)specifier.key] doubleValue];
		return height > 0 ? height : UITableViewAutomaticDimension;
	} else if ([specifier.type isEqualToString:kIASKCustomViewSpecifier]) {
		if ([self.delegate respondsToSelector:@selector(settingsViewController:heightForSpecifier:)]) {
			return [self.delegate settingsViewController:self heightForSpecifier:specifier];
		}
	}
	return UITableViewAutomaticDimension;
}

- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
	IASKSpecifier *specifier = [self.settingsReader headerSpecifierForSection:section];
	NSString *headerText = nil;
	if (specifier && [self.delegate respondsToSelector:@selector(settingsViewController:titleForHeaderInSection:specifier:)]) {
		headerText = [self.delegate settingsViewController:self titleForHeaderInSection:section specifier:specifier];
	}
	
    if (headerText.length == 0) {
        headerText = [self.settingsReader titleForSection:section];
    }
    return (headerText.length != 0) ? headerText : nil;
}

- (UIView *)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
	IASKSpecifier *specifier = [self.settingsReader headerSpecifierForSection:section];
	if (specifier && [self.delegate respondsToSelector:@selector(settingsViewController:viewForHeaderInSection:specifier:)]) {
		return [self.delegate settingsViewController:self viewForHeaderInSection:section specifier:specifier];
	} else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
	IASKSpecifier *specifier = [self.settingsReader headerSpecifierForSection:section];
	if (specifier && [self tableView:tableView viewForHeaderInSection:section] && [self.delegate respondsToSelector:@selector(settingsViewController:heightForHeaderInSection:specifier:)]) {
		CGFloat result = [self.delegate settingsViewController:self heightForHeaderInSection:section specifier:specifier];
		if (result > 0) {
			return result;
		}
	}
	return section > 0 || [self tableView:tableView titleForHeaderInSection:section].length ? UITableViewAutomaticDimension : 34;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	IASKSpecifier *specifier = [self.settingsReader headerSpecifierForSection:section];
	NSString *footerText = nil;
	if ([self.delegate respondsToSelector:@selector(settingsViewController:titleForFooterInSection:specifier:)]) {
		footerText = [self.delegate settingsViewController:self titleForFooterInSection:section specifier:specifier];
	}
    if (footerText.length == 0) {
        footerText = [self.settingsReader footerTextForSection:section];
    }
    
	if (_showCreditsFooter && (section == [self.settingsReader numberOfSections]-1)) {
		// show credits since this is the last section
		if (footerText.length == 0) {
			// show the credits on their own
			return kIASKCredits;
		} else {
			// show the credits below the app's FooterText
			return [NSString stringWithFormat:@"%@\n\n%@", footerText, kIASKCredits];
		}
	} else {
		return footerText;
	}
}

- (UIView *)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section {
	IASKSpecifier *specifier = [self.settingsReader headerSpecifierForSection:section];
    if (specifier && [self.delegate respondsToSelector:@selector(settingsViewController:viewForFooterInSection:specifier:)]) {
        return [self.delegate settingsViewController:self viewForFooterInSection:section specifier:specifier];
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
	IASKSpecifier *specifier = [self.settingsReader headerSpecifierForSection:section];
	if (specifier && [self tableView:tableView viewForFooterInSection:section] && [self.delegate respondsToSelector:@selector(settingsViewController:heightForFooterInSection:specifier:)]) {
        CGFloat result = [self.delegate settingsViewController:self heightForFooterInSection:section specifier:specifier];
        if (result > 0) {
            return result;
        }
    }
    return UITableViewAutomaticDimension;
}

- (UITableViewCell*)tableView:(UITableView *)tableView newCellForSpecifier:(IASKSpecifier*)specifier {

	NSString *identifier = [NSString stringWithFormat:@"%@-%ld-%d-%d", specifier.type, (long)specifier.textAlignment, !!specifier.hasSubtitle, specifier.embeddedDatePicker];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell) {
		return cell;
	}
	UITableViewCellStyle style = (specifier.textAlignment == NSTextAlignmentLeft || specifier.hasSubtitle) ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault;
	if ([identifier hasPrefix:kIASKPSToggleSwitchSpecifier]) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
	}
	else if (specifier.embeddedDatePicker) {
		cell = [[IASKEmbeddedDatePickerViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		[((IASKDatePickerViewCell*)cell).datePicker addTarget:self action:@selector(datePickerChangedValue:) forControlEvents:UIControlEventValueChanged];
}
	else if ([@[kIASKPSMultiValueSpecifier, kIASKPSTitleValueSpecifier, kIASKDatePickerSpecifier] containsObject:specifier.type]) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
		cell.accessoryType = [identifier hasPrefix:kIASKPSMultiValueSpecifier] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	}
	else if ([identifier hasPrefix:kIASKPSTextFieldSpecifier]) {
		cell = [[IASKPSTextFieldSpecifierViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		[((IASKPSTextFieldSpecifierViewCell*)cell).textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
	}
	else if ([identifier hasPrefix:kIASKTextViewSpecifier]) {
        cell = [[IASKTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	else if ([identifier hasPrefix:kIASKPSSliderSpecifier]) {
        cell = [[IASKPSSliderSpecifierViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	} else if ([identifier hasPrefix:kIASKPSChildPaneSpecifier]) {
		if (!specifier.hasSubtitle) {
			style = UITableViewCellStyleValue1;
		}
		cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if ([identifier hasPrefix:kIASKDatePickerControl]) {
		cell = [[IASKDatePickerViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		[((IASKDatePickerViewCell*)cell).datePicker addTarget:self action:@selector(datePickerChangedValue:) forControlEvents:UIControlEventValueChanged];
	} else {
		cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier];
	}
    cell.textLabel.minimumScaleFactor = kIASKMinimumFontSize / cell.textLabel.font.pointSize;
    cell.detailTextLabel.minimumScaleFactor = kIASKMinimumFontSize / cell.detailTextLabel.font.pointSize;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
	if ([specifier.type isEqualToString:kIASKCustomViewSpecifier] && [self.delegate respondsToSelector:@selector(settingsViewController:cellForSpecifier:)]) {
		UITableViewCell* cell = [self.delegate settingsViewController:self cellForSpecifier:specifier];
		assert(nil != cell && "delegate must return a UITableViewCell for custom cell types");
		return cell;
	}
	
	UITableViewCell* cell = [self tableView:tableView newCellForSpecifier:specifier];
	id currentValue = [self.settingsStore objectForSpecifier:specifier];
	NSString *title = specifier.title;
	
	if ([specifier.type isEqualToString:kIASKPSToggleSwitchSpecifier]) {
		cell.textLabel.text = title;

		BOOL toggleState;
		if (currentValue) {
			if ([currentValue isEqual:specifier.trueValue]) {
				toggleState = YES;
			} else if ([currentValue isEqual:specifier.falseValue]) {
				toggleState = NO;
			} else {
				toggleState = [currentValue respondsToSelector:@selector(boolValue)] ? [currentValue boolValue] : NO;
			}
		} else {
			toggleState = specifier.defaultBoolValue;
		}
		cell.detailTextLabel.text = [specifier subtitleForValue:toggleState ? @"YES" : @"NO"];
		if (specifier.toggleStyle == IASKToggleStyleSwitch) {
			IASKSwitch *toggle = [[IASKSwitch alloc] initWithFrame:CGRectMake(0, 0, 79, 27)];
			[toggle addTarget:self action:@selector(toggledValue:) forControlEvents:UIControlEventValueChanged];
			toggle.on = toggleState;
			toggle.specifier = specifier;
			cell.accessoryView = toggle;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		} else {
			cell.accessoryType = toggleState ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleDefault;
		}
	}
	else if ([specifier.type isEqualToString:kIASKPSMultiValueSpecifier]) {
		[self setMultiValuesFromDelegateIfNeeded:specifier];

		BOOL hasTitle = title.length > 0 && !specifier.isItemSpecifier;
		cell.detailTextLabel.text = [[specifier titleForCurrentValue:currentValue ?: specifier.defaultValue] description];
		if (hasTitle) {
			cell.textLabel.text = title;
		} else {
			cell.textLabel.text = cell.detailTextLabel.text;
			cell.detailTextLabel.text = nil;
		}
	}
	else if (specifier.embeddedDatePicker) {
		IASKEmbeddedDatePickerViewCell *datePickerCell = (id)cell;
		datePickerCell.titleLabel.text = title;
		datePickerCell.datePicker.specifier = specifier;
		datePickerCell.datePicker.datePickerMode = specifier.datePickerMode;
		if (@available(iOS 14.0, *)) {
			datePickerCell.datePicker.preferredDatePickerStyle = specifier.datePickerStyle;
		}
		datePickerCell.datePicker.minuteInterval = specifier.datePickerMinuteInterval;
		if ([self.delegate respondsToSelector:@selector(settingsViewController:dateForSpecifier:)]) {
			datePickerCell.datePicker.date = [self.delegate settingsViewController:self dateForSpecifier:specifier];
		} else {
			datePickerCell.datePicker.date = currentValue ?: NSDate.date;
		}
	}
	else if ([@[kIASKPSTitleValueSpecifier, kIASKDatePickerSpecifier] containsObject:specifier.type]) {
		cell.textLabel.text = title;
		id value = currentValue ?: specifier.defaultValue;
		
		if ([specifier.type isEqualToString:kIASKDatePickerSpecifier] && [self.delegate respondsToSelector:@selector(settingsViewController:datePickerTitleForSpecifier:)]) {
			value = [self.delegate settingsViewController:self datePickerTitleForSpecifier:specifier];
		}
		NSString *stringValue;
		if (specifier.multipleValues || specifier.multipleTitles) {
			stringValue = [specifier titleForCurrentValue:value];
		} else {
			stringValue = [value description];
		}
		
		if (specifier.textAlignment == NSTextAlignmentLeft) {
			cell.textLabel.text = stringValue;
		} else {
			cell.detailTextLabel.text = stringValue;
		}
		cell.userInteractionEnabled = [specifier.type isEqualToString:kIASKDatePickerSpecifier];
		if ([specifier.type isEqualToString:kIASKDatePickerSpecifier]) {
			cell.detailTextLabel.textColor = [specifier isEqual:self.settingsReader.selectedSpecifier] ? [UILabel appearanceWhenContainedInInstancesOfClasses:@[UITableViewCell.class]].textColor : self.tintColor;
		}
	}
	else if ([specifier.type isEqualToString:kIASKPSTextFieldSpecifier]) {
		cell.textLabel.text = title;
		
		NSString *textValue = currentValue ?: specifier.defaultStringValue;
		if (textValue && ![textValue isMemberOfClass:[NSString class]]) {
			textValue = [NSString stringWithFormat:@"%@", textValue];
		}
		IASKTextField *textField = ((IASKPSTextFieldSpecifierViewCell*)cell).textField;
		textField.text = textValue;
		textField.specifier = specifier;
		textField.delegate = self;
		if ([self.delegate respondsToSelector:@selector(settingsViewController:validateSpecifier:textField:previousValue:replacement:)]) {
			NSString *replacement = textField.text ?: @"";
			IASKValidationResult result = [self.delegate settingsViewController:self validateSpecifier:specifier textField:textField previousValue:textValue replacement:&replacement];
			if (result != IASKValidationResultOk) {
				textField.text = replacement;
			}
		}
	}
	else if ([specifier.type isEqualToString:kIASKTextViewSpecifier]) {
		IASKTextViewCell *textCell = (id)cell;
		NSString *value = currentValue ?: specifier.defaultStringValue;
		textCell.textView.text = value;
		textCell.textView.delegate = self;
		textCell.textView.specifier = specifier;
		textCell.textView.keyboardType = specifier.keyboardType;
		textCell.textView.autocapitalizationType = specifier.autocapitalizationType;
		textCell.textView.autocorrectionType = specifier.autoCorrectionType;
		textCell.textView.placeholder = specifier.placeholder;
		
		dispatch_async(dispatch_get_main_queue(), ^{
            [self cacheRowHeightForTextView:textCell.textView animated:NO];
		});
	}
	else if ([specifier.type isEqualToString:kIASKPSSliderSpecifier]) {
		if (specifier.minimumValueImage.length > 0) {
			NSString *path = [self.settingsReader pathForImageNamed:(id)specifier.minimumValueImage];
			((IASKPSSliderSpecifierViewCell*)cell).minImage.image = [UIImage imageWithContentsOfFile:path];
		}
		
		if (specifier.maximumValueImage.length > 0) {
			NSString *path = [self.settingsReader pathForImageNamed:(id)specifier.maximumValueImage];
			((IASKPSSliderSpecifierViewCell*)cell).maxImage.image = [UIImage imageWithContentsOfFile:path];
		}
		
		IASKSlider *slider = ((IASKPSSliderSpecifierViewCell*)cell).slider;
		slider.minimumValue = specifier.minimumValue;
		slider.maximumValue = specifier.maximumValue;
		slider.value = currentValue ? [currentValue floatValue] : [specifier.defaultValue floatValue];
		[slider addTarget:self action:@selector(sliderChangedValue:) forControlEvents:UIControlEventValueChanged];
		slider.specifier = specifier;
		[cell setNeedsLayout];
	}
	else if ([specifier.type isEqualToString:kIASKPSChildPaneSpecifier]) {
		cell.textLabel.text = title;
		if (specifier.hasSubtitle) {
			cell.detailTextLabel.text = [specifier subtitleForValue:currentValue];
		} else if (specifier.key) {
			NSString *valueString = currentValue ?: specifier.defaultValue;
			valueString = [valueString isKindOfClass:NSString.class] ? valueString : nil;
			if (valueString) {
				if (specifier.textAlignment == NSTextAlignmentLeft) {
					cell.textLabel.text = [self.settingsReader titleForId:valueString];
				} else {
					cell.detailTextLabel.text = [self.settingsReader titleForId:valueString];
				}
			}
		}
	} else if ([@[kIASKMailComposeSpecifier, kIASKOpenURLSpecifier] containsObject:specifier.type]) {
		cell.textLabel.text = title;
		cell.detailTextLabel.text = [specifier subtitleForValue:currentValue] ? : [specifier.defaultValue description];
		cell.accessoryType = (specifier.textAlignment == NSTextAlignmentLeft) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	} else if ([specifier.type isEqualToString:kIASKButtonSpecifier]) {
		cell.textLabel.text = ([currentValue isKindOfClass:NSString.class] && [self.settingsReader titleForId:currentValue].length) ? [self.settingsReader titleForId:currentValue] : title;
		cell.detailTextLabel.text = [specifier subtitleForValue:currentValue];
		cell.textLabel.textAlignment = specifier.textAlignment;
		cell.accessoryType = (specifier.textAlignment == NSTextAlignmentLeft) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	} else if ([specifier.type isEqualToString:kIASKPSRadioGroupSpecifier]) {
		NSInteger index = [specifier.multipleValues indexOfObject:(id)specifier.radioGroupValue];
		cell.textLabel.text = [self.settingsReader titleForId:specifier.multipleTitles[index]];
		[_selections[indexPath.section] updateSelectionInCell:cell indexPath:indexPath];
	} else if ([specifier.type isEqualToString:kIASKDatePickerControl]) {
		IASKDatePickerViewCell *datePickerCell = (id)cell;
		datePickerCell.datePicker.specifier = specifier;
		datePickerCell.datePicker.datePickerMode = specifier.datePickerMode;
		if (@available(iOS 14.0, *)) {
			datePickerCell.datePicker.preferredDatePickerStyle = specifier.datePickerStyle;
		}
		datePickerCell.datePicker.minuteInterval = specifier.datePickerMinuteInterval;
		if ([self.delegate respondsToSelector:@selector(settingsViewController:dateForSpecifier:)]) {
			datePickerCell.datePicker.date = [self.delegate settingsViewController:self dateForSpecifier:specifier];
		} else {
			datePickerCell.datePicker.date = currentValue ?: NSDate.date;
		}
	} else {
		cell.textLabel.text = title;
	}
    
	cell.imageView.image = specifier.cellImage;
	cell.imageView.highlightedImage = specifier.highlightedCellImage;
    
	if (![@[kIASKPSMultiValueSpecifier, kIASKPSTitleValueSpecifier, kIASKPSTextFieldSpecifier, kIASKTextViewSpecifier] containsObject:specifier.type]) {
		cell.textLabel.textAlignment = specifier.textAlignment;
	}
	cell.detailTextLabel.textAlignment = specifier.textAlignment;
	cell.textLabel.adjustsFontSizeToFitWidth = specifier.adjustsFontSizeToFitWidth;
	cell.detailTextLabel.adjustsFontSizeToFitWidth = specifier.adjustsFontSizeToFitWidth;
	cell.textLabel.textColor = (specifier.isAddSpecifier || specifier.textAlignment == NSTextAlignmentCenter) ? self.tintColor : [UILabel appearanceWhenContainedInInstancesOfClasses:@[UITableViewCell.class]].textColor;
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
	if ([specifier.type isEqualToString:kIASKPSSliderSpecifier] || ([specifier.type isEqualToString:kIASKPSToggleSwitchSpecifier] && specifier.toggleStyle == IASKToggleStyleSwitch) || specifier.embeddedDatePicker) {
		return nil;
	} else {
		return indexPath;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath NS_EXTENSION_UNAVAILABLE("Uses APIs (i.e UIApplication.sharedApplication) not available for use in App Extensions.") {
    IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
    
    //switches and sliders can't be selected (should be captured by tableView:willSelectRowAtIndexPath: delegate method)
	assert(![specifier.type isEqualToString:kIASKPSSliderSpecifier]);
    
	if (![@[kIASKPSChildPaneSpecifier, kIASKCustomViewSpecifier, kIASKPSRadioGroupSpecifier, ] containsObject:specifier.type]) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}

	[tableView beginUpdates];
	if ([specifier.type isEqualToString:kIASKDatePickerSpecifier]) {
		[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
	IASKSpecifier *selectedSpecifier = self.settingsReader.selectedSpecifier;
	if (selectedSpecifier.key) {
		NSIndexPath *oldIndexPath = [self.settingsReader indexPathForKey:(id)selectedSpecifier.key];
		self.settingsReader.selectedSpecifier = nil;
		[tableView reloadRowsAtIndexPaths:@[oldIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		[tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldIndexPath.row + 1 inSection:oldIndexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
		if (oldIndexPath.section == indexPath.section && oldIndexPath.row < indexPath.row) {
			indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
		}
	}

    if ([specifier.type isEqualToString:kIASKPSMultiValueSpecifier]) {
		IASKSpecifier *childSpecifier = [[IASKSpecifier alloc] initWithSpecifier:specifier.specifierDict];
		childSpecifier.settingsReader = self.settingsReader;
		IASKSpecifierValuesViewController *targetViewController = [[IASKSpecifierValuesViewController alloc] initWithSpecifier:childSpecifier style:self.tableView.style];
        targetViewController.view.backgroundColor = self.view.backgroundColor;
		targetViewController.settingsReader = self.settingsReader;
		[self setMultiValuesFromDelegateIfNeeded:childSpecifier];

		[self presentChildViewController:targetViewController specifier:specifier indexPath:indexPath];
		
	} else if ([specifier.type isEqualToString:kIASKPSToggleSwitchSpecifier]) {
		UITableViewCell *cell =	[tableView cellForRowAtIndexPath:indexPath];
		BOOL on = cell.accessoryType == UITableViewCellAccessoryCheckmark;
		[self setSpecifier:specifier on:!on];
		cell.accessoryType = on ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
		
	} else if ([specifier.type isEqualToString:kIASKPSTextFieldSpecifier]) {
        IASKPSTextFieldSpecifierViewCell *textFieldCell = (id)[tableView cellForRowAtIndexPath:indexPath];
        [textFieldCell.textField becomeFirstResponder];		
	} else if ([specifier.type isEqualToString:kIASKPSChildPaneSpecifier] || ([specifier.type isEqualToString:kIASKCustomViewSpecifier] && (specifier.file || specifier.viewControllerStoryBoardID || specifier.viewControllerClass || specifier.segueIdentifier))) {
		if (specifier.viewControllerStoryBoardID){
            NSString *storyBoardFileFromSpecifier = [specifier viewControllerStoryBoardFile];
            storyBoardFileFromSpecifier = storyBoardFileFromSpecifier && storyBoardFileFromSpecifier.length > 0 ? storyBoardFileFromSpecifier : [[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyBoardFileFromSpecifier bundle:nil];
			UIViewController * vc = [storyBoard instantiateViewControllerWithIdentifier:(id)specifier.viewControllerStoryBoardID];
            vc.view.tintColor = self.tintColor;
            [self.navigationController pushViewController:vc animated:YES];
			[tableView endUpdates];
            return;
        }
        
        Class vcClass = [specifier viewControllerClass];
        if (vcClass) {
			if (vcClass == [NSNull class]) {
				NSLog(@"class '%@' not found", [specifier localizedObjectForKey:kIASKViewControllerClass]);
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				[tableView endUpdates];
				return;
			}
            SEL initSelector = [specifier viewControllerSelector];
            if (!initSelector) {
                initSelector = @selector(init);
            }
            UIViewController * vc = [vcClass alloc];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			vc = [vc performSelector:initSelector withObject:specifier.file withObject:specifier];
#pragma clang diagnostic pop
            if ([vc respondsToSelector:@selector(setDelegate:)]) {
                [vc performSelector:@selector(setDelegate:) withObject:self.delegate];
            }
            if ([vc respondsToSelector:@selector(setSettingsStore:)]) {
                [vc performSelector:@selector(setSettingsStore:) withObject:self.settingsStore];
            }
            vc.view.tintColor = self.tintColor;
            [self.navigationController pushViewController:vc animated:YES];
			[tableView endUpdates];
            return;
		}
			
		NSString *segueIdentifier = specifier.segueIdentifier;
        if (segueIdentifier) {
			@try {
				[self performSegueWithIdentifier:segueIdentifier sender:self];
			} @catch (NSException *exception) {
				NSLog(@"segue with identifier '%@' not defined", segueIdentifier);
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
			}
			[tableView endUpdates];
            return;
        }
        
        if (!specifier.file) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
			[tableView endUpdates];
            return;
        }
        
        _reloadDisabled = YES; // Disable internal unnecessary reloads
        IASKAppSettingsViewController *targetViewController =
            [((IASKAppSettingsViewController*)[[self class] alloc]) initWithStyle:self.tableView.style];
        targetViewController.showDoneButton = NO;
        targetViewController.showCreditsFooter = NO; // Does not reload the tableview (but next setters do it)
        targetViewController.delegate = self.delegate;
        targetViewController.file = (id)specifier.file;
        targetViewController.hiddenKeys = self.hiddenKeys;
        targetViewController.title = specifier.title;
		targetViewController.view.backgroundColor = self.view.backgroundColor;
        _currentChildViewController = targetViewController;
        
        _reloadDisabled = NO;
		
		if ([specifier.parentSpecifier.type isEqualToString:kIASKListGroupSpecifier]) {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
		[self presentChildViewController:targetViewController specifier:specifier indexPath:indexPath];
        
	} else if ([specifier.type isEqualToString:kIASKOpenURLSpecifier]) {
		NSString *urlString = [specifier localizedObjectForKey:kIASKFile];
		NSURL *url = urlString ? [NSURL URLWithString:urlString] : nil;
		if (url) {
			IASK_IF_IOS11_OR_GREATER([UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];);
			IASK_IF_PRE_IOS11([UIApplication.sharedApplication openURL:url];);
		}
	} else if ([specifier.type isEqualToString:kIASKButtonSpecifier]) {
        if ([self.delegate respondsToSelector:@selector(settingsViewController:buttonTappedForSpecifier:)]) {
            [self.delegate settingsViewController:self buttonTappedForSpecifier:specifier];
        }
    } else if ([specifier.type isEqualToString:kIASKMailComposeSpecifier]) {
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
		if ([specifier localizedObjectForKey:kIASKMailComposeSubject]) {
			[mailViewController setSubject:(id)[specifier localizedObjectForKey:kIASKMailComposeSubject]];
		}
		if ([specifier.specifierDict objectForKey:kIASKMailComposeToRecipents]) {
			[mailViewController setToRecipients:[specifier.specifierDict objectForKey:kIASKMailComposeToRecipents]];
		}
		if ([specifier.specifierDict objectForKey:kIASKMailComposeCcRecipents]) {
			[mailViewController setCcRecipients:[specifier.specifierDict objectForKey:kIASKMailComposeCcRecipents]];
		}
		if ([specifier.specifierDict objectForKey:kIASKMailComposeBccRecipents]) {
			[mailViewController setBccRecipients:[[specifier specifierDict] objectForKey:kIASKMailComposeBccRecipents]];
		}
		if ([specifier localizedObjectForKey:kIASKMailComposeBody]) {
			BOOL isHTML = NO;
			if ([specifier.specifierDict objectForKey:kIASKMailComposeBodyIsHTML]) {
				isHTML = [[specifier.specifierDict objectForKey:kIASKMailComposeBodyIsHTML] boolValue];
			}
			if ([specifier localizedObjectForKey:kIASKMailComposeBody]) {
				[mailViewController setMessageBody:(id)[specifier localizedObjectForKey:kIASKMailComposeBody] isHTML:isHTML];
			}
		}
		
		if ([self.delegate respondsToSelector:@selector(settingsViewController:shouldPresentMailComposeViewController:forSpecifier:)]) {
			BOOL shouldPresent = [self.delegate settingsViewController:self shouldPresentMailComposeViewController:mailViewController forSpecifier:specifier];
			if (!shouldPresent) {
				[tableView endUpdates];
				return;
			}
		}
		
		if ([MFMailComposeViewController canSendMail]) {
			mailViewController.mailComposeDelegate = self;
            _currentChildViewController = mailViewController;
#if !TARGET_OS_MACCATALYST
            UIStatusBarStyle savedStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
#endif
            [self presentViewController:mailViewController animated:YES completion:^{
#if !TARGET_OS_MACCATALYST
			    [UIApplication sharedApplication].statusBarStyle = savedStatusBarStyle;
#endif
            }];
			
        } else {
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"Mail not configured", @"IASKLocalizable", self.settingsReader.iaskBundle, @"warning title")
																		   message:NSLocalizedStringFromTableInBundle(@"This device is not configured for sending Email. Please configure the Mail settings in the Settings app.", @"IASKLocalizable", self.settingsReader.iaskBundle, @"warning message")
																	preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"OK", @"IASKLocalizable", self.settingsReader.iaskBundle, @"InAppSettingsKit") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
			[self presentViewController:alert animated:YES completion:nil];
		}
        
    } else if ([specifier.type isEqualToString:kIASKCustomViewSpecifier] && [self.delegate respondsToSelector:@selector(settingsViewController:didSelectCustomViewSpecifier:)]) {
        [self.delegate settingsViewController:self didSelectCustomViewSpecifier:specifier];
	} else if ([specifier.type isEqualToString:kIASKPSRadioGroupSpecifier]) {
		[_selections[indexPath.section] selectRowAtIndexPath:indexPath];
	} else if ([specifier.type isEqualToString:kIASKDatePickerSpecifier]) {
		if (![selectedSpecifier isEqual:specifier]) {
			self.settingsReader.selectedSpecifier = specifier;
			NSIndexPath *insertedIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
			[tableView insertRowsAtIndexPaths:@[insertedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^{
				[tableView scrollToRowAtIndexPath:insertedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
			});
		}
    }
	[tableView endUpdates];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
	return specifier.parentSpecifier.deletable && specifier.isItemSpecifier;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
	[self.settingsStore removeObjectWithSpecifier:specifier];
	[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

	NSDictionary *userInfo = specifier.parentSpecifier.key && [self.settingsStore objectForSpecifier:(id)specifier.parentSpecifier] ? @{(id)specifier.parentSpecifier.key: [self.settingsStore objectForSpecifier:(id)specifier.parentSpecifier] ?: @[]} : nil;
	[NSNotificationCenter.defaultCenter postNotificationName:kIASKAppSettingChanged object:self userInfo:userInfo];
}

- (void)presentChildViewController:(UITableViewController<IASKViewController> *)targetViewController specifier:(IASKSpecifier *)specifier indexPath:(NSIndexPath*)indexPath {
	targetViewController.tableView.cellLayoutMarginsFollowReadableWidth = self.cellLayoutMarginsFollowReadableWidth;
	_currentChildViewController = targetViewController;
	targetViewController.settingsStore = self.settingsStore;
	targetViewController.view.tintColor = self.tintColor;
	if ([specifier.parentSpecifier.type isEqualToString:kIASKListGroupSpecifier]) {
		NSDictionary *itemDict = @{};
		if (!specifier.isAddSpecifier) {
			id value = [self.settingsStore objectForSpecifier:specifier];
			if ([value isKindOfClass:NSDictionary.class]) {
				itemDict = value;
			} else if (specifier.key && value) {
				itemDict = @{(id)specifier.key: value};
			}
		}
		IASKSettingsStoreInMemory *inMemoryStore = [[IASKSettingsStoreInMemory alloc] initWithDictionary:itemDict];
		targetViewController.settingsStore = inMemoryStore;
		targetViewController.listParentViewController = self;
		[targetViewController.settingsReader applyDefaultsToStore];
		UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:targetViewController];
		navCtrl.modalPresentationStyle = self.navigationController.modalPresentationStyle;
		navCtrl.popoverPresentationController.sourceView = [self.tableView cellForRowAtIndexPath:indexPath];
		targetViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(listItemCancel:)];
		targetViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(listItemDone:)];
		[self.navigationController presentViewController:navCtrl animated:YES completion:nil];
		
		__weak typeof(self)weakSelf = self;
		self.childPaneHandler = ^(BOOL doneEditing){
			if (!doneEditing) {
				if ([weakSelf.delegate respondsToSelector:@selector(settingsViewController:childPaneIsValidForSpecifier:contentDictionary:)]) {
					NSDictionary *oldContent = inMemoryStore.dictionary.copy;
					BOOL valid = [weakSelf.delegate settingsViewController:weakSelf childPaneIsValidForSpecifier:specifier contentDictionary:inMemoryStore.dictionary];
					if (![oldContent isEqualToDictionary:inMemoryStore.dictionary]) {
						[targetViewController.tableView reloadData];
						valid = [weakSelf.delegate settingsViewController:weakSelf childPaneIsValidForSpecifier:specifier contentDictionary:inMemoryStore.dictionary];
					}
					targetViewController.navigationItem.rightBarButtonItem.enabled = valid;
				}
				return;
			}
			if ([targetViewController respondsToSelector:@selector(currentFirstResponder)]) {
				[targetViewController.currentFirstResponder resignFirstResponder];
			}
			if (specifier.isAddSpecifier) {
				[weakSelf.settingsStore addObject:inMemoryStore.dictionary forSpecifier:specifier];
			} else {
				[weakSelf.settingsStore setObject:inMemoryStore.dictionary forSpecifier:specifier];
			}
			NSDictionary *userInfo = specifier.parentSpecifier.key && [weakSelf.settingsStore objectForSpecifier:(id)specifier.parentSpecifier] ? @{(id)specifier.parentSpecifier.key: (id)[weakSelf.settingsStore objectForSpecifier:(id)specifier.parentSpecifier]} : nil;
			[NSNotificationCenter.defaultCenter postNotificationName:kIASKAppSettingChanged object:weakSelf userInfo:userInfo];
			[weakSelf.tableView reloadData];
		};
		self.childPaneHandler(NO); // perform initial validation
	} else {
		[[self navigationController] pushViewController:targetViewController animated:YES];
	}
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate Function

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    // Forward the mail compose delegate
    if ([self.delegate respondsToSelector:@selector(settingsViewController:mailComposeController:didFinishWithResult:error:)]) {
         [self.delegate settingsViewController:self 
                         mailComposeController:controller 
                           didFinishWithResult:result 
                                         error:error];
    }
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark -
#pragma mark UITextFieldDelegate Functions

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.currentFirstResponder = textField;
}

- (void)textChanged:(IASKTextField*)textField {
    // Wait with setting the property until editing ends for the addSpecifier of list groups or if a validation delegate is implemented
    if ((!textField.specifier.isAddSpecifier && ![self.delegate respondsToSelector:@selector(settingsViewController:validateSpecifier:textField:previousValue:replacement:)]) ||
		(self.listParentViewController && [self.delegate respondsToSelector:@selector(settingsViewController:childPaneIsValidForSpecifier:contentDictionary:)]))
	{
		[self.settingsStore setObject:textField.text forSpecifier:textField.specifier];
        NSDictionary *userInfo = textField.specifier.key && textField.text ? @{(id)textField.specifier.key : (NSString *)textField.text} : nil;
        [NSNotificationCenter.defaultCenter postNotificationName:kIASKAppSettingChanged
                                                          object:self
                                                        userInfo:userInfo];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	self.currentFirstResponder = nil;
	return YES;
}

- (void)singleTapToEndEdit:(UIGestureRecognizer *)sender {
    [self.tableView endEditing:NO];
}

- (void)textFieldDidEndEditing:(IASKTextField *)textField {
	IASKSpecifier *specifier = textField.specifier;
	
	NSString *replacement = textField.text ?: @"";
	IASKValidationResult result = IASKValidationResultOk;
	if ([self.delegate respondsToSelector:@selector(settingsViewController:validateSpecifier:textField:previousValue:replacement:)]) {
		result = [self.delegate settingsViewController:self validateSpecifier:specifier textField:textField previousValue:textField.oldText replacement:&replacement];
	}
	
	void (^restoreText)(void) = ^{
		if (![textField.text isEqualToString:replacement]) {
			textField.text = replacement;
			[self textChanged:textField];
		}
	};
	
	switch (result) {
		case IASKValidationResultOk: {
			if (![self.settingsStore objectForSpecifier:specifier] && textField.text.length == 0) {
				return;
			}
			[self.settingsStore setObject:textField.text forSpecifier:specifier];
			if (specifier.isAddSpecifier) {
				NSUInteger section = [self.settingsReader indexPathForKey:(id)specifier.parentSpecifier.key].section;
				NSUInteger row = [self tableView:self.tableView numberOfRowsInSection:section] - 2;
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
				[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
				indexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
				[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			}
			NSDictionary *userInfo = specifier.key && textField.text ? @{(id)specifier.key: (id)textField.text} : nil;
			[NSNotificationCenter.defaultCenter postNotificationName:kIASKAppSettingChanged
															  object:self
															userInfo:userInfo];
			break;
		}
		case IASKValidationResultFailed:
			restoreText();
			break;
			
		case IASKValidationResultFailedWithShake: {
			[textField shake];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				restoreText();
			});
		}
		default:
			break;
	}
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
	self.currentFirstResponder = textView;
}

- (void)textViewDidChange:(IASKTextView *)textView {
    [self cacheRowHeightForTextView:textView animated:YES];
	
	CGRect visibleTableRect = UIEdgeInsetsInsetRect(self.tableView.bounds, self.tableView.contentInset);
	NSIndexPath *indexPath = [self.settingsReader indexPathForKey:(id)textView.specifier.key];
	CGRect cellFrame = [self.tableView rectForRowAtIndexPath:indexPath];
	
	if (!CGRectContainsRect(visibleTableRect, cellFrame)) {
		[self.tableView scrollRectToVisible:CGRectInset(cellFrame, 0, - 30) animated:YES];
	}

	[self.settingsStore setObject:textView.text forSpecifier:textView.specifier];
	[[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged
														object:self
													  userInfo:@{(id)textView.specifier.key: textView.text}];
	
}

- (void)cacheRowHeightForTextView:(IASKTextView *)textView animated:(BOOL)animated {
	CGFloat maxHeight = self.tableView.bounds.size.height - self.tableView.contentInset.top - self.tableView.contentInset.bottom - 60;
	CGFloat contentHeight = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, 10000)].height + 16;
	self.rowHeights[(id)textView.specifier.key] = @(MAX(44, MIN(maxHeight, contentHeight)));
	textView.scrollEnabled = contentHeight > maxHeight;

    void (^actions)(void) = ^{
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    };
    
    if (animated) {
        actions();
    }
    else {
        [UIView performWithoutAnimation:actions];
    }
}

#pragma mark - List groups
- (void)listItemCancel:(id)sender {
	self.childPaneHandler = nil;
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)listItemDone:(id)sender {
	self.childPaneHandler(YES);
	self.childPaneHandler = nil;
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifications

- (void)synchronizeSettings {
	[self.settingsStore synchronize];
}

static NSMutableDictionary *oldUserDefaults = nil;
- (void)userDefaultsDidChange {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		IASKSettingsStoreUserDefaults *udSettingsStore = (id)self.settingsStore;
		NSDictionary *currentDict = udSettingsStore.defaults.dictionaryRepresentation;
		NSMutableArray *indexPathsToUpdate = [NSMutableArray array];
		for (NSString *key in currentDict.allKeys) {
			if (oldUserDefaults && ![[oldUserDefaults valueForKey:key] isEqual:[currentDict valueForKey:key]]) {
				NSIndexPath *path = [self.settingsReader indexPathForKey:key];
				if (path && ![[self.settingsReader specifierForKey:key].type isEqualToString:kIASKCustomViewSpecifier] && [self.tableView.indexPathsForVisibleRows containsObject:path]) {
					[indexPathsToUpdate addObject:path];
				}
			}
		}
		oldUserDefaults = currentDict.mutableCopy;
		
		for (UITableViewCell *cell in self.tableView.visibleCells) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
			if ([cell isKindOfClass:[IASKPSTextFieldSpecifierViewCell class]] && [((IASKPSTextFieldSpecifierViewCell*)cell).textField isFirstResponder] && indexPath) {
				[indexPathsToUpdate removeObject:indexPath];
			} else if ([cell isKindOfClass:IASKEmbeddedDatePickerViewCell.class] && !((IASKEmbeddedDatePickerViewCell*)cell).datePicker.editing) {
				[indexPathsToUpdate removeObject:indexPath];
			}
		}
		if (indexPathsToUpdate.count) {
			[self.tableView reloadRowsAtIndexPaths:indexPathsToUpdate withRowAnimation:UITableViewRowAnimationAutomatic];
		}
	});
}

- (void)didChangeSettingViaIASK:(NSNotification*)notification {
	NSString *key = notification.userInfo.allKeys.firstObject;
	if (key) {
		[oldUserDefaults setValue:notification.userInfo[key] forKey:key];
	}
	if (self.childPaneHandler) {
		self.childPaneHandler(NO);
	}
}

- (void)reload {
	// wait 0.5 sec until UI is available after applicationWillEnterForeground
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
}

- (void)setMultiValuesFromDelegateIfNeeded:(IASKSpecifier *)specifier {
	if (specifier.multipleValues.count == 0) {
		if ([self.delegate respondsToSelector:@selector(settingsViewController:valuesForSpecifier:)] &&
			[self.delegate respondsToSelector:@selector(settingsViewController:titlesForSpecifier:)])
		{
			[specifier setMultipleValuesDictValues:[self.delegate settingsViewController:self valuesForSpecifier:specifier]
											titles:[self.delegate settingsViewController:self titlesForSpecifier:specifier]];
		}
		[specifier sortIfNeeded];
	}
}


#pragma mark CGRect Utility function
CGRect IASKCGRectSwap(CGRect rect) {
	CGRect newRect;
	newRect.origin.x = rect.origin.y;
	newRect.origin.y = rect.origin.x;
	newRect.size.width = rect.size.height;
	newRect.size.height = rect.size.width;
	return newRect;
}
@end
