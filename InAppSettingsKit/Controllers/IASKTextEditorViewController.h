//
//  IASKTextEditorViewController.h
//  http://www.inappsettingskit.com
//
//  Created by Lin Junjie on 13/8/12.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

#import <UIKit/UIKit.h>
#import "IASKSettingsStore.h"
#import "IASKViewController.h"
@class IASKSpecifier;
@class IASKSettingsReader;

@interface IASKTextEditorViewController : UIViewController <IASKViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IASKSpecifier *currentSpecifier;

@end
