//
//  HitView.h
//  plan
//
//  Created by Fengzy on 15/9/12.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HitViewDelegate <NSObject>

- (UIView *)hitViewClicked:(CGPoint)point event:(UIEvent *)event touchView:(UIView *)touchView;

@end

@interface HitView : UIView

@property (nonatomic,assign) id<HitViewDelegate> delegate;

@end
