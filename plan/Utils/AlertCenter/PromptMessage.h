//
//  PromptMessage.h
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PromptMessage : UIView {
    UIWindow * keyWindow;
}

@property(nonatomic,assign)NSInteger second;

- (void)showMessage:(NSString *)msg;

- (void)showMessage1:(NSAttributedString *)msg;

- (void)showRewardMessage:(NSString *)msg;

@end
