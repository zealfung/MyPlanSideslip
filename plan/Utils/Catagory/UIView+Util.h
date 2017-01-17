//
//  UIView+Util.h
//  plan
//
//  Created by Fengzy on 15/11/12.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIViewVisibility)
{
    UIViewVisibilityVisible,
    UIViewVisibilityInvisible,
    UIViewVisibilityGone
};

typedef NS_OPTIONS(NSUInteger, UIViewMarginDirection)
{
    UIViewMarginDirectionNone       = 0,
    UIViewMarginDirectionTop        = 1 << 0,
    UIViewMarginDirectionLeft       = 1 << 1,
    UIViewMarginDirectionBottom     = 1 << 2,
    UIViewMarginDirectionRight      = 1 << 3,
    UIViewMarginDirectionAll        = UIViewMarginDirectionTop|UIViewMarginDirectionLeft|UIViewMarginDirectionBottom|UIViewMarginDirectionRight
};

@interface UIView (Util)

@property (assign, nonatomic) CGFloat dop_x;
@property (assign, nonatomic) CGFloat dop_y;
@property (assign, nonatomic) CGFloat dop_width;
@property (assign, nonatomic) CGFloat dop_height;
@property (assign, nonatomic) CGSize dop_size;
@property (assign, nonatomic) CGPoint dop_origin;

- (void)setCornerRadius:(CGFloat)cornerRadius;
- (void)setBorderWidth:(CGFloat)width andColor:(UIColor *)color;

-(void)setVisibility:(UIViewVisibility)visibility;
-(void)setVisibility:(UIViewVisibility)visibility affectedMarginDirections:(UIViewMarginDirection)affectedMarginDirections;
//键盘顶部按钮栏
- (UIView *)getInputAccessoryView;

@end
