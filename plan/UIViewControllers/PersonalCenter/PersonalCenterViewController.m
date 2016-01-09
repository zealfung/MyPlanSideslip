//
//  PersonalCenterViewController.m
//  plan
//
//  Created by Fengzy on 15/11/1.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "Statistics.h"
#import "ShareCenter.h"
#import "PieceButton.h"
#import "ThreeSubView.h"
#import "StatisticsCenter.h"
#import "LogInViewController.h"
#import "SettingsViewController.h"
#import "PersonalCenterViewController.h"

@interface PersonalCenterViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    UIScrollView *scrollView;
    UIImageView *imgViewTop;
    UIImageView *imgViewAvatar;
    UIButton *btnCheckIn;
    UIButton *btnShareData;
    UIView *viewPieces;
    PieceButton *pbRecentlyCheckInDates;//最近连续签到天数
    PieceButton *pbMaxCheckInDates; //最大连续签到天数
    PieceButton *pbTotalEverydayPlan;//每日计划总数
    PieceButton *pbTotalEverydayPlanDone;//每日计划完成总数
    PieceButton *pbTotalLongtermPlan;//长远计划总数
    PieceButton *pbTotalLongtermPlanDone;//长远计划完成总数
    PieceButton *pbTotalTask;//任务总数
    PieceButton *pbTotalPhoto;//影像总数
    
    UIView *viewLogo;
    UILabel *labelUpdateTime;
}

@end

@implementation PersonalCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_ViewTitle_4;
    [self createRightBarButton];
    
    [NotificationCenter addObserver:self selector:@selector(loadCustomView) name:Notify_Settings_Save object:nil];
    [NotificationCenter addObserver:self selector:@selector(loadCustomView) name:Notify_LogIn object:nil];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, HEIGHT_FULL_SCREEN)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollView];
    
    [self loadCustomView];
}

- (void)dealloc {
    [NotificationCenter removeObserver:self];
}

- (void)createRightBarButton {
    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Settings selectedImageName:png_Btn_Settings selector:@selector(settingsAction:)];
}

