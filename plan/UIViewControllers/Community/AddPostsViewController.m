//
//  AddPostsViewController.m
//  plan
//
//  Created by Fengzy on 15/10/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "AssetHelper.h"
#import "PageScrollView.h"
#import "AddPostsViewController.h"
#import "DoImagePickerController.h"

NSUInteger const imgMax = 2;
NSUInteger const imgPageHeight = 148;
NSUInteger const imgPageWidth = 110;
NSUInteger const kAddPostsViewPhotoStartTag = 20151227;

@interface AddPostsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PageScrollViewDataSource, PageScrollViewDelegate, DoImagePickerControllerDelegate> {
    
    BOOL canAddPhoto;
    CGRect originalFrame;
    NSString *content;
    NSMutableArray *photoArray;
    PageScrollView *pageScrollView;
}

@property (nonatomic, weak) UILabel *tipsLabel;

@end

@implementation AddPostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_Posts_Add;
    [self createRightBarButton];
    
    canAddPhoto = YES;
    photoArray = [NSMutableArray array];
    
    [self loadCustomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [self relocationPage];
}

- (void)createRightBarButton {
    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Save selectedImageName:png_Btn_Save selector:@selector(saveAction:)];
}

- (void)loadCustomView {
    //描述
    self.textViewContent.textColor = color_333333;
    self.textViewContent.text = @"";
    self.textViewContent.inputAccessoryView = [self getInputAccessoryView];

    //照片
    UIImage *addImage = [UIImage imageNamed:png_Btn_AddPhoto];
    [photoArray addObject:addImage];
    
    CGFloat tipsHeight = 30;
    CGFloat photoViewHeight = HEIGHT_FULL_SCREEN / 2;
    CGFloat yEdgeInset = (photoViewHeight - imgPageHeight - tipsHeight - 44) / 2;

    pageScrollView = [[PageScrollView alloc] initWithFrame:CGRectMake(0, yEdgeInset, WIDTH_FULL_SCREEN, imgPageHeight) pageWidth:imgPageWidth pageDistance:10];
    pageScrollView.holdPageCount = 5;
    pageScrollView.dataSource = self;
    pageScrollView.delegate = self;
    [self.viewPhoto addSubview:pageScrollView];
    
    CGFloat labelYOffset = CGRectGetMaxY(pageScrollView.frame);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, labelYOffset, WIDTH_FULL_SCREEN, tipsHeight)];
    label.backgroundColor = [UIColor clearColor];
    label.font = font_Normal_16;
    label.textColor = color_8f8f8f;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = str_Posts_Add_Tips1;
    [self.viewPhoto addSubview:label];
    self.tipsLabel = label;
    
    originalFrame = self.view.frame;
}

#pragma mark - action
- (void)saveAction:(UIButton *)button {
    content = self.textViewContent.text;
    if (content.length == 0 && photoArray.count < 2) {
        [self alertButtonMessage:str_Posts_Add_Tips2];
        return;
    }
    
    [self showHUD];

    //去掉那张新增按钮图
    if (canAddPhoto) {
        [photoArray removeObjectAtIndex:photoArray.count - 1];
    }

//    BOOL result = [PlanCache storePhoto:self.photo];
//    [self hideHUD];
//    if (result) {
//        
//        [self alertToastMessage:str_Save_Success];
//        [self.navigationController popViewControllerAnimated:YES];
//        
//    } else {
//        
//        [self alertButtonMessage:str_Save_Fail];
//    }
}

- (void)relocationPage {
    NSUInteger addIndex = photoArray.count > 1 ? photoArray.count - 2 : photoArray.count - 1;
    [pageScrollView scrollToPage:addIndex animated:YES];
}

- (void)tapAction:(UITapGestureRecognizer *)tapGestureRecognizer {
    NSInteger index = tapGestureRecognizer.view.tag - kAddPostsViewPhotoStartTag;
    
    if (index != pageScrollView.currentPage) {
        
        [pageScrollView scrollToPage:index animated:YES];
    }
    
    if (index == photoArray.count - 1
        && index < imgMax) {
        
        [self addPhoto];
    }
}

- (NSUInteger)numberOfPagesInPageScrollView:(PageScrollView *)pageScrollView {
    return photoArray.count;
}

