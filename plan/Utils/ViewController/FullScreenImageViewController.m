//
//  FullScreenImageViewController.m
//  plan
//
//  Created by Fengzy on 15/10/8.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "FullScreenImageViewController.h"

@interface FullScreenImageViewController () <UIGestureRecognizerDelegate> {
    
    CGRect oldFrame;    //保存图片原来的大小
    CGRect largeFrame;  //确定图片放大最大的程度
    UIImageView *imageView;
    
}

@end

@implementation FullScreenImageViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = self.viewControllerTitle;
    
    [self loadCustomView];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (void)showLeftBarButtonView {
    
    NSMutableArray *leftBarButtonItems = [NSMutableArray array];
    UIImage *imgClose = [UIImage imageNamed:png_Btn_Delete];
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.frame = CGRectMake(0, 0, imgClose.size.width + 20, imgClose.size.height);
    [btnClose setAllImage:imgClose];
    [btnClose addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemDelete = [[UIBarButtonItem alloc] initWithCustomView:btnClose];
    [leftBarButtonItems addObject:itemDelete];
    
    self.leftBarButtonItems = leftBarButtonItems;
}

- (void)closeAction:(UIButton *)button {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)loadCustomView {
    
    imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = self.image;
    [imageView setUserInteractionEnabled:YES];
    [imageView setMultipleTouchEnabled:YES];
    [self addGestureRecognizerToView:imageView];
    
    oldFrame = imageView.frame;
    largeFrame = CGRectMake(0 - WIDTH_FULL_SCREEN, 0 - HEIGHT_FULL_SCREEN, 3 * oldFrame.size.width, 3 * oldFrame.size.height);
    
    [self.view addSubview:imageView];
    
}

// 添加所有的手势
- (void) addGestureRecognizerToView:(UIView *)view {
    // 旋转手势
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    [view addGestureRecognizer:rotationGestureRecognizer];
    
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [view addGestureRecognizer:panGestureRecognizer];
    
    //单指双击
    UITapGestureRecognizer *singleFingerTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    singleFingerTwo.numberOfTouchesRequired = 1;
    singleFingerTwo.numberOfTapsRequired = 2;
    singleFingerTwo.delegate = self;
    [view addGestureRecognizer:singleFingerTwo];
    
}

// 处理旋转手势
- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer {
    
    UIView *view = rotationGestureRecognizer.view;
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan || rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        view.transform = CGAffineTransformRotate(view.transform, rotationGestureRecognizer.rotation);
        [rotationGestureRecognizer setRotation:0];
    }
    
}

// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer {

    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        if (imageView.frame.size.width < oldFrame.size.width) {
            
            imageView.frame = oldFrame;
            //让图片无法缩得比原图小
        }
        if (imageView.frame.size.width > 3 * oldFrame.size.width) {
            
            imageView.frame = largeFrame;
            
        }
        pinchGestureRecognizer.scale = 1;
        
    }
    
}

// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        
    }
}

//处理单指事件
- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender {
    
    if(sender.numberOfTapsRequired == 2) {
        
        CGRect frame = imageView.frame;
        if (frame.size.width == oldFrame.size.width) {
            
            frame.size.width = frame.size.width * 3 / 2;
            frame.size.width = frame.size.height * 3 / 2;
            imageView.frame = frame;
            
        } else {
            
            imageView.frame = oldFrame;
            
        }
    }
}

@end
