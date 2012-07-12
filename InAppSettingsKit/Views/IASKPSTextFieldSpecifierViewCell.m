//
//  IASKPSTextFieldSpecifierViewCell.m
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009-2010:
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

#import "IASKPSTextFieldSpecifierViewCell.h"
#import "IASKTextField.h"
#import "IASKSettingsReader.h"

@implementation IASKPSTextFieldSpecifierViewCell

@synthesize label=_label,
            textField=_textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Label
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 21)];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleRightMargin;
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0f];
        _label.textColor = [UIColor darkTextColor];
        [self.contentView addSubview:_label];
        
        // TextField
        _textField = [[IASKTextField alloc] initWithFrame:CGRectMake(0, 0, 200, 21)];
        _textField.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleLeftMargin;
        _textField.font = [UIFont fontWithName:@"Helvetica" size:17.0f];
        _textField.textColor = [UIColor colorWithRed:0.275 green:0.376 blue:0.522 alpha:1.000];
        [self.contentView addSubview:_textField];
        
        // Others
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Label
    CGSize labelSize = [_label sizeThatFits:CGSizeZero];
	labelSize.width = MIN(labelSize.width, _label.bounds.size.width);
    _label.center = CGPointMake(kIASKPaddingLeft + _label.bounds.size.width / 2,
                                self.contentView.center.y);
    // TextField
    _textField.center = CGPointMake(_textField.center.x, self.contentView.center.y);
	CGRect textFieldFrame = _textField.frame;
	textFieldFrame.origin.x = _label.frame.origin.x + MAX(kIASKMinLabelWidth, labelSize.width) + kIASKSpacing;
	if (!_label.text.length)
		textFieldFrame.origin.x = _label.frame.origin.x;
	textFieldFrame.size.width = _textField.superview.frame.size.width - textFieldFrame.origin.x - _label.frame.origin.x;
	_textField.frame = textFieldFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
