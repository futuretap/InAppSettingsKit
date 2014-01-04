//
//  CustomViewCell.m
//  InAppSettingsKitSampleApp
//
//  Created by Ortwin Gentz on 05.11.10.
//  Copyright 2010 FutureTap. All rights reserved.
//

#import "CustomViewCell.h"


@implementation CustomViewCell

@synthesize textView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
