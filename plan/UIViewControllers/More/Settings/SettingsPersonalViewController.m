//
//  SettingsPersonalViewController.m
//  plan
//
//  Created by Fengzy on 16/4/15.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "CLLockVC.h"
#import "PlanCache.h"
#import "DataCenter.h"
#import "ThreeSubView.h"
#import <BmobSDK/BmobUser.h>
#import <ShareSDK/ShareSDK.h>
#import "LogInViewController.h"
#import "ChangePasswordViewController.h"
#import "SettingsSetTextViewController.h"
#import "SettingsPersonalViewController.h"

NSString *const kEdgeWhiteSpace = @"  ";

@interface SettingsPersonalViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    UIScrollView *scrollView;
    UIImageView *avatarView;
    ThreeSubView *nickThreeSubView;
    ThreeSubView *signatureThreeSubView;
    ThreeSubView *genderThreeSubView;
    ThreeSubView *birthThreeSubView;
    ThreeSubView *lifeThreeSubView;
    ThreeSubView *emailThreeSubView;
    ThreeSubView *changePasswordThreeSubView;
    UIDatePicker *datePicker;
    
    UITextField *txtEmail;
    UITextField *txtPwd;
}

@end

@implementation SettingsPersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STRViewTitle17;
    
    [NotificationCenter addObserver:self selector:@selector(loadCustomView) name:NTFLogIn object:nil];
    [NotificationCenter addObserver:self selector:@selector(loadCustomView) name:NTFSettingsSave object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!scrollView) {
        
        scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:scrollView];
        
        [self loadCustomView];
    }
}

- (void)createNavBarButton {
    if ([LogIn isLogin]) {
        self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Sync selectedImageName:png_Btn_Sync selector:@selector(syncDataAction)];
    } else {
        self.rightBarButtonItem = nil;
    }
}

- (void)loadCustomView {
    [self createNavBarButton];
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self showHUD];
    
    CGFloat yOffset = kEdgeInset;
    
    if([LogIn isLogin]) {
        ThreeSubView *view = [self getAccountView];
        [scrollView addSubview:view];
        [self configBorderForView:view];
        
        CGRect frame = view.frame;
        frame.origin.x = kEdgeInset;
        frame.origin.y = yOffset;
        view.frame = frame;
        
        yOffset = CGRectGetMaxY(frame) + kEdgeInset;
    }
    
    {
        UIView *view = [self createSectionTwoView];
        [scrollView addSubview:view];
        
        CGRect frame = view.frame;
        frame.origin.y = yOffset;
        view.frame = frame;
        
        yOffset = CGRectGetMaxY(frame) + kEdgeInset;
    }
    
    {
        UIView *view = [self createSectionThreeView];
        [scrollView addSubview:view];
        
        CGRect frame = view.frame;
        frame.origin.y = yOffset;
        view.frame = frame;
        
        yOffset = CGRectGetMaxY(frame) + kEdgeInset;
    }
    
    if([LogIn isLogin]) {
        UIButton *button = [self createExitButton];
        
        CGRect frame = CGRectZero;
        frame.origin.x = kEdgeInset;
        frame.origin.y = yOffset;
        frame.size.width = CGRectGetWidth(scrollView.frame) - kEdgeInset * 2;
        frame.size.height = kTableViewCellHeight;
        button.frame = frame;
        [scrollView addSubview:button];
        
        yOffset = CGRectGetMaxY(frame) + kTableViewCellHeight;
        
    } else {
        
        UIButton *button = [self createLogInButton];
        
        CGRect frame = CGRectZero;
        frame.origin.x = kEdgeInset;
        frame.origin.y = yOffset;
        frame.size.width = CGRectGetWidth(scrollView.frame) - kEdgeInset * 2;
        frame.size.height = kTableViewCellHeight;
        button.frame = frame;
        [scrollView addSubview:button];
        
        yOffset = CGRectGetMaxY(frame) + kTableViewCellHeight;
    }
    scrollView.contentSize = CGSizeMake(WIDTH_FULL_SCREEN, yOffset);
    
    [self hideHUD];
}

- (ThreeSubView *)getAccountView {
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock:nil rightBlock:nil];
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:str_Settings_Acount]];
    threeSubView.fixRightWidth = kEdgeInset;
    threeSubView.fixCenterWidth = [self contentWidth] - threeSubView.fixLeftWidth - threeSubView.fixRightWidth;
    BmobUser *user = [BmobUser currentUser];
    NSString *email = [user objectForKey:@"username"];
    NSRange range = [email rangeOfString:@"@"];
    if (range.location != NSNotFound) {
        NSString *replaceString = @"*";
        for (NSInteger i = 1; i < range.location - 1; i++) {
            replaceString = [replaceString stringByAppendingString:@"*"];
        }
        email = [email stringByReplacingCharactersInRange:NSMakeRange(1, range.location - 1) withString:replaceString];
    }
    [threeSubView.centerButton setAllTitle:email];
    [threeSubView autoLayout];
    return threeSubView;
}

