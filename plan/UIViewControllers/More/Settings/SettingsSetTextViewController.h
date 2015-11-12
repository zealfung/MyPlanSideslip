//
//  SettingsSetTextViewController.h
//  plan
//
//  Created by Fengzy on 15/9/2.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "FirstViewController.h"

typedef NS_ENUM(NSUInteger, SetType) {
    
    SetNickName = 1, //设置昵称
    
    SetLife, //设置生命
    
    SetEmail //设置邮箱
    
};

typedef void(^kSettingsFinishedBlock)(NSString *text);

@interface SettingsSetTextViewController : FatherViewController

@property (nonatomic, copy) kSettingsFinishedBlock finishedBlock;
@property (nonatomic, strong) NSString *textFieldPlaceholder;
@property (nonatomic, assign) SetType setType;

@end
