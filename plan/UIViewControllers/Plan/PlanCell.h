//
//  PlanCell.h
//  plan
//
//  Created by Fengzy on 15/9/12.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Plan.h"
#import <UIKit/UIKit.h>

extern NSUInteger const kPlanCellHeight;

@protocol PlanCellDelegate <NSObject>

- (void)didCellWillHide:(id)sender;
- (void)didCellHided:(id)sender;
- (void)didCellWillShow:(id)sender;
- (void)didCellShowed:(id)sender;
- (void)didCellClicked:(id)sender;
- (void)didCellClickedDoneButton:(id)sender;
- (void)didCellClickedDeleteButton:(id)sender;

@end

@interface PlanCell : UITableViewCell<UIGestureRecognizerDelegate> {
    CGFloat startLocation;
    BOOL hideMenuView;
}

@property (nonatomic, strong) IBOutlet UIView *moveContentView;
@property (nonatomic, assign) id<PlanCellDelegate> delegate;
//@property (nonatomic, strong) UILabel *labelContent;
@property (nonatomic, strong) NSString *isDone; //1是 0否
@property (nonatomic, strong) Plan *plan;

- (void)hideMenuView:(BOOL)hidden Animated:(BOOL)animated;
- (void)addControl;

@end
