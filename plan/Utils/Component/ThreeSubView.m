//
//  ThreeSubView.m
//  plan
//
//  Created by Fengzy on 15/8/28.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "ThreeSubView.h"

@interface ThreeSubView ()

@property (nonatomic, strong, readwrite) UIButton *leftButton;
@property (nonatomic, strong, readwrite) UIButton *centerButton;
@property (nonatomic, strong, readwrite) UIButton *rightButton;

@property (nonatomic, copy) ButtonSelectBlock leftBlock;
@property (nonatomic, copy) ButtonSelectBlock centerBlock;
@property (nonatomic, copy) ButtonSelectBlock rightBlock;

@end

@implementation ThreeSubView

- (id)initWithFrame:(CGRect)frame leftButtonSelectBlock:(ButtonSelectBlock)leftButtonSelectBlock centerButtonSelectBlock:(ButtonSelectBlock)centerButtonSelectBlock  rightButtonSelectBlock:(ButtonSelectBlock)rightButtonSelectBlock {
    self = [super initWithFrame:frame];
    if (self) {
        [self setLeftButtonSelectBlock:leftButtonSelectBlock centerButtonSelectBlock:centerButtonSelectBlock rightButtonSelectBlock:rightButtonSelectBlock];
    }
    return self;
}

- (CGFloat)widthForString:(NSString *)string font:(UIFont *)font {
    CGFloat width = 0.0f;
    if (iOS7_LATER) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        width = ceilf([string sizeWithAttributes:attributes].width);
    } else {
        width = ceilf([string sizeWithFont:font].width);
    }
    return width;
}

- (void)buttonAutoLayout:(UIButton *)button {
    UIFont *titleFont = button.titleLabel.font;
    CGFloat imageWidth = 0, titleWidth = 0, backgroundImageWidth = 0;
    
    imageWidth = [button imageForState:UIControlStateNormal].size.width;
    titleWidth = [self widthForString:[button titleForState:UIControlStateNormal] font:titleFont];
    backgroundImageWidth = [button backgroundImageForState:UIControlStateNormal].size.width;
    
    imageWidth = MAX(imageWidth, [button imageForState:UIControlStateSelected].size.width);
    titleWidth = MAX(titleWidth, [self widthForString:[button titleForState:UIControlStateSelected] font:titleFont]);
    backgroundImageWidth = MAX(backgroundImageWidth, [button backgroundImageForState:UIControlStateSelected].size.width);
    
    imageWidth = MAX(imageWidth, [button imageForState:UIControlStateDisabled].size.width);
    titleWidth = MAX(titleWidth, [self widthForString:[button titleForState:UIControlStateDisabled] font:titleFont]);
    backgroundImageWidth = MAX(backgroundImageWidth, [button backgroundImageForState:UIControlStateDisabled].size.width);
    
    imageWidth = MAX(imageWidth, [button imageForState:UIControlStateHighlighted].size.width);
    titleWidth = MAX(titleWidth, [self widthForString:[button titleForState:UIControlStateHighlighted] font:titleFont]);
    backgroundImageWidth = MAX(backgroundImageWidth, [button backgroundImageForState:UIControlStateHighlighted].size.width);
    
    imageWidth = MAX(imageWidth, [button imageForState:UIControlStateApplication].size.width);
    titleWidth = MAX(titleWidth, [self widthForString:[button titleForState:UIControlStateApplication] font:titleFont]);
    backgroundImageWidth = MAX(backgroundImageWidth, [button backgroundImageForState:UIControlStateApplication].size.width);
    
    imageWidth = MAX(imageWidth, [button imageForState:UIControlStateReserved].size.width);
    titleWidth = MAX(titleWidth, [self widthForString:[button titleForState:UIControlStateReserved] font:titleFont]);
    backgroundImageWidth = MAX(backgroundImageWidth, [button backgroundImageForState:UIControlStateReserved].size.width);
    
    button.frame = CGRectMake(0, 0, ceilf(MAX(imageWidth + titleWidth, backgroundImageWidth)) + 1, self.frame.size.height);
}

