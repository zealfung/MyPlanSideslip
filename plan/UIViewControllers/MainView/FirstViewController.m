//
//  FirstViewController.m
//  plan
//
//  Created by Fengzy on 15/8/28.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "PlanCache.h"
#import "DataCenter.h"
#import "ShareCenter.h"
#import "ThreeSubView.h"
#import "UIButton+Util.h"
#import "WZLBadgeImport.h"
#import "LogInViewController.h"
#import "FirstViewController.h"
#import "SideMenuViewController.h"
#import <RESideMenu/RESideMenu.h>
#import "SettingsPersonalViewController.h"

NSUInteger const kDaysPerMonth = 30;
NSUInteger const kSecondsPerDay = 86400;
NSUInteger const kMinutesPerDay = 1440;
NSUInteger const kHoursPerDay = 24;

@interface FirstViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) ThreeSubView *nickNameView;
@property (strong, nonatomic) ThreeSubView *liftetimeView;
@property (strong, nonatomic) ThreeSubView *daysLeftView;
@property (strong, nonatomic) ThreeSubView *secondsLeftView;
@property (strong, nonatomic) ThreeSubView *minuteLeftView;
@property (strong, nonatomic) ThreeSubView *hourLeftView;
@property (strong, nonatomic) UIView *statisticsView;
@property (strong, nonatomic) ThreeSubView *everydayView;
@property (strong, nonatomic) ThreeSubView *longtermView;
@property (strong, nonatomic) UIView *shareLogoView;

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger daysLeft;
@property (strong, nonatomic) NSDate *deadDay;

@property (assign, nonatomic) NSUInteger xMiddle;
@property (assign, nonatomic) NSUInteger yOffset;
@property (assign, nonatomic) NSUInteger ySpace;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = STRViewTitle1;
    self.tabBarItem.title = STRViewTitle1;

    __weak typeof(self) weakSelf = self;
    self.leftBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_LeftMenu selectedImageName:png_Btn_LeftMenu selector:@selector(leftMenuAction)];
    [self customRightButtonWithImage:[UIImage imageNamed:png_Btn_Share] action:^(UIButton *sender)
     {
         [weakSelf shareAction];
    }];
    
    [NotificationCenter addObserver:self selector:@selector(refreshView:) name:NTFSettingsSave object:nil];
    [NotificationCenter addObserver:self selector:@selector(refreshView:) name:NTFLogIn object:nil];
    [NotificationCenter addObserver:self selector:@selector(refreshView:) name:NTFLogOut object:nil];
    [NotificationCenter addObserver:self selector:@selector(refreshView:) name:NTFPlanSave object:nil];
    [NotificationCenter addObserver:self selector:@selector(refreshRedDot) name:NTFMessagesSave object:nil];
    
    [self loadCustomView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkUnread:self.tabBarController.tabBar index:0];
    [self refreshRedDot];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)leftMenuAction
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)shareAction
{
    self.shareLogoView.hidden = NO;
    
    UIImage* image = [UIImage imageNamed:png_ImageDefault];
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO , 0.0f);//高清，效率比较慢
    {
        [self.view.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    self.shareLogoView.hidden = YES;
    
    [ShareCenter showShareActionSheet:self.view image:image];
}

- (void)refreshView:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadCustomView];
    });
}

