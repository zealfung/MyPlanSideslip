//
//  SettingsViewController.m
//  plan
//
//  Created by Fengzy on 15/9/1.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "WeiboSDK.h"
#import "PlanCache.h"
#import "ThreeSubView.h"
#import <BmobSDK/BmobUser.h>
#import <ShareSDK/ShareSDK.h>
#import "SettingsViewController.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "SettingsSetTextViewController.h"

NSUInteger const kSettingsViewAlertTagForSetNickName = 932;
NSUInteger const kSettingsViewAlertTagForSetLife = 933;
NSUInteger const kSettingsViewPickerBgViewTag = 20141228;
NSUInteger const kSettingsViewEdgeInset = 10;
NSUInteger const kSettingsViewCellHeight = 44;
NSUInteger const kSettingsViewPickerHeight = 216;
NSUInteger const kSettingsViewToolBarHeight = 44;
NSUInteger const kSettingsViewRightEdgeInset = 8;
NSString * const kSettingsViewEdgeWhiteSpace = @"  ";


@interface SettingsViewController() <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TencentSessionDelegate>

@property (nonatomic, strong) UIView *layerView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) ThreeSubView *nickThreeSubView;
@property (nonatomic, strong) ThreeSubView *sexThreeSubView;
@property (nonatomic, strong) ThreeSubView *birthThreeSubView;
@property (nonatomic, strong) ThreeSubView *lifeThreeSubView;
@property (nonatomic, strong) ThreeSubView *emailThreeSubView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, retain) TencentOAuth *tencentOAuth;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = str_More_Settings;
    
    [NotificationCenter addObserver:self selector:@selector(loadCustomView) name:Notify_LogIn object:nil];
    [NotificationCenter addObserver:self selector:@selector(loadCustomView) name:Notify_Settings_Save object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (!self.layerView) {
        
        [self loadCustomView];
    }
}

- (void)dealloc {
    
    [NotificationCenter removeObserver:self];
    
}

- (void)loadCustomView {
    
    self.layerView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.layerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.layerView];
    
    CGFloat yOffset = kSettingsViewEdgeInset;
    
    {
        UIView *view = [self createSectionTwoView];
        [self.layerView addSubview:view];
        
        CGRect frame = view.frame;
        frame.origin.y = yOffset;
        view.frame = frame;
        
        yOffset = CGRectGetMaxY(view.frame) + kSettingsViewCellHeight;
    }
    
    if([LogIn isLogin]) {
        UIButton *button = [self createExitButton];
        [self.layerView addSubview:button];
        
        CGRect frame = CGRectZero;
        frame.origin.x = kSettingsViewEdgeInset;
        frame.origin.y = yOffset;
        frame.size.width = CGRectGetWidth(self.layerView.frame) - kSettingsViewEdgeInset * 2;
        frame.size.height = kSettingsViewCellHeight;
        button.frame = frame;
        
    } else {
        
        [self createLogInButton:yOffset];
    }
    
    [self hideHUD];
}

