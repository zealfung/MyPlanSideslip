//
//  AHSegmentPageView.m
//  plan
//
//  Created by Fengzy on 2017/6/3.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "AHSegmentPageView.h"

@interface AHSegmentPageView () <UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *itemsArray;

@end


@implementation AHSegmentPageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _scrollview = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollview.delegate = self;
    _scrollview.pagingEnabled = YES;
    _scrollview.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollview];
}

- (void)reloadData
{
    if (nil != _datasource)
    {
        _numberOfItems = [_datasource numberOfItemInAHSegmentPageView:self];
        _scrollview.contentSize = CGSizeMake(_numberOfItems * self.frame.size.width,self.frame.size.height);
    }
    
}

- (void)changeToItemAtIndex:(NSInteger)index
{
    if ([self.itemsArray objectAtIndex:index] == [NSNull null])
    {
        [self loadViewAtIndex:index];
    }
    [_scrollview setContentOffset:CGPointMake(index * self.bounds.size.width, 0) animated:_scrollAnimation];
    [self preLoadViewWithIndex:index];
    _currentIndex = index;
}

- (NSMutableArray*)itemsArray
{
    if (_itemsArray == nil)
    {
        NSInteger total = [_datasource numberOfItemInAHSegmentPageView:self];
        _itemsArray = [NSMutableArray arrayWithCapacity:total];
        for (int i = 0; i < total; i++)
        {
            [_itemsArray addObject:[NSNull null]];
        }
    }
    return _itemsArray;
}

- (void)loadViewAtIndex:(NSInteger)index
{
    if (_datasource != nil && [_datasource respondsToSelector:@selector(pageView:viewAtIndex:)])
    {
        UIView *view = [_datasource pageView:self viewAtIndex:index];
        view.frame = CGRectMake(self.bounds.size.width*index, 0, self.bounds.size.width, self.bounds.size.height);
        [_scrollview addSubview:view];
        [self.itemsArray replaceObjectAtIndex:index withObject:view];
    }
}

- (void)preLoadViewWithIndex:(NSInteger)index
{
    if (index > 0 && [self.itemsArray objectAtIndex:(index-1)] == [NSNull null])
    {
        [self loadViewAtIndex:(index-1)];
    }
    if (index < (_numberOfItems-1) && [self.itemsArray objectAtIndex:(index+1)] == [NSNull null])
    {
        [self loadViewAtIndex:(index+1)];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / self.bounds.size.width;
    if ([self.itemsArray objectAtIndex:index] == [NSNull null])
    {
        [self loadViewAtIndex:index];
    }
    [self preLoadViewWithIndex:index];
    
    if (index != _currentIndex)
    {
        if ([_delegate respondsToSelector:@selector(didScrollToIndex:)])
        {
            [_delegate didScrollToIndex:index];
            _currentIndex = index;
        }
    }
}

@end
