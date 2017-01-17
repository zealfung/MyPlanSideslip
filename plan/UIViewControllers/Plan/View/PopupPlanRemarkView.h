//
//  PopupPlanRemarkView.h
//  plan
//
//  Created by Fengzy on 17/1/17.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PopupPlanRemarkViewBlock)(NSString *);

@interface PopupPlanRemarkView : UIView

/** 确定按钮回调 */
@property (nonatomic, copy) PopupPlanRemarkViewBlock callbackBlock;
/** 初始化弹框 */
- (id)initWithTitle:(NSString *)title;
/** 显示弹框 */
- (void)show;

@end
