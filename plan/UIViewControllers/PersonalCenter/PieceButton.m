//
//  PieceButton.m
//  plan
//
//  Created by Fengzy on 15/11/2.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "PieceButton.h"

@implementation PieceButton

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self customInit];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title content:(NSString *)content icon:(UIImage *)icon bgColor:(UIColor *)bgColor {
    if (self = [super initWithFrame:CGRectMake(0, 0, kPieceButtonWidth, kPieceButtonHeight)]) {
        [self customInit];
        [self setTitle:title content:content icon:icon bgColor:bgColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self customInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self customInit];
}

- (id)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, kPieceButtonWidth, kPieceButtonHeight)]) {
        [self customInit];
    }
    return self;
}

- (void)customInit {

    CGFloat titleHeight = 20;
    CGFloat iconSize = kPieceButtonHeight / 2;
    self.backgroundColor = [UIColor whiteColor];
//    imgViewIcon = [[UIImageView alloc] initWithFrame:CGRectMake(12, iconSize / 2, iconSize, iconSize)];
//    labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(12 + iconSize, iconSize / 2 - titleHeight, kPieceButtonWidth - iconSize - 24, titleHeight)];
    labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(12, kPieceButtonHeight / 4, kPieceButtonWidth - 24, titleHeight)];
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.font = font_Normal_16;
    labelTitle.textColor = color_708cb0;
    
//    labelContent = [[UILabel alloc] initWithFrame:CGRectMake(12 + iconSize, iconSize / 2, kPieceButtonWidth - iconSize - 24, iconSize)];
    labelContent = [[UILabel alloc] initWithFrame:CGRectMake(12, iconSize, kPieceButtonWidth - 24, iconSize)];
    labelContent.textAlignment = NSTextAlignmentCenter;
    labelContent.font = font_Normal_32;
    labelContent.textColor = color_ff9900;//color_75aff4;
    
//    [self addSubview:imgViewIcon];
    [self addSubview:labelTitle];
    [self addSubview:labelContent];
}

- (void)setTitle:(NSString *)title content:(NSString *)content icon:(UIImage *)icon bgColor:(UIColor *)bgColor {
    imgViewIcon.image = icon;
    labelTitle.text = title;
    labelContent.text = content;
    self.backgroundColor = bgColor;
}

@end
