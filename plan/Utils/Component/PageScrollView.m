//
//  PageScrollView.m
//  plan
//
//  Created by Fengzy on 15/10/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <objc/runtime.h>
#import "PageScrollView.h"

NSUInteger const kPageScrollViewCellStartTag = 20151006;
NSString * const kPageScrollViewCellTagKey = @"cellTag";

@interface UIView (PageScrollViewCellTag)

@property (nonatomic, assign) NSInteger customTag;

@end


@implementation UIView (PageScrollViewCellTag)

@dynamic customTag;

- (void)setCustomTag:(NSInteger)customTag {
    
    objc_setAssociatedObject(self, (__bridge const void *)(kPageScrollViewCellTagKey), [NSNumber numberWithInteger:customTag], OBJC_ASSOCIATION_RETAIN);
    
}

- (NSInteger)customTag {
    
    NSNumber *number = objc_getAssociatedObject(self, (__bridge const void *)(kPageScrollViewCellTagKey));
    return [number integerValue];
    
}

- (void)clearCustomTag {
    
    objc_removeAssociatedObjects(self);
    
}

- (UIView *)viewWithCustomTag:(NSInteger)tag {
    
    for (UIView *view in self.subviews) {
        
        if (view.customTag == tag) {
            
            return view;
        }
    }
    return nil;
    
}

@end

@interface PageScrollView () <UIScrollViewDelegate> {
    
    struct {
        
        unsigned int responseDidScrollToPage:1;
        
    } _delegateFlags;
    
}

@property (nonatomic, weak) MPScrollView *scrollView;
@property (nonatomic, assign) CGFloat pageDistance;
@property (nonatomic, assign, readwrite) NSInteger currentPage;
@property (nonatomic, assign) NSUInteger totalPage;

@end

@implementation PageScrollView

- (id)initWithFrame:(CGRect)frame pageWidth:(CGFloat)pageWidth pageDistance:(CGFloat)pageDistance {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.currentPage = -1;
        self.pageDistance = pageDistance;
        self.holdPageCount = 3;
        
        {
            frame.origin.x = ceilf((CGRectGetWidth(frame) - pageWidth)/2);
            frame.origin.y = 0;
            frame.size.width = pageWidth + pageDistance;
            
            MPScrollView *scrollView = [[MPScrollView alloc] initWithFrame:frame];
            scrollView.backgroundColor = [UIColor clearColor];
            scrollView.showsVerticalScrollIndicator = NO;
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.delegate = self;
            scrollView.clipsToBounds = NO;
            scrollView.pagingEnabled = YES;
            [self addSubview:scrollView];
            self.scrollView = scrollView;
            
            self.scrollView.responseInsets = UIEdgeInsetsMake(0, CGRectGetMinX(frame), 0, CGRectGetWidth(self.bounds) - CGRectGetMaxX(frame));
        }
        
        _delegateFlags.responseDidScrollToPage = NO;
    }
    return self;
    
}

- (void)scrollToPage:(NSUInteger)pageIndex {
    
    [self scrollToPage:pageIndex animated:NO];
    
}

- (void)scrollToPage:(NSUInteger)pageIndex animated:(BOOL)animated {
    
    [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.bounds) * pageIndex, 0) animated:animated];
    
    if (_delegateFlags.responseDidScrollToPage) {
        
        [self.delegate pageScrollView:self didScrollToPage:pageIndex];
        
    }
    
}

- (void)reloadData {
    
    self.totalPage = [_dataSource numberOfPagesInPageScrollView:self];
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSInteger index = 0; index < self.totalPage; index++) {
        
        [self loadScrollViewWithPageIndex:index];
    }
    [self setNeedsLayout];
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX([self frameForCellWithIndex:self.totalPage - 1]), CGRectGetHeight(self.scrollView.bounds));
    [self scrollViewDidScroll:self.scrollView];
    [self scrollViewDidEndDecelerating:self.scrollView];
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if ([self pointInside:point withEvent:event]) {
        
        CGPoint newPoint = CGPointZero;
        newPoint.x = point.x - self.scrollView.frame.origin.x + self.scrollView.contentOffset.x;
        newPoint.y = point.y - self.scrollView.frame.origin.y + self.scrollView.contentOffset.y;
        if ([self.scrollView pointInside:newPoint withEvent:event]) {
            
            return [self.scrollView hitTest:newPoint withEvent:event];
            
        }
        return self.scrollView;
    }
    return nil;
    
}

- (CGRect)frameForCellWithIndex:(NSUInteger)index {
    
    CGRect frame = CGRectZero;
    frame.origin.x = CGRectGetWidth(self.scrollView.bounds) * index;
    frame.origin.y = 0;
    frame.size = self.scrollView.bounds.size;
    
    return frame;
}

- (void)loadScrollViewWithPageIndex:(NSInteger)index {
    
    CGRect frame = [self frameForCellWithIndex:index];
    
    UIView *cellView = [self.dataSource pageScrollView:self cellForPageIndex:index];
    frame.origin.x = CGRectGetMinX(frame) + self.pageDistance / 2;
    frame.size.width -= self.pageDistance;
    cellView.frame = frame;
    cellView.customTag = kPageScrollViewCellStartTag + index;
    [self.scrollView addSubview:cellView];
}

#pragma mark - sets
- (void)setDelegate:(id <PageScrollViewDelegate>)delegate {
    
    _delegate = delegate;
    _delegateFlags.responseDidScrollToPage = [delegate respondsToSelector:@selector(pageScrollView:didScrollToPage:)];
    
}

- (void)setDataSource:(id <PageScrollViewDataSource>)dataSource {
    
    _dataSource = dataSource;
    self.totalPage = [dataSource numberOfPagesInPageScrollView:self];
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (_delegateFlags.responseDidScrollToPage) {
        
        [self.delegate pageScrollView:self didScrollToPage:page];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page != self.currentPage) {
        
        self.currentPage = page;
        
        NSInteger leftRightKeepCount = (self.holdPageCount - 1) / 2;
        
        for (NSInteger index = 0; index < self.totalPage; index++) {
            
            if (page - leftRightKeepCount <= index && index <= page + leftRightKeepCount) {
                
                UIView *view = [scrollView viewWithCustomTag:kPageScrollViewCellStartTag + index];
                if (!view) {
                    
                    [self loadScrollViewWithPageIndex:index];
                }
                
            } else {
                
                UIView *view = [scrollView viewWithCustomTag:kPageScrollViewCellStartTag + index];
                
                if (view && view.superview) {
                    
                    [view clearCustomTag];
                    [view removeFromSuperview];
                }
            }
        }
    }
}

@end


@implementation MPScrollView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGPoint parentLocation = [self convertPoint:point toView:[self superview]];
    CGRect responseRect = self.frame;
    responseRect.origin.x -= self.responseInsets.left;
    responseRect.origin.y -= self.responseInsets.top;
    responseRect.size.width += (self.responseInsets.left + self.responseInsets.right);
    responseRect.size.height += (self.responseInsets.top + self.responseInsets.bottom);
    
    return CGRectContainsPoint(responseRect, parentLocation);
}

@end
