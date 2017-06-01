//
//  UIViewController+Util.m
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+Util.h"

NSInteger const kIOS7SmartLeftMarginWidth = -14;
NSInteger const kIOS7SmartRightMarginWidth = -14;

@interface UIControl (Util)

@property (nonatomic, copy) void(^block)(__kindof UIControl *sender);

@end

@implementation UIControl (Util)
/** 当参数block为nil时，则是调用以前版本的事件(backAction:)，不为nil相当于重写以前的事件(backAction:) */
-(void )actionWithEvents:(UIControlEvents )events target:(__weak id )target sel:(SEL )sel block:(void(^ )(__kindof UIControl *sender))block
{
    if (block)
    {
        [self addTarget:self action:@selector(pr_action:) forControlEvents:events];
        self.block = block;
    }
    else
    {
        if ([target respondsToSelector:sel])
        {
            [self addTarget:target action:sel forControlEvents:events];
        }
    }
}

-(void )setBlock:(void(^ )(__kindof UIControl *) )block
{
    objc_setAssociatedObject(self, @selector(block), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(void(^ )(__kindof UIControl *) )block
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void )pr_action:(UIControl *)sender
{
    if (self.block)
    {
        self.block(self);
    }
}

@end

@implementation UIViewController (Util)

- (void)setIsPush:(BOOL)isPush
{
    objc_setAssociatedObject(self, @selector(isPush), @(isPush), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isPush
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)customBackButton
{
    [self customLeftButtonWithImage:nil action:nil];
    
}

- (void)customBackButtonForTitle:(NSString *)title
{
    if (self.navigationController.viewControllers.count > 0)
    {
        NSMutableArray *barButtonItems = [NSMutableArray array];
        {
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            barButtonItem.width = 0;
            [barButtonItems addObject:barButtonItem];
        }
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.titleLabel.font = font_Normal_15;
            [button setTitleColor:RGBColor(102, 102, 102, 1) forState:UIControlStateNormal];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            CGRect frame = CGRectMake(0, 0, 0, 40);
            if (title.length > 0) {
                [button setTitle:title forState:UIControlStateNormal];
                UIFont *font = button.titleLabel.font;
                CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: font}];
                frame.size.width = size.width + 40;
            } else {
                frame.size.width = 60;
            }
            button.frame = frame;
            [button setImage:[UIImage imageNamed:@"Btn_Arrow_Left"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
            [barButtonItems addObject:barButtonItem];
        }
        self.navigationItem.leftBarButtonItems = barButtonItems;
    }
}

- (void)willBack
{
    [self.view endEditing:YES];
}

- (void)backAction:(UIButton*)sender
{
    [self willBack];
    if(self.isPush)
    {
        if (self.navigationController)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem
{
    NSArray *leftBarButtonItems = nil;
    if (leftBarButtonItem)
    {
        leftBarButtonItems = @[leftBarButtonItem];
    }
    self.leftBarButtonItems = leftBarButtonItems;
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem
{
    NSArray *rightBarButtonItems = nil;
    if (rightBarButtonItem)
    {
        rightBarButtonItems = @[rightBarButtonItem];
    }
    self.rightBarButtonItems = rightBarButtonItems;
}

- (UIBarButtonItem *)getLeftBarButtonItem
{
    UIBarButtonItem *item = nil;
    NSArray *array = self.leftBarButtonItems;
    if (array.count)
    {
        item = array[0];
    }
    return item;
}

- (UIBarButtonItem *)getRightBarButtonItem
{
    UIBarButtonItem *item = nil;
    NSArray *array = self.rightBarButtonItems;
    if (array.count)
    {
        item = array[0];
    }
    return item;
}

- (void)setLeftBarButtonItems:(NSArray *)items
{
    if (iOS7_LATER)
    {
        self.navigationItem.leftBarButtonItems = [self barButtonItems:items marginWidth:kIOS7SmartLeftMarginWidth];
    }
    else
    {
        self.navigationItem.leftBarButtonItems = items;
    }
}

- (void)setRightBarButtonItems:(NSArray *)items
{
    if (iOS7_LATER)
    {
        self.navigationItem.rightBarButtonItems = [self barButtonItems:items marginWidth:kIOS7SmartRightMarginWidth];
    }
    else
    {
        self.navigationItem.rightBarButtonItems = items;
    }
}

- (NSArray *)getLeftBarButtonItems
{
    return [self getBarButtonItemsForItems:self.navigationItem.leftBarButtonItems];
}


- (NSArray *)getRightBarButtonItems
{
    return [self getBarButtonItemsForItems:self.navigationItem.rightBarButtonItems];
}

- (NSArray *)getBarButtonItemsForItems:(NSArray *)items
{
    NSArray *array = nil;
    if (iOS7_LATER && items.count > 0)
    {
        NSMutableArray *mutItems = [NSMutableArray arrayWithArray:items];
        [mutItems removeObjectAtIndex:0];
        
        array = [NSArray arrayWithArray:mutItems];
    }
    else
    {
        array = items;
    }
    return array;
}

- (NSArray *)barButtonItems:(NSArray *)items marginWidth:(NSInteger)marginWidth
{
    NSArray *tmpItems = nil;
    
    if (items.count > 0)
    {
        NSMutableArray *mutItems = [NSMutableArray arrayWithArray:items];
        
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedSpace.width = marginWidth;
        
        [mutItems insertObject:fixedSpace atIndex:0];
        
        tmpItems = [NSArray arrayWithArray:mutItems];
    }
    return tmpItems;
}

//create left title
-(UIBarButtonItem *)createLeftItemWithTitle:(NSString *)title font:(UIFont *)font textColor:(UIColor *)color action:(void(^)(UIButton *sender)) action
{
    UIButton *button = [self createButtonWithTitle:title image:nil font:font textColor:color contentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft action:action];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(UIBarButtonItem *)createLeftItemWithAttributedTitle:(NSAttributedString *)title action:(void(^)(UIButton *sender)) action
{
    UIButton *button = [self createButtonWithAttributedTitle:title contentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft action:action];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(UIBarButtonItem *)createLeftItemWithImage:(UIImage *)image title:(NSString *)title font:(UIFont *)font textColor:(UIColor *)color action:(void(^)(UIButton *sender)) action
{
    UIButton *button = [self createButtonWithTitle:title image:image font:font textColor:color contentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft action:action];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

//create right title
-(UIBarButtonItem *)createRightItemWithTitle:(NSString *)title font:(UIFont *)font textColor:(UIColor *)color action:(void(^)(UIButton *sender)) action
{
    UIButton *button = [self createButtonWithTitle:title image:nil font:font textColor:color contentHorizontalAlignment:UIControlContentHorizontalAlignmentRight action:action];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(UIBarButtonItem *)createRightItemWithAttributedTitle:(NSAttributedString *)title action:(void(^)(UIButton *sender)) action
{
    UIButton *button = [self createButtonWithAttributedTitle:title contentHorizontalAlignment:UIControlContentHorizontalAlignmentRight action:action];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

//create by image left
-(UIBarButtonItem *)createLeftItemWithImage:(UIImage *)image
                                     action:(void(^)(UIButton *sender)) action
{
    UIButton *button = [self createButtonWithTitle:nil image:image font:nil textColor:nil contentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft action:action];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

//create by image right
-(UIBarButtonItem *)createRightItemWithImage:(UIImage *)image
                                      action:(void(^)(UIButton *sender)) action
{
    UIButton *button = [self createButtonWithTitle:nil image:image font:nil textColor:nil contentHorizontalAlignment:UIControlContentHorizontalAlignmentRight action:action];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

//left
-(void )customLeftButtonWithImage:(UIImage *)image action:(void(^)(UIButton *sender)) action
{
    if (image == nil)
    {
        //默认图片
        image = [UIImage imageNamed:png_Icon_Arrow_Left];
    }
    UIBarButtonItem *item = [self createLeftItemWithImage:image action:action];
    [self customLeftButtonsWithArray:@[item]];
}

-(void )customLeftButtonWithTitle:(NSString *)title action:(void(^)(UIButton *sender)) action
{
    UIBarButtonItem *item = [self createLeftItemWithTitle:title font:nil textColor:nil action:action];
    [self customLeftButtonsWithArray:@[item]];
}

-(void )customLeftButtonWithAttributedTitle:(NSAttributedString *)title action:(void(^)(UIButton *sender)) action
{
    UIBarButtonItem *item = [self createLeftItemWithAttributedTitle:title action:action];
    [self customLeftButtonsWithArray:@[item]];
}

-(void )customLeftButtonWithImage:(UIImage *)image title:(NSString *)title action:(void(^)(UIButton *sender)) action
{
    if (image == nil)
    {
        //默认图片
        image = [UIImage imageNamed:png_Icon_Arrow_Left];
    }
    UIBarButtonItem *item = [self createLeftItemWithImage:image title:title font:nil textColor:nil action:action];
    [self customLeftButtonsWithArray:@[item]];
}

//right
-(void )customRightButtonWithImage:(UIImage *)image action:(void(^)(UIButton *sender)) action
{
    UIBarButtonItem *item = [self createRightItemWithImage:image action:action];
    [self customRightButtonsWithArray:@[item]];
}

-(void )customRightButtonWithTitle:(NSString *)title action:(void(^)(UIButton *sender)) action
{
    UIBarButtonItem *item = [self createRightItemWithTitle:title font:font_Normal_16 textColor:[UIColor whiteColor] action:action];
    [self customRightButtonsWithArray:@[item]];
}

-(void )customRightButtonWithAttributedTitle:(NSAttributedString *)title action:(void(^)(UIButton *sender)) action
{
    UIBarButtonItem *item = [self createRightItemWithAttributedTitle:title action:action];
    [self customRightButtonsWithArray:@[item]];
}

//set items
-(void )customLeftButtonsWithArray:(NSArray<UIBarButtonItem *> *)items
{
    self.navigationItem.leftBarButtonItems = items;
}

-(void )customRightButtonsWithArray:(NSArray<UIBarButtonItem *> *)items
{
    self.navigationItem.rightBarButtonItems = items;
}

#pragma mark - pravice ---- 创建按钮样式
-(UIButton *)createButtonWithTitle:(NSString *)title image:(UIImage *)image font:(UIFont *)font textColor:(UIColor *)textColor contentHorizontalAlignment:(UIControlContentHorizontalAlignment )contentHorizontalAlignment action:(void (^)(UIButton *))action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.contentHorizontalAlignment = contentHorizontalAlignment;
    if (font)
    {
        button.titleLabel.font = font;
    }
    else
    {
        //默认字体大小
        button.titleLabel.font = font_Normal_16;
    }
    if (textColor)
    {
        [button setTitleColor:textColor forState:UIControlStateNormal];
        [button setTitleColor:[textColor colorWithAlphaComponent:0.3] forState:UIControlStateHighlighted];
    }
    else
    {
        //默认字体颜色
        textColor = color_Blue;
        [button setTitleColor:textColor forState:UIControlStateNormal];
        [button setTitleColor:[textColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    }
    if (title)
    {
        [button setTitle:title forState:UIControlStateNormal];
    }
    if (image)
    {
        [button setImage:image forState:UIControlStateNormal];
    }
    //默认最小宽度为60
    CGSize size = [button sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    if (size.width < 40)
    {
        size.width = 40;
    }
    
    button.frame = CGRectMake(0, 0, size.width, 40);
    //    button.backgroundColor = [UIColor redColor];
    /** 当参数block为nil时，则是调用以前版本的事件(backAction:)，不为nil相当于重写以前的事件(backAction:) */
    [button actionWithEvents:UIControlEventTouchUpInside target:self sel:@selector(backAction:) block:action];
    return button;
}

-(UIButton *)createButtonWithAttributedTitle:(NSAttributedString *)title contentHorizontalAlignment:(UIControlContentHorizontalAlignment )contentHorizontalAlignment action:(void (^)(UIButton *))action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.contentHorizontalAlignment = contentHorizontalAlignment;
    if (title.length > 0)
    {
        [button setAttributedTitle:title forState:UIControlStateNormal];
        __block UIColor *color = [UIColor colorWithWhite:1 alpha:1];
        //遍历是否设置了字体颜色，默认取富文本最后一种颜色，用于点击时的效果设置
        [title enumerateAttributesInRange:NSMakeRange(0, title.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            if (nil != attrs[NSForegroundColorAttributeName])
            {
                color = attrs[NSForegroundColorAttributeName];
            }
        }];
        //设置点击时的效果
        NSMutableAttributedString *muAtt = [[NSMutableAttributedString alloc] initWithAttributedString:title];
        [muAtt addAttribute:NSForegroundColorAttributeName value:[color colorWithAlphaComponent:0.5] range:NSMakeRange(0, title.length)];
        [button setAttributedTitle:[muAtt copy] forState:UIControlStateHighlighted];
    }
    //默认最小宽度为60
    CGSize size = [button sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    if (size.width < 50)
    {
        size.width = 50;
    }
    button.frame = CGRectMake(0, 0, size.width, 40);
    /** 当参数block为nil时，则是调用以前版本的事件(backAction:)，不为nil相当于重写以前的事件(backAction:) */
    [button actionWithEvents:UIControlEventTouchUpInside target:self sel:@selector(backAction:) block:action];
    return button;
}

@end
