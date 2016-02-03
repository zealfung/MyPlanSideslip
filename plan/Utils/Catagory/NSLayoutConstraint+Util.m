//
//  NSLayoutConstraint+Util.m
//  plan
//
//  Created by Fengzy on 16/2/3.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import <objc/runtime.h>
#import "NSLayoutConstraint+Util.h"

static const void *key = &key;

@implementation NSLayoutConstraint (Util)

- (void)clear {
    if (self.constant != 0) {
        NSNumber *oldConstant = @(self.constant);
        self.constant = 0;
        objc_setAssociatedObject(self, &key, oldConstant, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)restore {
    NSNumber *oldConstant = objc_getAssociatedObject(self, &key);
    if (oldConstant) {
        self.constant = oldConstant.floatValue;
        objc_setAssociatedObject(self, &key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
