//
//  PlanSectionView.h
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

static const NSUInteger kPlanSectionViewHeight = 50;

@interface PlanSectionView : UIView

@property (nonatomic, assign) NSInteger sectionIndex;

- (id)initWithTitle:(NSString *)title isAllDone:(BOOL)isAllDone;

- (id)initWithTitle:(NSString *)title;

- (void)toggleArrow;

@end
