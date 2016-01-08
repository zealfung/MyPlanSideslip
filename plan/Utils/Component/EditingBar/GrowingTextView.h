//
//  GrowingTextView.h
//  plan
//
//  Created by Fengzy on 16/1/7.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "PlaceholderTextView.h"

@interface GrowingTextView : PlaceholderTextView

@property (nonatomic, assign) NSUInteger maxNumberOfLines;
@property (nonatomic, readonly) CGFloat maxHeight;

- (void)setUpWithPlaceholder:(NSString *)placeholder;
- (CGFloat)measureHeight;

@end