- (void)refreshRedDot
{
    //小红点
    if ([PlanCache hasUnreadMessages])
    {
        [self.leftBarButtonItem showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
        self.leftBarButtonItem.badgeCenterOffset = CGPointMake(-8, 0);
    }
    else
    {
        [self.leftBarButtonItem clearBadge];
    }
}

- (void)loadCustomView
{
    BmobUser *user = [BmobUser currentUser];
    
    if (user)
    {
        BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        __weak typeof(self) weakSelf = self;
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
        {
            if (error)
            {
                [Config shareInstance].settings = [PlanCache getPersonalSettings];
            }
            else
            {
                if (array.count)
                {
                    BmobObject *object = array[0];
                    [Config shareInstance].settings.objectId = object.objectId;
                    [Config shareInstance].settings.nickname = [object objectForKey:@"nickName"];
                    [Config shareInstance].settings.birthday = [object objectForKey:@"birthday"];
                    [Config shareInstance].settings.gender = [object objectForKey:@"gender"];
                    [Config shareInstance].settings.lifespan = [object objectForKey:@"lifespan"];
                    [Config shareInstance].settings.isAutoSync = [object objectForKey:@"isAutoSync"];
                    [Config shareInstance].settings.createtime = [object objectForKey:@"createdTime"];
                    [Config shareInstance].settings.updatetime = [object objectForKey:@"updatedTime"];
                    [Config shareInstance].settings.syntime = [object objectForKey:@"syncTime"];
                    [Config shareInstance].settings.countdownType = [object objectForKey:@"countdownType"];
                    [Config shareInstance].settings.dayOrMonth = [object objectForKey:@"dayOrMonth"];
                    [Config shareInstance].settings.autoDelayUndonePlan = [object objectForKey:@"autoDelayUndonePlan"];
                    [Config shareInstance].settings.signature = [object objectForKey:@"signature"];
                    [Config shareInstance].settings.avatarURL = [object objectForKey:@"avatarURL"];
                    [Config shareInstance].settings.centerTopURL = [object objectForKey:@"centerTopURL"];
                    
                    [PlanCache storePersonalSettings:[Config shareInstance].settings isNotify:NO];
                }
                else
                {
                    [Config shareInstance].settings = [PlanCache getPersonalSettings];
                }
            }
            
            [weakSelf createAvatar];
            [weakSelf createLabelText];
            [weakSelf refreshRedDot];
        }];
    }
    else
    {
        [Config shareInstance].settings = [PlanCache getPersonalSettings];
        [self createAvatar];
        [self createLabelText];
    }

    [self createShareLogo];
}

- (void)createAvatar
{
    if (self.scrollView)
    {
        [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    else
    {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, HEIGHT_FULL_VIEW)];
        self.scrollView.backgroundColor = [UIColor whiteColor];
        self.scrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:self.scrollView];
    }
    
    NSUInteger avatarSize = WIDTH_FULL_SCREEN / 3;
    self.xMiddle = WIDTH_FULL_SCREEN / 2;
    self.ySpace = HEIGHT_FULL_SCREEN / 25;
    self.yOffset = iPhone4 ? HEIGHT_FULL_SCREEN / 28 : HEIGHT_FULL_SCREEN / 15 - self.ySpace;
    
    UIImage *image = [UIImage imageNamed:png_AvatarDefault];
    if ([Config shareInstance].settings.avatar)
    {
        image = [UIImage imageWithData:[Config shareInstance].settings.avatar];
    }
    UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(self.xMiddle - avatarSize / 2, self.yOffset, avatarSize, avatarSize)];
    avatar.clipsToBounds = YES;
    avatar.layer.borderWidth = 1;
    avatar.userInteractionEnabled = YES;
    avatar.layer.cornerRadius = avatarSize / 2;
    avatar.backgroundColor = [UIColor clearColor];
    avatar.layer.borderColor = [color_dedede CGColor];
    avatar.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toSettingsViewController)];
    [avatar addGestureRecognizer:singleTap];
    
    [avatar sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:[Config shareInstance].settings.avatarURL] andPlaceholderImage:image options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
     }
     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if (image)
         {
             NSData *imgData = UIImageJPEGRepresentation(image, 1);
             [Config shareInstance].settings.avatar = imgData;
             [PlanCache storePersonalSettings:[Config shareInstance].settings isNotify:NO];
         }
     }];
    
    [self.scrollView addSubview:avatar];
    
    self.yOffset += avatarSize + self.ySpace;
}

