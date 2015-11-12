//
//  FirstViewController.m
//  plan
//
//  Created by Fengzy on 15/8/28.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "PlanCache.h"
#import "ThreeSubView.h"
#import "UIButton+Util.h"
#import "MoreViewController.h"
#import "FirstViewController.h"

NSUInteger const kSecondsPerDay = 86400;


@interface FirstViewController () <UITextFieldDelegate> {
    
    ThreeSubView *nickNameView;
    ThreeSubView *liftetimeView;
    ThreeSubView *daysLeftView;
    ThreeSubView *secondsLeftView;
    UIView *statisticsView;
    ThreeSubView *everydayView;
    ThreeSubView *longtermView;
    
    NSTimer *timer;
    NSInteger daysLeft;
    NSDate *deadDay;
    
    NSUInteger xMiddle;
    NSUInteger yOffset;
    NSUInteger ySpace;
    
}

@end

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = str_ViewTitle_1;
    self.tabBarItem.title = str_ViewTitle_1;
    
    [NotificationCenter addObserver:self selector:@selector(refreshView:) name:Notify_Settings_Changed object:nil];
    [NotificationCenter addObserver:self selector:@selector(refreshView:) name:Notify_Plan_Save object:nil];
    
    //打开本地数据库
    [PlanCache openDBWithAccount:@"unknown"];
    //加载个人设置
    [Config shareInstance].settings = [PlanCache getPersonalSettings];
    
    [self loadCustomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [NotificationCenter removeObserver:self];
}

- (void)refreshView:(NSNotification*)notification
{
    [self loadCustomView];
}

- (void)loadCustomView{
    [self createAvatar];
    [self createLabelText];
    [self createStatisticsView];
}

- (void)createAvatar
{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSUInteger avatarBgSize = WIDTH_FULL_SCREEN / 3;
    NSUInteger avatarSize = avatarBgSize - 8;
    xMiddle = WIDTH_FULL_SCREEN / 2;
    yOffset = iPhone4 ? HEIGHT_FULL_SCREEN / 28 : HEIGHT_FULL_SCREEN / 15;
    ySpace = HEIGHT_FULL_SCREEN / 25;
    
    UIImage *bgImage = [UIImage imageNamed:png_AvatarBg];
    
    UIImageView *avatarBg = [[UIImageView alloc] initWithFrame:CGRectMake(xMiddle - avatarBgSize / 2, yOffset, avatarBgSize, avatarBgSize)];
    avatarBg.backgroundColor = [UIColor clearColor];
    avatarBg.image = bgImage;
    avatarBg.layer.cornerRadius = avatarBgSize / 2;
    avatarBg.clipsToBounds = YES;
    avatarBg.userInteractionEnabled = YES;
    avatarBg.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toMoreViewController)];
    [avatarBg addGestureRecognizer:singleTap];
    [self.view addSubview:avatarBg];
    
    {
        UIImage *image = [[Config shareInstance] getAvatar];
        
        UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(ceilf((avatarBgSize - avatarSize)/2), ceilf((avatarBgSize - avatarSize)/2), avatarSize, avatarSize)];
        avatar.backgroundColor = [UIColor clearColor];
        avatar.image = image;
        avatar.layer.cornerRadius = avatarSize / 2;
        avatar.clipsToBounds = YES;
        avatar.contentMode = UIViewContentModeScaleAspectFit;
        
        [avatarBg addSubview:avatar];
    }
    
    yOffset += avatarBgSize + ySpace;
}