- (UIView *)createSectionTwoView {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kSettingsViewEdgeInset, 0, [self contentWidth], 0)];
    view.backgroundColor = [UIColor whiteColor];
    
    NSUInteger yOffset = 0;
    
    {
        ThreeSubView *threeSubView = [self createAvatarView];
        [self addSeparatorForView:threeSubView];
        [view addSubview:threeSubView];
        
        CGRect frame = threeSubView.frame;
        frame.origin.y = yOffset;
        threeSubView.frame = frame;
        
        yOffset = CGRectGetMaxY(frame);
    }
    
    {
        ThreeSubView *threeSubView = [self createNickNameView];
        [self addSeparatorForView:threeSubView];
        [view addSubview:threeSubView];
        
        CGRect frame = threeSubView.frame;
        frame.origin.y = yOffset;
        threeSubView.frame = frame;
        
        yOffset = CGRectGetMaxY(frame);
    }
    
    {
        ThreeSubView *threeSubView = [self createGenderView];
        [self addSeparatorForView:threeSubView];
        [view addSubview:threeSubView];
        
        CGRect frame = threeSubView.frame;
        frame.origin.y = yOffset;
        threeSubView.frame = frame;
        
        yOffset = CGRectGetMaxY(frame);
    }
    
    {
        ThreeSubView *threeSubView = [self createBirthdayView];
        [self addSeparatorForView:threeSubView];
        [view addSubview:threeSubView];
        
        CGRect frame = threeSubView.frame;
        frame.origin.y = yOffset;
        threeSubView.frame = frame;
        
        yOffset = CGRectGetMaxY(frame);
    }
    
    {
        ThreeSubView *threeSubView = [self createLifespanView];
        [view addSubview:threeSubView];
        
        CGRect frame = threeSubView.frame;
        frame.origin.y = yOffset;
        threeSubView.frame = frame;
        
        yOffset = CGRectGetMaxY(frame);
    }
    
    CGRect frame = view.frame;
    frame.size.height = yOffset;
    view.frame = frame;
    
    [self configBorderForView:view];
    
    return view;
    
}

- (ThreeSubView *)createAvatarView {
    
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: ^{
        [weakSelf setAvatar];
    } rightBlock:nil];
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:str_Settings_Avatar]];
    threeSubView.fixCenterWidth = [self contentWidth] - threeSubView.fixLeftWidth;
    [threeSubView autoLayout];
    
    NSUInteger yDistance = 2;
    UIImage *bgImage = [UIImage imageNamed:png_AvatarBg];
    CGFloat bgSize = kSettingsViewCellHeight - yDistance;
    UIImageView *avatarBg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(threeSubView.centerButton.bounds) - kSettingsViewEdgeInset - bgSize, yDistance, bgSize, bgSize)];
    avatarBg.backgroundColor = [UIColor clearColor];
    avatarBg.image = bgImage;
    avatarBg.layer.cornerRadius = bgSize / 2;
    avatarBg.clipsToBounds = YES;
    avatarBg.userInteractionEnabled = YES;
    avatarBg.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImage *avatarImage = [UIImage imageNamed:png_AvatarDefault];
    if ([Config shareInstance].settings.avatar) {
        
        avatarImage = [Config shareInstance].settings.avatar;
    }
    CGFloat avatarSize = bgSize - yDistance;
    UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(ceilf((bgSize - avatarSize)/2), ceilf((bgSize - avatarSize)/2), avatarSize, avatarSize)];
    avatar.backgroundColor = [UIColor clearColor];
    avatar.image = avatarImage;
    avatar.layer.cornerRadius = avatarSize / 2;
    avatar.clipsToBounds = YES;
    avatar.contentMode = UIViewContentModeScaleAspectFit;
    avatar.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setAvatar)];
    [avatar addGestureRecognizer:singleTap];
    
    [avatarBg addSubview:avatar];
    [threeSubView.centerButton addSubview:avatarBg];
    
    self.avatarView = avatar;

    return threeSubView;
    
}

- (ThreeSubView *)createNickNameView {
    
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: ^{
        [weakSelf toSetNickNameViewController];
    } rightBlock:nil];
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:str_Settings_Nickname]];
    threeSubView.fixRightWidth = kSettingsViewRightEdgeInset;
    threeSubView.fixCenterWidth = [self contentWidth] - threeSubView.fixLeftWidth - threeSubView.fixRightWidth;
    
    NSString *userNickName = [Config shareInstance].settings.nickname;
    if (userNickName.length == 0) {
        userNickName = str_Settings_Nickname_Tips;
    }
    [threeSubView.centerButton setAllTitle:userNickName];
    [threeSubView autoLayout];
    
    self.nickThreeSubView = threeSubView;
    
    return threeSubView;
    
}

