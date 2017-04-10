//
//  AddPhotoViewController.m
//  plan
//
//  Created by Fengzy on 15/10/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "AssetHelper.h"
#import "PageScrollView.h"
#import <BmobSDK/BmobACL.h>
#import <BmobSDK/BmobFile.h>
#import <BmobSDK/BmobObjectsBatch.h>
#import "AddPhotoViewController.h"
#import "DoImagePickerController.h"

NSUInteger const photoMax = 9;
NSUInteger const pageHeight = 148;
NSUInteger const pageWidth = 110;

@interface AddPhotoViewController () <UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PageScrollViewDataSource, PageScrollViewDelegate, DoImagePickerControllerDelegate>

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic, assign) PageScrollView *pageScrollView;
@property (nonatomic, assign) UILabel *tipsLabel;
@property (nonatomic, assign) BOOL canAddPhoto;
@property (nonatomic, assign) NSInteger photoUploadCount;

@end

@implementation AddPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.operationType == Add)
    {
        self.title = STRViewTips22;
    }
    else
    {
        self.title = STRViewTips23;
    }
    
    self.canAddPhoto = YES;
    self.photoArray = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [self customRightButtonWithImage:[UIImage imageNamed:png_Btn_Save] action:^(UIButton *sender) {
        [weakSelf saveAction:sender];
    }];

    [self loadCustomView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self relocationPage];
}

- (void)loadCustomView
{
    self.labelTime.text = STRViewTips34;
    self.labelLocation.text = STRViewTips33;
    //描述
    if (self.operationType == Edit
        && self.photo.content
        && self.photo.content.length)
    {
        self.textViewContent.textColor = color_333333;
        self.textViewContent.text = self.photo.content;
    }
    else
    {
        self.textViewContent.textColor = color_8f8f8f;
        self.textViewContent.text = STRViewTips24;
    }
    self.textViewContent.inputAccessoryView = [self getInputAccessoryView];
    self.textViewContent.delegate = self;
    //时间
    if (self.photo.phototime
        && self.photo.phototime.length > 0)
    {
        self.textFieldTime.text = self.photo.phototime;
    }
    else
    {
        self.textFieldTime.text = [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
    }
    [self.textFieldTime addTarget:self action:@selector(setPhotoTime) forControlEvents:UIControlEventTouchDown];
    self.textFieldTime.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    self.textFieldTime.delegate = self;
    self.textFieldTime.tag = 0;
    //地点
    if (self.operationType == Edit
        && self.photo.location
        && self.photo.location.length > 0)
    {
        self.textFieldLocation.text = self.photo.location;
    }
    self.textFieldLocation.inputAccessoryView = [self getInputAccessoryView];
    self.textFieldLocation.placeholder = STRViewTips30;
    self.textFieldLocation.delegate = self;
    self.textFieldLocation.tag = 1;
    //照片
    NSData *addImage = UIImageJPEGRepresentation([UIImage imageNamed:png_Btn_AddPhoto], 1);
    if (self.operationType == Edit)
    {
        self.photoArray = [NSMutableArray arrayWithArray:self.photo.photoArray];
        
        if (self.photoArray.count < photoMax)
        {
            [self.photoArray addObject:addImage];
        }
    }
    else
    {
        [self.photoArray addObject:addImage];
    }
    
    CGFloat tipsHeight = 30;
    CGFloat photoViewHeight = HEIGHT_FULL_SCREEN / 2;
    CGFloat yEdgeInset = (photoViewHeight - pageHeight - tipsHeight - 44) / 2;

    PageScrollView *pageScrollView = [[PageScrollView alloc] initWithFrame:CGRectMake(0, yEdgeInset, WIDTH_FULL_SCREEN, pageHeight) pageWidth:pageWidth pageDistance:10];
    pageScrollView.holdPageCount = 5;
    pageScrollView.dataSource = self;
    pageScrollView.delegate = self;
    [self.viewPhoto addSubview:pageScrollView];
    self.pageScrollView = pageScrollView;
    
    CGFloat labelYOffset = CGRectGetMaxY(pageScrollView.frame);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, labelYOffset, WIDTH_FULL_SCREEN, tipsHeight)];
    label.backgroundColor = [UIColor clearColor];
    label.font = font_Normal_16;
    label.textColor = color_8f8f8f;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = STRViewTips27;
    [self.viewPhoto addSubview:label];
    self.tipsLabel = label;
}

