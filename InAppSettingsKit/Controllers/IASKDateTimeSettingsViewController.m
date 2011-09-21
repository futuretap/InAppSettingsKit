//
//  IASKDateTimeSettingsViewController.m
//  InAppSettingsKitSampleApp
//
//  Created by Marton Szabo on 9/20/11.
//  Copyright 2011 jollyblade@gmail.com. All rights reserved.
//

#import "IASKDateTimeSettingsViewController.h"
#import "IASKSpecifier.h"
#import "IASKSettingsReader.h"
#import "IASKSettingsStoreUserDefaults.h"


@implementation IASKDateTimeSettingsViewController

@synthesize datePicker= _datePicker;
@synthesize currentSpecifier=_currentSpecifier;
@synthesize settingsReader = _settingsReader;
@synthesize settingsStore = _settingsStore;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.datePicker = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(IBAction)didChangeDate:(id)sender {
    [self.settingsStore setObject:self.datePicker.date forKey:[_currentSpecifier key]];
	[self.settingsStore synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged
                                                        object:[_currentSpecifier key]
                                                      userInfo:[NSDictionary dictionaryWithObject:self.datePicker.date
                                                                                           forKey:[_currentSpecifier key]]];
}

- (id<IASKSettingsStore>)settingsStore {
    if(_settingsStore == nil) {
        _settingsStore = [[IASKSettingsStoreUserDefaults alloc] init];
    }
    return _settingsStore;
}

- (void) updateCheckedItem {
    if([self.settingsStore objectForKey:[_currentSpecifier key]]) {
        NSDate* currentDate = [self.settingsStore objectForKey:[_currentSpecifier key]];
        
        self.datePicker.date = currentDate;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (_currentSpecifier) {
        [self setTitle:[_currentSpecifier title]];
        NSString* dateTimeType = [_currentSpecifier dateTimeType];
        if(dateTimeType == nil || [dateTimeType isEqualToString:kIASKDateTimeTypeFull]){
            self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        }
        else if([dateTimeType isEqualToString:kIASKDateTimeTypeDate]){
            self.datePicker.datePickerMode = UIDatePickerModeDate;
        }
        else if([dateTimeType isEqualToString:kIASKDateTimeTypeTime]){
            self.datePicker.datePickerMode = UIDatePickerModeTime;
        }
        
        [self updateCheckedItem];
    }    
    CGSize size = CGSizeMake(320, 420);
    self.contentSizeForViewInPopover = size;
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(userDefaultsDidChange)
												 name:NSUserDefaultsDidChangeNotification
											   object:[NSUserDefaults standardUserDefaults]];
}

- (void)viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
	[super viewDidDisappear:animated];
}

- (void)dealloc {
    [_currentSpecifier release], _currentSpecifier = nil;
	[_settingsReader release], _settingsReader = nil;
    [_settingsStore release], _settingsStore = nil;
    [super dealloc];
}

#pragma mark Notifications

- (void)userDefaultsDidChange {
    [self updateCheckedItem];
}


@end
