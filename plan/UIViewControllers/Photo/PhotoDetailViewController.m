//
//  PhotoDetailViewController.m
//  plan
//
//  Created by Fengzy on 15/10/8.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "KxMenu.h"
#import "PlanCache.h"
#import "PagedFlowView.h"
#import "AddPhotoViewController.h"
#import "PhotoDetailViewController.h"
#import "UINavigationController+Util.h"
#import "FullScreenImageArrayViewController.h"

NSUInteger const kPhotoDeleteTag = 20151011;

@interface PhotoDetailViewController () <PagedFlowViewDataSource, PagedFlowViewDelegate>

@property(nonatomic, assign) CGFloat xMargins;
@property(nonatomic, assign) CGFloat yMargins;
@property(nonatomic, assign) CGFloat yOffset;
@property(nonatomic, strong) UILabel *labelCurrentPage;
@property(nonatomic, strong) PagedFlowView *pageFlowView;

@end

@implementation PhotoDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = STRViewTips32;
    self.view.backgroundColor = color_eeeeee;
    
    __weak typeof(self) weakSelf = self;
    [self customRightButtonWithImage:[UIImage imageNamed:png_Btn_More] action:^(UIButton *sender) {
        [weakSelf showMenu:sender];
    }];
    
    [NotificationCenter addObserver:self selector:@selector(refreshData) name:NTFPhotoSave object:nil];
    
    [self initVariables];
    [self loadCustomView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initVariables
{
    self.xMargins = 12;
    self.yMargins = 30;
    self.yOffset = HEIGHT_FULL_SCREEN - self.yMargins - 64;
}

- (void)loadCustomView
{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self createTextViewContent];
    [self createLabelTimeAndLocation];
    [self createLabelCurrentPage];
    [self createPagedFlowView];
}

- (void)createTextViewContent
{
    if (self.photo.content && self.photo.content.length)
    {
        CGSize size = [self.photo.content sizeWithFont:font_Normal_16 constrainedToSize:CGSizeMake(240, 2000) lineBreakMode:NSLineBreakByCharWrapping];
        CGFloat contentHeight = size.height + 10;//获取自适应文本内容高度
        contentHeight = contentHeight > 108 ? 108 : contentHeight;//content高度不能超过108
        
        self.yOffset -= contentHeight;
        UITextView *contentView = [[UITextView alloc] initWithFrame:CGRectMake(self.xMargins, self.yOffset, WIDTH_FULL_SCREEN - self.xMargins * 2, contentHeight)];
        contentView.backgroundColor = [UIColor clearColor];
        contentView.font = font_Normal_16;
        contentView.showsHorizontalScrollIndicator = NO;
        contentView.showsVerticalScrollIndicator = NO;
        contentView.textColor = [Utils getGenderColor];
        contentView.text = self.photo.content;
        contentView.editable = NO;
        if (contentHeight < 30)
        {
            contentView.textAlignment = NSTextAlignmentCenter;
        }
        else
        {
            contentView.textAlignment = NSTextAlignmentLeft;
        }
        
        [self.view addSubview:contentView];
    }
}

- (void)createLabelTimeAndLocation
{
    NSString *timeAndLocation = [NSString stringWithFormat:STRViewTips35, self.photo.phototime];
    if (self.photo.location && self.photo.location.length > 0)
    {
        timeAndLocation = [NSString stringWithFormat:STRViewTips36, timeAndLocation, self.photo.location];
    }
    self.yOffset -= 30;
    UILabel *labelTimeAndLocation = [[UILabel alloc] initWithFrame:CGRectMake(self.xMargins, self.yOffset, WIDTH_FULL_SCREEN - self.xMargins * 2, 30)];
    labelTimeAndLocation.font = font_Normal_18;
    labelTimeAndLocation.textColor = color_333333;
    labelTimeAndLocation.textAlignment = NSTextAlignmentCenter;
    labelTimeAndLocation.text = timeAndLocation;
    [self.view addSubview:labelTimeAndLocation];
}

- (void)createLabelCurrentPage
{
    self.yOffset -= 30;
    UILabel *labelPage = [[UILabel alloc] initWithFrame:CGRectMake(self.xMargins, self.yOffset, WIDTH_FULL_SCREEN - self.xMargins * 2, 30)];
    labelPage.font = font_Bold_18;
    labelPage.textColor = [Utils getGenderColor];
    labelPage.textAlignment = NSTextAlignmentCenter;
    labelPage.text = [NSString stringWithFormat:@"1 / %ld", (long)self.photo.photoURLArray.count];
    self.labelCurrentPage = labelPage;
    [self.view addSubview:labelPage];
}