- (void)setPhotoTime
{
    [self.textFieldTime resignFirstResponder];
    
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
                                                     formatter:STRDateFormatterType4];
        
        picker.minimumDate = minDate;
        [pickerView addSubview:picker];
        self.datePicker = picker;
        
        NSString *photoDate = self.textFieldTime.text;
        
        if (photoDate)
        {
            NSDate *date = [CommonFunction NSStringDateToNSDate:photoDate formatter:STRDateFormatterType4];
            if (date)
            {
                [self.datePicker setDate:date animated:YES];
            }
        }
        else
        {
            NSDate *defaultDate = [CommonFunction NSStringDateToNSDate:[NSString stringWithFormat:@"%zd-%zd-%zd",
                                                                        defaultComponents.year,
                                                                        defaultComponents.month,
                                                                        defaultComponents.day]
                                                             formatter:STRDateFormatterType4];
            self.datePicker.date = defaultDate;
        }
    }
    pickerView.tag = kDatePickerBgViewTag;
    [self.view addSubview:pickerView];
}

- (void)onPickerCertainBtn
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:STRDateFormatterType4];
    NSString *photoTime = [dateFormatter stringFromDate:self.datePicker.date];
    self.textFieldTime.text = photoTime;
    UIView *pickerView = [self.view viewWithTag:kDatePickerBgViewTag];
    [pickerView removeFromSuperview];
}

- (void)onPickerCancelBtn
{
    UIView *pickerView = [self.view viewWithTag:kDatePickerBgViewTag];
    [pickerView removeFromSuperview];
}

#pragma mark - action
- (void)saveAction:(UIButton *)button
{
    if (self.photoArray.count < 2)
    {
        [self alertButtonMessage:STRViewTips28];
        return;
    }
    [self.view endEditing:YES];
    [self showHUD];
    
    NSString *timeNow = [CommonFunction getTimeNowString];
    NSString *photoid = [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType5];
    
    if (self.operationType == Add)
    {
        self.photo = [[Photo alloc] init];
        self.photo.photoid = photoid;
        self.photo.createtime = timeNow;
        self.photo.updatetime = timeNow;
        self.photo.photoURLArray = [NSMutableArray arrayWithCapacity:9];
        for (NSInteger i = 0; i < 9; i++)
        {
            self.photo.photoURLArray[i] = @"";
        }
    }
    else
    {
        self.photo.updatetime = timeNow;
    }
    if (![self.textViewContent.text isEqualToString:STRViewTips24])
    {
        self.photo.content = self.textViewContent.text;
    }
    self.photo.phototime = self.textFieldTime.text;
    if (self.textFieldLocation.text.length > 0)
    {
        self.photo.location = self.textFieldLocation.text;
    }
    //去掉那张新增按钮图
    if (self.canAddPhoto)
    {
        [self.photoArray removeObjectAtIndex:self.photoArray.count - 1];
    }
    self.photo.photoArray = self.photoArray;
    
    [self submit:self.photo];
}

- (void)relocationPage
{
    NSUInteger addIndex = self.photoArray.count > 1 ? self.photoArray.count - 2 : self.photoArray.count - 1;
    [self.pageScrollView scrollToPage:addIndex animated:YES];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSString *text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([text isEqualToString:STRViewTips24])
    {
        textView.text = @"";
        textView.textColor = color_333333;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSString *text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0)
    {
        textView.text = STRViewTips24;
        textView.textColor = color_8f8f8f;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == 0)
    {
        [self.textViewContent resignFirstResponder];
        [self.textFieldLocation resignFirstResponder];
        return NO;
    }
    else if (textField.tag == 1)
    {
        if (iPhone4 || iPhone5)
        {
            self.viewTimeAndLocationBottom.constant = 50;
        }
        return YES;
    }
    else
    {
        return YES;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.viewTimeAndLocationBottom.constant = 0;
    return YES;
}

- (void)tapAction:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSInteger index = tapGestureRecognizer.view.tag - (kDatePickerBgViewTag + 1);
    
    if (index != self.pageScrollView.currentPage)
    {
        [self.pageScrollView scrollToPage:index animated:YES];
    }
    
    if (index == self.photoArray.count - 1
        && index < photoMax)
    {
        [self addPhoto];
    }
}

