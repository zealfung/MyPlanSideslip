//
//  Config.h
//  plan
//
//  Created by Fengzy on 15/8/28.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Settings.h"
#import <Foundation/Foundation.h>

@interface Config : NSObject

@property (nonatomic, strong) Settings *settings;

+(instancetype)shareInstance;


@end
