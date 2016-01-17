//
//  MessagesDetailViewController.m
//  plan
//
//  Created by Fengzy on 15/12/10.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "ShareCenter.h"
#import "SDPhotoBrowser.h"
#import "SDWebImageManager.h"
#import "WebViewController.h"
#import "MessagesDetailViewController.h"

@interface MessagesDetailViewController () <SDPhotoBrowserDelegate> {
    NSMutableArray *imgArray;
    NSInteger postImgDownloadCount;
    UIScrollView *scrollView;
}

@end

@implementation MessagesDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_ViewTitle_13;
    if ([self.message.canShare isEqualToString:@"1"]) {
        [self createNavBarButton];
    }
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
        
        if (self.message.imgURLArray && self.message.imgURLArray.count > 0) {
            [self showHUD];
            imgArray = [NSMutableArray array];
            postImgDownloadCount = 0;
            for (NSInteger i=0; i < self.message.imgURLArray.count; i++) {
                if ([self.message.imgURLArray[i] isKindOfClass:[NSString class]]) {
                    [self downloadImages:self.message.imgURLArray[i] index:i];
                }
            }
        } else {
            [self loadCustomView];
        }
    }
}

- (void)createNavBarButton {
    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Share_circle selectedImageName:png_Btn_Share_circle selector:@selector(shareAction)];
}

- (void)shareAction {
    [ShareCenter showShareActionSheet:self.view title:str_Share_Tips3 content:self.message.content shareUrl:self.message.detailURL sharedImageURL:@""];
}

- (void)loadCustomView {
    [self hideHUD];
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, WIDTH_FULL_SCREEN - 24, 50)];
    labelTitle.textColor = color_333333;
    labelTitle.font = font_Normal_18;
    labelTitle.numberOfLines = 2;
    labelTitle.text = self.message.title;
    [scrollView addSubview:labelTitle];
    
    UILabel *labelTime = [[UILabel alloc] initWithFrame:CGRectMake(12, 60, WIDTH_FULL_SCREEN - 24, 20)];
    labelTime.textColor = color_666666;
    labelTime.font = font_Normal_13;
    labelTime.text = self.message.createTime;
    [scrollView addSubview:labelTime];

    NSString *content = self.message.content;
    CGFloat yOffset = 80;
    if (content && content.length > 0) {
        UITextView *contentView = [[UITextView alloc] initWithFrame:CGRectMake(5, yOffset, WIDTH_FULL_SCREEN - 10, 240)];
        contentView.textColor = color_333333;
        contentView.font = font_Normal_16;
        contentView.editable = NO;
        contentView.scrollEnabled = NO;
        contentView.text = content;
        [contentView sizeToFit];
        [scrollView addSubview:contentView];
        
        yOffset += contentView.frame.size.height + 20;
    }
    
    if (imgArray && imgArray.count > 0) {
        for (NSInteger i=0; i < imgArray.count; i++) {
            UIImage *image = imgArray[i];
            CGFloat kWidth = WIDTH_FULL_SCREEN - 10;
            CGFloat kHeight = WIDTH_FULL_SCREEN * image.size.height / image.size.width;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, yOffset, kWidth, kHeight)];
            imageView.backgroundColor = [UIColor clearColor];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.tag = i;
            imageView.image = image;
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedImageAction:)];
            [imageView addGestureRecognizer:singleTap];
            
            [scrollView addSubview:imageView];
            yOffset += kHeight + 3;
        }
    }

    if (self.message.detailURL && self.message.detailURL.length > 0) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(12, yOffset, 150, 30);
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = font_Normal_16;
        [button setAllTitle:str_Messages_Tips3];
        [button setAllTitleColor:[CommonFunction getGenderColor]];
        [button addTarget:self action:@selector(detailAction:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button];
    }
    yOffset += 150;
    
    scrollView.contentSize = CGSizeMake(WIDTH_FULL_SCREEN, yOffset);
}

- (void)downloadImages:(NSString *)imgURL index:(NSInteger)index {
    UIImage *imgDefault = [UIImage imageNamed:png_ImageDefault_Rectangle];
    [imgArray addObject:imgDefault];
    NSURL *URL = [NSURL URLWithString:imgURL];
    __weak typeof(self) weakSelf = self;
    [[SDWebImageManager sharedManager] downloadImageWithURL:URL options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
        postImgDownloadCount ++;
        
        if (!error && image) {
            imgArray[index] = image;
        }
        
        if (postImgDownloadCount == self.message.imgURLArray.count) {
            [weakSelf loadCustomView];
        }
    }];
}

#pragma mark - photobrowser代理方法
// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    return imgArray[index];
}

// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index {
    NSString *urlStr = self.message.imgURLArray[index];
    return [NSURL URLWithString:urlStr];
}

- (void)clickedImageAction:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    UIImageView *imgView = (UIImageView *)tap.view;
    
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = scrollView;
    browser.imageCount = self.message.imgURLArray.count; //图片总数
    browser.currentImageIndex = imgView.tag;
    browser.delegate = self;
    [browser show];
}

- (void)detailAction:(UIButton *)button {
    WebViewController *controller = [[WebViewController alloc] init];
    controller.url = self.message.detailURL;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
