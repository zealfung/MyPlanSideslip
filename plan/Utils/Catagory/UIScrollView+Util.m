//
//  UIScrollView+Util.m
//  plan
//
//  Created by Fengzy on 2017/4/26.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "UIScrollView+Util.h"
#import <objc/runtime.h>

@implementation EmptyConfiguration

@end

@implementation UIScrollView (Empty)

- (void)setConfiguration:(EmptyConfiguration *)configuration
{
    objc_setAssociatedObject(self, @selector(configuration), configuration, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (EmptyConfiguration *)configuration
{
    EmptyConfiguration *obj = objc_getAssociatedObject(self, _cmd);
    if (obj == nil)
    {
        obj = [EmptyConfiguration new];
        obj.verticalOffset = -64;
        obj.textColor = color_999999;
        obj.font = font_Normal_16;
        obj.text = @"暂无数据";
        obj.image = [UIImage imageNamed:@"Icon_EmptyTable"];
        objc_setAssociatedObject(self, _cmd, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return obj;
}

- (void)setDefaultEmpty
{
    [self setEmptyWithText:nil image:nil];
}

- (void)setEmptyWithText:(NSString *)text
{
    [self setEmptyWithText:text font:nil];
}

- (void)setEmptyWithText:(NSString *)text font:(UIFont *)font
{
    [self setEmptyWithText:text font:font textColor:nil];
}

- (void)setEmptyWithText:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor
{
    [self setEmptyWithText:text font:font textColor:textColor image:nil];
}

- (void)setEmptyWithImage:(UIImage *)image
{
    [self setEmptyWithText:nil image:image];
}

- (void)setEmptyWithText:(NSString *)text image:(UIImage *)image
{
    [self setEmptyWithText:text font:nil textColor:nil image:image];
}

- (void)setEmptyWithText:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor image:(UIImage *)image
{
    [self setDelegateAndDataSource];
    if (text)
    {
        self.configuration.text = text;
    }
    if (font)
    {
        self.configuration.font = font;
    }
    if (textColor)
    {
        self.configuration.textColor = textColor;
    }
    if (image)
    {
        self.configuration.image = image;
    }
}

- (void)setDelegateAndDataSource
{
    self.emptyDataSetSource = self;
    self.emptyDataSetDelegate = self;
}

#pragma mark - <DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return self.configuration.image;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:self.configuration.text attributes:@{NSFontAttributeName:self.configuration.font,NSStrokeColorAttributeName:self.configuration.textColor}];
    
    return attr;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return self.configuration.verticalOffset;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return self.configuration.space;
}

- (void)emptyDataSetWillAppear:(UIScrollView *)scrollView
{
    scrollView.contentOffset = CGPointZero;
}

//是否允许滚动，默认为NO
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

@end
