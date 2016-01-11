//
//  AddPostsViewController.m
//  plan
//
//  Created by Fengzy on 15/10/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "BmobFile.h"
#import "BmobUser.h"
#import "BmobQuery.h"
#import "AssetHelper.h"
#import "PageScrollView.h"
#import <BmobSDK/BmobProFile.h>
#import "AddPostsViewController.h"
#import "DoImagePickerController.h"

NSUInteger const imgMax = 2;
NSUInteger const imgPageHeight = 148;
NSUInteger const imgPageWidth = 110;
NSUInteger const kAddPostsViewPhotoStartTag = 20151227;

@interface AddPostsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PageScrollViewDataSource, PageScrollViewDelegate, DoImagePickerControllerDelegate> {
    
    BOOL isSending;
    BOOL canAddPhoto;
    CGRect originalFrame;
    NSString *content;
    UILabel *tipsLabel;
    NSMutableArray *photoArray;
    NSMutableArray *uploadPhotoArray;
    PageScrollView *pageScrollView;
    NSInteger uploadCount;
    CGFloat uploadProgress1;
    CGFloat uploadProgress2;
}

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

    self.textViewContent.textColor = color_333333;
    self.textViewContent.text = @"";
    self.textViewContent.inputAccessoryView = [self getInputAccessoryView];

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
    tipsLabel = label;
    
    originalFrame = self.view.frame;
}

#pragma mark - action
- (void)saveAction:(UIButton *)button {
    if (isSending) return;
    
    [self.view endEditing:YES];
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
    
    __weak typeof(self) weakSelf = self;

    BmobObject *newPosts = [BmobObject objectWithClassName:@"Posts"];
    [newPosts setObject:content forKey:@"content"];
    [newPosts setObject:[NSDate date] forKey:@"updatedTime"];
    [newPosts setObject:@"0" forKey:@"isDeleted"];
    [newPosts setObject:@"0" forKey:@"isTop"];
    [newPosts setObject:@"0" forKey:@"isHighlight"];

    //设置帖子关联的作者
    [Config shareInstance].settings = [PlanCache getPersonalSettings];
    BmobObject *author = [BmobObject objectWithoutDatatWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId];
    [newPosts setObject:author forKey:@"author"];
    isSending = YES;
    //异步保存
    [newPosts saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        isSending = NO;
        if (isSuccessful) {
            if (photoArray.count == 0) {
                [NotificationCenter postNotificationName:Notify_Posts_New object:nil];
                [weakSelf alertToastMessage:str_Send_Success];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        } else {
            [weakSelf alertButtonMessage:str_Send_Fail];
            NSLog(@"%@",error);
        }
    }];
    if (photoArray.count > 0) {
        uploadCount = 0;
        uploadPhotoArray = [NSMutableArray array];
        for (NSInteger i = 0; i < photoArray.count; i++) {
            [uploadPhotoArray addObject:@""];
            [self uploadImage:photoArray[i] index:i obj:newPosts];
        }
    } else {
        [self hideHUD];
    }
}

- (void)uploadImage:(UIImage *)image index:(NSInteger)index obj:(BmobObject *)obj {
    if (index == 0) {
        uploadProgress1 = 0;
    } else {
        uploadProgress2 = 0;
    }
    __weak typeof(self) weakSelf = self;
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
    [BmobProFile uploadFileWithFilename:@"imgPhoto.png" fileData:imgData block:^(BOOL isSuccessful, NSError *error, NSString *filename, NSString *url, BmobFile *bmobFile) {
        if (isSuccessful) {
            
            uploadPhotoArray[index] = bmobFile.url;
            uploadCount += 1;
            if (uploadCount == photoArray.count) {
                [obj addObjectsFromArray:uploadPhotoArray forKey:@"imgURLArray"];
                [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    [weakSelf hideHUD];
                    [NotificationCenter postNotificationName:Notify_Posts_New object:nil];
                    [weakSelf alertToastMessage:str_Send_Success];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
            }
        } else if (error) {
            [weakSelf hideHUD];
            [weakSelf alertButtonMessage:str_Send_Fail];
        }
    } progress:^(CGFloat progress) {
        CGFloat smallProgress = progress;
        if (photoArray.count > 1) {
            if (index == 0) {
                uploadProgress1 = progress;
            } else {
                uploadProgress2 = progress;
            }
            smallProgress = uploadProgress1 > uploadProgress2 ? uploadProgress2 : uploadProgress1;
        }
        weakSelf.hudText = [NSString stringWithFormat:@"%0.0f%%", smallProgress * 100];
        //上传进度
        NSLog(@"上传帖子图片进度： %f",progress);
    }];
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
        tipsLabel.text = str_Posts_Add_Tips1;
    } else if (photoArray.count > 1) {
        long selectedCount = canAddPhoto ? photoArray.count - 1 : photoArray.count;
        long canSelectCount = imgMax - selectedCount;
        tipsLabel.text = [NSString stringWithFormat:str_Photo_Add_Tips6, selectedCount, canSelectCount];
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
    
    if (!img) return;
    
    if (photoArray.count < imgMax) {
        [photoArray insertObject:img atIndex:photoArray.count - 1];
    } else {
        photoArray[imgMax - 1] = img;
        canAddPhoto = NO;
    }
}

@end