- (ThreeSubView *)createGenderView {
    
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: ^{
        [weakSelf setMale];
    } rightBlock: ^{
        [weakSelf setFemale];
    }];
    
    threeSubView.fixCenterWidth = 55;
    [threeSubView.centerButton setImage:[UIImage imageNamed:png_Icon_Gender_M_Normal] forState:UIControlStateNormal];
    [threeSubView.centerButton setImage:[UIImage imageNamed:png_Icon_Gender_M_Selected] forState:UIControlStateSelected];
    [threeSubView.centerButton setAllTitle:str_Settings_Gender_M];
    
    threeSubView.fixRightWidth = 55;
    [threeSubView.rightButton setImage:[UIImage imageNamed:png_Icon_Gender_F_Normal] forState:UIControlStateNormal];
    [threeSubView.rightButton setImage:[UIImage imageNamed:png_Icon_Gender_F_Selected] forState:UIControlStateSelected];
    [threeSubView.rightButton setAllTitle:str_Settings_Gender_F];
    
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:str_Settings_Gender]];
    threeSubView.fixLeftWidth = [self contentWidth] - threeSubView.fixRightWidth - threeSubView.fixCenterWidth;
    
    threeSubView.centerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    threeSubView.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    NSString *gender = [Config shareInstance].settings.gender;
    if (gender) {
        if ([gender intValue] == 0) {
            
            threeSubView.rightButton.selected = YES;
            
        } else if ([gender intValue] == 1) {
            
            threeSubView.centerButton.selected = YES;
        }
    }
    [threeSubView autoLayout];
    
    self.sexThreeSubView = threeSubView;
    
    return threeSubView;
    
}

- (ThreeSubView *)createBirthdayView {
    
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: ^{
        [weakSelf setBirthday];
    } rightBlock:nil];
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:str_Settings_Birthday]];
    threeSubView.fixRightWidth = kSettingsViewRightEdgeInset;
    threeSubView.fixCenterWidth = [self contentWidth] - threeSubView.fixLeftWidth - threeSubView.fixRightWidth;
    
    NSString *birthday = [Config shareInstance].settings.birthday;
    if (birthday.length == 0) {
        birthday = str_Settings_Birthday_Tips;
    }
    [threeSubView.centerButton setAllTitle:birthday];
    [threeSubView autoLayout];
    
    self.birthThreeSubView = threeSubView;
    
    return threeSubView;
    
}

- (ThreeSubView *)createLifespanView {
    
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: ^{
        [weakSelf toSetLifeViewController];
    } rightBlock:nil];
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:str_Settings_Lifespan]];
    threeSubView.fixRightWidth = kSettingsViewRightEdgeInset;
    threeSubView.fixCenterWidth = [self contentWidth] - threeSubView.fixLeftWidth - threeSubView.fixRightWidth;
    
    NSString *lifetime = [Config shareInstance].settings.lifespan;
    if (lifetime.length == 0) {
        lifetime = str_Settings_Lifespan_Tips;
    }
    [threeSubView.centerButton setAllTitle:lifetime];
    [threeSubView autoLayout];
    
    self.lifeThreeSubView = threeSubView;
    
    return threeSubView;
    
}