- (UIView *)createSectionTwoView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kEdgeInset, 0, [self contentWidth], 0)];
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
        [self addSeparatorForView:threeSubView];
        [view addSubview:threeSubView];
        
        CGRect frame = threeSubView.frame;
        frame.origin.y = yOffset;
        threeSubView.frame = frame;
        
        yOffset = CGRectGetMaxY(frame);
    }
    {
        ThreeSubView *threeSubView = [self createSignatureView];
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

- (UIView *)createSectionThreeView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kEdgeInset, 0, [self contentWidth], 0)];
    view.backgroundColor = [UIColor whiteColor];
    
    NSUInteger yOffset = 0;
    if ([LogIn isLogin]) {
        ThreeSubView *threeSubView = [self createChangePassword];
        [self addSeparatorForView:threeSubView];
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
    
    UIImage *avatarImage = [UIImage imageNamed:png_AvatarDefault];
    if ([Config shareInstance].settings.avatar) {
        avatarImage = [UIImage imageWithData:[Config shareInstance].settings.avatar];
    }
    NSUInteger yDistance = 2;
    CGFloat avatarSize = kTableViewCellHeight - yDistance;
    UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(threeSubView.centerButton.bounds) - kEdgeInset - avatarSize, yDistance, avatarSize, avatarSize)];
    avatar.image = avatarImage;
    avatar.clipsToBounds = YES;
    avatar.layer.borderWidth = 1;
    avatar.userInteractionEnabled = YES;
    avatar.layer.cornerRadius = avatarSize / 2;
    avatar.backgroundColor = [UIColor clearColor];
    avatar.layer.borderColor = [color_dedede CGColor];
    avatar.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setAvatar)];
    [avatar addGestureRecognizer:singleTap];

    [threeSubView.centerButton addSubview:avatar];
    
    avatarView = avatar;
    return threeSubView;
}

- (ThreeSubView *)createNickNameView {
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: ^{
        [weakSelf toSetNickNameViewController];
    } rightBlock:nil];
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:str_Settings_Nickname]];
    threeSubView.fixRightWidth = kEdgeInset;
    threeSubView.fixCenterWidth = [self contentWidth] - threeSubView.fixLeftWidth - threeSubView.fixRightWidth;
    
    NSString *userNickName = [Config shareInstance].settings.nickname;
    if (userNickName.length == 0) {
        userNickName = str_Settings_Nickname_Tips;
    }
    [threeSubView.centerButton setAllTitle:userNickName];
    [threeSubView autoLayout];
    
    nickThreeSubView = threeSubView;
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
    genderThreeSubView = threeSubView;
    return threeSubView;
}

- (ThreeSubView *)createBirthdayView {
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: ^{
        [weakSelf setBirthday];
    } rightBlock:nil];
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:str_Settings_Birthday]];
    threeSubView.fixRightWidth = kEdgeInset;
    threeSubView.fixCenterWidth = [self contentWidth] - threeSubView.fixLeftWidth - threeSubView.fixRightWidth;
    
    NSString *birthday = [Config shareInstance].settings.birthday;
    if (birthday.length == 0) {
        birthday = str_Settings_Birthday_Tips;
    }
    [threeSubView.centerButton setAllTitle:birthday];
    [threeSubView autoLayout];
    birthThreeSubView = threeSubView;
    return threeSubView;
}

- (ThreeSubView *)createLifespanView {
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: ^{
        [weakSelf toSetLifeViewController];
    } rightBlock:nil];
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:str_Settings_Lifespan]];
    threeSubView.fixRightWidth = kEdgeInset;
    threeSubView.fixCenterWidth = [self contentWidth] - threeSubView.fixLeftWidth - threeSubView.fixRightWidth;
    
    NSString *lifetime = [Config shareInstance].settings.lifespan;
    if (lifetime.length == 0) {
        lifetime = str_Settings_Lifespan_Tips;
    }
    [threeSubView.centerButton setAllTitle:lifetime];
    [threeSubView autoLayout];
    lifeThreeSubView = threeSubView;
    return threeSubView;
}

- (ThreeSubView *)createSignatureView {
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: ^{
        [weakSelf toSetSignatureViewController];
    } rightBlock:nil];
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:str_Settings_Signature]];
    threeSubView.fixRightWidth = kEdgeInset;
    threeSubView.fixCenterWidth = [self contentWidth] - threeSubView.fixLeftWidth - threeSubView.fixRightWidth;
    
    NSString *signature = [Config shareInstance].settings.signature;
    if (signature.length == 0) {
        signature = str_Settings_Signature_Tips;
    }
    [threeSubView.centerButton setAllTitle:signature];
    [threeSubView autoLayout];
    
    signatureThreeSubView = threeSubView;
    return threeSubView;
}