- (UIView *)pageScrollView:(PageScrollView *)pageScrollView cellForPageIndex:(NSUInteger)index {
    UIImage *photo = photoArray[index];

    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.userInteractionEnabled = YES;
    imageView.tag = kAddPostsViewPhotoStartTag + index;
    imageView.image = photo;
    imageView.backgroundColor = [UIColor clearColor];
    if (canAddPhoto && (index == photoArray.count - 1)) {
        
        imageView.contentMode = UIViewContentModeScaleToFill;
        
    } else {
        
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
    }
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [imageView addGestureRecognizer:tapGestureRecognizer];
    
    if (canAddPhoto && index != (photoArray.count - 1)) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.backgroundColor = color_ff0000_06;
        btn.frame = CGRectMake((imgPageWidth - 30) / 2, imgPageHeight - 30 - 5, 30, 30);
        btn.layer.cornerRadius = 15;
        btn.tag = index;
        [btn setBackgroundImage:[UIImage imageNamed:png_Btn_Photo_Delete] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:btn];

    } else if (!canAddPhoto) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.backgroundColor = color_ff0000_06;
        btn.frame = CGRectMake((imgPageWidth - 30) / 2, imgPageHeight - 30 - 5, 30, 30);
        btn.layer.cornerRadius = 15;
        btn.tag = index;
        [btn setBackgroundImage:[UIImage imageNamed:png_Btn_Photo_Delete] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:btn];
    }
    return imageView;
}

- (void)pageScrollView:(PageScrollView *)pageScrollView didScrollToPage:(NSInteger)pageNumber {
    if (photoArray.count == 1) {
        
        self.tipsLabel.text = str_Posts_Add_Tips1;
        
    } else if (photoArray.count > 1) {
    
        long selectedCount = canAddPhoto ? photoArray.count - 1 : photoArray.count;
        long canSelectCount = imgMax - selectedCount;
        self.tipsLabel.text = [NSString stringWithFormat:str_Photo_Add_Tips6, selectedCount, canSelectCount];
    }
}

- (void)addPhoto {
    //从相册选择
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        DoImagePickerController *cont = [[DoImagePickerController alloc] initWithNibName:@"DoImagePickerController" bundle:nil];
        cont.delegate = self;
        cont.nResultType = DO_PICKER_RESULT_UIIMAGE;
        cont.nMaxCount = imgMax + 1 - photoArray.count;
//        {
//            cont.nMaxCount = DO_NO_LIMIT_SELECT;
//            cont.nResultType = DO_PICKER_RESULT_ASSET;  // if you want to get lots photos, you'd better use this mode for memory!!!
//        }
        cont.nColumnCount = 4;
        
        [self presentViewController:cont animated:YES completion:nil];
        
    } else {
        
        [self alertButtonMessage:str_Common_Tips1];
    }
}

- (void)deletePhoto:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger index = btn.tag;
    [photoArray removeObjectAtIndex:index];
    
    UIImage *addImage = [UIImage imageNamed:png_Btn_AddPhoto];
    if (!canAddPhoto) {
        photoArray[imgMax - 1] = addImage;
        canAddPhoto = YES;
    } else {
        NSInteger count = photoArray.count;
        photoArray[count - 1] = addImage;
    }
    
    [pageScrollView reloadData];
    [self relocationPage];
}

#pragma mark - DoImagePickerControllerDelegate
- (void)didCancelDoImagePickerController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectPhotosFromDoImagePickerController:(DoImagePickerController *)picker result:(NSArray *)aSelected {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (picker.nResultType == DO_PICKER_RESULT_UIIMAGE) {
        for (int i = 0; i < MIN(imgMax, aSelected.count); i++) {
            [self addImageToPhotoArray:aSelected[i]];
        }
    } else if (picker.nResultType == DO_PICKER_RESULT_ASSET) {
        for (int i = 0; i < MIN(imgMax, aSelected.count); i++) {
            UIImage *image = [ASSETHELPER getImageFromAsset:aSelected[i] type:ASSET_PHOTO_SCREEN_SIZE];
            [self addImageToPhotoArray:image];
        }
        [ASSETHELPER clearData];
    }
    [pageScrollView reloadData];
}

- (void)addImageToPhotoArray:(UIImage *)image {
    UIImage *img = [CommonFunction compressImage:image];
    if (photoArray.count < imgMax) {
        [photoArray insertObject:img atIndex:photoArray.count - 1];
    } else {
        photoArray[imgMax - 1] = img;
        canAddPhoto = NO;
    }
}

@end