- (UIButton *)createExitButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor redColor];
    button.titleLabel.font = font_Bold_18;
    button.layer.cornerRadius = 5;
    button.clipsToBounds = YES;
    [button setAllTitle:str_Settings_LogOut];
    [button addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)createLogInButton:(CGFloat)yOffset {
    
    yOffset = [self showLineView:yOffset];
    
    CGFloat buttonSize = WIDTH_FULL_SCREEN / 7;
    
//    UIButton *btnSinaWeibo = [[UIButton alloc] initWithFrame:CGRectMake(buttonSize, yOffset, buttonSize, buttonSize)];

    UIButton *btnSinaWeibo = [[UIButton alloc] initWithFrame:CGRectMake(buttonSize * 2, yOffset, buttonSize, buttonSize)];
    [btnSinaWeibo setBackgroundImage:[UIImage imageNamed:png_Btn_LogIn_SinaWeibo] forState:UIControlStateNormal];
    btnSinaWeibo.layer.cornerRadius = buttonSize / 2;
    btnSinaWeibo.clipsToBounds = YES;
    [btnSinaWeibo addTarget:self action:@selector(sinaWeiboLogin) forControlEvents:UIControlEventTouchUpInside];
    
//    UIButton *btnQQ = [[UIButton alloc] initWithFrame:CGRectMake(buttonSize * 3, yOffset, buttonSize, buttonSize)];
    
    UIButton *btnQQ = [[UIButton alloc] initWithFrame:CGRectMake(buttonSize * 4, yOffset, buttonSize, buttonSize)];
//    UIButton *btnQQ = [[UIButton alloc] initWithFrame:CGRectMake(buttonSize * 3, yOffset, buttonSize, buttonSize)];
    [btnQQ setBackgroundImage:[UIImage imageNamed:png_Btn_LogIn_QQ] forState:UIControlStateNormal];
    btnQQ.layer.cornerRadius = buttonSize / 2;
    btnQQ.clipsToBounds = YES;
    [btnQQ addTarget:self action:@selector(qqLogIn) forControlEvents:UIControlEventTouchUpInside];
    
    //由于微信的第三方登录功能需要先花钱认证开发者资格才能申请开通，所以暂时不做了
//    UIButton *btnWechat = [[UIButton alloc] initWithFrame:CGRectMake(buttonSize * 5, yOffset, buttonSize, buttonSize)];
//    [btnWechat setBackgroundImage:[UIImage imageNamed:png_Btn_LogIn_Wechat] forState:UIControlStateNormal];
//    btnWechat.layer.cornerRadius = buttonSize / 2;
//    btnWechat.clipsToBounds = YES;
//    [btnWechat addTarget:self action:@selector(wechatLogIn) forControlEvents:UIControlEventTouchUpInside];
    
    [self.layerView addSubview:btnSinaWeibo];
    [self.layerView addSubview:btnQQ];
//    [self.layerView addSubview:btnWechat];

}

- (CGFloat)showLineView:(CGFloat)yOffset {
    
    CGFloat xEdgeInset = kSettingsViewEdgeInset * 2;
    CGFloat labelWidth = 80;
    CGFloat labelHeight = 25;
    CGFloat lineWidth = (WIDTH_FULL_SCREEN - labelWidth - xEdgeInset * 4) / 2;
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(xEdgeInset * 2 + lineWidth, yOffset, labelWidth, labelHeight)];
    tipsLabel.font = font_Normal_16;
    tipsLabel.text = str_Settings_LogIn;
    tipsLabel.textColor = color_GrayDark;
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(xEdgeInset, yOffset + labelHeight / 2, lineWidth, 1)];
    leftLine.backgroundColor = color_GrayLight;
    
    UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(xEdgeInset * 3 + lineWidth + labelWidth, yOffset + labelHeight / 2, lineWidth, 1)];
    rightLine.backgroundColor = color_GrayLight;
    
    [self.layerView addSubview:leftLine];
    [self.layerView addSubview:tipsLabel];
    [self.layerView addSubview:rightLine];
    
    return yOffset + labelHeight * 2;
}

