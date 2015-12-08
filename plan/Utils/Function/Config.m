//
//  Config.m
//  plan
//
//  Created by Fengzy on 15/8/28.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Config.h"

static Config *instance = nil;

@implementation Config

+ (Config *)shareInstance {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[[self class] hideAlloc] init];
        }
    }
    return instance;
}

+ (id)hideAlloc {
    return [super alloc];
}

+ (id)alloc {
    return nil;
}

+ (id)new {
    return [self alloc];
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    @synchronized(self) {
        if (instance == nil) {
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

@end
