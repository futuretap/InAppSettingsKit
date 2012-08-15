//
//  IASKTextViewCell.m
//  InAppSettingsKitSampleApp
//
//  Created by Lin Junjie on 13/8/12.
//
//

#define IS_IPAD					(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kTextViewPaddingX		(IS_IPAD ? 100 : 30)
#define kTextViewPaddingY		(IS_IPAD ? 16 : 16)

#import "IASKTextViewCell.h"

@interface IASKTextViewCell () {
	UITextView *_textView;
}
@end

@implementation IASKTextViewCell
@synthesize textView = _textView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
		CGRect frame = self.frame;
		frame.size.width -= kTextViewPaddingX;
		frame.origin.x += kTextViewPaddingX/2;
		frame.size.height -= kTextViewPaddingY;
		frame.origin.y += kTextViewPaddingY/2;
		
		UITextView *textView = [[UITextView alloc] initWithFrame:frame];
		textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		textView.font = [UIFont systemFontOfSize:17.0];
		textView.backgroundColor = [UIColor clearColor];
		_textView = textView;
		[self addSubview:textView];
		[textView release];

		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)dealloc {
	[_textView release];
	_textView = nil;
	
    [super dealloc];
}

@end