- (void)createPagedFlowView
{
    self.pageFlowView = [[PagedFlowView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, self.yOffset)];
    self.pageFlowView.backgroundColor = color_e9eff1;
    self.pageFlowView.minimumPageAlpha = 0.7;
    self.pageFlowView.minimumPageScale = 0.9;
    self.pageFlowView.delegate = self;
    self.pageFlowView.dataSource = self;
    [self.view addSubview:self.pageFlowView];
}

- (void)refreshData
{
    self.photo = [PlanCache getPhotoById:self.photo.photoid];
    [self initVariables];
    [self loadCustomView];
}

#pragma mark - action
- (void)showMenu:(UIButton *)sender
{
    NSArray *menuItems =
    @[
//      [KxMenuItem menuItem:STRCommonTip33
//                     image:[UIImage imageNamed:png_Btn_Edit]
//                    target:self
//                    action:@selector(editAction:)],
      [KxMenuItem menuItem:STRCommonTip34
                     image:[UIImage imageNamed:png_Btn_Delete]
                    target:self
                    action:@selector(deleteAction:)],
      ];
    
    if (![KxMenu isShowMenu])
    {
        CGRect frame = sender.frame;
        frame.origin.y -= 30;
        [KxMenu showMenuInView:self.view
                      fromRect:frame
                     menuItems:menuItems];
    }
    else
    {
        [KxMenu dismissMenu];
    }
}

- (void)editAction:(UIButton *)sender
{
    AddPhotoViewController *controller = [[AddPhotoViewController alloc] init];
    controller.operationType = Edit;
    controller.photo = self.photo;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)deleteAction:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRViewTips37
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:STRCommonTip28
                                          otherButtonTitles:STRCommonTip27,
                          nil];
    
    alert.tag = kPhotoDeleteTag;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kPhotoDeleteTag)
    {
        if (buttonIndex == 1)
        {
            [self showHUD];
            __weak typeof(self) weakSelf = self;
            BmobQuery *bquery = [BmobQuery queryWithClassName:@"Photo"];
            [bquery getObjectInBackgroundWithId:self.photo.photoid block:^(BmobObject *object,NSError *error)
             {
                 if (error)
                 {
                     [weakSelf hideHUD];
                 }
                 else
                 {
                     if (object)
                     {
                         [object setObject:@"1" forKey:@"isDeleted"];
                         [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
                          {
                              [weakSelf hideHUD];
                              if (isSuccessful)
                              {
                                  [NotificationCenter postNotificationName:NTFPhotoSave object:nil];
                                  [weakSelf alertToastMessage:STRCommonTip16];
                                  [weakSelf.navigationController popViewControllerAnimated:YES];
                              }
                              else
                              {
                                  [weakSelf alertButtonMessage:STRCommonTip17];
                              }
                          }];
                     }
                     else
                     {
                         [weakSelf hideHUD];
                     }
                 }
             }];
        }
    }
}

#pragma mark - PagedFlowView Datasource
- (NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView
{
    return self.photo.photoURLArray.count;
}

- (UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index
{
    [flowView dequeueReusableCell]; //必须要调用否则会内存泄漏
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    NSURL *photoURL = [NSURL URLWithString:self.photo.photoURLArray[index]];
    [imageView sd_setImageWithURL:photoURL placeholderImage:[UIImage imageNamed:png_ImageDefault_Rectangle]];
    return imageView;
}

#pragma mark - PagedFlowView Delegate
- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView
{
    CGFloat width = self.yOffset * 185.4 / 300;
    return CGSizeMake(width, self.yOffset);
}

- (void)flowView:(PagedFlowView *)flowView didScrollToPageAtIndex:(NSInteger)index
{
    long current = index + 1;
    long total = self.photo.photoURLArray.count;
    self.labelCurrentPage.text = [NSString stringWithFormat:@"%ld / %ld", current, total];
}

- (void)flowView:(PagedFlowView *)flowView didTapPageAtIndex:(NSInteger)index
{
    FullScreenImageArrayViewController *controller = [[FullScreenImageArrayViewController alloc] init];
    controller.imgURLArray = self.photo.photoURLArray;
    controller.defaultIndex = index;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