- (ThreeSubView *)getThreeSubViewForCenterBlock:(ButtonSelectBlock)centerBlock rightBlock:(ButtonSelectBlock)rightBlock {
    
    CGRect frame = CGRectZero;
    frame.size = [self cellSize];
    
    ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:frame leftButtonSelectBlock:nil centerButtonSelectBlock:centerBlock rightButtonSelectBlock:rightBlock];
    
    threeSubView.backgroundColor = [UIColor clearColor];
    
    threeSubView.fixLeftWidth = 100;
    threeSubView.leftButton.titleLabel.font = font_Normal_14;
    threeSubView.centerButton.titleLabel.font = font_Normal_16;
    threeSubView.rightButton.titleLabel.font = font_Normal_16;
    
    [threeSubView.leftButton setAllTitleColor:color_GrayDark];
    [threeSubView.centerButton setAllTitleColor:color_GrayDark];
    [threeSubView.rightButton setAllTitleColor:color_GrayDark];
    
    [threeSubView.leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [threeSubView.centerButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [threeSubView.rightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    
    return threeSubView;
}

- (void)configBorderForView:(UIView *)view {
    
    view.layer.borderWidth = 1;
    view.layer.borderColor = [color_GrayLight CGColor];
    view.layer.cornerRadius = 2;
    
}

- (void)addSeparatorForView:(UIView *)view {
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.bounds) - 1, CGRectGetWidth(view.bounds) - 1, 1)];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
    
}

- (NSUInteger)contentWidth {
    
    static NSUInteger contentWidth = 0;
    if (contentWidth == 0) {
        
        contentWidth = CGRectGetWidth(self.layerView.bounds) - kSettingsViewEdgeInset * 2;
        
    }
    return contentWidth;
    
}

- (CGSize)cellSize {
    
    static CGSize cellSize = {0, 0};
    if (CGSizeEqualToSize(cellSize, CGSizeZero)) {
        
        cellSize = CGSizeMake([self contentWidth], kSettingsViewCellHeight);
        
    }
    return cellSize;
}

- (NSString *)addLeftWhiteSpaceForString:(NSString *)string {
    
    return [NSString stringWithFormat:@"%@%@", kSettingsViewEdgeWhiteSpace, string];
    
}

- (void)setAvatar {
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:str_Settings_SetAvatar_Tips1
                                                                 delegate:self
                                                        cancelButtonTitle:str_Cancel
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:str_Settings_SetAvatar_Camera, str_Settings_SetAvatar_Album, nil];
        [actionSheet showInView:self.view];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:str_Settings_SetAvatar_Tips2
                                                                 delegate:self
                                                        cancelButtonTitle:str_Cancel
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:str_Settings_SetAvatar_Album, nil];
        [actionSheet showInView:self.view];
        
    } else {
        //不支持相片选取
    }
}

