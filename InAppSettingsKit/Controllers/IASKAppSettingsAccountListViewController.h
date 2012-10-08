//
//  Created by Jan Chaloupecky on 10/4/12.
//


#import <Foundation/Foundation.h>
#import "IASKAppSettingsViewController.h"


@interface IASKAppSettingsAccountListViewController : IASKAppSettingsViewController <IASKSettingsDelegate> {

    NSString* _accountTemplatePlist;
    NSString*_accoutArrayId;

    NSMutableArray * _accountArray;

    UIBarButtonItem *_editButton;




}


- (id)initWithFile:(NSString*)accountTemplatePlist key:(NSString*)accoutArrayID;


@property (nonatomic, retain) id<IASKSettingsStore> settingsStore;
@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, copy) NSString *addAcountTitle;
@property (nonatomic, copy) NSString *accountCellTitleKey;
@property (nonatomic, copy) NSString *accountCellSubtitleKey;









@end