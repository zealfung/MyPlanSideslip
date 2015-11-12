//
//  Config.m
//  plan
//
//  Created by Fengzy on 15/8/28.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Config.h"

static Config * instance = nil;

@implementation Config

+ (id)shareInstance {
    if(instance == nil)
    {
        instance = [[super allocWithZone:nil] init];
    }
    return instance;
}


@end
