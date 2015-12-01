//
//  AppDelegate.h
//  plan
//
//  Created by Fengzy on 15/8/28.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate> {
    
    UILocalNotification *lastNotification;
}

@property (strong, nonatomic) UIWindow *window;


@end

