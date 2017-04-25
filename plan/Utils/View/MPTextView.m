//
//  MPTextView.m
//  plan
//
//  Created by Fengzy on 2017/4/24.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "MPTextView.h"

@interface MPTextView() <UITextViewDelegate>

@end

@implementation MPTextView

-(void )layoutSubviews
{
    [self setTextHolder];
}

- (void)setMptext:(NSString *)mptext
{
    self.text = mptext;
    [self setTextHolder];
    if (self.textChange)
    {
        self.textChange(mptext);
    }
}

- (NSString *)mptext
{
    return self.text;
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = placeHolder;
    UILabel *label = [self viewWithTag:100];
    if (label == nil)
    {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = self.font;
        label.textColor = color_dedede;
        label.tag = 100;
        label.frame = CGRectMake(5, 0, CGRectGetWidth(self.frame), 30);
        [self addSubview:label];
    }
    label.text = placeHolder;
    [self setTextHolder];
    self.delegate = self;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self setTextHolder];
    if (self.textChange)
    {
        self.textChange(self.text);
    }
}


-(void )setTextHolder
{
    if (self.placeHolder)
    {
        UIView *view = [self viewWithTag:100];
        if (self.text.length > 0)
        {
            view.alpha = 0.0f;
        }
        else
        {
            view.alpha = 1.0f;
        }
    }
}
@end
