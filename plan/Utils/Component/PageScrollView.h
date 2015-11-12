//
//  PageScrollView.h
//  plan
//
//  Created by Fengzy on 15/10/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PageScrollViewDataSource;
@protocol PageScrollViewDelegate;

@interface PageScrollView : UIView

@property (nonatomic, assign) NSInteger holdPageCount; //最多显示多少个页面，缺省3个，必须为奇数
@property (nonatomic, assign, readonly) NSInteger currentPage;
@property (nonatomic, weak) id<PageScrollViewDelegate> delegate;
@property (nonatomic, weak) id<PageScrollViewDataSource> dataSource;

- (id)initWithFrame:(CGRect)frame pageWidth:(CGFloat)pageWidth pageDistance:(CGFloat)pageDistance;

- (void)scrollToPage:(NSUInteger)pageIndex;

- (void)scrollToPage:(NSUInteger)pageIndex animated:(BOOL)animated;

- (void)reloadData;

@end


@protocol  PageScrollViewDelegate <NSObject>

@optional

- (void)pageScrollView:(PageScrollView *)pageScrollView didScrollToPage:(NSInteger)pageNumber;

@end


@protocol PageScrollViewDataSource <NSObject>

@required
//返回显示View的个数
- (NSUInteger)numberOfPagesInPageScrollView:(PageScrollView *)pageScrollView;

//返回给某列使用的View
- (UIView *)pageScrollView:(PageScrollView *)pageScrollView cellForPageIndex:(NSUInteger)index;

@end


@interface MPScrollView : UIScrollView

@property (nonatomic, assign) UIEdgeInsets responseInsets;

@end