- (void)toSetNickNameViewController {
    
    __weak typeof(self) weakSelf = self;
    SettingsSetTextViewController *controller = [[SettingsSetTextViewController alloc] init];
    controller.title = str_Set_Nickname;
    controller.textFieldPlaceholder = str_Set_Nickname_Tips1;
    controller.setType = SetNickName;
    controller.finishedBlock = ^(NSString *text) {
        
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (text.length > 10) {
            [weakSelf alertButtonMessage:str_Set_Nickname_Tips2];
            return;
        }
        
        if (text.length == 0) {
            [weakSelf alertButtonMessage:str_Set_Nickname_Tips1];
            return;
        }

        [Config shareInstance].settings.nickname = text;
        [PlanCache storePersonalSettings:[Config shareInstance].settings];
        
        [weakSelf.nickThreeSubView.centerButton setAllTitle:text];
        [self alertToastMessage:str_Save_Success];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)toSetLifeViewController {
    
    __weak typeof(self) weakSelf = self;
    SettingsSetTextViewController *controller = [[SettingsSetTextViewController alloc] init];
    controller.title = str_Set_Lifespan;
    controller.textFieldPlaceholder = str_Set_Lifespan_Tips1;
    controller.setType = SetLife;
    controller.finishedBlock = ^(NSString *text) {
        
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (text.length == 0) {
            [weakSelf alertButtonMessage:str_Set_Lifespan_Tips2];
            return;
        }
        
        if ([text intValue]> 130) {
            [weakSelf alertButtonMessage:str_Set_Lifespan_Tips3];
            return;
        }

        [Config shareInstance].settings.lifespan = text;
        [PlanCache storePersonalSettings:[Config shareInstance].settings];

        [weakSelf.lifeThreeSubView.centerButton setAllTitle:text];
        [self alertToastMessage:str_Save_Success];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)setMale {
    
    self.sexThreeSubView.centerButton.selected = YES;
    self.sexThreeSubView.rightButton.selected = NO;
    
    [Config shareInstance].settings.gender = @"1";
    
    [PlanCache storePersonalSettings:[Config shareInstance].settings];
    
}

- (void)setFemale {
    
    self.sexThreeSubView.centerButton.selected = NO;
    self.sexThreeSubView.rightButton.selected = YES;
    
    [Config shareInstance].settings.gender = @"0";
    
    [PlanCache storePersonalSettings:[Config shareInstance].settings];
    
}

- (void)setBirthday {
    
    UIView *pickerView = [[UIView alloc] initWithFrame:self.view.bounds];
    pickerView.backgroundColor = [UIColor clearColor];
    
    {
        UIView *bgView = [[UIView alloc] initWithFrame:pickerView.bounds];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.3;
        [pickerView addSubview:bgView];
    }
    {
        UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, pickerView.frame.size.height - kSettingsViewPickerHeight - kSettingsViewToolBarHeight, CGRectGetWidth(pickerView.bounds), kSettingsViewToolBarHeight)];
        toolbar.barStyle = UIBarStyleBlack;
        toolbar.translucent = YES;
        UIBarButtonItem* item1 = [[UIBarButtonItem alloc] initWithTitle:str_OK style:UIBarButtonItemStylePlain target:nil action:@selector(onPickerCertainBtn)];
        UIBarButtonItem* item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem* item3 = [[UIBarButtonItem alloc] initWithTitle:str_Cancel style:UIBarButtonItemStylePlain target:nil action:@selector(onPickerCancelBtn)];
        NSArray* toolbarItems = [NSArray arrayWithObjects:item3, item2, item1, nil];
        [toolbar setItems:toolbarItems];
        [pickerView addSubview:toolbar];
    }
    {
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, pickerView.frame.size.height - kSettingsViewPickerHeight, CGRectGetWidth(pickerView.bounds), kSettingsViewPickerHeight)];
        picker.backgroundColor = [UIColor whiteColor];
        picker.locale = [NSLocale currentLocale];
        picker.datePickerMode = UIDatePickerModeDate;
        picker.maximumDate = [NSDate date];
        NSDateComponents *defaultComponents = [CommonFunction getDateTime:[NSDate date]];
        NSDate *minDate = [CommonFunction NSStringDateToNSDate:[NSString stringWithFormat:@"%zd-%zd-%zd",
                                                                 defaultComponents.year - 100,
                                                                 defaultComponents.month,
                                                                 defaultComponents.day]
                                                      formatter:str_DateFormatter_yyyy_MM_dd];

        picker.minimumDate = minDate;
        [pickerView addSubview:picker];
        self.datePicker = picker;
        
        NSString *birthday = [Config shareInstance].settings.birthday;
        
        if (birthday) {
            NSDate *date = [CommonFunction NSStringDateToNSDate:birthday formatter:str_DateFormatter_yyyy_MM_dd];
            if (date) {
                [self.datePicker setDate:date animated:YES];
            }
        } else {
            NSDate *defaultDate = [CommonFunction NSStringDateToNSDate:[NSString stringWithFormat:@"%zd-%zd-%zd",
                                                                         defaultComponents.year - 20,
                                                                         defaultComponents.month,
                                                                         defaultComponents.day]
                                                              formatter:str_DateFormatter_yyyy_MM_dd];
            self.datePicker.date = defaultDate;
        }
    }
    
    pickerView.tag = kSettingsViewPickerBgViewTag;
    [self.view addSubview:pickerView];
    
}

