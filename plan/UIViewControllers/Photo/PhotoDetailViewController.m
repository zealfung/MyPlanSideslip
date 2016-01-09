//
//  PhotoDetailViewController.m
//  plan
//
//  Created by Fengzy on 15/10/8.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "PlanCache.h"
#import "PagedFlowView.h"
#import "AddPhotoViewController.h"
#import "PhotoDetailViewController.h"
#import "UINavigationController+Util.h"
#import "FullScreenImageArrayViewController.h"

NSUInteger const kPhotoDeleteTag = 20151011;

@interface PhotoDetailViewController () <PagedFlowViewDataSource, PagedFlowViewDelegate> {
    
    CGFloat xMargins;
    CGFloat yMargins;
    CGFloat yOffset;
    UILabel *labelCurrentPage;
    PagedFlowView *pageFlowView;
}

@end

@implementation PhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_Photo_Detail;
    self.view.backgroundColor = color_eeeeee;
    
    [NotificationCenter addObserver:self selector:@selector(refreshData) name:Notify_Photo_Save object:nil];
    
    [self createRightBarButton];
    [self initVariables];
    [self loadCustomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [NotificationCenter removeObserver:self];
}

- (void)createRightBarButton {
    self.rightBarButtonItems = [NSArray arrayWithObjects:
                                               [self createBarButtonItemWithNormalImageName:png_Btn_Edit selectedImageName:png_Btn_Edit selector:@selector(editAction:)],
                                               [self createBarButtonItemWithNormalImageName:png_Btn_Delete selectedImageName:png_Btn_Delete selector:@selector(deleteAction:)], nil];
}

- (void)initVariables {
    xMargins = 12;
    yMargins = 30;
    yOffset = HEIGHT_FULL_SCREEN - yMargins - 64;
}

- (void)loadCustomView {
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self createTextViewContent];
    [self createLabelTimeAndLocation];
    [self createLabelCurrentPage];
    [self createPagedFlowView];
}

- (void)createTextViewContent {
    if (self.photo.content && self.photo.content.length > 0) {
        
        CGSize size = [self.photo.content sizeWithFont:font_Normal_16 constrainedToSize:CGSizeMake(240, 2000) lineBreakMode:NSLineBreakByCharWrapping];
        CGFloat contentHeight = size.height + 10;//获取自适应文本内容高度
        contentHeight = contentHeight > 108 ? 108 : contentHeight;//content高度不能超过108
        
        yOffset -= contentHeight;
        UITextView *contentView = [[UITextView alloc] initWithFrame:CGRectMake(xMargins, yOffset, WIDTH_FULL_SCREEN - xMargins * 2, contentHeight)];
        contentView.backgroundColor = [UIColor clearColor];
        contentView.font = font_Normal_16;
        contentView.showsHorizontalScrollIndicator = NO;
        contentView.showsVerticalScrollIndicator = NO;
        contentView.textColor = [CommonFunction getGenderColor];
        contentView.text = self.photo.content;
        contentView.editable = NO;
        if (contentHeight < 30) {
            
            contentView.textAlignment = NSTextAlignmentCenter;
            
        } else {
            
            contentView.textAlignment = NSTextAlignmentLeft;
        }
        
        [self.view addSubview:contentView];
    }
}

- (void)createLabelTimeAndLocation {
    NSString *timeAndLocation = [NSString stringWithFormat:str_Photo_Detail_Tips1, self.photo.phototime];
    if (self.photo.location && self.photo.location.length > 0) {
        
        timeAndLocation = [NSString stringWithFormat:str_Photo_Detail_Tips2, timeAndLocation, self.photo.location];
    }
    yOffset -= 30;
    UILabel *labelTimeAndLocation = [[UILabel alloc] initWithFrame:CGRectMake(xMargins, yOffset, WIDTH_FULL_SCREEN - xMargins * 2, 30)];
    labelTimeAndLocation.font = font_Normal_18;
    labelTimeAndLocation.textColor = color_333333;
    labelTimeAndLocation.textAlignment = NSTextAlignmentCenter;
    labelTimeAndLocation.text = timeAndLocation;
    [self.view addSubview:labelTimeAndLocation];
}

- (void)createLabelCurrentPage {
    yOffset -= 30;
    UILabel *labelPage = [[UILabel alloc] initWithFrame:CGRectMake(xMargins, yOffset, WIDTH_FULL_SCREEN - xMargins * 2, 30)];
    labelPage.font = font_Bold_18;
    labelPage.textColor = [CommonFunction getGenderColor];
    labelPage.textAlignment = NSTextAlignmentCenter;
    labelPage.text = [NSString stringWithFormat:@"1 / %ld", (long)self.photo.photoArray.count];
    labelCurrentPage = labelPage;
    [self.view addSubview:labelPage];
}

- (void)createPagedFlowView {
    pageFlowView = [[PagedFlowView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, yOffset)];
    pageFlowView.backgroundColor = color_e9eff1;
    pageFlowView.minimumPageAlpha = 0.7;
    pageFlowView.minimumPageScale = 0.9;
    pageFlowView.delegate = self;
    pageFlowView.dataSource = self;
    [self.view addSubview:pageFlowView];
}

- (void)refreshData {
    self.photo = [PlanCache getPhotoById:self.photo.photoid];
    [self initVariables];
    [self loadCustomView];
}

#pragma mark - action
- (void)editAction:(UIButton *)button {
    AddPhotoViewController *controller = [[AddPhotoViewController alloc] init];
    controller.operationType = Edit;
    controller.photo = self.photo;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)deleteAction:(UIButton *)button {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str_Photo_Delete_Tips
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:str_Cancel
                                          otherButtonTitles:str_OK,
                          nil];
    
    alert.tag = kPhotoDeleteTag;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kPhotoDeleteTag) {
        
        if (buttonIndex == 1) {
            
            BOOL result = [PlanCache deletePhoto:self.photo];
            if (result) {
                
                [self alertToastMessage:str_Delete_Success];
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                
                [self alertButtonMessage:str_Delete_Fail];
            }
        }
    }
}

#pragma mark - PagedFlowView Datasource
- (NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView {
    return self.photo.photoArray.count;
}

- (UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index {
    [flowView dequeueReusableCell]; //必须要调用否则会内存泄漏
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = self.photo.photoArray[index];
    return imageView;
}

#pragma mark - PagedFlowView Delegate
- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView {
    CGFloat width = yOffset * 185.4 / 300;
    return CGSizeMake(width, yOffset);
}

- (void)flowView:(PagedFlowView *)flowView didScrollToPageAtIndex:(NSInteger)index {
    long current = index + 1;
    long total = self.photo.photoArray.count;
    labelCurrentPage.text = [NSString stringWithFormat:@"%ld / %ld", current, total];
}

- (void)flowView:(PagedFlowView *)flowView didTapPageAtIndex:(NSInteger)index {
    FullScreenImageArrayViewController *controller = [[FullScreenImageArrayViewController alloc] init];
    controller.imgArray = self.photo.photoArray;
    controller.defaultIndex = index;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
