//
//  AppDelegate.m
//  plan
//
//  Created by Fengzy on 15/8/28.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Plan.h"
#import "LogIn.h"
#import "CLLockVC.h"
#import "PlanCache.h"
#import "DataCenter.h"
#import "RESideMenu.h"
#import "CLLockNavVC.h"
#import "RegisterSDK.h"
#import "AppDelegate.h"
#import "StatisticsCenter.h"
#import "LogInViewController.h"
#import "LocalNotificationManager.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //本地通知注册
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        
    }
    
    UILocalNotification *localNotify = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotify) {
        //程序在后台或者已关闭
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [NotificationCenter postNotificationName:NTFLocalPush object:nil userInfo:localNotify.userInfo];
        });
    }

    //注册第三方SDK
    [RegisterSDK registerSDK];
    
    return YES;
}

//禁止横向旋转屏幕
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    return UIInterfaceOrientationMaskPortrait;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // 清除推送图标标记
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // 清除推送图标标记
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    UIViewController *controller = self.window.rootViewController;
    if ([controller isKindOfClass:[RESideMenu class]]) {
        //加载个人设置
        [Config shareInstance].settings = [PlanCache getPersonalSettings];
        BOOL hasPwd = [[Config shareInstance].settings.isUseGestureLock isEqualToString:@"1"]
        && [Config shareInstance].settings.gesturePasswod
        && [Config shareInstance].settings.gesturePasswod.length > 0;
        if (hasPwd) {
            //手势解锁
            __weak typeof(self) weakSelf = self;
            [CLLockVC showVerifyLockVCInVC:controller isLogIn:YES forgetPwdBlock:^{
                
                LogInViewController *LogInVC = [[LogInViewController alloc] init];
                LogInVC.isForgotGesture = YES;
                CLLockNavVC *navVC = [[CLLockNavVC alloc] initWithRootViewController:LogInVC];
                weakSelf.window.rootViewController = navVC;
                
            } successBlock:^(CLLockVC *lockVC, NSString *pwd) {
                
                [lockVC dismiss:.5f];
            }];
        }
    }
    
    if ([LogIn isLogin]) {
        //签到
        [StatisticsCenter checkIn];
        //更新版本号信息
        [DataCenter updateVersionToServerForSettings];
        //自动同步数据
        if ([[Config shareInstance].settings.isAutoSync isEqualToString:@"1"]) {
            [DataCenter startSyncData];
        } else {
            //同步个人设置
            [Config shareInstance].isSyncSettingsOnly = YES;
            [DataCenter startSyncSettings];
        }
    }
    
    //加载系统消息
    [DataCenter getMessagesFromServer];
}

/**
 *  接收本地推送
 */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification {
    
    lastNotification = notification;
    //重置5天未新建计划提醒时间
    [self checkFiveDayNotification];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
    } else if(buttonIndex == 1) {
        //显示
        [NotificationCenter postNotificationName:NTFLocalPush object:nil userInfo:lastNotification.userInfo];
        
        NSDictionary *dict = lastNotification.userInfo;
        NSInteger type = [[dict objectForKey:@"type"] integerValue];
        if (type == 0) {//计划提醒
            Plan *plan = [[Plan alloc] init];
            plan.account = [dict objectForKey:@"account"];
            plan.planid = [dict objectForKey:@"tag"];
            if ([plan.planid isEqualToString:Notify_FiveDay_Tag]) {
                //5天未新建计划提醒，不需要跳转到计划详情
                return;
            }
            //切换到计划栏
            [self changeTabbarSelectedItem:1];
            
        } else if (type == 1) {//任务提醒
            //切换到任务栏
            [self changeTabbarSelectedItem:2];
        }
        
    } else if(buttonIndex == 2) {
        //5分钟后提醒
        NSDate *date = [[NSDate date] dateByAddingTimeInterval:5 * 60];
        [LocalNotificationManager updateNotificationWithTag:lastNotification fireDate:date userInfo:lastNotification.userInfo alertBody:lastNotification.alertBody];
    }
}

- (void)changeTabbarSelectedItem:(NSInteger)index {
    RESideMenu *rootView = (RESideMenu *)self.window.rootViewController;
    UITabBarController *tabController = (UITabBarController *)rootView.contentViewController;
    NSArray *array = tabController.viewControllers;
    if (array) {
        tabController.selectedViewController = array[index];
    }
}

- (void)checkFiveDayNotification {
    NSDictionary *dict = lastNotification.userInfo;
    Plan *plan = [[Plan alloc] init];
    plan.account = [dict objectForKey:@"account"];
    plan.planid = [dict objectForKey:@"tag"];
    plan.createtime = [dict objectForKey:@"createtime"];
    plan.content = [dict objectForKey:@"content"];
    plan.beginDate = [dict objectForKey:@"beginDate"];
    plan.iscompleted = [dict objectForKey:@"iscompleted"];
    plan.completetime = [dict objectForKey:@"completetime"];
    plan.isnotify = @"1";
    plan.notifytime = [dict objectForKey:@"notifytime"];
    
    if ([plan.planid isEqualToString:Notify_FiveDay_Tag]) {
        //如果还是没有新建计划，每天提醒一次
        NSDate *tomorrow = [[NSDate date] dateByAddingTimeInterval:24 * 3600];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:str_DateFormatter_yyyy_MM_dd_HHmm];
        NSString *fiveDayTomorrow = [dateFormatter stringFromDate:tomorrow];
        plan.notifytime = fiveDayTomorrow;
        [PlanCache updatePlanNotification:plan];
    } else {
        BmobUser *user = [BmobUser currentUser];
        NSString *account = @"";
        if (user) {
            account = user.objectId;
        }
        if (![plan.account isEqualToString:account]) {//非该账号的提醒，不显示
            return;
        }
        UIApplicationState state = [UIApplication sharedApplication].applicationState;
        if (state == UIApplicationStateInactive) {
            //程序在后台或者已关闭
            [NotificationCenter postNotificationName:NTFLocalPush object:nil userInfo:lastNotification.userInfo];
            
            NSDictionary *dict = lastNotification.userInfo;
            NSInteger type = [[dict objectForKey:@"type"] integerValue];
            if (type == 0) {//计划提醒
                Plan *plan = [[Plan alloc] init];
                plan.account = [dict objectForKey:@"account"];
                plan.planid = [dict objectForKey:@"tag"];
                if ([plan.planid isEqualToString:Notify_FiveDay_Tag]) {
                    //5天未新建计划提醒，不需要跳转到计划详情
                    return;
                }
                //切换到计划栏
                [self changeTabbarSelectedItem:1];
                
            } else if (type == 1) {//任务提醒
                //切换到任务栏
                [self changeTabbarSelectedItem:2];
            }
            
        } else {
            //程序正在运行
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lastNotification.alertTitle message:lastNotification.alertBody delegate:self cancelButtonTitle:STRCommonTip28 otherButtonTitles:STRCommonTip29, STRCommonTip42, nil];
            [alert show];
        }
    }
}

@end
