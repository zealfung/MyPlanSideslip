//
//  UINavigationController+Util.h
//  plan
//
//  Created by Fengzy on 15/11/21.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Util)

- (void)navigationBarOptimize;

- (void)navCtrlConfig;

@end

@interface UINavigationController (StatusBarStyleController)

@end


@interface UINavigationController (AutorotateController)

@end


@interface AutorotateOrientationNavigationController : UINavigationController

@end