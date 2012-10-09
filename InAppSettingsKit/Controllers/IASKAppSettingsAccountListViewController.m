//
//  Created by Jan Chaloupecky on 10/4/12.
//


#import "IASKAppSettingsAccountListViewController.h"
#import "IASKAppSettingsViewController.h"
#import "IASKSettingStoreMemory.h"

// the row that is always present at the bottom "Add Account"
#define kIASKStaticRowsCount 1

@implementation IASKAppSettingsAccountListViewController {

}
@synthesize addAcountTitle;


- (id)initWithFile:(NSString*)anAccountTemplatePlist key:(NSString*)anAccoutArrayID {
    self = [super init];
    if (self) {
        _accountTemplatePlist = [anAccountTemplatePlist copy];
        _accoutArrayId = [anAccoutArrayID copy];
    }

    return self;
}



- (void)viewDidLoad {
    [self setupRightBarButton];

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    //todo check if this has to be overwritten
}



#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Accounts";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_accountArray) {
        return _accountArray.count + kIASKStaticRowsCount;
    }

    return  kIASKStaticRowsCount;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


    static NSString *CellIdentifierAccountDetails = @"AccountCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierAccountDetails];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierAccountDetails];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell autorelease];
    }

    // last row "Add Account"
    if (indexPath.row == _accountArray.count) {

        if(addAcountTitle) {
            cell.textLabel.text = addAcountTitle;
        } else {
            cell.textLabel.text = @"New Account...";
        }

        cell.detailTextLabel.text = nil;

    } else {
        // account entry


        NSDictionary *accountDict = [_accountArray objectAtIndex:(NSUInteger) indexPath.row];
        NSAssert([accountDict isKindOfClass:[NSDictionary class]], @"Backend store object for key %@  and index %d must be an NSDictionary", _accoutArrayId, indexPath.row);


        // todo check if delegate can supply a cell other

        if(self.accountCellTitleKey) {
            //cell.textLabel.text = [accountDict objectForKey:@"myAccountFullName"];
            cell.textLabel.text = [accountDict objectForKey: self.accountCellTitleKey];
        }

        if(self.accountCellSubtitleKey) {
            cell.detailTextLabel.text = [accountDict objectForKey:self.accountCellSubtitleKey];;
        }
    }

    return cell;

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    // do not allow to edit the "Add Accout" row
    return indexPath.row != _accountArray.count;
    //return YES;

}


// Determine whether a given row is eligible for reordering or not.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row != _accountArray.count;
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    IASKAppSettingsViewController * targetViewController = [[IASKAppSettingsViewController alloc] init];

    targetViewController.showDoneButton = YES;
    targetViewController.settingsStore = nil;
    targetViewController.file = _accountTemplatePlist;


    IASKSettingStoreMemory *memoryStore = [IASKSettingStoreMemory objectWithUserPrefArrayId:_accoutArrayId backendSettingStore:self.settingsStore];

    targetViewController.settingsStore = memoryStore;

    targetViewController.delegate = self;
    [[self navigationController] pushViewController:targetViewController animated:YES];

    // details of an existing account
    if (indexPath.row != _accountArray.count) {
        memoryStore.existingMemorySettingStore = [_accountArray objectAtIndex:(NSUInteger) indexPath.row];

    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    [targetViewController release];

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        [_accountArray removeObjectAtIndex:(NSUInteger) indexPath.row];


        // persist
        [_settingsStore setObject:_accountArray forKey:_accoutArrayId];

        [self reloadAccountsAnimated:YES];

        if(_accountArray.count == 0) {
            // switch of editing when all entries were removed
            [self enterEditMode:nil];
        }

    }

}

// Process the row move. This means updating the data model to correct the item indices.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath {
    id item = [[_accountArray objectAtIndex:(NSUInteger) fromIndexPath.row] retain];
    [_accountArray removeObject:item];
    [_accountArray insertObject:item atIndex:(NSUInteger) toIndexPath.row];

    [_settingsStore setObject:_accountArray forKey:_accoutArrayId];
    [self reloadAccountsAnimated:NO];
    [item release];
}




- (void)setSettingsStore:(id <IASKSettingsStore>)settingsStore {
    if (_settingsStore != settingsStore) {
        [settingsStore retain];
        [_settingsStore release];
        _settingsStore = settingsStore;
    }
    [self reloadAccountsAnimated:NO];


}

#pragma mark - local methods

- (void)reloadAccountsAnimated: (BOOL) animated {
// reload the accounts
    NSArray * _backEndArray = [_settingsStore objectForKey:_accoutArrayId];

    if(_backEndArray) {
        NSAssert([_backEndArray isKindOfClass:[NSArray class]], @"Backend store object for key %@ must be an NSArray", _accoutArrayId);
        [_accountArray release];
        _accountArray = [_backEndArray mutableCopy];
    }

    if(animated) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadData];
    }

}


- (IBAction)enterEditMode:(id)sender {

    if ([self.tableView isEditing]) {
        // If the tableView is already in edit mode, turn it off. Also change the title of the button to reflect the intended verb (‘Edit’, in this case).
        [self.tableView setEditing:NO animated:YES];
        [_editButton setTitle:@"Edit"];
        [_editButton setStyle:UIBarButtonItemStyleBordered];
    }
    else {
        // Turn on edit mode
        [_editButton setTitle:@"Done"];
        [_editButton setStyle:UIBarButtonItemStyleDone];
        [self.tableView setEditing:YES animated:YES];
    }
}

-(void) setupRightBarButton {
    _editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(enterEditMode:)];
    self.navigationItem.rightBarButtonItem = _editButton;
}



#pragma mark - IASKSettingsDelegate

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    [self reloadAccountsAnimated:NO];

    [self.navigationController popViewControllerAnimated:YES];

}

- (void)dealloc {
    [_accountTemplatePlist release]; _accountTemplatePlist = nil;
    [_accountArray release]; _accountArray = nil;

    [_settingsStore release]; _settingsStore = nil;
    [_editButton release]; _editButton = nil;

    [addAcountTitle release];
    [super dealloc];
}



@end