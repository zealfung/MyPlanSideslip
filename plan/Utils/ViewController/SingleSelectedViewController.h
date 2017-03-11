//
//  SingleSelectedViewController.h
//  plan
//
//  Created by Fengzy on 17/3/11.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "SelectItem.h"
#import "FatherTableViewController.h"

@interface SingleSelectedViewController : FatherTableViewController

/** 界面标题 */
@property (nonatomic, strong) NSString *viewTitle;
/** 数据源 */
@property (nonatomic, strong) NSArray<SelectItem *> *arrayData;
/** 默认选中的值 */
@property (nonatomic, strong) NSString *selectedValue;
/** 选中后的回调函数 */
@property (nonatomic, strong) void(^SelectedDelegate)(NSString *selectedValue);

@end
