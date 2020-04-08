//
//  IASKAppSettingsViewController.m
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009-2010:
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
#import "IASKSettingsReader.h"
#import "IASKSettingsStoreUserDefaults.h"
#import "IASKPSSliderSpecifierViewCell.h"
#import "IASKPSTextFieldSpecifierViewCell.h"
#import "IASKSwitch.h"
#import "IASKSlider.h"
#import "IASKSpecifier.h"
#import "IASKSpecifierValuesViewController.h"
#import "IASKTextField.h"
#import "IASKTextViewCell.h"
#import "IASKMultipleValueSelection.h"

#if !__has_feature(objc_arc)
#error "IASK needs ARC"
#endif

static NSString *kIASKCredits = @"Powered by InAppSettingsKit"; // Leave this as-is!!!

#define kIASKSpecifierValuesViewControllerIndex       0
#define kIASKSpecifierChildViewControllerIndex        1

#define kIASKCreditsViewWidth                         285

CGRect IASKCGRectSwap(CGRect rect);

@interface IASKAppSettingsViewController () <UITextViewDelegate> {
    IASKSettingsReader		*_settingsReader;
    id<IASKSettingsStore>  _settingsStore;
    
    id                      _currentFirstResponder;
    __weak UIViewController *_currentChildViewController;
    BOOL _reloadDisabled;
	/// The selected index for every group (in case it's a radio group).
	NSArray *_selections;
}

@property (nonatomic, strong) id currentFirstResponder;
@property (nonatomic, strong) NSMutableDictionary *rowHeights;

- (void)_textChanged:(id)sender;
- (void)synchronizeSettings;
- (void)userDefaultsDidChange;
- (void)reload;
@end

@implementation IASKAppSettingsViewController
//synthesize properties from protocol
@synthesize settingsReader = _settingsReader;
@synthesize settingsStore = _settingsStore;
@synthesize file = _file;