- (void)createLabelText
{
    NSString *nickname = STRCommonTip12;
    NSInteger lifetime = 100;
    CGFloat labelHeight = HEIGHT_FULL_SCREEN / 62;
    CGFloat labelWidth = WIDTH_FULL_SCREEN / 3 > 125 ? WIDTH_FULL_SCREEN / 3 : 125;

    if (![CommonFunction isEmptyString:[Config shareInstance].settings.nickname])
    {
        nickname = [Config shareInstance].settings.nickname;
    }
    if (![CommonFunction isEmptyString:[Config shareInstance].settings.lifespan])
    {
        NSString *life = [Config shareInstance].settings.lifespan;
        lifetime = [life integerValue];
    }
    
    __weak typeof(self) weakSelf = self;
    ThreeSubView *nickNameSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(self.xMiddle, self.yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock: ^ {
        
        [weakSelf toSettingsViewController];
        
    } rightButtonSelectBlock:nil];
    
    [nickNameSubView.centerButton.titleLabel setFont:font_Bold_32];
    [nickNameSubView.centerButton setAllTitleColor:[CommonFunction getGenderColor]];
    [nickNameSubView.centerButton setAllTitle:nickname];
    [nickNameSubView autoLayout];
    
    [self.scrollView addSubview:nickNameSubView];
    
    self.nickNameView = nickNameSubView;
    
    CGRect nickFrame = CGRectZero;
    nickFrame.size.width = self.nickNameView.frame.size.width;
    nickFrame.size.height = self.nickNameView.frame.size.height;
    nickFrame.origin.x = self.xMiddle - self.nickNameView.frame.size.width/2;
    nickFrame.origin.y = self.yOffset;
    
    self.nickNameView.frame = nickFrame;
    self.yOffset += self.nickNameView.frame.size.height + (iPhone4 ? self.ySpace : self.ySpace * 2);
    
    ThreeSubView *liftetimeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(self.xMiddle, self.yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    
    [liftetimeSubView.leftButton.titleLabel setFont:font_Normal_16];
    [liftetimeSubView.leftButton setAllTitleColor:color_Black];
    [liftetimeSubView.leftButton setAllTitle:STRViewTips1];
    [liftetimeSubView.centerButton.titleLabel setFont:font_Normal_24];
    [liftetimeSubView.centerButton setAllTitleColor:color_Red];
    [liftetimeSubView.centerButton setAllTitle:[NSString stringWithFormat:@"%zd",lifetime]];
    [liftetimeSubView.rightButton.titleLabel setFont:font_Normal_16];
    [liftetimeSubView.rightButton setAllTitleColor:color_Black];
    [liftetimeSubView.rightButton setAllTitle:STRViewTips2];
    [liftetimeSubView autoLayout];
    [self.scrollView addSubview:liftetimeSubView];
    
    self.liftetimeView = liftetimeSubView;
    
    CGRect lifeFrame = CGRectZero;
    lifeFrame.size.width = self.liftetimeView.frame.size.width;
    lifeFrame.size.height = self.liftetimeView.frame.size.height;
    lifeFrame.origin.x = self.xMiddle - self.liftetimeView.frame.size.width/2;
    lifeFrame.origin.y = self.yOffset;
    
    self.liftetimeView.frame = lifeFrame;
    self.yOffset += self.liftetimeView.frame.size.height + self.ySpace;
    
    NSString *birthdayFormat = @"1987-03-05 00:00:00";
    if (![CommonFunction isEmptyString:[Config shareInstance].settings.birthday])
    {
        birthdayFormat = [NSString stringWithFormat:@"%@ 00:00:00", [Config shareInstance].settings.birthday];
    }
    
    NSDate *birthday = [CommonFunction NSStringDateToNSDate:birthdayFormat formatter:STRDateFormatterType1];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned units  = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comp = [calendar components:units fromDate:birthday];
    NSInteger year = [comp year];
    year += lifetime;
    [comp setYear:year];

    self.deadDay = [calendar dateFromComponents:comp];
    
    NSDate *now = [NSDate date];
    NSTimeInterval secondsBetweenDates= [self.deadDay timeIntervalSinceDate:now];
    if(secondsBetweenDates < 0)
    {
        self.daysLeft = 0;
    }
    else
    {
        self.daysLeft = secondsBetweenDates/kSecondsPerDay;
    }
    if ([[Config shareInstance].settings.dayOrMonth isEqualToString:@"1"])
    {
        self.daysLeft = self.daysLeft / kDaysPerMonth;
    }
    //剩余天数
    ThreeSubView *daysLeftSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(self.xMiddle, self.yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    [daysLeftSubView.leftButton.titleLabel setFont:font_Normal_16];
    [daysLeftSubView.leftButton setAllTitleColor:color_Black];
    [daysLeftSubView.leftButton setAllTitle:STRViewTips3];
    [daysLeftSubView.centerButton.titleLabel setFont:font_Normal_24];
    [daysLeftSubView.centerButton setAllTitleColor:color_Red];
    if (![CommonFunction isEmptyString:[Config shareInstance].settings.birthday])
    {
        [daysLeftSubView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:self.daysLeft]];
    }
    else
    {
        [daysLeftSubView.centerButton setAllTitle:@"X"];
    }
    [daysLeftSubView.rightButton.titleLabel setFont:font_Normal_16];
    [daysLeftSubView.rightButton setAllTitleColor:color_Black];
    if ([[Config shareInstance].settings.dayOrMonth isEqualToString:@"1"])
    {
        [daysLeftSubView.rightButton setAllTitle:STRCommonTime15];
    }
    else
    {
        [daysLeftSubView.rightButton setAllTitle:STRCommonTime14];
    }
    [daysLeftSubView autoLayout];
    [self.scrollView addSubview:daysLeftSubView];
    
    self.daysLeftView = daysLeftSubView;
    
    CGRect daysFrame = CGRectZero;
    daysFrame.size.width = self.daysLeftView.frame.size.width;
    daysFrame.size.height = self.daysLeftView.frame.size.height;
    daysFrame.origin.x = self.xMiddle - self.daysLeftView.frame.size.width/2;
    daysFrame.origin.y = self.yOffset;
    
    self.daysLeftView.frame = daysFrame;
    self.yOffset += self.daysLeftView.frame.size.height + self.ySpace;
    //剩余秒
    if ([self showSeconds])
    {
        ThreeSubView *secondsLeftSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(self.xMiddle, self.yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
        [secondsLeftSubView.leftButton.titleLabel setFont:font_Normal_16];
        [secondsLeftSubView.leftButton setAllTitleColor:color_Black];
        [secondsLeftSubView.leftButton setAllTitle:STRViewTips4];
        [secondsLeftSubView.centerButton.titleLabel setFont:font_Normal_24];
        [secondsLeftSubView.centerButton setAllTitleColor:color_Red];
        [secondsLeftSubView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:kSecondsPerDay]];
        [secondsLeftSubView.rightButton.titleLabel setFont:font_Normal_16];
        [secondsLeftSubView.rightButton setAllTitleColor:color_Black];
        [secondsLeftSubView.rightButton setAllTitle:STRCommonTime11];
        [secondsLeftSubView autoLayout];
        [self.scrollView addSubview:secondsLeftSubView];
        
        self.secondsLeftView = secondsLeftSubView;
        
        CGRect secondsFrame = CGRectZero;
        secondsFrame.size.width = self.secondsLeftView.frame.size.width;
        secondsFrame.size.height = self.secondsLeftView.frame.size.height;
        secondsFrame.origin.x = self.xMiddle - self.secondsLeftView.frame.size.width/2;
        secondsFrame.origin.y = self.yOffset;
        
        self.secondsLeftView.frame = secondsFrame;
        self.yOffset += self.secondsLeftView.frame.size.height + self.ySpace;
    }
    //剩余分
    if ([self showMinutes])
    {
        ThreeSubView *minuteLeftSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(self.xMiddle, self.yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
        [minuteLeftSubView.leftButton.titleLabel setFont:font_Normal_16];
        [minuteLeftSubView.leftButton setAllTitleColor:color_Black];
        [minuteLeftSubView.leftButton setAllTitle:STRViewTips4];
        [minuteLeftSubView.centerButton.titleLabel setFont:font_Normal_24];
        [minuteLeftSubView.centerButton setAllTitleColor:color_Red];
        [minuteLeftSubView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:kMinutesPerDay]];
        [minuteLeftSubView.rightButton.titleLabel setFont:font_Normal_16];
        [minuteLeftSubView.rightButton setAllTitleColor:color_Black];
        [minuteLeftSubView.rightButton setAllTitle:STRCommonTime12];
        [minuteLeftSubView autoLayout];
        [self.scrollView addSubview:minuteLeftSubView];
        
        self.minuteLeftView = minuteLeftSubView;
        
        CGRect minuteFrame = CGRectZero;
        minuteFrame.size.width = self.minuteLeftView.frame.size.width;
        minuteFrame.size.height = self.minuteLeftView.frame.size.height;
        minuteFrame.origin.x = self.xMiddle - self.minuteLeftView.frame.size.width/2;
        minuteFrame.origin.y = self.yOffset;
        
        self.minuteLeftView.frame = minuteFrame;
        self.yOffset += self.minuteLeftView.frame.size.height + self.ySpace;
    }
    //剩余时
    if ([self showHours])
    {
        ThreeSubView *hourLeftSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(self.xMiddle, self.yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
        [hourLeftSubView.leftButton.titleLabel setFont:font_Normal_16];
        [hourLeftSubView.leftButton setAllTitleColor:color_Black];
        [hourLeftSubView.leftButton setAllTitle:STRViewTips4];
        [hourLeftSubView.centerButton.titleLabel setFont:font_Normal_24];
        [hourLeftSubView.centerButton setAllTitleColor:color_Red];
        [hourLeftSubView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:kHoursPerDay]];
        [hourLeftSubView.rightButton.titleLabel setFont:font_Normal_16];
        [hourLeftSubView.rightButton setAllTitleColor:color_Black];
        [hourLeftSubView.rightButton setAllTitle:STRCommonTime13];
        [hourLeftSubView autoLayout];
        [self.scrollView addSubview:hourLeftSubView];
        
        self.hourLeftView = hourLeftSubView;
        
        CGRect hourFrame = CGRectZero;
        hourFrame.size.width = self.hourLeftView.frame.size.width;
        hourFrame.size.height = self.hourLeftView.frame.size.height;
        hourFrame.origin.x = self.xMiddle - self.hourLeftView.frame.size.width/2;
        hourFrame.origin.y = self.yOffset;
        
        self.hourLeftView.frame = hourFrame;
        self.yOffset += self.hourLeftView.frame.size.height + self.ySpace;
    }
    //倒计时
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(secondsCountdown) userInfo:nil repeats:YES];
}