- (void)setLeftButtonSelectBlock:(ButtonSelectBlock)leftButtonSelectBlock centerButtonSelectBlock:(ButtonSelectBlock)centerButtonSelectBlock  rightButtonSelectBlock:(ButtonSelectBlock)rightButtonSelectBlock {
    self.leftBlock = leftButtonSelectBlock;
    self.centerBlock = centerButtonSelectBlock;
    self.rightBlock = rightButtonSelectBlock;
    
    if (!self.leftButton) {
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.leftButton.exclusiveTouch = YES;
        [self.leftButton addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leftButton];
    }
    
    if (!self.centerButton) {
        self.centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.centerButton.exclusiveTouch = YES;
        [self.centerButton addTarget:self action:@selector(centerAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.centerButton];
    }
    
    if (!self.rightButton) {
        self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rightButton.exclusiveTouch = YES;
        [self.rightButton addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightButton];
    }
    
    [self configEnableStatusForButton:self.leftButton withBlock:self.leftBlock];
    [self configEnableStatusForButton:self.centerButton withBlock:self.centerBlock];
    [self configEnableStatusForButton:self.rightButton withBlock:self.rightBlock];
}

- (void)configEnableStatusForButton:(UIButton *)button withBlock:(ButtonSelectBlock)block {
    if (!block) {
        button.userInteractionEnabled = NO;
    } else {
        button.userInteractionEnabled = YES;
    }
}

#pragma mark - action

- (void)leftAction:(UIButton *)button {
    if (self.leftBlock) {
        self.leftBlock();
    }
}

- (void)centerAction:(UIButton *)button {
    if (self.centerBlock) {
        self.centerBlock();
    }
}

- (void)rightAction:(UIButton *)button {
    if (self.rightBlock) {
        self.rightBlock();
    }
}

#pragma mark - layout

- (void)autoLayout {
    int xOffset = 0;
    CGRect rect = CGRectZero;
    
    [self buttonAutoLayout:self.leftButton];
    rect = self.leftButton.frame;
    rect.origin.x = 0;
    if (self.fixLeftWidth != 0) {
        rect.size.width = self.fixLeftWidth;
    }
    self.leftButton.frame = rect;
    xOffset += self.leftButton.frame.size.width;
    
    [self buttonAutoLayout:self.centerButton];
    rect = self.centerButton.frame;
    rect.origin.x = xOffset;
    if (self.fixCenterWidth != 0) {
        rect.size.width = self.fixCenterWidth;
    }
    self.centerButton.frame = rect;
    xOffset += self.centerButton.frame.size.width;
    
    [self buttonAutoLayout:self.rightButton];
    rect = self.rightButton.frame;
    rect.origin.x = xOffset;
    if (self.fixRightWidth != 0) {
        rect.size.width = self.fixRightWidth;
    }
    self.rightButton.frame = rect;
    xOffset += self.rightButton.frame.size.width;
    
    rect = self.frame;
    rect.size.width = xOffset;
    self.frame = rect;
}


- (void)autoFit {
    CGRect rect = self.frame;
    int buttonWidth = ceilf(CGRectGetWidth(rect)/3.0);
    int buttonHeight = ceilf(CGRectGetHeight(rect));
    CGRect buttonFrame = CGRectMake(0, 0, buttonWidth, buttonHeight);
    self.leftButton.frame = buttonFrame;
    
    buttonFrame.origin.x = buttonWidth;
    self.centerButton.frame = buttonFrame;
    
    buttonFrame.origin.x = CGRectGetMaxX(buttonFrame);
    buttonFrame.size.width = ceilf(CGRectGetWidth(rect) - CGRectGetMinX(buttonFrame));
    self.rightButton.frame = buttonFrame;
}

- (void)LeftAndCenterButtonAutoFit {
    CGRect rect = self.frame;
    int buttonWidth = ceilf(CGRectGetWidth(rect)/2.0);
    int buttonHeight = ceilf(CGRectGetHeight(rect));
    CGRect buttonFrame = CGRectMake(0, 0, buttonWidth, buttonHeight);
    self.leftButton.frame = buttonFrame;
    
    buttonFrame.origin.x = buttonWidth;
    self.centerButton.frame = buttonFrame;
}


@end
