//
//  IASKDateTimeSettingsViewController.h
//  InAppSettingsKitSampleApp
//
//  Created by Marton Szabo on 9/20/11.
//  Copyright 2011 jollyblade@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IASKSettingsStore.h"

@class IASKSpecifier;
@class IASKSettingsReader;

@interface IASKDateTimeSettingsViewController : UIViewController {

    IASKSpecifier			*_currentSpecifier;
    IASKSettingsReader		*_settingsReader;
    id<IASKSettingsStore>	_settingsStore;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) IASKSpecifier *currentSpecifier;
@property (nonatomic, retain) IASKSettingsReader *settingsReader;
@property (nonatomic, retain) id<IASKSettingsStore> settingsStore;

-(IBAction)didChangeDate:(id)sender;

@end
