//
//  GrowingTextView.m
//  plan
//
//  Created by Fengzy on 16/1/7.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "GrowingTextView.h"

@implementation GrowingTextView

- (void)setUpWithPlaceholder:(NSString *)placeholder {
    self.font = [UIFont systemFontOfSize:16];
    self.scrollEnabled = NO;
    self.scrollsToTop = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.enablesReturnKeyAutomatically = YES;
    self.textContainerInset = UIEdgeInsetsMake(7.5, 3.5, 7.5, 0);
    [self setUpPlaceholderLabel:placeholder];
    _maxNumberOfLines = 4;
    _maxHeight = ceilf(self.font.lineHeight * _maxNumberOfLines + 15 + 4 * (_maxNumberOfLines - 1));
}

- (CGFloat)measureHeight {
    return ceilf([self sizeThatFits:self.frame.size].height + 10);
}

@end
