//
//  CustomViewCell.h
//  InAppSettingsKitSampleApp
//
//  Created by Ortwin Gentz on 05.11.10.
//  Copyright 2010 FutureTap. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomViewCell : UITableViewCell {
	UITextView *textView;
}

@property (nonatomic, retain) IBOutlet UITextView *textView;

@end