- (void)loadCustomView {
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat yOffset = 0;

    {
        CGFloat imgSize = WIDTH_FULL_SCREEN * 0.618;
        UIImage *image = [UIImage imageNamed:png_Bg_SideTop];
        if ([Config shareInstance].settings.centerTop) {
            
            image = [Config shareInstance].settings.centerTop;
        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, WIDTH_FULL_SCREEN, imgSize)];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeTopImage)];
        [imageView addGestureRecognizer:singleTap];
        imgViewTop = imageView;
        [scrollView addSubview:imageView];
        
        yOffset = imgSize;
    }
    {
        CGFloat avatarBgSize = WIDTH_FULL_SCREEN / 5;
        CGFloat avatarSize = avatarBgSize - 4;
        UIImage *bgImage = [UIImage imageNamed:png_AvatarBg];
        
        UIImageView *avatarBg = [[UIImageView alloc] initWithFrame:CGRectMake(avatarBgSize * 2, yOffset - avatarBgSize / 2, avatarBgSize, avatarBgSize)];
        avatarBg.backgroundColor = [UIColor clearColor];
        avatarBg.image = bgImage;
        avatarBg.layer.cornerRadius = avatarBgSize / 2;
        avatarBg.clipsToBounds = YES;
        avatarBg.userInteractionEnabled = YES;
        avatarBg.contentMode = UIViewContentModeScaleAspectFit;
        [scrollView addSubview:avatarBg];
        {
            UIImage *image = [UIImage imageNamed:png_AvatarDefault];
            if ([Config shareInstance].settings.avatar) {
                
                image = [Config shareInstance].settings.avatar;
            }
            UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(ceilf((avatarBgSize - avatarSize)/2), ceilf((avatarBgSize - avatarSize)/2), avatarSize, avatarSize)];
            avatar.backgroundColor = [UIColor clearColor];
            avatar.image = image;
            avatar.layer.cornerRadius = avatarSize / 2;
            avatar.clipsToBounds = YES;
            avatar.contentMode = UIViewContentModeScaleAspectFit;
            
            [avatarBg addSubview:avatar];
        }
        yOffset = avatarBg.frame.origin.y + avatarBgSize + 10;
    }
    {
        CGFloat nickNameWidth = WIDTH_FULL_SCREEN / 5;
        CGFloat nickNameHeight = 20;
        NSString *nickname = str_NickName;
        if (![CommonFunction isEmptyString:[Config shareInstance].settings.nickname]) {
            nickname = [Config shareInstance].settings.nickname;
        }

        UILabel *labelNickName = [[UILabel alloc] initWithFrame:CGRectMake(nickNameWidth * 2 - nickNameHeight / 2, yOffset, nickNameWidth, nickNameHeight)];
        labelNickName.text = nickname;
        labelNickName.font = font_Normal_14;
        labelNickName.textAlignment = NSTextAlignmentCenter;
        labelNickName.textColor = [CommonFunction getGenderColor];
        
        UIImageView *imgViewGender = [[UIImageView alloc] initWithFrame:CGRectMake(nickNameWidth * 3 - nickNameHeight / 2, yOffset, nickNameHeight, nickNameHeight)];
        imgViewGender.image = [CommonFunction getGenderIcon];
        
        [scrollView addSubview:labelNickName];
        [scrollView addSubview:imgViewGender];
        yOffset = labelNickName.frame.origin.y + nickNameHeight + 10;
    }
    {
//        CGFloat rankingHeight = 20;
//        ThreeSubView *tsvRanking = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, yOffset, WIDTH_FULL_SCREEN, rankingHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
//        [tsvRanking.leftButton.titleLabel setFont:font_Normal_10];
//        [tsvRanking.leftButton setAllTitleColor:color_708cb0];
//        [tsvRanking.leftButton setAllTitle:str_PersonalCenter_Tips1];
//        [tsvRanking.centerButton.titleLabel setFont:font_Normal_20];
//        [tsvRanking.centerButton setAllTitleColor:color_75aff4];
//        if (![CommonFunction isEmptyString:[Config shareInstance].settings.birthday]) {
//            [tsvRanking.centerButton setAllTitle:[NSString stringWithFormat:@"%zd",@""]];
//        } else {
//            [tsvRanking.centerButton setAllTitle:@"X"];
//        }
        
//        [tsvRanking.centerButton setAllTitle:@"99.33%"];
//        
//        [tsvRanking.rightButton.titleLabel setFont:font_Normal_10];
//        [tsvRanking.rightButton setAllTitleColor:color_708cb0];
//        [tsvRanking.rightButton setAllTitle:str_PersonalCenter_Tips2];
//        [tsvRanking autoLayout];
        
//        CGRect rankingFrame = CGRectZero;
//        rankingFrame.size.width = tsvRanking.frame.size.width;
//        rankingFrame.size.height = tsvRanking.frame.size.height;
//        rankingFrame.origin.x = WIDTH_FULL_SCREEN / 2 - tsvRanking.frame.size.width/2;
//        rankingFrame.origin.y = yOffset;
//        tsvRanking.frame = rankingFrame;
        
//        [scrollView addSubview:tsvRanking];
        
//        yOffset = tsvRanking.frame.origin.y + rankingHeight + 10;
        
        CGFloat btnWidth = WIDTH_FULL_SCREEN / 5;
        CGFloat btnHeight = 30;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnWidth * 2, yOffset, btnWidth, btnHeight)];
        btn.layer.cornerRadius = 5;
        if ([LogIn isLogin] && [StatisticsCenter isCheckInToday]) {
            btn.layer.borderColor = [color_8f8f8f CGColor];
            btn.layer.borderWidth = 1;
            [btn setAllTitle:str_CheckIn_Tips2];
            [btn setAllTitleColor:color_8f8f8f];
            btn.enabled = NO;
        } else {
            btn.layer.borderColor = [[CommonFunction getGenderColor] CGColor];
            btn.layer.borderWidth = 1;
            [btn setAllTitle:str_CheckIn_Tips1];
            [btn setAllTitleColor:[CommonFunction getGenderColor]];
        }
        [btn.titleLabel setFont:font_Normal_14];
        [btn addTarget:self action:@selector(checkIn:) forControlEvents:UIControlEventTouchUpInside];
        btnCheckIn = btn;
        [scrollView addSubview:btn];
        
        yOffset =  CGRectGetMaxY(btn.frame) + 10;
    }
    {
        NSString *dayPlanTotalCount = [PlanCache getPlanTotalCountByPlantype:@"1"];
        NSString *doneDayPlanTotalCount = [PlanCache getPlanCompletedCountByPlantype:@"1"];
        NSString *longPlanTotalCount = [PlanCache getPlanTotalCountByPlantype:@"0"];
        NSString *doneLongPlanTotalCount = [PlanCache getPlanCompletedCountByPlantype:@"0"];
        NSString *taskTotalCount = [PlanCache getTaskTotalCount];
        NSString *photoTotalCount = [PlanCache getPhotoTotalCount];
        Statistics *statistics= [PlanCache getStatistics];
        
        viewPieces = [[UIView alloc] initWithFrame:CGRectMake(0, yOffset, WIDTH_FULL_SCREEN, kPieceButtonHeight * 4)];
        
        pbRecentlyCheckInDates = [[PieceButton alloc] initWithTitle:str_PersonalCenter_SubTitle1 content:statistics.recentMax icon:[UIImage imageNamed:png_ImageDefault] bgColor:color_F9F2EA];
        pbMaxCheckInDates = [[PieceButton alloc] initWithTitle:str_PersonalCenter_SubTitle2 content:statistics.recordMax icon:[UIImage imageNamed:png_ImageDefault] bgColor:color_F2F3F5];
        pbTotalEverydayPlan = [[PieceButton alloc] initWithTitle:str_PersonalCenter_SubTitle3 content:dayPlanTotalCount icon:[UIImage imageNamed:png_ImageDefault] bgColor:color_F2F3F5];
        pbTotalEverydayPlanDone = [[PieceButton alloc] initWithTitle:str_PersonalCenter_SubTitle4 content:doneDayPlanTotalCount icon:[UIImage imageNamed:png_ImageDefault] bgColor:color_F9F2EA];
        pbTotalLongtermPlan = [[PieceButton alloc] initWithTitle:str_PersonalCenter_SubTitle5 content:longPlanTotalCount icon:[UIImage imageNamed:png_ImageDefault] bgColor:color_F9F2EA];
        pbTotalLongtermPlanDone = [[PieceButton alloc] initWithTitle:str_PersonalCenter_SubTitle6 content:doneLongPlanTotalCount icon:[UIImage imageNamed:png_ImageDefault] bgColor:color_F2F3F5];
        pbTotalTask = [[PieceButton alloc] initWithTitle:str_PersonalCenter_SubTitle7 content:taskTotalCount icon:[UIImage imageNamed:png_ImageDefault] bgColor:color_F2F3F5];
        pbTotalPhoto = [[PieceButton alloc] initWithTitle:str_PersonalCenter_SubTitle8 content:photoTotalCount icon:[UIImage imageNamed:png_ImageDefault] bgColor:color_F9F2EA];
        
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:pbRecentlyCheckInDates];
        [array addObject:pbMaxCheckInDates];
        [array addObject:pbTotalEverydayPlan];
        [array addObject:pbTotalEverydayPlanDone];
        [array addObject:pbTotalLongtermPlan];
        [array addObject:pbTotalLongtermPlanDone];
        [array addObject:pbTotalTask];
        [array addObject:pbTotalPhoto];
        
        for (int i = 0; i < array.count; i++) {
            
            PieceButton *btn = array[i];
            btn.frame = CGRectMake(i%2 * kPieceButtonWidth, i/2 * kPieceButtonHeight, kPieceButtonWidth, kPieceButtonHeight);
            [viewPieces addSubview:btn];
        }
        [scrollView addSubview:viewPieces];
        yOffset = CGRectGetMaxY(viewPieces.frame) + 10;
    }
    {
        CGFloat viewWidth = 110;
        CGFloat viewHeight = 20;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(WIDTH_FULL_SCREEN - viewWidth - 5, yOffset, viewWidth, viewHeight)];
        UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewHeight, viewHeight)];
        logo.image = [UIImage imageNamed:png_Icon_Logo_512];
        [view addSubview:logo];
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(viewHeight + 2, 0, viewWidth - viewHeight - 2, viewHeight)];
        labelName.text = str_Share_Tips1;
        labelName.font = font_Normal_10;
        labelName.textColor = [CommonFunction getGenderColor];
        [view addSubview:labelName];
        view.hidden = YES;
        viewLogo = view;
        [scrollView addSubview:view];
        
        CGFloat btnWidth = WIDTH_FULL_SCREEN / 3;
        CGFloat btnHeight = 30;
        UIButton *btnShare = [[UIButton alloc] initWithFrame:CGRectMake(btnWidth, yOffset, btnWidth, btnHeight)];
        btnShare.backgroundColor = color_ff9900;
        btnShare.layer.cornerRadius = btnHeight / 2;
        [btnShare.titleLabel setFont:font_Normal_14];
        [btnShare setAllTitle:str_Share_Tips2];
        [btnShare setAllTitleColor:[UIColor whiteColor]];
        [btnShare addTarget:self action:@selector(shareData:) forControlEvents:UIControlEventTouchUpInside];
        btnShareData = btnShare;
        [scrollView addSubview:btnShare];
        yOffset =  CGRectGetMaxY(btnShare.frame) + 74;
    }
    scrollView.contentSize = CGSizeMake(WIDTH_FULL_SCREEN, yOffset);
}

