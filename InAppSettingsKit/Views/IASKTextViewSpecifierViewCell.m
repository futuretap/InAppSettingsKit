//
//  IASKPSTextViewSpecifierViewCell.m
//  InAppSettingsKit
//
//  Created by Robert La Ferla on 9/17/15.
//  Copyright (c) 2015 InAppSettingsKit. All rights reserved.
//

#import "IASKTextViewSpecifierViewCell.h"
#import "IASKTextView.h"
#import "IASKSettingsReader.h"

@implementation IASKTextViewSpecifierViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        
        // TextField
        _textView = [[IASKTextView alloc] initWithFrame:CGRectMake(0, 0, 200, self.frame.size.height)];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        _textView.font = [UIFont systemFontOfSize:kIASKLabelFontSize];
//        _textView.minimumFontSize = kIASKMinimumFontSize;
        IASK_IF_PRE_IOS7(_textView.textColor = [UIColor colorWithRed:0.275f green:0.376f blue:0.522f alpha:1.000f];);
        [self.contentView addSubview:_textView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIEdgeInsets padding = (UIEdgeInsets) { 0, kIASKPaddingLeft, 0, kIASKPaddingRight };
    if ([self respondsToSelector:@selector(layoutMargins)]) {
        padding = [self layoutMargins];
    }
    
    // Label
    CGFloat imageOffset = self.imageView.image ? self.imageView.bounds.size.width + padding.left : 0;
    CGSize labelSize = [self.textLabel sizeThatFits:CGSizeZero];
    labelSize.width = MAX(labelSize.width, kIASKMinLabelWidth - imageOffset);
    self.textLabel.frame = (CGRect){self.textLabel.frame.origin, {MIN(kIASKMaxLabelWidth, labelSize.width), self.textLabel.frame.size.height}} ;
    
    // TextView
    _textView.center = CGPointMake(_textView.center.x, self.contentView.center.y);
    CGRect textViewFrame = _textView.frame;
    textViewFrame.origin.x = self.textLabel.frame.origin.x + MAX(kIASKMinLabelWidth - imageOffset, self.textLabel.frame.size.width) + kIASKSpacing;
    textViewFrame.size.width = _textView.superview.frame.size.width - textViewFrame.origin.x - padding.right;
    
    if (!self.textLabel.text.length) {
        textViewFrame.origin.x = padding.left + imageOffset;
        textViewFrame.size.width = self.contentView.bounds.size.width - padding.left - padding.right - imageOffset;
    } else if (_textView.textAlignment == NSTextAlignmentRight) {
        textViewFrame.origin.x = self.textLabel.frame.origin.x + labelSize.width + kIASKSpacing;
        textViewFrame.size.width = _textView.superview.frame.size.width - textViewFrame.origin.x - padding.right;
    }
    _textView.frame = textViewFrame;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
