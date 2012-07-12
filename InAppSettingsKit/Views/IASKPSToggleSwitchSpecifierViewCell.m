//
//  IASKPSToggleSwitchSpecifierViewCell.m
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009:
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

#import "IASKPSToggleSwitchSpecifierViewCell.h"
#import "IASKSwitch.h"
#import "IASKSettingsReader.h"

@implementation IASKPSToggleSwitchSpecifierViewCell

@synthesize label=_label, 
            toggle=_toggle;
            
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Label
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 21)];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleRightMargin;
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0f];
        _label.textColor = [UIColor darkTextColor];
        [self.contentView addSubview:_label];
        
        // Toggle
        _toggle = [[IASKSwitch alloc] initWithFrame:CGRectMake(0, 0, 79, 27)];
        _toggle.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:_toggle];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Switch
    self.toggle.frame = CGRectMake(self.contentView.bounds.size.width - kIASKPaddingRight - self.toggle.frame.size.width,
                                   self.contentView.center.y - self.toggle.bounds.size.height / 2,
                                   self.toggle.bounds.size.width,
                                   self.toggle.bounds.size.height);
    // Label
    if(self.imageView.image) {
        //resize the label to make room for the image
        self.label.frame = CGRectMake(CGRectGetWidth(self.imageView.bounds) + self.imageView.frame.origin.x + kIASKSpacing, 
                                      self.contentView.center.y - self.label.bounds.size.height / 2, 
                                      self.toggle.frame.origin.x - CGRectGetWidth(self.imageView.bounds) - 2.f * kIASKSpacing, 
                                      self.label.frame.size.height);
    } else {
        self.label.frame = CGRectMake(kIASKPaddingLeft,
                                      self.contentView.center.y - self.label.bounds.size.height / 2,
                                      self.toggle.frame.origin.x - (kIASKSpacing + kIASKPaddingLeft),
                                      self.label.frame.size.height);
    }
}

@end
