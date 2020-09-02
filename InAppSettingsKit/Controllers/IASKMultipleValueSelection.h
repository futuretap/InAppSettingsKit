//
//  IASKMultipleValueSelection.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IASKSpecifier;
@protocol IASKSettingsStore;

/// Encapsulates the selection among multiple values.
/// This is used for PSMultiValueSpecifier and PSRadioGroupSpecifier
@interface IASKMultipleValueSelection : NSObject

@property (nullable, nonatomic, assign) UITableView *tableView;
@property (nonatomic, copy, readonly) NSIndexPath *checkedIndexPath;
@property (nonatomic, strong) id<IASKSettingsStore> settingsStore;

- (id)initWithSettingsStore:(id<IASKSettingsStore>)settingsStore
				  tableView:(nullable UITableView*)tableView
				  specifier:(IASKSpecifier*)specifier
					section:(NSInteger)section;
- (void)selectRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)updateSelectionInCell:(UITableViewCell*)cell indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
