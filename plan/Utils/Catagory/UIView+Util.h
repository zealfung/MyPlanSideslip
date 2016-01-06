//
//  UIView+Util.h
//  plan
//
//  Created by Fengzy on 15/11/12.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Util)

@property (assign, nonatomic) CGFloat dop_x;
@property (assign, nonatomic) CGFloat dop_y;
@property (assign, nonatomic) CGFloat dop_width;
@property (assign, nonatomic) CGFloat dop_height;
@property (assign, nonatomic) CGSize dop_size;
@property (assign, nonatomic) CGPoint dop_origin;

- (void)setCornerRadius:(CGFloat)cornerRadius;
- (void)setBorderWidth:(CGFloat)width andColor:(UIColor *)color;

@end