- (NSUInteger)numberOfPagesInPageScrollView:(PageScrollView *)pageScrollView
{
    return self.photoArray.count;
}

- (UIView *)pageScrollView:(PageScrollView *)pageScrollView cellForPageIndex:(NSUInteger)index
{
    if (index >= self.photoArray.count)
        return nil;
    
    UIImage *photo = [UIImage imageWithData:self.photoArray[index]];

    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.userInteractionEnabled = YES;
    imageView.tag = (kDatePickerBgViewTag + 1) + index;
    imageView.image = photo;
    imageView.backgroundColor = [UIColor clearColor];
    if (self.canAddPhoto && (index == self.photoArray.count - 1))
    {
        imageView.contentMode = UIViewContentModeScaleToFill;
    }
    else
    {
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
    }
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [imageView addGestureRecognizer:tapGestureRecognizer];
    
    if (self.canAddPhoto && index != (self.photoArray.count - 1))
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.backgroundColor = color_ff0000_06;
        btn.frame = CGRectMake((pageWidth - 30) / 2, pageHeight - 30 - 5, 30, 30);
        btn.layer.cornerRadius = 15;
        btn.tag = index;
        [btn setBackgroundImage:[UIImage imageNamed:png_Btn_Photo_Delete] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:btn];
    }
    else if (!self.canAddPhoto)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.backgroundColor = color_ff0000_06;
        btn.frame = CGRectMake((pageWidth - 30) / 2, pageHeight - 30 - 5, 30, 30);
        btn.layer.cornerRadius = 15;
        btn.tag = index;
        [btn setBackgroundImage:[UIImage imageNamed:png_Btn_Photo_Delete] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:btn];
    }
    return imageView;
}

- (void)pageScrollView:(PageScrollView *)pageScrollView didScrollToPage:(NSInteger)pageNumber
{
    if (self.photoArray.count == 1)
    {
        self.tipsLabel.text = STRViewTips27;
    }
    else if (self.photoArray.count)
    {
        long selectedCount = self.canAddPhoto ? self.photoArray.count - 1 : self.photoArray.count;
        long canSelectCount = photoMax - selectedCount;
        self.tipsLabel.text = [NSString stringWithFormat:STRViewTips29, selectedCount, canSelectCount];
    }
}

- (void)addPhoto
{
    if (self.operationType == Edit)
    {
        self.photo.photoURLArray = [NSMutableArray arrayWithCapacity:9];
        for (NSInteger i = 0; i < 9; i++)
        {
            self.photo.photoURLArray[i] = @"";
        }
    }
    //从相册选择
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        DoImagePickerController *picker = [[DoImagePickerController alloc] initWithNibName:@"DoImagePickerController" bundle:nil];
        picker.delegate = self;
        picker.nResultType = DO_PICKER_RESULT_UIIMAGE;
        picker.nMaxCount = photoMax + 1 - self.photoArray.count;
//        {
//            cont.nMaxCount = DO_NO_LIMIT_SELECT;
//            cont.nResultType = DO_PICKER_RESULT_ASSET;  // if you want to get lots photos, you'd better use this mode for memory!!!
//        }
        picker.nColumnCount = 4;
        
        dispatch_async(dispatch_get_main_queue(), ^{//如果不这样写，在iPad上会访问不了相册
            [self presentViewController:picker animated:YES completion:nil];
        });
    }
    else
    {
        [self alertButtonMessage:STRCommonTip1];
    }
}

- (void)deletePhoto:(id)sender
{
    if (self.operationType == Edit)
    {
        self.photo.photoURLArray = [NSMutableArray arrayWithCapacity:9];
        for (NSInteger i = 0; i < 9; i++)
        {
            self.photo.photoURLArray[i] = @"";
        }
    }
    UIButton *btn = (UIButton *)sender;
    NSInteger index = btn.tag;
    [self.photoArray removeObjectAtIndex:index];
    
    NSData *addImage = UIImageJPEGRepresentation([UIImage imageNamed:png_Btn_AddPhoto], 1);
    if (!self.canAddPhoto)
    {
        self.photoArray[photoMax - 1] = addImage;
        self.canAddPhoto = YES;
    }
    else
    {
        NSInteger count = self.photoArray.count;
        self.photoArray[count - 1] = addImage;
    }
    
    [self.pageScrollView reloadData];
    [self relocationPage];
}

