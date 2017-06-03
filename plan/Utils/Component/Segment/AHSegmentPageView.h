//
//  AHSegmentPageView.h
//  plan
//
//  Created by Fengzy on 2017/6/3.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AHSegmentPageView;

@protocol AHSegmentPageViewDataSource <NSObject>

- (NSInteger)numberOfItemInAHSegmentPageView:(AHSegmentPageView*)pageView;
- (UIView*)pageView:(AHSegmentPageView*)pageView viewAtIndex:(NSInteger)index;

@end

@protocol AHSegmentPageViewDelegate <NSObject>

- (void)didScrollToIndex:(NSInteger)index;

@end


@interface AHSegmentPageView : UIView

@property(nonatomic, strong) UIScrollView *scrollview;
@property(nonatomic, assign) NSInteger numberOfItems;
@property(nonatomic, assign) BOOL scrollAnimation;
@property(nonatomic, weak) id<AHSegmentPageViewDataSource> datasource;
@property(nonatomic, weak) id<AHSegmentPageViewDelegate> delegate;

- (void)reloadData;
- (void)changeToItemAtIndex:(NSInteger)index;

@end