- (void)createStatisticsView
{
    BOOL isiPhone4oriPhone5 = iPhone4 || iPhone5;
    
    CGFloat xOffset = isiPhone4oriPhone5 ? WIDTH_FULL_SCREEN / 15 : WIDTH_FULL_SCREEN / 7;
    CGFloat viewWidth = WIDTH_FULL_SCREEN - xOffset * 2;
    CGFloat subviewWidth = viewWidth / 3;
    CGFloat viewHeight = HEIGHT_FULL_SCREEN * 0.1875;
    CGFloat subviewHeight = viewHeight / 3;

    UIView *statisticsBgView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, self.yOffset, viewWidth, subviewHeight * 4)];
    [self.scrollView addSubview:statisticsBgView];
    [self addSeparatorForLeft:statisticsBgView];
    [self addSeparatorForMiddleLeft:statisticsBgView];
    [self addSeparatorForMiddleRight:statisticsBgView];
    [self addSeparatorForTop:statisticsBgView];
    [self addSeparatorForRight:statisticsBgView];
    self.statisticsView = statisticsBgView;
    
    ThreeSubView *topTitleView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, subviewWidth * 3, subviewHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    [topTitleView.leftButton.titleLabel setFont:font_Normal_16];
    [topTitleView.leftButton setAllTitleColor:color_Black];
    [topTitleView.leftButton setAllTitle:STRViewTips5];
    topTitleView.fixLeftWidth = subviewWidth;
    [topTitleView.centerButton.titleLabel setFont:font_Normal_16];
    [topTitleView.centerButton setAllTitleColor:color_Black];
    [topTitleView.centerButton setAllTitle:STRViewTips7];
    topTitleView.fixCenterWidth = subviewWidth;
    [topTitleView.rightButton.titleLabel setFont:font_Normal_16];
    [topTitleView.rightButton setAllTitleColor:color_Black];
    [topTitleView.rightButton setAllTitle:STRViewTips8];
    topTitleView.fixRightWidth = subviewWidth;
    [self addSeparatorForBottom:topTitleView];
    [topTitleView autoLayout];
    [self.statisticsView addSubview:topTitleView];

    {
        ThreeSubView *everydayStatisticsView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, subviewHeight, subviewWidth * 3, subviewHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];

        float total = [[PlanCache getPlanTotalCount:@"ALL"] floatValue];
        [everydayStatisticsView.leftButton.titleLabel setFont:font_Normal_16];
        [everydayStatisticsView.leftButton setAllTitleColor:color_Black];
        [everydayStatisticsView.leftButton setAllTitle:[NSString stringWithFormat:@"%.0f", total]];
        everydayStatisticsView.fixLeftWidth = subviewWidth;
        
        float done = [[PlanCache getPlanCompletedCount] floatValue];
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
        [self.statisticsView addSubview:everydayStatisticsView];
    }
    
    ThreeSubView *titleView2 = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, subviewHeight * 2, subviewWidth * 3, subviewHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    [titleView2.leftButton.titleLabel setFont:font_Normal_16];
    [titleView2.leftButton setAllTitleColor:color_Black];
    [titleView2.leftButton setAllTitle:STRViewTips6];
    titleView2.fixLeftWidth = subviewWidth;
    [titleView2.centerButton.titleLabel setFont:font_Normal_16];
    [titleView2.centerButton setAllTitleColor:color_Black];
    [titleView2.centerButton setAllTitle:STRViewTips7];
    titleView2.fixCenterWidth = subviewWidth;
    [titleView2.rightButton.titleLabel setFont:font_Normal_16];
    [titleView2.rightButton setAllTitleColor:color_Black];
    [titleView2.rightButton setAllTitle:STRViewTips8];
    titleView2.fixRightWidth = subviewWidth;
    [self addSeparatorForBottom:titleView2];
    [titleView2 autoLayout];
    [self.statisticsView addSubview:titleView2];
    
    {
        ThreeSubView *todayStatisticsView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, subviewHeight * 3, subviewWidth * 3, subviewHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
        
        NSArray *array = [NSArray arrayWithArray:[PlanCache getPlan:YES startIndex:0]];
        NSMutableArray *todayArray = [NSMutableArray array];
        
        NSString *todayKey = [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
        NSString *key = @"";
        for (NSInteger i = 0; i < array.count; i++)
        {
            Plan *plan = array[i];
            
            if ([[Config shareInstance].settings.autoDelayUndonePlan isEqualToString:@"1"]
                && [plan.iscompleted isEqualToString:@"0"])
            {
                key = todayKey;
                plan.beginDate = todayKey;
            }
            else
            {
                key = plan.beginDate;
            }
            
            if ([key isEqualToString:todayKey])
            {
                [todayArray addObject:plan];
            }
        }
        
        float total = todayArray.count;
        [todayStatisticsView.leftButton.titleLabel setFont:font_Normal_16];
        [todayStatisticsView.leftButton setAllTitleColor:color_Black];
        [todayStatisticsView.leftButton setAllTitle:[NSString stringWithFormat:@"%.0f", total]];
        todayStatisticsView.fixLeftWidth = subviewWidth;
        
        float done = 0;
        for (Plan *plan in todayArray)
        {
            if ([plan.iscompleted isEqualToString:@"1"])
            {
                done ++;
            }
        }
        [todayStatisticsView.centerButton.titleLabel setFont:font_Normal_16];
        [todayStatisticsView.centerButton setAllTitleColor:color_Green_Emerald];
        [todayStatisticsView.centerButton setAllTitle:[NSString stringWithFormat:@"%.0f", done]];
        todayStatisticsView.fixCenterWidth = subviewWidth;
        
        float percent = 0;
        if (total)
        {
            percent = (float)done*100 /(float)total;
        }
        [todayStatisticsView.rightButton.titleLabel setFont:font_Normal_16];
        [todayStatisticsView.rightButton setAllTitleColor:color_Red];
        [todayStatisticsView.rightButton setAllTitle:[NSString stringWithFormat:@"%.2f%%", percent]];
        todayStatisticsView.fixRightWidth = subviewWidth;
        
        [self addSeparatorForBottom:todayStatisticsView];
        [todayStatisticsView autoLayout];
        [self.statisticsView addSubview:todayStatisticsView];
    }

    self.yOffset += subviewHeight * 5 + 20;
    
    self.scrollView.contentSize = CGSizeMake(WIDTH_FULL_SCREEN, self.yOffset);
}

