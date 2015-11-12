//
//  PromptMessage.m
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "PromptMessage.h"

@implementation PromptMessage

@synthesize second;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.cornerRadius = 5;
        self.backgroundColor =[UIColor blackColor];
        self.alpha = 0.8;
        second = 2;
    }
    return self;
}

- (void)showMessage:(NSString *)msg {
    keyWindow =[UIApplication sharedApplication].keyWindow;
    
    UIView * background = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    background.tag = 100;
    [background setBackgroundColor:[UIColor clearColor]];
    [keyWindow addSubview:background];
    
    CGFloat promptHeight = 0.0f;
    
    UILabel * promptMessage = [[UILabel alloc] initWithFrame:CGRectMake(10,10, 240, 0)];
    [promptMessage setTextAlignment:NSTextAlignmentCenter];
    promptMessage.numberOfLines = 0;
    [promptMessage setFont:[UIFont systemFontOfSize:15.0f]];
    [promptMessage setText:msg];
    
    [promptMessage setTextColor:[UIColor whiteColor]];
    promptMessage.backgroundColor = [UIColor clearColor];
    CGSize size = [promptMessage boundingRectWithSize:CGSizeMake(240,0)];
    [promptMessage setFrame:CGRectMake(10,10, 240, size.height+10)];
    [self addSubview:promptMessage];
    
    promptHeight = promptHeight + size.height + 30;
    
    self.frame =CGRectMake(WIDTH_FULL_SCREEN/2-130,HEIGHT_FULL_SCREEN/2-promptHeight/2, 260,promptHeight);
    [background addSubview:self];
    
    [UIView animateKeyframesWithDuration:0.3 delay:1 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations: ^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [background removeFromSuperview];
    }];
}

- (void)showMessage1:(NSAttributedString *)msg {
    keyWindow =[UIApplication sharedApplication].keyWindow;
    
    UIView * background = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    background.tag = 100;
    [background setBackgroundColor:[UIColor clearColor]];
    [keyWindow addSubview:background];
    
    CGFloat promptHeight = 0.0f;
    
    UILabel * promptMessage = [[UILabel alloc] initWithFrame:CGRectMake(0,10, 140, 0)];
    [promptMessage setTextAlignment:NSTextAlignmentCenter];
    promptMessage.numberOfLines = 0;
    [promptMessage setFont:[UIFont systemFontOfSize:15.0f]];
    [promptMessage setAttributedText:msg];
    
    promptMessage.backgroundColor = [UIColor clearColor];
    CGSize size = [promptMessage boundingRectWithSize:CGSizeMake(140,0)];
    [promptMessage setFrame:CGRectMake(0,10, 140, size.height+10)];
    [self addSubview:promptMessage];
    
    promptHeight = promptHeight + size.height + 30;
    
    self.frame =CGRectMake(WIDTH_FULL_SCREEN/2-130+50,HEIGHT_FULL_SCREEN/2-promptHeight/2, 140,promptHeight);
    [background addSubview:self];
    
    [UIView animateKeyframesWithDuration:0.3 delay:1 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations: ^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [background removeFromSuperview];
    }];
}


- (void)showRewardMessage:(NSString *)msg {
    keyWindow =[UIApplication sharedApplication].keyWindow;
    
    UIView * background = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    background.tag = 100;
    [background setBackgroundColor:[UIColor clearColor]];
    [keyWindow addSubview:background];
    
    CGFloat promptHeight = 0.0f;
    
    UILabel * promptMessage = [[UILabel alloc] initWithFrame:CGRectMake(10,10, 240, 0)];
    [promptMessage setTextAlignment:NSTextAlignmentCenter];
    promptMessage.numberOfLines = 0;
    [promptMessage setFont:[UIFont systemFontOfSize:15.0f]];
    [promptMessage setText:msg];
    
    [promptMessage setTextColor:[UIColor whiteColor]];
    promptMessage.backgroundColor = [UIColor clearColor];
    CGSize size = [promptMessage boundingRectWithSize:CGSizeMake(240,0)];
    [promptMessage setFrame:CGRectMake(10,10, 240, size.height+10)];
    [self addSubview:promptMessage];
    
    promptHeight = promptHeight + size.height + 30;
    
    self.frame =CGRectMake(WIDTH_FULL_SCREEN/2-130,HEIGHT_FULL_SCREEN/2-promptHeight/2, 260,promptHeight);
    [background addSubview:self];
    
    [UIView animateKeyframesWithDuration:0.3 delay:1 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations: ^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [background removeFromSuperview];
    }];
}


@end
