//
//  FatherViewController.h
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FatherViewController : UIViewController

@property (nonatomic, strong, readonly) UIButton *backButton;
@property (nonatomic, assign) BOOL isPush;//是否是push进来的
@property (nonatomic, strong) NSString *hudText;

//创建导航栏文字按钮
-(UIBarButtonItem *)createBarButtonItemWithTitle:(NSString *)title titleColor:(UIColor *)color font:(UIFont *)font selector:(SEL)selector;

//创建导航栏图片按钮
-(UIBarButtonItem *)createBarButtonItemWithNormalImageName:(NSString *)normalImageName selectedImageName:(NSString *)selectedImageName selector:(SEL)selector;

//键盘顶部按钮栏
- (UIView *)getInputAccessoryView;

- (void)backAction:(UIButton*)sender;

//返回,可被重写
- (void)willBack;

//检查TabBar未读小红点
- (void)checkUnread:(UITabBar *)tabbar index:(int)index;

@end


@interface FatherViewController (HUDControl)

- (void)showHUD;
- (void)hideHUD;

@end


@interface FatherViewController (alert)

//显示带有“知道了”按钮的提示框
- (void)alertButtonMessage:(NSString *)message;

//显示会自动消失的提示框
- (void)alertToastMessage:(NSString *)message;

//在导航栏显示会自动消失的提示框
- (void)alertNavBarMessage:(NSString *)message;

@end