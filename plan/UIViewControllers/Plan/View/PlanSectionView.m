//
//  PlanSectionView.m
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "PlanSectionView.h"


@implementation PlanSectionView {
    
    BOOL _toggle;
    UILabel *labelTitle;
    UILabel *labelCount;
    UIImageView *imgViewToggle;
}

- (id)initWithTitle:(NSString *)title count:(NSString *)count isAllDone:(BOOL)isAllDone {
    self = [super initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, kPlanSectionViewHeight)];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.backgroundColor = color_Blue;
        
        imgViewToggle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:png_Btn_SectionUp]];
        labelTitle = [[UILabel alloc] init];
        if (isAllDone) {
            labelTitle.textColor = [UIColor whiteColor];
        } else {
            labelTitle.textColor = [UIColor yellowColor];
        }
        labelTitle.font = font_Normal_18;
        labelTitle.text = title;
        
        labelCount = [[UILabel alloc] init];
        labelCount.text = count;
        labelCount.font = font_Normal_18;
        labelCount.textColor = [UIColor whiteColor];
        labelCount.textAlignment = NSTextAlignmentLeft;
        
        CGFloat arrowWidth = 7;
        CGFloat arrowHeight = 6;
        CGFloat titleWidth = 160;
        CGFloat countWidth = 80;
        CGFloat toggleX = WIDTH_FULL_SCREEN - kEdgeInset - arrowWidth;
        CGFloat countX = kEdgeInset + titleWidth + 10;
        
        labelTitle.frame = CGRectMake(kEdgeInset, 0, titleWidth, kPlanSectionViewHeight);
        labelCount.frame = CGRectMake(countX, 0, countWidth, kPlanSectionViewHeight);
        imgViewToggle.frame = CGRectMake(toggleX, (kPlanSectionViewHeight - arrowHeight)/2, arrowWidth, arrowHeight);
        
        [self addSubview:labelTitle];
        [self addSubview:labelCount];
        [self addSubview:imgViewToggle];
    }
    return self;
}

- (void)toggleArrow {
    CGFloat fl = (M_PI / 180) * 180;
    if (_toggle) {
        imgViewToggle.transform = CGAffineTransformMakeRotation(fl * 4);
    } else {
        imgViewToggle.transform = CGAffineTransformMakeRotation(fl);
    }
    _toggle = !_toggle;
}

@end
