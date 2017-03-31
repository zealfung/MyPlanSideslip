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

@interface FullScreenImageArrayViewController () <UIScrollViewDelegate>
//{
//    
//    UIScrollView *myScrollView;
//    NSInteger currentPage;
//    NSInteger tmpPage;
//    BOOL fullScreen;
//}
@property(nonatomic, strong) UIScrollView *myScrollView;
@property(nonatomic, assign) NSInteger currentPage;
@property(nonatomic, assign) NSInteger tmpPage;
@property(nonatomic, assign) BOOL fullScreen;

@end

@implementation FullScreenImageArrayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    {
        UITapGestureRecognizer *oneTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTapAction:)];
        [self.view addGestureRecognizer:oneTapGestureRecognizer];
        
        UITapGestureRecognizer *twoTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoTapAction:)];
        twoTapGestureRecognizer.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:twoTapGestureRecognizer];
        
        [oneTapGestureRecognizer requireGestureRecognizerToFail:twoTapGestureRecognizer];
    }
    
    if (!(iOS7_LATER))
    {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
    else
    {
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.fullScreen = YES;
    self.currentPage = -1;
    [[UIApplication sharedApplication] setStatusBarHidden:self.fullScreen withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:self.fullScreen animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.myScrollView)
    {
        self.myScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        self.myScrollView.backgroundColor = [UIColor clearColor];
        self.myScrollView.pagingEnabled = YES;
        self.myScrollView.delegate = self;
        self.myScrollView.showsVerticalScrollIndicator = NO;
        self.myScrollView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:self.myScrollView];
        
        self.myScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.myScrollView.frame) * self.imgURLArray.count, CGRectGetHeight(self.myScrollView.frame));
        [self.myScrollView setContentOffset:CGPointMake(self.defaultIndex * self.myScrollView.frame.size.width, 0) animated:NO];
        [self scrollViewDidScroll:self.myScrollView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(oneTapAction:) object:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
        (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
        (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight))
    {
        return YES;
    }
    return NO;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)viewDidLayoutSubviews
{
    self.tmpPage = self.currentPage;
    
    CGRect bounds = self.view.bounds;
    self.myScrollView.frame = bounds;
    
    bounds = self.myScrollView.bounds;
    
    CGSize contentSize = CGSizeMake(CGRectGetWidth(bounds) * self.imgURLArray.count, CGRectGetHeight(bounds));
    self.myScrollView.contentSize = contentSize;
    
    CGPoint contentPoint = CGPointMake(self.tmpPage * CGRectGetWidth(bounds), 0);
    [self.myScrollView setContentOffset:contentPoint animated:NO];
    
    for (int index = 0; index < self.imgURLArray.count; index++)
    {
        ImageScrollView *view = (ImageScrollView *)[self.myScrollView viewWithTag:kFullScreenImageArrayViewBaseTag + index];
        [view setZoomScale:1 animated:NO];
        view.frame = [self getPhotoViewFrameForIndex:index];
        view.contentSize = view.bounds.size;
        view.imageView.frame = view.bounds;
    }
}

- (CGRect)getPhotoViewFrameForIndex:(NSInteger)index
{
    CGRect rect = self.myScrollView.bounds;
    rect.origin.x = self.myScrollView.frame.size.width * index;
    return rect;
}

- (void)oneTapAction:(UITapGestureRecognizer *)tapGesture
{
    self.fullScreen = !self.fullScreen;
    
    [[UIApplication sharedApplication] setStatusBarHidden:self.fullScreen withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:self.fullScreen animated:NO];
    
    [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(oneTapAction:) object:nil];
    
    if (!self.fullScreen)
    {
        [self performSelector:@selector(oneTapAction:) withObject:nil afterDelay:5];
    }
}

- (void)twoTapAction:(UITapGestureRecognizer *)tapGesture
{
    ImageScrollView *imgView = (ImageScrollView *)[self.myScrollView viewWithTag:self.currentPage + kFullScreenImageArrayViewBaseTag];
    [imgView autoZoomScale];
}

- (void)loadScrollViewWithPageIndex:(NSInteger)index
{
    if (index < 0 || index >= self.imgURLArray.count)
    {
        return;
    }
    
    ImageScrollView *imgView = [[ImageScrollView alloc] initWithFrame:[self getPhotoViewFrameForIndex:index]];
    imgView.tag = kFullScreenImageArrayViewBaseTag + index;
    imgView.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imgView.imageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:self.imgURLArray[index]] andPlaceholderImage:[UIImage imageNamed:png_ImageDefault] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
     }
     completed:nil];
    [self.myScrollView addSubview:imgView];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page != self.currentPage)
    {
        self.currentPage = page;
        
        for (NSInteger i = 0; i < self.imgURLArray.count; i++)
        {
            ImageScrollView *imgView = (ImageScrollView *)[self.myScrollView viewWithTag:kFullScreenImageArrayViewBaseTag + i];
            if (i != page && i != page - 1 && i != page + 1)
            {
                if (imgView.superview != nil)
                {
                    [imgView removeFromSuperview];
                }
            }
            else
            {
                if (!imgView)
                {
                    [self loadScrollViewWithPageIndex:i];
                }
            }
        }
    }
}

@end