- (void)createShareLogo
{
    CGFloat viewWidth = 110;
    CGFloat viewHeight = 20;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(WIDTH_FULL_SCREEN - viewWidth - 5, self.yOffset, viewWidth, viewHeight)];
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewHeight, viewHeight)];
    logo.image = [UIImage imageNamed:png_Icon_Logo_512];
    [view addSubview:logo];
    UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(viewHeight + 2, 0, viewWidth - viewHeight - 2, viewHeight)];
    labelName.text = STRViewTips110;
    labelName.font = font_Normal_10;
    labelName.textColor = [CommonFunction getGenderColor];
    [view addSubview:labelName];
    view.hidden = YES;
    self.shareLogoView = view;
    [self.scrollView addSubview:view];
}

- (void)addSeparatorForTop:(UIView *)view
{
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.bounds) - 1, 1)];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (void)addSeparatorForBottom:(UIView *)view
{
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.bounds) - 1, CGRectGetWidth(view.bounds) - 1, 1)];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (void)addSeparatorForLeft:(UIView *)view
{
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, CGRectGetHeight(view.bounds))];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (void)addSeparatorForMiddleLeft:(UIView *)view
{
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.bounds) / 3, 0, 1, CGRectGetHeight(view.bounds))];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (void)addSeparatorForMiddleRight:(UIView *)view
{
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.bounds) * 2 / 3 + 1, 0, 1, CGRectGetHeight(view.bounds))];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (void)addSeparatorForRight:(UIView *)view
{
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
    
    //刷新秒
    NSInteger secondsLeft = kSecondsPerDay - hour*3600 - minute*60 - second;
    if ([self showSeconds])
    {
        [self.secondsLeftView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:secondsLeft]];
        [self.secondsLeftView autoLayout];
        CGRect frame = self.secondsLeftView.frame;
        frame.origin.x = WIDTH_FULL_SCREEN / 2 - self.secondsLeftView.frame.size.width / 2;
        self.secondsLeftView.frame = frame;
    }
    //刷新分
    if ([self showMinutes])
    {
        NSInteger minutesLeft = kMinutesPerDay - hour*60 - minute;
        [self.minuteLeftView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:minutesLeft]];
        [self.minuteLeftView autoLayout];
        CGRect frame = self.minuteLeftView.frame;
        frame.origin.x = WIDTH_FULL_SCREEN / 2 - self.minuteLeftView.frame.size.width / 2;
        self.minuteLeftView.frame = frame;
    }
    //刷新时
    if ([self showHours])
    {
        NSInteger hoursLeft = kHoursPerDay - hour;
        [self.hourLeftView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:hoursLeft]];
        [self.hourLeftView autoLayout];
        CGRect frame = self.hourLeftView.frame;
        frame.origin.x = WIDTH_FULL_SCREEN / 2 - self.hourLeftView.frame.size.width / 2;
        self.hourLeftView.frame = frame;
    }
    
    if (secondsLeft == kSecondsPerDay)
    {
        NSTimeInterval secondsBetweenDates= [self.deadDay timeIntervalSinceDate:now];
        if(secondsBetweenDates < 0)
        {
            self.daysLeft = 0;
        }
        else
        {
            self.daysLeft = secondsBetweenDates / kSecondsPerDay;
        }
        if ([[Config shareInstance].settings.dayOrMonth isEqualToString:@"1"])
        {
            self.daysLeft = self.daysLeft / kDaysPerMonth;
        }
        [self.daysLeftView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:self.daysLeft]];
        [self.daysLeftView autoLayout];
        CGRect frame = self.daysLeftView.frame;
        frame.origin.x = WIDTH_FULL_SCREEN / 2 - self.daysLeftView.frame.size.width / 2;
        self.daysLeftView.frame = frame;
    }
}

- (void)toSettingsViewController
{
    if ([LogIn isLogin])
    {
        SettingsPersonalViewController *controller = [[SettingsPersonalViewController alloc]init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else
    {
        LogInViewController *controller = [[LogInViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (BOOL)showSeconds
{
    if (![Config shareInstance].settings.countdownType
        || [[Config shareInstance].settings.countdownType isEqualToString:@"0"]
        || [[Config shareInstance].settings.countdownType isEqualToString:@"3"])
    {
        return YES;
    }
    return NO;
}

- (BOOL)showMinutes
{
    if ([[Config shareInstance].settings.countdownType isEqualToString:@"1"]
        || [[Config shareInstance].settings.countdownType isEqualToString:@"3"])
    {
        return YES;
    }
    return NO;
}

- (BOOL)showHours
{
    if ([[Config shareInstance].settings.countdownType isEqualToString:@"2"]
        || [[Config shareInstance].settings.countdownType isEqualToString:@"3"])
    {
        return YES;
    }
    return NO;
}

@end
