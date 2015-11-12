//
//  NSString+Util.m
//  plan
//
//  Created by Fengzy on 15/8/29.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSString (Util)

//忽略大小写比较
- (BOOL)sameToString:(NSString *)string {
    if (!string) {
        return NO;
    }
    
    return [self caseInsensitiveCompare:string] == NSOrderedSame;
}

@end
