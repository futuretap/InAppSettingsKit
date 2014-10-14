//
//  IASKTextViewCell.m
//  InAppSettingsKitSampleApp
//
//  Created by Lin Junjie on 13/8/12.
//
//

#define IS_IPAD					(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kTextViewPaddingX		(IS_IPAD ? 100 : 30)
#define kTextViewPaddingY		(IS_IPAD ? 20 : 10)

#import "IASKTextViewCell.h"

@interface IASKTextViewCell ()


@end

@implementation IASKTextViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
		CGRect frame = self.frame;
		frame.size.width -= kTextViewPaddingX;
		frame.origin.x += kTextViewPaddingX/2;
		frame.size.height -= kTextViewPaddingY*3;
		frame.origin.y += kTextViewPaddingY/2;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
		
		UITextView *textView = [[UITextView alloc] initWithFrame:frame];
		textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		textView.font = [UIFont systemFontOfSize:17.0];
		textView.backgroundColor = [UIColor whiteColor];
		_textView = textView;
		[self addSubview:textView];

		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
