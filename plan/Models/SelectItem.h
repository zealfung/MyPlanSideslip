//
//  SelectItem.h
//  plan
//
//  Created by Fengzy on 17/3/11.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "ModelBase.h"

@interface SelectItem : ModelBase

/** 名称 */
@property (nonatomic, strong) NSString *itemName;
/** 值 */
@property (nonatomic, strong) NSString *itemValue;

@end