- (void)onPickerCertainBtn {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:str_DateFormatter_yyyy_MM_dd];
    NSString *birthday = [dateFormatter stringFromDate:self.datePicker.date];
    
    [Config shareInstance].settings.birthday = birthday;
    
    if (birthday.length == 0) {
        birthday = str_Settings_Birthday_Tips;
    }
    [self.birthThreeSubView.centerButton setAllTitle:birthday];
    
    UIView *pickerView = [self.view viewWithTag:kSettingsViewPickerBgViewTag];
    [pickerView removeFromSuperview];
    
    [Config shareInstance].settings.birthday = birthday;
    
    [PlanCache storePersonalSettings:[Config shareInstance].settings];
    
}

- (void)onPickerCancelBtn {
    
    UIView *pickerView = [self.view viewWithTag:kSettingsViewPickerBgViewTag];
    [pickerView removeFromSuperview];
    
}

- (void)saveAvatar:(UIImage *)icon {
    
    if (icon == nil) {
        return;
    }
    
    self.avatarView.image = icon;
    self.avatarView.contentMode = UIViewContentModeScaleAspectFit;

    [Config shareInstance].settings.avatar = icon;
    [PlanCache storePersonalSettings:[Config shareInstance].settings];
    
}

- (void)exitAction {
    
    [LogIn bmobLogOut];

}

- (void)sinaWeiboLogin {
    
    if([WeiboSDK isWeiboAppInstalled]) {
        
        [self showHUD];
        
        [WeiboSDK enableDebugMode:YES];
        //向新浪发送请求
        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
        request.redirectURI = str_SinaWeibo_RedirectURI;
        request.scope = @"all";
        [WeiboSDK sendRequest:request];
        
    } else {
        
        [self alertButtonMessage:str_Settings_LogIn_SinaWeibo_Tips1];
    }
    
}

- (void)qqLogIn {

    if ([TencentOAuth iphoneQQInstalled]) {
        
        [self showHUD];
        //注册
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:str_QQ_AppID andDelegate:self];
        //授权
        NSArray *permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO,nil];
        [_tencentOAuth authorize:permissions inSafari:NO];
        //获取用户信息
        [_tencentOAuth getUserInfo];
        
    } else {
        
        [self alertButtonMessage:str_Settings_LogIn_QQ_Tips1];
    }
    
}

- (void)wechatLogIn {

    [ShareSDK getUserInfo:SSDKPlatformTypeWechat onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        
        if (state == SSDKResponseStateSuccess) {
            
        }
    
    }];
    
}

- (void)tencentDidLogin {
    
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length]) {

        NSString *accessToken = _tencentOAuth.accessToken;
        NSString *uid = _tencentOAuth.openId;
        NSDate *expiresDate = _tencentOAuth.expirationDate;
        
        [LogIn bmobLogIn:BmobSNSPlatformQQ accessToken:accessToken uid:uid expiresDate:expiresDate];
        
    } else {
        
        [self hideHUD];
        
    }
    
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    
    [self hideHUD];
}

- (void)tencentDidNotNetWork {
    
    [self hideHUD];
}

- (void)tencentDidLogout {
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex==[actionSheet cancelButtonIndex]) {
        
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:str_Settings_SetAvatar_Camera]) {
        //拍照
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor darkGrayColor]};
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.allowsEditing = YES;
            imagePickerController.delegate = self;
            [self presentViewController:imagePickerController animated:YES completion:nil];
            
        } else {
            
            [self alertButtonMessage:str_Common_Tips2];
        }
        
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:str_Settings_SetAvatar_Album]) {
        //从相册选择
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor darkGrayColor]};
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.allowsEditing = YES;
            imagePickerController.delegate = self;
            [self presentViewController:imagePickerController animated:YES completion:nil];
            
        } else {
            
            [self alertButtonMessage:str_Common_Tips1];
            
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *img = [CommonFunction compressImage:image];
    [self saveAvatar:img];
    
}


@end