- (void)settingsAction:(UIButton *)button {
    SettingsViewController *controller = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)checkIn:(UIButton *)button {
    if ([LogIn isLogin]) {
        [StatisticsCenter checkIn];
    } else {
        //登录界面
        LogInViewController *controller = [[LogInViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)shareData:(UIButton *)button {
    viewLogo.hidden = NO;
    labelUpdateTime.hidden = YES;
    btnShareData.hidden = YES;

    UIImage* image = [UIImage imageNamed:png_ImageDefault];
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, NO , 0.0f);//高清，效率比较慢
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();

    viewLogo.hidden = YES;
    labelUpdateTime.hidden = NO;
    btnShareData.hidden = NO;
    
    [ShareCenter showShareActionSheet:self.view image:image];
}

- (void)changeTopImage {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:str_Cancel
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:str_Settings_SetAvatar_Camera, str_Settings_SetAvatar_Album, nil];
        [actionSheet showInView:self.view];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:str_Cancel
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:str_Settings_SetAvatar_Album, nil];
        [actionSheet showInView:self.view];
        
    } else {
        //不支持相片选取
    }
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
    [Config shareInstance].settings.centerTop = img;
    [Config shareInstance].settings.centerTopURL = @"";
    [PlanCache storePersonalSettings:[Config shareInstance].settings];
}

@end
