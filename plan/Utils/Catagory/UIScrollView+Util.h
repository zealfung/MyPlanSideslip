//
//  UIScrollView+Util.h
//  plan
//
//  Created by Fengzy on 2017/4/26.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface EmptyConfiguration : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy)   NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
/** 文字图片偏移 */
@property (nonatomic, assign) CGFloat verticalOffset;
/** 文字图片之间间距 */
@property (nonatomic, assign) CGFloat space;

@end


@interface UIScrollView (Empty)<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (nonatomic, strong) EmptyConfiguration *configuration;

- (void)setDefaultEmpty;
- (void)setEmptyWithText:(NSString *)text;
- (void)setEmptyWithText:(NSString *)text font:(UIFont *)font;
- (void)setEmptyWithText:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor;
- (void)setEmptyWithImage:(UIImage *)image;
- (void)setEmptyWithText:(NSString *)text image:(UIImage *)image;
- (void)setEmptyWithText:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor image:(UIImage *)image;

@end
