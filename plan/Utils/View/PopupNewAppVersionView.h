//
//  PopupNewAppVersionView.h
//  plan
//
//  Created by Fengzy on 2017/5/25.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupNewAppVersionView : UIView

/** 初始化弹框 */
+ (instancetype)shareInstance:(NSString *)version whatNew:(NSString *)whatNew isForce:(BOOL)isForce;

/** 显示弹框 */
- (void)show;

@end