#pragma mark accessors
- (IASKSettingsReader*)settingsReader {
	if (!_settingsReader) {
		_settingsReader = [[IASKSettingsReader alloc] initWithFile:self.file];
		if (self.neverShowPrivacySettings) {
			_settingsReader.showPrivacySettings = NO;
		}
	}
	return _settingsReader;
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
	for (int i = 0; i < _settingsReader.numberOfSections; i++) {
		IASKSpecifier *specifier = [self.settingsReader headerSpecifierForSection:i];
		if ([specifier.type isEqualToString:kIASKPSRadioGroupSpecifier]) {
			IASKMultipleValueSelection *selection = [[IASKMultipleValueSelection alloc] initWithSettingsStore:self.settingsStore];
			selection.tableView = self.tableView;
			selection.specifier = specifier;
			selection.section = i;
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
    if (style != UITableViewStyleGrouped) {
        NSLog(@"WARNING: only UITableViewStyleGrouped style is supported by InAppSettingsKit.");
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
	if (@available(iOS 9.0, *)) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = self.cellLayoutMarginsFollowReadableWidth;
    }
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
	
	if ([self.settingsStore isKindOfClass:[IASKSettingsStoreUserDefaults class]]) {
		NSNotificationCenter *dc = NSNotificationCenter.defaultCenter;
		IASKSettingsStoreUserDefaults *udSettingsStore = (id)self.settingsStore;
		[dc addObserver:self selector:@selector(userDefaultsDidChange) name:NSUserDefaultsDidChangeNotification object:udSettingsStore.defaults];
		[dc addObserver:self selector:@selector(didChangeSettingViaIASK:) name:kIASKAppSettingChanged object:nil];
		[self userDefaultsDidChange]; // force update in case of changes while we were hidden
	}
}

- (void)viewDidAppear:(BOOL)animated {
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

- (void)viewDidDisappear:(BOOL)animated {
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
            for (NSString *key in hideKeys) {
                NSIndexPath *indexPath = [self.settingsReader indexPathForKey:key];
                if (indexPath) {
                    [hideIndexPaths addObject:indexPath];
                }
            }
            
            // calculate sections to be deleted
            NSMutableIndexSet *hideSections = [NSMutableIndexSet indexSet];
            for (NSInteger section = 0; section < [self numberOfSectionsInTableView:self.tableView ]; section++) {
                NSInteger rowsInSection = 0;
                for (NSIndexPath *indexPath in hideIndexPaths) {
                    if (indexPath.section == section) {
                        rowsInSection++;
                    }
                }
                if (rowsInSection && rowsInSection >= [self.settingsReader numberOfRowsForSection:section]) {
                    [hideSections addIndex:section];
                }
            }
			
            // set the datasource
            self.settingsReader.hiddenKeys = theHiddenKeys;
            
            
            // calculate rows to be inserted
            NSMutableArray *showIndexPaths = [NSMutableArray array];
            for (NSString *key in showKeys) {
                NSIndexPath *indexPath = [self.settingsReader indexPathForKey:key];
                if (indexPath) {
                    [showIndexPaths addObject:indexPath];
                }
            }
            
            // calculate sections to be inserted
            NSMutableIndexSet *showSections = [NSMutableIndexSet indexSet];
            for (NSInteger section = 0; section < [self.settingsReader numberOfSections]; section++) {
                NSInteger rowsInSection = 0;
                for (NSIndexPath *indexPath in showIndexPaths) {
                    if (indexPath.section == section) {
                        rowsInSection++;
                    }
                }
                if (rowsInSection && rowsInSection >= [self.settingsReader numberOfRowsForSection:section]) {
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
	if (@available(iOS 9.0, *)) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = cellLayoutMarginsFollowReadableWidth;
    }
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

- (void)toggledValue:(id)sender {
    IASKSwitch *toggle    = (IASKSwitch*)sender;
    IASKSpecifier *spec   = [_settingsReader specifierForKey:[toggle key]];
    
    if ([toggle isOn]) {
        if ([spec trueValue] != nil) {
            [self.settingsStore setObject:[spec trueValue] forKey:[toggle key]];
        }
        else {
            [self.settingsStore setBool:YES forKey:[toggle key]]; 
        }
    }
    else {
        if ([spec falseValue] != nil) {
            [self.settingsStore setObject:[spec falseValue] forKey:[toggle key]];
        }
        else {
            [self.settingsStore setBool:NO forKey:[toggle key]]; 
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:[self.settingsStore objectForKey:[toggle key]]
                                                                                           forKey:[toggle key]]];
}

- (void)sliderChangedValue:(id)sender {
    IASKSlider *slider = (IASKSlider*)sender;
    [self.settingsStore setFloat:[slider value] forKey:[slider key]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:[slider value]]
                                                                                           forKey:[slider key]]];
}


#pragma mark -
#pragma mark UITableView Functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.settingsReader numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.settingsReader numberOfRowsForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
	if ([specifier.type isEqualToString:kIASKTextViewSpecifier]) {
		CGFloat height = (CGFloat)[self.rowHeights[specifier.key] doubleValue];
		return height > 0 ? height : UITableViewAutomaticDimension;
	} else if ([[specifier type] isEqualToString:kIASKCustomViewSpecifier]) {
		if ([self.delegate respondsToSelector:@selector(tableView:heightForSpecifier:)]) {
			return [self.delegate tableView:tableView heightForSpecifier:specifier];
		}
	}
	return UITableViewAutomaticDimension;
}

- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = [self.delegate respondsToSelector:@selector(settingsViewController:tableView:titleForHeaderForSection:)] ? [self.delegate settingsViewController:self tableView:tableView titleForHeaderForSection:section] : nil;
    if (headerText.length == 0) {
        headerText = [self.settingsReader titleForSection:section];
    }
    return (headerText.length != 0) ? headerText : nil;
}

- (UIView *)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
	if ([self.delegate respondsToSelector:@selector(settingsViewController:tableView:viewForHeaderForSection:)]) {
		return [self.delegate settingsViewController:self tableView:tableView viewForHeaderForSection:section];
	} else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
	if ([self tableView:tableView viewForHeaderInSection:section] && [self.delegate respondsToSelector:@selector(settingsViewController:tableView:heightForHeaderForSection:)]) {
		CGFloat result = [self.delegate settingsViewController:self tableView:tableView heightForHeaderForSection:section];
		if (result > 0) {
			return result;
		}
	}
	return section > 0 || [self tableView:tableView titleForHeaderInSection:section].length ? UITableViewAutomaticDimension : 34;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *footerText = [self.delegate respondsToSelector:@selector(settingsViewController:tableView:titleForFooterForSection:)] ? [self.delegate settingsViewController:self tableView:tableView titleForFooterForSection:section] : nil;
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
    if ([self.delegate respondsToSelector:@selector(settingsViewController:tableView:viewForFooterForSection:)]) {
        return [self.delegate settingsViewController:self tableView:tableView viewForFooterForSection:section];
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    if ([self tableView:tableView viewForFooterInSection:section] && [self.delegate respondsToSelector:@selector(settingsViewController:tableView:heightForFooterForSection:)]) {
        CGFloat result = [self.delegate settingsViewController:self tableView:tableView heightForFooterForSection:section];
        if (result > 0) {
            return result;
        }
    }
    return UITableViewAutomaticDimension;
}

- (UITableViewCell*)tableView:(UITableView *)tableView newCellForSpecifier:(IASKSpecifier*)specifier {

	NSString *identifier = [NSString stringWithFormat:@"%@-%ld-%d", specifier.type, (long)specifier.textAlignment, !!specifier.subtitle.length];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell) {
		return cell;
	}
	UITableViewCellStyle style = (specifier.textAlignment == NSTextAlignmentLeft || specifier.subtitle.length) ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault;
	if ([identifier hasPrefix:kIASKPSToggleSwitchSpecifier]) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
		cell.accessoryView = [[IASKSwitch alloc] initWithFrame:CGRectMake(0, 0, 79, 27)];
		[((IASKSwitch*)cell.accessoryView) addTarget:self action:@selector(toggledValue:) forControlEvents:UIControlEventValueChanged];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	else if ([identifier hasPrefix:kIASKPSMultiValueSpecifier] || [identifier hasPrefix:kIASKPSTitleValueSpecifier]) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
		cell.accessoryType = [identifier hasPrefix:kIASKPSMultiValueSpecifier] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	}
	else if ([identifier hasPrefix:kIASKPSTextFieldSpecifier]) {
		cell = [[IASKPSTextFieldSpecifierViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		[((IASKPSTextFieldSpecifierViewCell*)cell).textField addTarget:self action:@selector(_textChanged:) forControlEvents:UIControlEventEditingChanged];
	}
	else if ([identifier hasPrefix:kIASKTextViewSpecifier]) {
        cell = [[IASKTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	else if ([identifier hasPrefix:kIASKPSSliderSpecifier]) {
        cell = [[IASKPSSliderSpecifierViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	} else if ([identifier hasPrefix:kIASKPSChildPaneSpecifier]) {
		if (!specifier.subtitle.length) {
			style = UITableViewCellStyleValue1;
		}
		cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if ([identifier isEqualToString:kIASKMailComposeSpecifier]) {
		cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	} else {
		cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier];

		if ([identifier isEqualToString:kIASKOpenURLSpecifier]) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
    cell.textLabel.minimumScaleFactor = kIASKMinimumFontSize / cell.textLabel.font.pointSize;
    cell.detailTextLabel.minimumScaleFactor = kIASKMinimumFontSize / cell.detailTextLabel.font.pointSize;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
	if ([specifier.type isEqualToString:kIASKCustomViewSpecifier] && [self.delegate respondsToSelector:@selector(tableView:cellForSpecifier:)]) {
		UITableViewCell* cell = [self.delegate tableView:tableView cellForSpecifier:specifier];
		assert(nil != cell && "delegate must return a UITableViewCell for custom cell types");
		return cell;
	}
	
	UITableViewCell* cell = [self tableView:tableView newCellForSpecifier:specifier];

	if ([specifier.type isEqualToString:kIASKPSToggleSwitchSpecifier]) {
		cell.textLabel.text = specifier.title;
		cell.detailTextLabel.text = specifier.subtitle;

		id currentValue = [self.settingsStore objectForKey:specifier.key];
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
		IASKSwitch *toggle = (IASKSwitch*)cell.accessoryView;
		toggle.on = toggleState;
		toggle.key = specifier.key;
	}
	else if ([specifier.type isEqualToString:kIASKPSMultiValueSpecifier]) {
		cell.textLabel.text = specifier.title;
		[self setMultiValuesFromDelegateIfNeeded:specifier];
		cell.detailTextLabel.text = [[specifier titleForCurrentValue:[self.settingsStore objectForKey:specifier.key] ?: specifier.defaultValue] description];
	}
	else if ([specifier.type isEqualToString:kIASKPSTitleValueSpecifier]) {
		cell.textLabel.text = specifier.title;
		id value = [self.settingsStore objectForKey:specifier.key] ? : specifier.defaultValue;
		
		NSString *stringValue;
		if (specifier.multipleValues || specifier.multipleTitles) {
			stringValue = [specifier titleForCurrentValue:value];
		} else {
			stringValue = [value description];
		}
		
		cell.detailTextLabel.text = stringValue;
		cell.userInteractionEnabled = NO;
	}
	else if ([specifier.type isEqualToString:kIASKPSTextFieldSpecifier]) {
		cell.textLabel.text = specifier.title;
		
		NSString *textValue = [self.settingsStore objectForKey:specifier.key] ?: specifier.defaultStringValue;
		if (textValue && ![textValue isMemberOfClass:[NSString class]]) {
			textValue = [NSString stringWithFormat:@"%@", textValue];
		}
		IASKTextField *textField = ((IASKPSTextFieldSpecifierViewCell*)cell).textField;
		textField.text = textValue;
		textField.key = specifier.key;
		textField.regex = specifier.regex;
		textField.delegate = self;
		textField.secureTextEntry = [specifier isSecure];
		textField.keyboardType = specifier.keyboardType;
		textField.autocapitalizationType = specifier.autocapitalizationType;
		if([specifier isSecure]){
			textField.autocorrectionType = UITextAutocorrectionTypeNo;
		} else {
			textField.autocorrectionType = specifier.autoCorrectionType;
		}
		textField.textAlignment = specifier.textAlignment;
		textField.placeholder = specifier.placeholder;
		textField.adjustsFontSizeToFitWidth = specifier.adjustsFontSizeToFitWidth;
	}
	else if ([specifier.type isEqualToString:kIASKTextViewSpecifier]) {
		IASKTextViewCell *textCell = (id)cell;
		NSString *value = [self.settingsStore objectForKey:specifier.key] ?: specifier.defaultStringValue;
		textCell.textView.text = value;
		textCell.textView.delegate = self;
		textCell.textView.key = specifier.key;
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
			((IASKPSSliderSpecifierViewCell*)cell).minImage.image = [UIImage imageWithContentsOfFile:[_settingsReader pathForImageNamed:specifier.minimumValueImage]];
		}
		
		if (specifier.maximumValueImage.length > 0) {
			((IASKPSSliderSpecifierViewCell*)cell).maxImage.image = [UIImage imageWithContentsOfFile:[_settingsReader pathForImageNamed:specifier.maximumValueImage]];
		}
		
		IASKSlider *slider = ((IASKPSSliderSpecifierViewCell*)cell).slider;
		slider.minimumValue = specifier.minimumValue;
		slider.maximumValue = specifier.maximumValue;
		slider.value =	[self.settingsStore objectForKey:specifier.key] != nil ? [[self.settingsStore objectForKey:specifier.key] floatValue] : [specifier.defaultValue floatValue];
		[slider addTarget:self action:@selector(sliderChangedValue:) forControlEvents:UIControlEventValueChanged];
		slider.key = specifier.key;
		[cell setNeedsLayout];
	}
	else if ([specifier.type isEqualToString:kIASKPSChildPaneSpecifier]) {
		cell.textLabel.text = specifier.title;
		if (specifier.subtitle.length) {
			cell.detailTextLabel.text = specifier.subtitle;
		} else if (specifier.key) {
			NSString *valueString = [self.settingsStore objectForKey:specifier.key] ? : specifier.defaultValue;
			valueString = [valueString isKindOfClass:NSString.class] ? valueString : nil;
			cell.detailTextLabel.text = valueString;
		}
	} else if ([specifier.type isEqualToString:kIASKOpenURLSpecifier] || [specifier.type isEqualToString:kIASKMailComposeSpecifier]) {
		cell.textLabel.text = specifier.title;
		cell.detailTextLabel.text = specifier.subtitle ? : [specifier.defaultValue description];
		cell.accessoryType = (specifier.textAlignment == NSTextAlignmentLeft) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	} else if ([specifier.type isEqualToString:kIASKButtonSpecifier]) {
		NSString *value = [self.settingsStore objectForKey:specifier.key];
		cell.textLabel.text = ([value isKindOfClass:NSString.class] && [self.settingsReader titleForId:value].length) ? [self.settingsReader titleForId:value] : specifier.title;
		cell.detailTextLabel.text = specifier.subtitle;
		if (specifier.textAlignment != NSTextAlignmentLeft) {
        cell.textLabel.textColor = tableView.tintColor;
		};
		cell.textLabel.textAlignment = specifier.textAlignment;
		cell.accessoryType = (specifier.textAlignment == NSTextAlignmentLeft) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	} else if ([specifier.type isEqualToString:kIASKPSRadioGroupSpecifier]) {
		NSInteger index = [specifier.multipleValues indexOfObject:specifier.radioGroupValue];
		cell.textLabel.text = [self.settingsReader titleForId:specifier.multipleTitles[index]];
		[_selections[indexPath.section] updateSelectionInCell:cell indexPath:indexPath];
	} else {
		cell.textLabel.text = specifier.title;
	}
    
	cell.imageView.image = specifier.cellImage;
	cell.imageView.highlightedImage = specifier.highlightedCellImage;
    
	if (![specifier.type isEqualToString:kIASKPSMultiValueSpecifier] && ![specifier.type isEqualToString:kIASKPSTitleValueSpecifier] && ![specifier.type isEqualToString:kIASKPSTextFieldSpecifier] && ![specifier.type isEqualToString:kIASKTextViewSpecifier]) {
		cell.textLabel.textAlignment = specifier.textAlignment;
	}
	cell.detailTextLabel.textAlignment = specifier.textAlignment;
	cell.textLabel.adjustsFontSizeToFitWidth = specifier.adjustsFontSizeToFitWidth;
	cell.detailTextLabel.adjustsFontSizeToFitWidth = specifier.adjustsFontSizeToFitWidth;
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//create a set of specifier types that can't be selected
	static NSSet* noSelectionTypes = nil;
	if(nil == noSelectionTypes) {
		noSelectionTypes = [NSSet setWithObjects:kIASKPSToggleSwitchSpecifier, kIASKPSSliderSpecifier, nil];
	}
  
	IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
	if([noSelectionTypes containsObject:specifier.type]) {
		return nil;
	} else {
		return indexPath;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
    
    //switches and sliders can't be selected (should be captured by tableView:willSelectRowAtIndexPath: delegate method)
    assert(![[specifier type] isEqualToString:kIASKPSToggleSwitchSpecifier]);
    assert(![[specifier type] isEqualToString:kIASKPSSliderSpecifier]);
    
    if ([[specifier type] isEqualToString:kIASKPSMultiValueSpecifier]) {
        IASKSpecifierValuesViewController *targetViewController = [[IASKSpecifierValuesViewController alloc] initWithStyle:UITableViewStyleGrouped];
		[self setMultiValuesFromDelegateIfNeeded:specifier];
        [targetViewController setCurrentSpecifier:specifier];
        targetViewController.settingsReader = self.settingsReader;
        targetViewController.settingsStore = self.settingsStore;
        targetViewController.view.tintColor = self.view.tintColor;
        _currentChildViewController = targetViewController;
        [[self navigationController] pushViewController:targetViewController animated:YES];
		if (@available(iOS 9.0, *)) {
			targetViewController.tableView.cellLayoutMarginsFollowReadableWidth = self.cellLayoutMarginsFollowReadableWidth;
		}
		
    } else if ([[specifier type] isEqualToString:kIASKPSTextFieldSpecifier]) {
        IASKPSTextFieldSpecifierViewCell *textFieldCell = (id)[tableView cellForRowAtIndexPath:indexPath];
        [textFieldCell.textField becomeFirstResponder];		
	} else if ([[specifier type] isEqualToString:kIASKPSChildPaneSpecifier]) {
        if ([specifier viewControllerStoryBoardID]){
            NSString *storyBoardFileFromSpecifier = [specifier viewControllerStoryBoardFile];
            storyBoardFileFromSpecifier = storyBoardFileFromSpecifier && storyBoardFileFromSpecifier.length > 0 ? storyBoardFileFromSpecifier : [[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyBoardFileFromSpecifier bundle:nil];
            UIViewController * vc = [storyBoard instantiateViewControllerWithIdentifier:[specifier viewControllerStoryBoardID]];
            vc.view.tintColor = self.view.tintColor;
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        
        Class vcClass = [specifier viewControllerClass];
        if (vcClass) {
			if (vcClass == [NSNull class]) {
				NSLog(@"class '%@' not found", [specifier localizedObjectForKey:kIASKViewControllerClass]);
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				return;
			}
            SEL initSelector = [specifier viewControllerSelector];
            if (!initSelector) {
                initSelector = @selector(init);
            }
            UIViewController * vc = [vcClass alloc];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            vc = [vc performSelector:initSelector withObject:[specifier file] withObject:specifier];
#pragma clang diagnostic pop
            if ([vc respondsToSelector:@selector(setDelegate:)]) {
                [vc performSelector:@selector(setDelegate:) withObject:self.delegate];
            }
            if ([vc respondsToSelector:@selector(setSettingsStore:)]) {
                [vc performSelector:@selector(setSettingsStore:) withObject:self.settingsStore];
            }
            vc.view.tintColor = self.view.tintColor;
            [self.navigationController pushViewController:vc animated:YES];
            return;
		}
			
        NSString *segueIdentifier = [specifier segueIdentifier];
        if (segueIdentifier) {
			@try {
				[self performSegueWithIdentifier:segueIdentifier sender:self];
			} @catch (NSException *exception) {
				NSLog(@"segue with identifier '%@' not defined", segueIdentifier);
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
			}
            return;
        }
        
        if (nil == [specifier file]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        
        _reloadDisabled = YES; // Disable internal unnecessary reloads
        
        IASKAppSettingsViewController *targetViewController = [[[self class] alloc] init];
        targetViewController.showDoneButton = NO;
        targetViewController.showCreditsFooter = NO; // Does not reload the tableview (but next setters do it)
        targetViewController.delegate = self.delegate;
        targetViewController.settingsStore = self.settingsStore;
        targetViewController.file = specifier.file;
        targetViewController.hiddenKeys = self.hiddenKeys;
        targetViewController.title = specifier.title;
        targetViewController.view.tintColor = self.view.tintColor;
        _currentChildViewController = targetViewController;
        
        _reloadDisabled = NO;
		
        [[self navigationController] pushViewController:targetViewController animated:YES];
        
    } else if ([[specifier type] isEqualToString:kIASKOpenURLSpecifier]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
		IASK_IF_IOS11_OR_GREATER([UIApplication.sharedApplication openURL:(NSURL *)[NSURL URLWithString:[specifier localizedObjectForKey:kIASKFile]] options:@{} completionHandler:nil];);
		IASK_IF_PRE_IOS11([UIApplication.sharedApplication openURL:(NSURL *)[NSURL URLWithString:[specifier localizedObjectForKey:kIASKFile]]];);
    } else if ([[specifier type] isEqualToString:kIASKButtonSpecifier]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if ([self.delegate respondsToSelector:@selector(settingsViewController:buttonTappedForSpecifier:)]) {
            [self.delegate settingsViewController:self buttonTappedForSpecifier:specifier];
        } else if ([self.delegate respondsToSelector:@selector(settingsViewController:buttonTappedForKey:)]) {
            // deprecated, provided for backward compatibility
            NSLog(@"InAppSettingsKit Warning: -settingsViewController:buttonTappedForKey: is deprecated. Please use -settingsViewController:buttonTappedForSpecifier:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [self.delegate settingsViewController:self buttonTappedForKey:[specifier key]];
#pragma clang diagnostic pop
        } else {
            // legacy code, provided for backward compatibility
            // the delegate mechanism above is much cleaner and doesn't leak
            Class buttonClass = [specifier buttonClass];
            SEL buttonAction = [specifier buttonAction];
            if ([buttonClass respondsToSelector:buttonAction]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [buttonClass performSelector:buttonAction withObject:self withObject:[specifier key]];
#pragma clang diagnostic pop
                NSLog(@"InAppSettingsKit Warning: Using IASKButtonSpecifier without implementing the delegate method is deprecated");
            }
        }
    } else if ([[specifier type] isEqualToString:kIASKMailComposeSpecifier]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
		if ([specifier localizedObjectForKey:kIASKMailComposeSubject]) {
			[mailViewController setSubject:[specifier localizedObjectForKey:kIASKMailComposeSubject]];
		}
		if ([[specifier specifierDict] objectForKey:kIASKMailComposeToRecipents]) {
			[mailViewController setToRecipients:[[specifier specifierDict] objectForKey:kIASKMailComposeToRecipents]];
		}
		if ([[specifier specifierDict] objectForKey:kIASKMailComposeCcRecipents]) {
			[mailViewController setCcRecipients:[[specifier specifierDict] objectForKey:kIASKMailComposeCcRecipents]];
		}
		if ([[specifier specifierDict] objectForKey:kIASKMailComposeBccRecipents]) {
			[mailViewController setBccRecipients:[[specifier specifierDict] objectForKey:kIASKMailComposeBccRecipents]];
		}
		if ([specifier localizedObjectForKey:kIASKMailComposeBody]) {
			BOOL isHTML = NO;
			if ([[specifier specifierDict] objectForKey:kIASKMailComposeBodyIsHTML]) {
				isHTML = [[[specifier specifierDict] objectForKey:kIASKMailComposeBodyIsHTML] boolValue];
			}
			
			if ([self.delegate respondsToSelector:@selector(settingsViewController:mailComposeBodyForSpecifier:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
				[mailViewController setMessageBody:[self.delegate settingsViewController:self
															 mailComposeBodyForSpecifier:specifier] isHTML:isHTML];
#pragma clang diagnostic pop
			}
			else {
				[mailViewController setMessageBody:[specifier localizedObjectForKey:kIASKMailComposeBody] isHTML:isHTML];
			}
		}
		
		UIViewController<MFMailComposeViewControllerDelegate> *vc = nil;
		
		if ([self.delegate respondsToSelector:@selector(settingsViewController:viewControllerForMailComposeViewForSpecifier:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
			vc = [self.delegate settingsViewController:self viewControllerForMailComposeViewForSpecifier:specifier];
#pragma clang diagnostic pop
		}
		
		if (vc == nil) {
			vc = self;
		}
		
		if ([self.delegate respondsToSelector:@selector(settingsViewController:shouldPresentMailComposeViewController:forSpecifier:)]) {
			BOOL shouldPresent = [self.delegate settingsViewController:self shouldPresentMailComposeViewController:mailViewController forSpecifier:specifier];
			if (!shouldPresent) {
				return;
			}
		}
		
		if ([MFMailComposeViewController canSendMail]) {
			mailViewController.mailComposeDelegate = vc;
            _currentChildViewController = mailViewController;
            UIStatusBarStyle savedStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
            [vc presentViewController:mailViewController animated:YES completion:^{
			    [UIApplication sharedApplication].statusBarStyle = savedStatusBarStyle;
            }];
			
        } else {
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Mail not configured", @"InAppSettingsKit")
																		   message:NSLocalizedString(@"This device is not configured for sending Email. Please configure the Mail settings in the Settings app.", @"InAppSettingsKit")
																	preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"InAppSettingsKit") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
			[self presentViewController:alert animated:YES completion:nil];
		}
        
    } else if ([[specifier type] isEqualToString:kIASKCustomViewSpecifier] && [self.delegate respondsToSelector:@selector(settingsViewController:tableView:didSelectCustomViewSpecifier:)]) {
        [self.delegate settingsViewController:self tableView:tableView didSelectCustomViewSpecifier:specifier];
	} else if ([[specifier type] isEqualToString:kIASKPSRadioGroupSpecifier]) {
		[_selections[indexPath.section] selectRowAtIndexPath:indexPath];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
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

- (void)_textChanged:(id)sender {
    IASKTextField *text = sender;
    // If there's a regex to do input validation then don't set the property now. Instead it's done when editting ends
    if (text.regex == nil) {
        [_settingsStore setObject:text.text forKey:text.key];
        NSDictionary *userInfo = text.text ? @{text.key : (NSString *)text.text} : nil;
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

- (void)textFieldDidEndEditing:(UITextField *)textField {
    BOOL allow = true;
	IASKTextField *text      = (IASKTextField *) textField;
	IASKSpecifier *specifier = [self.settingsReader specifierForKey:text.key];
	if (text.regex != nil) {
        NSString *textValue = text.text ?: @"";
        allow = [text.regex numberOfMatchesInString:textValue options:0 range:(NSRange){0, textValue.length}] > 0;
    }
    // if the input validates has passed, update the settings store and send out a notification. If it's failed set the
    // text field back to the previous value.
    if (allow) {
        [_settingsStore setObject:text.text forKey:[text key]];
        NSDictionary *userInfo = text.text ? @{text.key : (NSString *)text.text} : nil;
        [NSNotificationCenter.defaultCenter postNotificationName:kIASKAppSettingChanged
                                                          object:self
                                                        userInfo:userInfo];
		if ([self.delegate respondsToSelector:@selector(settingsViewController:validationSuccessForSpecifier:textField:)]) {
			[self.delegate settingsViewController:self
					validationSuccessForSpecifier:specifier
										textField:text];
		}
    } else {
        NSString *textValue = [self.settingsStore objectForKey:text.key] ?: specifier.defaultStringValue;
        if (textValue && ![textValue isMemberOfClass:NSString.class]) {
            textValue = [NSString stringWithFormat:@"%@", textValue];
        }
		// If the delegate can handle validation failures check what response it requires
		BOOL defaultBehaviour = true;
		if ([self.delegate respondsToSelector:@selector(settingsViewController:validationFailureForSpecifier:textField:previousValue:)]) {
			defaultBehaviour = [self.delegate settingsViewController:self
									   validationFailureForSpecifier:specifier
														   textField:text
													   previousValue:textValue];
		}
		if (defaultBehaviour) {
			text.text = textValue;
			[text shake];
		}
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
	self.currentFirstResponder = textView;
}

- (void)textViewDidChange:(IASKTextView *)textView {
    [self cacheRowHeightForTextView:textView animated:YES];
	
	CGRect visibleTableRect = UIEdgeInsetsInsetRect(self.tableView.bounds, self.tableView.contentInset);
	NSIndexPath *indexPath = [self.settingsReader indexPathForKey:textView.key];
	CGRect cellFrame = [self.tableView rectForRowAtIndexPath:indexPath];
	
	if (!CGRectContainsRect(visibleTableRect, cellFrame)) {
		[self.tableView scrollRectToVisible:CGRectInset(cellFrame, 0, - 30) animated:YES];
	}

	[_settingsStore setObject:textView.text forKey:textView.key];
	[[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged
														object:textView.key
													  userInfo:@{textView.key: textView.text}];
	
}

- (void)cacheRowHeightForTextView:(IASKTextView *)textView animated:(BOOL)animated {
	CGFloat maxHeight = self.tableView.bounds.size.height - self.tableView.contentInset.top - self.tableView.contentInset.bottom - 60;
	CGFloat contentHeight = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, 10000)].height + 16;
	self.rowHeights[textView.key] = @(MAX(44, MIN(maxHeight, contentHeight)));
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

#pragma mark Notifications

- (void)synchronizeSettings {
    [_settingsStore synchronize];
}

static NSDictionary *oldUserDefaults = nil;
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
		oldUserDefaults = currentDict;
		
		for (UITableViewCell *cell in self.tableView.visibleCells) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
			if ([cell isKindOfClass:[IASKPSTextFieldSpecifierViewCell class]] && [((IASKPSTextFieldSpecifierViewCell*)cell).textField isFirstResponder] && indexPath) {
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
	[oldUserDefaults setValue:notification.userInfo[key] forKey:key];
}

- (void)reload {
	// wait 0.5 sec until UI is available after applicationWillEnterForeground
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
}

- (void)setMultiValuesFromDelegateIfNeeded:(IASKSpecifier *)specifier {
	if (specifier.multipleValues.count == 0) {
		NSLog(@"need to init from delegate");
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