#pragma mark - DoImagePickerControllerDelegate
- (void)didCancelDoImagePickerController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectPhotosFromDoImagePickerController:(DoImagePickerController *)picker result:(NSArray *)aSelected
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (picker.nResultType == DO_PICKER_RESULT_UIIMAGE)
    {
        for (int i = 0; i < MIN(photoMax, aSelected.count); i++)
        {
            [self addImageToPhotoArray:aSelected[i]];
        }
    }
    else if (picker.nResultType == DO_PICKER_RESULT_ASSET)
    {
        for (int i = 0; i < MIN(photoMax, aSelected.count); i++)
        {
            UIImage *image = [ASSETHELPER getImageFromAsset:aSelected[i] type:ASSET_PHOTO_SCREEN_SIZE];
            [self addImageToPhotoArray:image];
        }
        [ASSETHELPER clearData];
    }
    [self.pageScrollView reloadData];
}

- (void)addImageToPhotoArray:(UIImage *)image
{
    NSData *imgData = [CommonFunction compressImage:image];

    if (!imgData) return;
    
    if (self.photoArray.count < photoMax)
    {
        [self.photoArray insertObject:imgData atIndex:self.photoArray.count - 1];
    }
    else
    {
        self.photoArray[photoMax - 1] = imgData;
        self.canAddPhoto = NO;
    }
}

- (void)submit:(Photo *)photo
{
    BmobUser *user = [BmobUser currentUser];
    if (!user)
    {
        [self alertToastMessage:@"未登录"];
        return;
    }
    [self showHUD];
    BmobObject *newPhoto = [BmobObject objectWithClassName:@"Photo"];
    NSDictionary *dic = @{@"userObjectId":user.objectId,
                          @"photoId":photo.photoid,
                          @"content":photo.content,
                          @"location":photo.location,
                          @"createdTime":photo.createtime,
                          @"photoTime":photo.phototime,
                          @"updatedTime":@"2015-09-09 09:09:09",
                          @"isDeleted":@"0"};
    [newPhoto saveAllWithDictionary:dic];
    __weak typeof(self) weakSelf = self;
    BmobACL *acl = [BmobACL ACL];
    [acl setReadAccessForUser:user];//设置只有当前用户可读
    [acl setWriteAccessForUser:user];//设置只有当前用户可写
    newPhoto.ACL = acl;
    [newPhoto saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
     {
         if (isSuccessful)
         {
             weakSelf.photoUploadCount = 0;
             for (NSInteger i = 0; i < photo.photoArray.count; i++)
             {
                 [weakSelf uploadPhoto:photo index:i obj:newPhoto];
             }
         }
         else
         {
             NSLog(@"新增岁月影像：%@",error);
             [weakSelf hideHUD];
             [weakSelf alertButtonMessage:STRCommonTip14];
         }
     }];
}

- (void)uploadPhoto:(Photo *)photo index:(NSInteger)index obj:(BmobObject *)obj
{
    NSData *imgData = photo.photoArray[index];
    NSString *urlName = [NSString stringWithFormat:@"photo%ldURL", (long)(index+1)];
    if (imgData)
    {
        __weak typeof(self) weakSelf = self;
        BmobFile *file = [[BmobFile alloc] initWithFileName:@"imgPhoto.png" withFileData:imgData];
        [file saveInBackground:^(BOOL isSuccessful, NSError *error)
         {
             weakSelf.photoUploadCount ++;
             if (isSuccessful)
             {
                 [obj setObject:file.url forKey:urlName];
                 [obj setObject:photo.updatetime forKey:@"updatedTime"];
                 [obj updateInBackground];
             }
             if (weakSelf.photoUploadCount >= photo.photoArray.count)
             {
                 [weakSelf hideHUD];
                 [NotificationCenter postNotificationName:NTFPhotoSave object:nil];
                 [weakSelf alertToastMessage:STRCommonTip13];
                 [weakSelf.navigationController popViewControllerAnimated:YES];
             }
         }
         withProgressBlock:^(CGFloat progress)
         {
             //上传进度
             NSLog(@"上传影像图片进度： %f",progress);
         }];
    }
}

@end
