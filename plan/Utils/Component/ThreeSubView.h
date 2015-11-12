//
//  ThreeSubView.h
//  plan
//
//  Created by Fengzy on 15/8/28.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ButtonSelectBlock)(void);

@interface ThreeSubView : UIView

@property (nonatomic, strong, readonly) UIButton *leftButton;
@property (nonatomic, strong, readonly) UIButton *centerButton;
@property (nonatomic, strong, readonly) UIButton *rightButton;


@property (nonatomic, assign) NSUInteger fixLeftWidth;
@property (nonatomic, assign) NSUInteger fixCenterWidth;
@property (nonatomic, assign) NSUInteger fixRightWidth;


- (id)initWithFrame:(CGRect)frame leftButtonSelectBlock:(ButtonSelectBlock)leftButtonSelectBlock centerButtonSelectBlock:(ButtonSelectBlock)centerButtonSelectBlock  rightButtonSelectBlock:(ButtonSelectBlock)rightButtonSelectBlock;

- (void)setLeftButtonSelectBlock:(ButtonSelectBlock)leftButtonSelectBlock centerButtonSelectBlock:(ButtonSelectBlock)centerButtonSelectBlock  rightButtonSelectBlock:(ButtonSelectBlock)rightButtonSelectBlock;

- (void)autoLayout;
- (void)autoFit;
- (void)LeftAndCenterButtonAutoFit;

@end
