//
//  UIViewController+Util.h
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Util)

/** 是否是push进来的 */
@property (nonatomic, assign) BOOL isPush;

/** 创建不带文字的自定义导航栏返回按钮 */
- (void)customBackButton;

/** 创建带文字的自定义导航栏返回按钮 */
- (void)customBackButtonForTitle:(NSString *)title;

/** 界面返回方法，可被重写 */
- (void)backAction:(UIButton*)sender;

/** 界面预备返回方法，可被重写 */
- (void)willBack;

@property (nonatomic, getter = getLeftBarButtonItem, setter = setLeftBarButtonItem:) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, getter = getRightBarButtonItem, setter = setRightBarButtonItem:) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, getter = getRightBarButtonItems, setter = setRightBarButtonItems:) NSArray *rightBarButtonItems;
@property (nonatomic, getter = getLeftBarButtonItems, setter = setLeftBarButtonItems:) NSArray *leftBarButtonItems;
/** 创建左边标题按钮，文字靠左边    |text---------| */
-(UIBarButtonItem *)createLeftItemWithTitle:(NSString *)title
                                       font:(UIFont *)font
                                  textColor:(UIColor *)color
                                     action:(void(^)(UIButton *sender)) action;
//富文本标题
-(UIBarButtonItem *)createLeftItemWithAttributedTitle:(NSAttributedString *)title
                                               action:(void(^)(UIButton *sender)) action;

/** 创建左边带图标标题按钮    |image text---------| */
-(UIBarButtonItem *)createLeftItemWithImage:(UIImage *)image
                                      title:(NSString *)title
                                       font:(UIFont *)font
                                  textColor:(UIColor *)color
                                     action:(void(^)(UIButton *sender)) action;

/** 创建右边标题按钮，文字靠右边    |---------text| */
-(UIBarButtonItem *)createRightItemWithTitle:(NSString *)title
                                        font:(UIFont *)font
                                   textColor:(UIColor *)color
                                      action:(void(^)(UIButton *sender)) action;
//富文本标题
-(UIBarButtonItem *)createRightItemWithAttributedTitle:(NSAttributedString *)title
                                                action:(void(^)(UIButton *sender)) action;


/** 创建图标按钮,居左 */
-(UIBarButtonItem *)createLeftItemWithImage:(UIImage *)image
                                     action:(void(^)(UIButton *sender)) action;

/** 创建图标按钮,居左 */
-(UIBarButtonItem *)createRightItemWithImage:(UIImage *)image
                                      action:(void(^)(UIButton *sender)) action;


/** back，为了兼容以前的返回事件，代码里传了target跟sel。
 *  当参数block为nil时，则是调用以前版本的事件(backAction:)，不为nil相当于重写以前的事件(backAction:)
 */
-(void)customLeftButtonWithImage:(UIImage *)image
                           action:(void(^)(UIButton *sender)) action;

-(void)customLeftButtonWithTitle:(NSString *)title
                           action:(void(^)(UIButton *sender)) action;

-(void)customLeftButtonWithAttributedTitle:(NSAttributedString *)title
                                     action:(void(^)(UIButton *sender)) action;

/** 返回，带文字图标 */
-(void)customLeftButtonWithImage:(UIImage *)image
                            title:(NSString *)title
                           action:(void(^)(UIButton *sender)) action;

/** right按钮 */
-(void)customRightButtonWithImage:(UIImage *)image
                            action:(void(^)(UIButton *sender)) action;

-(void)customRightButtonWithTitle:(NSString *)title
                            action:(void(^)(UIButton *sender)) action;

-(void)customRightButtonWithAttributedTitle:(NSAttributedString *)title
                                      action:(void(^)(UIButton *sender)) action;

/** 用此方法添加到导航栏，方便以后可控修改 */
-(void)customLeftButtonsWithArray:(NSArray<UIBarButtonItem *> *)items;
-(void)customRightButtonsWithArray:(NSArray<UIBarButtonItem *> *)items;

@end
