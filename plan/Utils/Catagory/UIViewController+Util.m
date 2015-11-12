//
//  UIViewController+Util.m
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "UIViewController+Util.h"

NSInteger const kIOS7SmartLeftMarginWidth = -14;
NSInteger const kIOS7SmartRightMarginWidth = -14;

@implementation UIViewController (Util)


- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    NSArray *leftBarButtonItems = nil;
    if (leftBarButtonItem) {
        leftBarButtonItems = @[leftBarButtonItem];
    }
    self.leftBarButtonItems = leftBarButtonItems;
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem {
    NSArray *rightBarButtonItems = nil;
    if (rightBarButtonItem) {
        rightBarButtonItems = @[rightBarButtonItem];
    }
    self.rightBarButtonItems = rightBarButtonItems;
}

- (UIBarButtonItem *)getLeftBarButtonItem {
    UIBarButtonItem *item = nil;
    NSArray *array = self.leftBarButtonItems;
    if (array.count > 0) {
        item = array[0];
    }
    return item;
}

- (UIBarButtonItem *)getRightBarButtonItem {
    UIBarButtonItem *item = nil;
    NSArray *array = self.rightBarButtonItems;
    if (array.count > 0) {
        item = array[0];
    }
    return item;
}

- (void)setLeftBarButtonItems:(NSArray *)items {
    if (iOS7_LATER) {
        
        self.navigationItem.leftBarButtonItems = [self barButtonItems:items marginWidth:kIOS7SmartLeftMarginWidth];
        
    } else {
        
        self.navigationItem.leftBarButtonItems = items;
    }
}

- (void)setRightBarButtonItems:(NSArray *)items {
    if (iOS7_LATER) {
        
        self.navigationItem.rightBarButtonItems = [self barButtonItems:items marginWidth:kIOS7SmartRightMarginWidth];
        
    } else {
        
        self.navigationItem.rightBarButtonItems = items;
    }
}

- (NSArray *)getLeftBarButtonItems {
    return [self getBarButtonItemsForItems:self.navigationItem.leftBarButtonItems];
}


- (NSArray *)getRightBarButtonItems {
    return [self getBarButtonItemsForItems:self.navigationItem.rightBarButtonItems];
}


- (NSArray *)getBarButtonItemsForItems:(NSArray *)items {
    NSArray *array = nil;
    if (iOS7_LATER && items.count > 0) {
        
        NSMutableArray *mutItems = [NSMutableArray arrayWithArray:items];
        [mutItems removeObjectAtIndex:0];
        
        array = [NSArray arrayWithArray:mutItems];
        
    } else {
        
        array = items;
    }
    
    return array;
}

- (NSArray *)barButtonItems:(NSArray *)items marginWidth:(NSInteger)marginWidth {
    NSArray *tmpItems = nil;
    
    if (items.count > 0) {
        
        NSMutableArray *mutItems = [NSMutableArray arrayWithArray:items];
        
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedSpace.width = marginWidth;
        
        [mutItems insertObject:fixedSpace atIndex:0];
        
        tmpItems = [NSArray arrayWithArray:mutItems];
    }
    
    return tmpItems;
}

@end
