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
    UILabel *titleLabel;
    UIImageView *toggleImageView;
    
}

- (id)initWithTitle:(NSString *)title isAllDone:(BOOL)isAllDone {
    
    self = [super initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, kPlanSectionViewHeight)];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.backgroundColor = color_Blue;
        
        toggleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:png_Btn_SectionUp]];
        titleLabel = [[UILabel alloc] init];
        if (isAllDone) {
            
            titleLabel.textColor = [UIColor whiteColor];
            
        } else {
            
            titleLabel.textColor = [UIColor yellowColor];
            
        }
        titleLabel.font = font_Normal_18;
        titleLabel.text = title;
        
        NSInteger xOffset = 12;
        CGFloat arrowWidth = 7;
        CGFloat arrowHeight = 6;
        CGFloat titleWidth = 200;
        
        toggleImageView.frame = CGRectMake(WIDTH_FULL_SCREEN - xOffset - arrowWidth, (kPlanSectionViewHeight - arrowHeight)/2, arrowWidth, arrowHeight);
        titleLabel.frame = CGRectMake(xOffset, 0, titleWidth, kPlanSectionViewHeight);
        
        [self addSubview:toggleImageView];
        [self addSubview:titleLabel];
        
    }
    
    return self;
}

- (void)toggleArrow {
    
    CGFloat fl = (M_PI / 180) * 180;
    
    if (_toggle) {
        
        toggleImageView.transform = CGAffineTransformMakeRotation(fl * 4);
        
    } else {
        
        toggleImageView.transform = CGAffineTransformMakeRotation(fl);
        
    }
    _toggle = !_toggle;
}

@end