- (ThreeSubView *)createChangePassword {
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: ^{
        [weakSelf toChangePasswordViewController];
    } rightBlock: ^{
        [weakSelf toChangePasswordViewController];
    }];
    
    threeSubView.fixRightWidth = 55;
    [threeSubView.rightButton setImage:[UIImage imageNamed:png_Icon_Arrow_Right] forState:UIControlStateNormal];
    
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:str_Settings_ChangePassword]];
    threeSubView.fixCenterWidth = [self contentWidth] - threeSubView.fixRightWidth - threeSubView.fixLeftWidth;
    threeSubView.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    [threeSubView autoLayout];
    changePasswordThreeSubView = threeSubView;
    return threeSubView;
}

- (UIButton *)createLogInButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color_0BA32A;
    button.titleLabel.font = font_Bold_18;
    button.layer.cornerRadius = 5;
    button.clipsToBounds = YES;
    [button setAllTitle:str_Settings_LogIn];
    [button addTarget:self action:@selector(logInAction) forControlEvents:UIControlEventTouchUpInside];
    return button;
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
        contentWidth = CGRectGetWidth(scrollView.bounds) - kEdgeInset * 2;
    }
    return contentWidth;
}

- (CGSize)cellSize {
    static CGSize cellSize = {0, 0};
    if (CGSizeEqualToSize(cellSize, CGSizeZero)) {
        cellSize = CGSizeMake([self contentWidth], kTableViewCellHeight);
    }
    return cellSize;
}

- (NSString *)addLeftWhiteSpaceForString:(NSString *)string {
    
    return [NSString stringWithFormat:@"%@%@", kEdgeWhiteSpace, string];
}

- (void)setAvatar {
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:str_Settings_SetAvatar_Tips1
                                                                 delegate:self
                                                        cancelButtonTitle:STRCommonTip28
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:str_Settings_SetAvatar_Camera, str_Settings_SetAvatar_Album, nil];
        [actionSheet showInView:self.view];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:str_Settings_SetAvatar_Tips2
                                                                 delegate:self
                                                        cancelButtonTitle:STRCommonTip28
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
        
        [nickThreeSubView.centerButton setAllTitle:text];
        [self alertToastMessage:STRCommonTip13];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toSetSignatureViewController {
    __weak typeof(self) weakSelf = self;
    SettingsSetTextViewController *controller = [[SettingsSetTextViewController alloc] init];
    controller.title = str_Set_Signature;
    controller.textFieldPlaceholder = str_Set_Signature_Tips1;
    controller.setType = SetNickName;
    controller.finishedBlock = ^(NSString *text) {
        
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (text.length == 0) {
            [weakSelf alertButtonMessage:str_Set_Signature_Tips1];
            return;
        }
        
        [Config shareInstance].settings.signature = text;
        [PlanCache storePersonalSettings:[Config shareInstance].settings];
        
        [signatureThreeSubView.centerButton setAllTitle:text];
        [self alertToastMessage:STRCommonTip13];
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
        
        [lifeThreeSubView.centerButton setAllTitle:text];
        [self alertToastMessage:STRCommonTip13];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toGestureLockViewController {
    __weak typeof(self) weakSelf = self;
    BOOL hasPwd = [[Config shareInstance].settings.isUseGestureLock isEqualToString:@"1"];
    if (hasPwd) {
        //关闭手势解锁
        [CLLockVC showVerifyLockVCInVC:self isLogIn:NO forgetPwdBlock:^{
            
            LogInViewController *controller = [[LogInViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            
        } successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            
            [Config shareInstance].settings.isUseGestureLock = @"0";
            [Config shareInstance].settings.gesturePasswod = @"";
            [PlanCache storePersonalSettings:[Config shareInstance].settings];
            [lockVC dismiss:.5f];
        }];
        
    } else {
        
        //打开手势解锁
        [CLLockVC showSettingLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            
            [weakSelf alertToastMessage:STRSettingsViewTips11];
            [lockVC dismiss:.5f];
        }];
    }
}

- (void)toChangePasswordViewController {
    ChangePasswordViewController *controller = [[ChangePasswordViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toChangeGestureViewController {
    __weak typeof(self) weakSelf = self;
    BOOL hasPwd = [[Config shareInstance].settings.isUseGestureLock isEqualToString:@"1"];
    if (hasPwd) {
        [CLLockVC showModifyLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            
            [weakSelf alertToastMessage:STRCommonTip15];
            [lockVC dismiss:.5f];
        }];
    }
}

- (void)setMale {
    genderThreeSubView.centerButton.selected = YES;
    genderThreeSubView.rightButton.selected = NO;
    [Config shareInstance].settings.gender = @"1";
    [PlanCache storePersonalSettings:[Config shareInstance].settings];
}

- (void)setFemale {
    genderThreeSubView.centerButton.selected = NO;
    genderThreeSubView.rightButton.selected = YES;
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
        UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, pickerView.frame.size.height - kDatePickerHeight - kToolBarHeight, CGRectGetWidth(pickerView.bounds), kToolBarHeight)];
        toolbar.barStyle = UIBarStyleBlack;
        toolbar.translucent = YES;
        UIBarButtonItem* item1 = [[UIBarButtonItem alloc] initWithTitle:STRCommonTip27 style:UIBarButtonItemStylePlain target:nil action:@selector(onPickerCertainBtn)];
        UIBarButtonItem* item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem* item3 = [[UIBarButtonItem alloc] initWithTitle:STRCommonTip28 style:UIBarButtonItemStylePlain target:nil action:@selector(onPickerCancelBtn)];
        NSArray* toolbarItems = [NSArray arrayWithObjects:item3, item2, item1, nil];
        [toolbar setItems:toolbarItems];
        [pickerView addSubview:toolbar];
    }
    {
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, pickerView.frame.size.height - kDatePickerHeight, CGRectGetWidth(pickerView.bounds), kDatePickerHeight)];
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
        datePicker = picker;
        
        NSString *birthday = [Config shareInstance].settings.birthday;
        
        if (birthday) {
            NSDate *date = [CommonFunction NSStringDateToNSDate:birthday formatter:str_DateFormatter_yyyy_MM_dd];
            if (date) {
                [datePicker setDate:date animated:YES];
            }
        } else {
            NSDate *defaultDate = [CommonFunction NSStringDateToNSDate:[NSString stringWithFormat:@"%zd-%zd-%zd",
                                                                        defaultComponents.year - 20,
                                                                        defaultComponents.month,
                                                                        defaultComponents.day]
                                                             formatter:str_DateFormatter_yyyy_MM_dd];
            datePicker.date = defaultDate;
        }
    }
    
    pickerView.tag = kDatePickerBgViewTag;
    [self.view addSubview:pickerView];
}