- (void)createLabelText
{
    
    NSString *nickname = str_NickName;
    NSInteger lifetime = 100;
    CGFloat labelHeight = HEIGHT_FULL_SCREEN / 62;
    CGFloat labelWidth = WIDTH_FULL_SCREEN / 3 > 125 ? WIDTH_FULL_SCREEN / 3 : 125;
    
    if ([Config shareInstance].settings.nickname) {
        nickname = [Config shareInstance].settings.nickname;
    }
    if ([Config shareInstance].settings.lifespan) {
        NSString *life = [Config shareInstance].settings.lifespan;
        lifetime = [life integerValue];
    }
    
    __weak typeof(self) weakSelf = self;
    ThreeSubView *nickNameSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(xMiddle, yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:^{
        
        [weakSelf toMoreViewController];
        
    } rightButtonSelectBlock:nil];
    
    [nickNameSubView.centerButton.titleLabel setFont:font_Bold_32];
    [nickNameSubView.centerButton setAllTitleColor:color_Blue];
    [nickNameSubView.centerButton setAllTitle:nickname];
    
    [nickNameSubView autoLayout];
    
    [self.view addSubview:nickNameSubView];
    
    nickNameView = nickNameSubView;
    
    CGRect nickFrame = CGRectZero;
    nickFrame.size.width = nickNameView.frame.size.width;
    nickFrame.size.height = nickNameView.frame.size.height;
    nickFrame.origin.x = xMiddle - nickNameView.frame.size.width/2;
    nickFrame.origin.y = yOffset;
    
    nickNameView.frame = nickFrame;
    yOffset += nickNameView.frame.size.height + ySpace * 2;
    
    ThreeSubView *liftetimeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(xMiddle, yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    
    [liftetimeSubView.leftButton.titleLabel setFont:font_Normal_16];
    [liftetimeSubView.leftButton setAllTitleColor:color_Black];
    [liftetimeSubView.leftButton setAllTitle:str_FirstView_1];
    
    [liftetimeSubView.centerButton.titleLabel setFont:font_Normal_24];
    [liftetimeSubView.centerButton setAllTitleColor:color_Red];
    [liftetimeSubView.centerButton setAllTitle:[NSString stringWithFormat:@"%zd",lifetime]];
    
    [liftetimeSubView.rightButton.titleLabel setFont:font_Normal_16];
    [liftetimeSubView.rightButton setAllTitleColor:color_Black];
    [liftetimeSubView.rightButton setAllTitle:str_FirstView_2];
    
    [liftetimeSubView autoLayout];
    
    [self.view addSubview:liftetimeSubView];
    
    liftetimeView = liftetimeSubView;
    
    CGRect lifeFrame = CGRectZero;
    lifeFrame.size.width = liftetimeView.frame.size.width;
    lifeFrame.size.height = liftetimeView.frame.size.height;
    lifeFrame.origin.x = xMiddle - liftetimeView.frame.size.width/2;
    lifeFrame.origin.y = yOffset;
    
    liftetimeView.frame = lifeFrame;
    yOffset += liftetimeView.frame.size.height + ySpace;
    
    NSString *birthdayFormat = @"1987-03-05 00:00:00";
    if ([Config shareInstance].settings.birthday) {
        birthdayFormat = [NSString stringWithFormat:@"%@ 00:00:00", [Config shareInstance].settings.birthday];
    }
    
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* birthday = [formater dateFromString:birthdayFormat];
    
    NSTimeInterval secondsLifetime = kSecondsPerDay * 365 * lifetime;
    deadDay = [birthday dateByAddingTimeInterval:secondsLifetime];
    
    NSDate *now = [NSDate date];
    NSTimeInterval secondsBetweenDates= [deadDay timeIntervalSinceDate:now];
    if(secondsBetweenDates < 0){
        daysLeft = 0;
    } else {
        daysLeft = secondsBetweenDates/kSecondsPerDay;
    }
    
    ThreeSubView *daysLeftSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(xMiddle, yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    
    [daysLeftSubView.leftButton.titleLabel setFont:font_Normal_16];
    [daysLeftSubView.leftButton setAllTitleColor:color_Black];
    [daysLeftSubView.leftButton setAllTitle:str_FirstView_3];
    
    [daysLeftSubView.centerButton.titleLabel setFont:font_Normal_24];
    [daysLeftSubView.centerButton setAllTitleColor:color_Red];
    if ([Config shareInstance].settings.birthday) {
        [daysLeftSubView.centerButton setAllTitle:[NSString stringWithFormat:@"%zd",daysLeft]];
    } else {
        [daysLeftSubView.centerButton setAllTitle:@"X"];
    }
    
    
    [daysLeftSubView.rightButton.titleLabel setFont:font_Normal_16];
    [daysLeftSubView.rightButton setAllTitleColor:color_Black];
    [daysLeftSubView.rightButton setAllTitle:str_FirstView_4];
    
    [daysLeftSubView autoLayout];
    
    [self.view addSubview:daysLeftSubView];
    
    daysLeftView = daysLeftSubView;
    
    CGRect daysFrame = CGRectZero;
    daysFrame.size.width = daysLeftView.frame.size.width;
    daysFrame.size.height = daysLeftView.frame.size.height;
    daysFrame.origin.x = xMiddle - daysLeftView.frame.size.width/2;
    daysFrame.origin.y = yOffset;
    
    daysLeftView.frame = daysFrame;
    yOffset += daysLeftView.frame.size.height + ySpace;
    
    
    ThreeSubView *secondsLeftSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(xMiddle, yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    
    [secondsLeftSubView.leftButton.titleLabel setFont:font_Normal_16];
    [secondsLeftSubView.leftButton setAllTitleColor:color_Black];
    [secondsLeftSubView.leftButton setAllTitle:str_FirstView_5];
    
    [secondsLeftSubView.centerButton.titleLabel setFont:font_Normal_24];
    [secondsLeftSubView.centerButton setAllTitleColor:color_Red];
    [secondsLeftSubView.centerButton setAllTitle:[NSString stringWithFormat:@"%zd",kSecondsPerDay]];
    
    [secondsLeftSubView.rightButton.titleLabel setFont:font_Normal_16];
    [secondsLeftSubView.rightButton setAllTitleColor:color_Black];
    [secondsLeftSubView.rightButton setAllTitle:str_FirstView_6];
    
    [secondsLeftSubView autoLayout];
    
    [self.view addSubview:secondsLeftSubView];
    
    secondsLeftView = secondsLeftSubView;
    
    CGRect secondsFrame = CGRectZero;
    secondsFrame.size.width = secondsLeftView.frame.size.width;
    secondsFrame.size.height = secondsLeftView.frame.size.height;
    secondsFrame.origin.x = xMiddle - secondsLeftView.frame.size.width/2;
    secondsFrame.origin.y = yOffset;
    
    secondsLeftView.frame = secondsFrame;
    
    
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(secondsCountdown) userInfo:nil repeats:YES];
}

- (void)createStatisticsView
{
    BOOL isiPhone4oriPhone5 = iPhone4 || iPhone5;
    
    CGFloat xOffset = isiPhone4oriPhone5 ? WIDTH_FULL_SCREEN / 15 : WIDTH_FULL_SCREEN / 7;
    CGFloat viewWidth = WIDTH_FULL_SCREEN - xOffset * 2;
    CGFloat subviewWidth = viewWidth / 4;
    CGFloat viewHeight = HEIGHT_FULL_SCREEN * 0.1875;
    CGFloat subviewHeight = viewHeight / 3;
    
    yOffset += iPhone4 ? ySpace : ySpace * 2;
    
    UIView *statisticsBgView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, yOffset, viewWidth, viewHeight)];
    [self.view addSubview:statisticsBgView];
    [self addSeparatorForLeft:statisticsBgView];
    [self addSeparatorForTop:statisticsBgView];
    [self addSeparatorForRight:statisticsBgView];
    [self addSeparatorForBottom:statisticsBgView];
    statisticsView = statisticsBgView;
    
    ThreeSubView *topTitleView = [[ThreeSubView alloc] initWithFrame:CGRectMake(subviewWidth, 0, subviewWidth * 3, subviewHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    
    [topTitleView.leftButton.titleLabel setFont:font_Normal_16];
    [topTitleView.leftButton setAllTitleColor:color_Black];
    [topTitleView.leftButton setAllTitle:str_FirstView_7];
    topTitleView.fixLeftWidth = subviewWidth;
    
    [topTitleView.centerButton.titleLabel setFont:font_Normal_16];
    [topTitleView.centerButton setAllTitleColor:color_Black];
    [topTitleView.centerButton setAllTitle:str_FirstView_8];
    topTitleView.fixCenterWidth = subviewWidth;
    
    [topTitleView.rightButton.titleLabel setFont:font_Normal_16];
    [topTitleView.rightButton setAllTitleColor:color_Black];
    [topTitleView.rightButton setAllTitle:str_FirstView_9];
    topTitleView.fixRightWidth = subviewWidth;
    
    [self addSeparatorForBottom:topTitleView];
    [topTitleView autoLayout];
    [statisticsView addSubview:topTitleView];
    
    
    ThreeSubView *topTitleView1 = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, subviewWidth, subviewHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    
    [topTitleView1.leftButton.titleLabel setFont:font_Normal_16];
    [topTitleView1.leftButton setAllTitleColor:color_Black];
    [topTitleView1.leftButton setAllTitle:str_FirstView_10];
    topTitleView1.fixLeftWidth = subviewWidth;
    
    [self addSeparatorForRight:topTitleView1];
    [self addSeparatorForBottom:topTitleView1];
    [topTitleView1 autoLayout];
    [statisticsView addSubview:topTitleView1];
    
    ThreeSubView *topTitleView2 = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, subviewHeight, subviewWidth, subviewHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    
    [topTitleView2.leftButton.titleLabel setFont:font_Normal_16];
    [topTitleView2.leftButton setAllTitleColor:color_Blue];
    [topTitleView2.leftButton setAllTitle:str_FirstView_11];
    topTitleView2.fixLeftWidth = subviewWidth;
    
    [self addSeparatorForRight:topTitleView2];
    [self addSeparatorForBottom:topTitleView2];
    [topTitleView2 autoLayout];
    [statisticsView addSubview:topTitleView2];
    
    ThreeSubView *topTitleView3 = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, subviewHeight * 2, subviewWidth, subviewHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    
    [topTitleView3.leftButton.titleLabel setFont:font_Normal_16];
    [topTitleView3.leftButton setAllTitleColor:color_Blue];
    [topTitleView3.leftButton setAllTitle:str_FirstView_12];
    topTitleView3.fixLeftWidth = subviewWidth;
    
    [self addSeparatorForRight:topTitleView3];
    [topTitleView3 autoLayout];
    [statisticsView addSubview:topTitleView3];
    
    {
        ThreeSubView *everydayStatisticsView = [[ThreeSubView alloc] initWithFrame:CGRectMake(subviewWidth, subviewHeight, subviewWidth * 3, subviewHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
        
        //plantype 1 每日计划
        float total = [[PlanCache getPlanTotalCountByPlantype:@"1"] floatValue];
        [everydayStatisticsView.leftButton.titleLabel setFont:font_Normal_16];
        [everydayStatisticsView.leftButton setAllTitleColor:color_Black];
        [everydayStatisticsView.leftButton setAllTitle:[NSString stringWithFormat:@"%.0f", total]];
        everydayStatisticsView.fixLeftWidth = subviewWidth;
        
        float done = [[PlanCache getPlanCompletedCountByPlantype:@"1"] floatValue];
        [everydayStatisticsView.centerButton.titleLabel setFont:font_Normal_16];
        [everydayStatisticsView.centerButton setAllTitleColor:color_Green_Emerald];
        [everydayStatisticsView.centerButton setAllTitle:[NSString stringWithFormat:@"%.0f", done]];
        everydayStatisticsView.fixCenterWidth = subviewWidth;
        
        float percent = 0;
        if (total > 0) {
            percent = (float)done*100 /(float)total;
        }
        [everydayStatisticsView.rightButton.titleLabel setFont:font_Normal_16];
        [everydayStatisticsView.rightButton setAllTitleColor:color_Red];
        [everydayStatisticsView.rightButton setAllTitle:[NSString stringWithFormat:@"%.2f%%", percent]];
        everydayStatisticsView.fixRightWidth = subviewWidth;
        
        [self addSeparatorForBottom:everydayStatisticsView];
        [everydayStatisticsView autoLayout];
        [statisticsView addSubview:everydayStatisticsView];
    }
    {
        ThreeSubView *longtermStatisticsView = [[ThreeSubView alloc] initWithFrame:CGRectMake(subviewWidth, subviewHeight * 2, subviewWidth * 3, subviewHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
        
        //plantype 0 长远计划
        float total = [[PlanCache getPlanTotalCountByPlantype:@"0"] floatValue];
        [longtermStatisticsView.leftButton.titleLabel setFont:font_Normal_16];
        [longtermStatisticsView.leftButton setAllTitleColor:color_Black];
        [longtermStatisticsView.leftButton setAllTitle:[NSString stringWithFormat:@"%.0f", total]];
        longtermStatisticsView.fixLeftWidth = subviewWidth;
        
        float done = [[PlanCache getPlanCompletedCountByPlantype:@"0"] floatValue];
        [longtermStatisticsView.centerButton.titleLabel setFont:font_Normal_16];
        [longtermStatisticsView.centerButton setAllTitleColor:color_Green_Emerald];
        [longtermStatisticsView.centerButton setAllTitle:[NSString stringWithFormat:@"%.0f", done]];
        longtermStatisticsView.fixCenterWidth = subviewWidth;
        
        float percent = 0;
        if (total > 0) {
            percent = done*100 /total;
        }
        [longtermStatisticsView.rightButton.titleLabel setFont:font_Normal_16];
        [longtermStatisticsView.rightButton setAllTitleColor:color_Red];
        [longtermStatisticsView.rightButton setAllTitle:[NSString stringWithFormat:@"%.2f%%", percent]];
        longtermStatisticsView.fixRightWidth = subviewWidth;
        
        [longtermStatisticsView autoLayout];
        [statisticsView addSubview:longtermStatisticsView];
    }
}


- (void)addSeparatorForTop:(UIView *)view{
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.bounds) - 1, 1)];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (void)addSeparatorForBottom:(UIView *)view{
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.bounds) - 1, CGRectGetWidth(view.bounds) - 1, 1)];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (void)addSeparatorForLeft:(UIView *)view{
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, CGRectGetHeight(view.bounds))];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (void)addSeparatorForRight:(UIView *)view{
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.bounds) - 1, 0, 1, CGRectGetHeight(view.bounds))];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (void)secondsCountdown
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger hour = [dateComponent hour];
    NSInteger minute = [dateComponent minute];
    NSInteger second = [dateComponent second];
    NSInteger secondsLeft = kSecondsPerDay - hour*3600 - minute*60 -second;
    
    [secondsLeftView.centerButton setAllTitle:[NSString stringWithFormat:@"%zd",secondsLeft]];
    [secondsLeftView autoLayout];
    CGRect frame = secondsLeftView.frame;
    frame.origin.x = self.view.frame.size.width / 2 - secondsLeftView.frame.size.width / 2;
    secondsLeftView.frame = frame;
    
    if (secondsLeft == kSecondsPerDay) {
        NSTimeInterval secondsBetweenDates= [deadDay timeIntervalSinceDate:now];
        if(secondsBetweenDates < 0){
            daysLeft = 0;
        } else {
            daysLeft = secondsBetweenDates/kSecondsPerDay;
        }
        
        [daysLeftView.centerButton setAllTitle:[NSString stringWithFormat:@"%zd",daysLeft]];
        [daysLeftView autoLayout];
        CGRect frame = daysLeftView.frame;
        frame.origin.x = self.view.frame.size.width / 2 - daysLeftView.frame.size.width / 2;
        daysLeftView.frame = frame;
        
    }
}

#pragma mark －进入更多
-(void)toMoreViewController
{
    MoreViewController *controller = [[MoreViewController alloc]init];
    controller.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
