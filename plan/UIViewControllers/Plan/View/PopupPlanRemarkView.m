//
//  PopupPlanRemarkView.m
//  plan
//
//  Created by Fengzy on 17/1/17.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "PopupPlanRemarkView.h"

@interface PopupPlanRemarkView ()

@property (nonatomic, strong) UIControl *backgroundControl;//灰色遮罩背景
@property (nonatomic, strong) UITextView *txtView;

@end

@implementation PopupPlanRemarkView


- (id)initWithTitle:(NSString *)title
{
    if (self)
    {
        self = [super init];
        
        CGFloat frameWidth = WIDTH_FULL_SCREEN * 0.6;
        CGFloat frameHeight = HEIGHT_FULL_SCREEN * 0.4;
        CGFloat yOffset = 0;
        
        self.frame = CGRectMake(0, 0, frameWidth, frameHeight);
        self.layer.cornerRadius = 7;
        self.layer.masksToBounds= YES;
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, frameWidth, frameHeight * 0.15)];
        labelTitle.font = font_Bold_16;
        labelTitle.text = title;
        labelTitle.backgroundColor = color_Blue;
        labelTitle.textColor = [UIColor whiteColor];
        labelTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:labelTitle];
        
        yOffset += frameHeight * 0.15 + 10;

        UITextView *txtViewRemark = [[UITextView alloc] initWithFrame:CGRectMake(10, yOffset, frameWidth - 20, frameHeight - yOffset - 60)];
        txtViewRemark.backgroundColor = [UIColor whiteColor];
        txtViewRemark.scrollEnabled = YES;
        txtViewRemark.selectable = YES;
        txtViewRemark.editable = YES;
        txtViewRemark.font = font_Normal_16;
        txtViewRemark.textColor = color_333333;
        txtViewRemark.textAlignment = NSTextAlignmentLeft;
        txtViewRemark.layer.borderWidth = 1;
        txtViewRemark.layer.borderColor = [color_dedede CGColor];
        txtViewRemark.inputAccessoryView = [self getInputAccessoryView];
        [self addSubview:txtViewRemark];
        self.txtView = txtViewRemark;
        
        UIButton *btnOK = [UIButton buttonWithType:UIButtonTypeCustom];
        btnOK.frame = CGRectMake(10, frameHeight - 10 - frameHeight * 0.15, frameWidth - 20, frameHeight * 0.15);
        [btnOK setAllTitle:STRCommonTip27];
        btnOK.layer.cornerRadius = 5;
        btnOK.titleLabel.font = font_Normal_16;
        [btnOK setBackgroundColor:color_Blue];
        [btnOK setAllTitleColor:[UIColor whiteColor]];
        [btnOK addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnOK];
    }
    return self;
}

- (void)okAction:(UIButton *)sender
{
    if (self.callbackBlock)
    {
        self.callbackBlock(self.txtView.text);
    }
    [self hide];
}

//显示菜单界面
- (void)show
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.backgroundControl = [[UIControl alloc] initWithFrame:window.frame];
    self.backgroundControl.backgroundColor = [UIColor blackColor];
    self.backgroundControl.alpha = 0.5;
    
    [window addSubview:self.backgroundControl];
    self.center = window.center;
    [window addSubview:self];
    [self showAnimation];
}

//隐藏菜单界面
- (void)hide
{
    [self hideAnimation];
    [self.backgroundControl removeFromSuperview];
}

//显示时的动画效果
- (void)showAnimation
{
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.layer addAnimation:popAnimation forKey:nil];
}

//注销时的动画效果
- (void)hideAnimation
{
    [UIView animateWithDuration:0.4 animations:^{
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