- (void)onPickerCertainBtn {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:str_DateFormatter_yyyy_MM_dd];
    NSString *birthday = [dateFormatter stringFromDate:datePicker.date];
    
    [Config shareInstance].settings.birthday = birthday;
    
    if (birthday.length == 0) {
        birthday = str_Settings_Birthday_Tips;
    }
    [birthThreeSubView.centerButton setAllTitle:birthday];
    
    UIView *pickerView = [self.view viewWithTag:kDatePickerBgViewTag];
    [pickerView removeFromSuperview];
    [Config shareInstance].settings.birthday = birthday;
    [PlanCache storePersonalSettings:[Config shareInstance].settings];
}

- (void)onPickerCancelBtn {
    UIView *pickerView = [self.view viewWithTag:kDatePickerBgViewTag];
    [pickerView removeFromSuperview];
}

- (void)saveAvatar:(NSData *)icon {
    if (icon == nil) {
        return;
    }
    
    avatarView.image = [UIImage imageWithData:icon];
    avatarView.contentMode = UIViewContentModeScaleAspectFit;
    
    [Config shareInstance].settings.avatar = icon;
    [Config shareInstance].settings.avatarURL = @"";
    [PlanCache storePersonalSettings:[Config shareInstance].settings];
}

- (void)logInAction {
    LogInViewController *controller = [[LogInViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)exitAction {
    [BmobUser logout];
    [NotificationCenter postNotificationName:NTFSettingsSave object:nil];
    [NotificationCenter postNotificationName:NTFPlanSave object:nil];
    [NotificationCenter postNotificationName:NTFPhotoSave object:nil];
    [NotificationCenter postNotificationName:NTFTaskSave object:nil];
    [NotificationCenter postNotificationName:NTFPostsRefresh object:nil];
}

- (void)syncDataAction {
    [AlertCenter alertNavBarYellowMessage:str_Sync_Begin];
    [DataCenter startSyncData];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex==[actionSheet cancelButtonIndex]) {
        
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:str_Settings_SetAvatar_Camera]) {
        //拍照
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor darkGrayColor]};
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.allowsEditing = YES;
            picker.delegate = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:picker animated:YES completion:nil];
            });
            
        } else {
            
            [self alertButtonMessage:STRCommonTip2];
        }
        
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:str_Settings_SetAvatar_Album]) {
        //从相册选择
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor darkGrayColor]};
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.allowsEditing = YES;
            picker.delegate = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{//如果不这样写，在iPad上会访问不了相册
                [self presentViewController:picker animated:YES completion:nil];
            });
            
        } else {
            
            [self alertButtonMessage:STRCommonTip1];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self saveAvatar:[CommonFunction compressImage:image]];
}

@end
