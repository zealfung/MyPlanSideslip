//
//  AlertCenter.h
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertCenter : NSObject

+ (void)alertButtonMessage:(NSString *)message;

+ (void)alertToastMessage:(NSString *)message;

@end
