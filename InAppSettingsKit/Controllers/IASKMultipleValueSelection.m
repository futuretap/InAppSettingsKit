//
//  IASKMultipleValueSelection.m
//  InAppSettingsKit
//
//  All rights reserved.
//
//  It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz,
//  as the original authors of this code. You can give credit in a blog post, a tweet or on
//  a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

#import "IASKMultipleValueSelection.h"
#import "IASKSettingsStore.h"
#import "IASKSettingsStoreUserDefaults.h"
#import "IASKSpecifier.h"
#import "IASKSettingsReader.h"


@interface IASKMultipleValueSelection ()
@property (nonatomic, strong) IASKSpecifier *specifier;
@property (nonatomic) NSInteger section;

@property (nonatomic) NSInteger checkedIndex;
@end

@implementation IASKMultipleValueSelection

@synthesize settingsStore = _settingsStore;

- (id)initWithSettingsStore:(id<IASKSettingsStore>)settingsStore
				  tableView:(UITableView*)tableView
				  specifier:(IASKSpecifier*)specifier
					section:(NSInteger)section {
    if ((self = [super init])) {
        self.settingsStore = settingsStore;
		self.tableView = tableView;
		self.specifier = specifier;
		self.section = section;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)setSpecifier:(IASKSpecifier *)specifier {
    _specifier = specifier;
    [self updateCheckedItem];
}

- (NSIndexPath *)checkedIndexPath {
	return [NSIndexPath indexPathForRow:self.checkedIndex inSection:_section];;
}

- (void)updateCheckedItem {
    // Find the currently checked item
	id value = [self.settingsStore objectForSpecifier:self.specifier];
    if (!value) {
		value = self.specifier.defaultValue;
    }
	self.checkedIndex = [self.specifier.multipleValues indexOfObject:value];
}

- (id<IASKSettingsStore>)settingsStore {
    if (_settingsStore == nil) {
        self.settingsStore = [[IASKSettingsStoreUserDefaults alloc] init];
    }
    return _settingsStore;
}

- (void)setSettingsStore:(id<IASKSettingsStore>)settingsStore {
	if ([_settingsStore isKindOfClass:IASKSettingsStoreUserDefaults.class]) {
		IASKSettingsStoreUserDefaults *udSettingsStore = (id)_settingsStore;
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:udSettingsStore.defaults];
	}
	
	_settingsStore = settingsStore;
	
	if ([settingsStore isKindOfClass:IASKSettingsStoreUserDefaults.class]) {
		IASKSettingsStoreUserDefaults *udSettingsStore = (id)settingsStore;
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(userDefaultsDidChange)
													 name:NSUserDefaultsDidChangeNotification
												   object:udSettingsStore.defaults];
	}
	[self updateCheckedItem];
}

#pragma mark - selection

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath == self.checkedIndexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

	NSArray *values = self.specifier.multipleValues;

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self deselectCell:[self.tableView cellForRowAtIndexPath:self.checkedIndexPath]];
    [self selectCell:[self.tableView cellForRowAtIndexPath:indexPath]];
	self.checkedIndex = indexPath.row;

	[self.settingsStore setObject:[values objectAtIndex:indexPath.row] forSpecifier:self.specifier];
    [self.settingsStore synchronize];
	NSDictionary *userInfo = self.specifier.key && values[indexPath.row] ? @{(id)self.specifier.key: (id)values[indexPath.row]} : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged object:self userInfo:userInfo];
};

- (void)updateSelectionInCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:self.checkedIndexPath]) {
        [self selectCell:cell];
    } else {
        [self deselectCell:cell];
    }
}

- (void)selectCell:(UITableViewCell *)cell {
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
}

- (void)deselectCell:(UITableViewCell *)cell {
    [cell setAccessoryType:UITableViewCellAccessoryNone];
}


#pragma mark Notifications

- (void)userDefaultsDidChange {
    NSIndexPath *oldCheckedItem = self.checkedIndexPath;
    if (_specifier) {
        [self updateCheckedItem];
    }

    // only reload the table if it had changed; prevents animation cancellation
    if (![self.checkedIndexPath isEqual:oldCheckedItem]) {
        [self.tableView reloadData];
    }
}

@end
