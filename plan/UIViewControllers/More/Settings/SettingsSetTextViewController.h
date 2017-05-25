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
    
    SetLife, //设置岁数
    
    SetEmail //设置邮箱
    
};


@interface SettingsSetTextViewController : FatherViewController

/** 回调函数 */
@property (nonatomic, copy) void(^finishedBlock)(NSString *text);
/** 默认值 */
@property (nonatomic, copy) NSString *textFieldDefaultValue;
/** 灰色提示输入文案 */
@property (nonatomic, copy) NSString *textFieldPlaceholder;
/** 设置类型 */
@property (nonatomic, assign) SetType setType;

@end
