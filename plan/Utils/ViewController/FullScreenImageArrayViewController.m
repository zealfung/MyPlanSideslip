//
//  FullScreenImageArrayViewController.m
//  plan
//
//  Created by Fengzy on 15/11/21.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "ImageScrollView.h"
#import "FullScreenImageArrayViewController.h"

NSInteger const kFullScreenImageArrayViewBaseTag = 20151121;

@interface FullScreenImageArrayViewController () <UIScrollViewDelegate> {
    
    UIScrollView *myScrollView;
    NSInteger currentPage;
    NSInteger tmpPage;
    BOOL fullScreen;
}

@end

@implementation FullScreenImageArrayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        UITapGestureRecognizer *oneTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTapAction:)];
        [self.view addGestureRecognizer:oneTapGestureRecognizer];
        
        UITapGestureRecognizer *twoTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoTapAction:)];
        twoTapGestureRecognizer.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:twoTapGestureRecognizer];
        
        [oneTapGestureRecognizer requireGestureRecognizerToFail:twoTapGestureRecognizer];
    }
    
    if (!iOS7_LATER) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        self.wantsFullScreenLayout = YES;
    } else {
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    fullScreen = YES;
    currentPage = -1;
    [[UIApplication sharedApplication] setStatusBarHidden:fullScreen withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:fullScreen animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!myScrollView) {
        
        myScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        myScrollView.backgroundColor = [UIColor clearColor];
        myScrollView.pagingEnabled = YES;
        myScrollView.delegate = self;
        myScrollView.showsVerticalScrollIndicator = NO;
        myScrollView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:myScrollView];
        
        myScrollView.contentSize = CGSizeMake(CGRectGetWidth(myScrollView.frame) * self.imgArray.count, CGRectGetHeight(myScrollView.frame));
        [myScrollView setContentOffset:CGPointMake(self.defaultIndex * myScrollView.frame.size.width, 0) animated:NO];
        [self scrollViewDidScroll:myScrollView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(oneTapAction:) object:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)backAction:(UIButton *)button {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
        (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
        (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        
        return YES;
    }
    return NO;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)viewDidLayoutSubviews {
    tmpPage = currentPage;
    
    CGRect bounds = self.view.bounds;
    myScrollView.frame = bounds;
    
    bounds = myScrollView.bounds;
    
    CGSize contentSize = CGSizeMake(CGRectGetWidth(bounds) * self.imgArray.count, CGRectGetHeight(bounds));
    myScrollView.contentSize = contentSize;
    
    CGPoint contentPoint = CGPointMake(tmpPage * CGRectGetWidth(bounds), 0);
    [myScrollView setContentOffset:contentPoint animated:NO];
    
    for (int index = 0; index < self.imgArray.count; index++) {
        
        ImageScrollView *view = (ImageScrollView *)[myScrollView viewWithTag:kFullScreenImageArrayViewBaseTag + index];
        [view setZoomScale:1 animated:NO];
        view.frame = [self getPhotoViewFrameForIndex:index];
        view.contentSize = view.bounds.size;
        view.imageView.frame = view.bounds;
    }
}

- (CGRect)getPhotoViewFrameForIndex:(NSInteger)index {
    CGRect rect = myScrollView.bounds;
    rect.origin.x = myScrollView.frame.size.width * index;
    
    return rect;
}

- (void)oneTapAction:(UITapGestureRecognizer *)tapGesture {
    fullScreen = !fullScreen;
    
    [[UIApplication sharedApplication] setStatusBarHidden:fullScreen withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:fullScreen animated:NO];
    
    [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(oneTapAction:) object:nil];
    
    if (!fullScreen) {
        
        [self performSelector:@selector(oneTapAction:) withObject:nil afterDelay:5];
        
    }
}

- (void)twoTapAction:(UITapGestureRecognizer *)tapGesture {
    ImageScrollView *imgView = (ImageScrollView *)[myScrollView viewWithTag:currentPage + kFullScreenImageArrayViewBaseTag];
    [imgView autoZoomScale];
}

- (void)loadScrollViewWithPageIndex:(NSInteger)index {
    if (index < 0 || index >= self.imgArray.count) {
        return;
    }
    
    ImageScrollView *imgView = [[ImageScrollView alloc] initWithFrame:[self getPhotoViewFrameForIndex:index]];
    imgView.tag = kFullScreenImageArrayViewBaseTag + index;
    imgView.imageView.contentMode = UIViewContentModeScaleAspectFit;//UIViewContentModeCenter;
    imgView.imageView.image = self.imgArray[index];
    [myScrollView addSubview:imgView];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page != currentPage) {
        
        currentPage = page;
        
        for (NSInteger i = 0; i < self.imgArray.count; i++) {
            
            ImageScrollView *imgView = (ImageScrollView *)[myScrollView viewWithTag:kFullScreenImageArrayViewBaseTag + i];
            if (i != page && i != page - 1 && i != page + 1) {
                
                if (imgView.superview != nil)
                {
                    [imgView removeFromSuperview];
                }
                
            } else {

                if (!imgView) {
                    
                    [self loadScrollViewWithPageIndex:i];
                    
                }
            }
        }
    }
}

@end
