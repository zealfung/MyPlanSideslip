//
//  UIButton+Util.h
//  plan
//
//  Created by Fengzy on 15/8/28.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIButton (Util)

- (void)setAllTitle:(NSString *)title;
- (void)setAllTitleColor:(UIColor *)color;
- (void)setAllImage:(UIImage *)image;
- (void)setAllBackgroundImage:(UIImage *)image;

- (void)setNormalTitleColor:(UIColor *)color;
- (void)setNormalTitle:(NSString *)title;
- (void)setNormalImage:(UIImage *)image;
- (void)setNormalBackgroundImage:(UIImage *)image;

- (void)centerButtonAndImageWithSpacing:(CGFloat)spacing;

@end
