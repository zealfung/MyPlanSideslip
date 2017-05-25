//
//  PopupNewAppVersionView.m
//  plan
//
//  Created by Fengzy on 2017/5/25.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "PopupNewAppVersionView.h"

static PopupNewAppVersionView *instance = nil;

@interface PopupNewAppVersionView ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIControl *backgroundControl;//灰色遮罩背景

@end

@implementation PopupNewAppVersionView

+ (PopupNewAppVersionView *)shareInstance:(NSString *)version whatNew:(NSString *)whatNew isForce:(BOOL)isForce
{
    @synchronized(self)
    {
        if (instance == nil)
        {
            instance = [[[self class] hideAlloc] initWithVersion:version whatNew:whatNew isForce:isForce];
        }
    }
    return instance;
}

+ (id)hideAlloc
{
    return [super alloc];
}

+ (id)alloc
{
    return nil;
}

+ (id)new
{
    return [self alloc];
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (instance == nil)
        {
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

- (id)initWithVersion:(NSString *)version whatNew:(NSString *)whatNew isForce:(BOOL)isForce
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
        
        UIImageView *imgHeaderView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, frameHeight / 3)];
        [imgHeaderView setImage:[UIImage imageNamed:@"Bg_NewAppVersion"]];
        [self addSubview:imgHeaderView];
        
        UILabel *labelHeader = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, frameWidth, frameHeight / 4)];
        labelHeader.font = font_Bold_20;
        labelHeader.text = @"更新提示";
        labelHeader.textColor = [UIColor whiteColor];
        labelHeader.textAlignment = NSTextAlignmentCenter;
        [imgHeaderView addSubview:labelHeader];
        
        if (!isForce) {
            UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
            btnClose.frame = CGRectMake(frameWidth - 35, 5, 30, 30);
            [btnClose setAllImage:[UIImage imageNamed:@"Btn_Close"]];
            [btnClose addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btnClose];
        }
        yOffset += frameHeight / 3;
        
        UILabel *labelVersion = [[UILabel alloc] initWithFrame: CGRectMake(20, yOffset, frameWidth - 40, 30)];
        labelVersion.font = font_Normal_18;
        labelVersion.text = version;
        labelVersion.textColor = color_32393F;
        labelVersion.textAlignment = NSTextAlignmentLeft;
        [self addSubview:labelVersion];
        yOffset += 30;
        
        UITextView *txtWhatNewView = [[UITextView alloc] initWithFrame:CGRectMake(20, yOffset, frameWidth - 40, frameHeight - yOffset - 60)];
        txtWhatNewView.backgroundColor = [UIColor whiteColor];
        txtWhatNewView.scrollEnabled = YES;
        txtWhatNewView.selectable = NO;
        txtWhatNewView.editable = NO;
        txtWhatNewView.font = font_Normal_14;
        txtWhatNewView.textColor = color_32393F;
        txtWhatNewView.textAlignment = NSTextAlignmentLeft;
        txtWhatNewView.text = whatNew;
        [self addSubview:txtWhatNewView];
        
        UIButton *btnUpdate = [UIButton buttonWithType:UIButtonTypeCustom];
        btnUpdate.frame = CGRectMake(10, frameHeight - 10 - frameHeight * 0.15, frameWidth - 20, frameHeight * 0.15);
        [btnUpdate setAllTitle:@"更新"];
        btnUpdate.layer.cornerRadius = 5;
        btnUpdate.titleLabel.font = font_Normal_14;
        [btnUpdate setAllTitleColor:[UIColor whiteColor]];
        [btnUpdate setBackgroundImage:[UIImage imageNamed:@"Btn_NewAppVersion"] forState:UIControlStateNormal];
        [btnUpdate addTarget:self action:@selector(updateAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnUpdate];
    }
    return self;
}

- (void)closeAction:(UIButton *)sender
{
    NSString *showDate = [CommonFunction NSDateToNSString:[NSDate date] formatter:@"yyyy-MM-dd"];
    [UserDefaults setObject:showDate forKey:STRCheckNewVersion];
    [UserDefaults synchronize];
    [self hide];
}

- (void)updateAction:(UIButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/apple-store/id983206049?pt=572643&mt=8&ct="]];
}

//显示菜单界面
- (void)show
{
    if (!self.window)
    {
        self.window = [[UIApplication sharedApplication] keyWindow];
        self.backgroundControl = [[UIControl alloc] initWithFrame:self.window.frame];
        self.backgroundControl.backgroundColor = [UIColor blackColor];
        self.backgroundControl.alpha = 0.5;
        
        [self.window addSubview:self.backgroundControl];
        self.center = self.window.center;
        [self.window addSubview:self];
    }

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
