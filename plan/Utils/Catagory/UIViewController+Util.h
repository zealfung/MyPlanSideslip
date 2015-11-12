//
//  UIViewController+Util.h
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Util)

@property (nonatomic, getter = getLeftBarButtonItem, setter = setLeftBarButtonItem:) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, getter = getRightBarButtonItem, setter = setRightBarButtonItem:) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, getter = getRightBarButtonItems, setter = setRightBarButtonItems:) NSArray *rightBarButtonItems;
@property (nonatomic, getter = getLeftBarButtonItems, setter = setLeftBarButtonItems:) NSArray *leftBarButtonItems;

@end
