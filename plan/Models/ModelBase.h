//
//  ModelBase.h
//  plan
//
//  Created by Fengzy on 15/8/29.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "BaseItem.h"

/**
 *  用于解析json数据,子类模型继承此类,包含coding跟copying
 */
@interface ModelBase : BaseItem <NSCoding, NSCopying, NSSecureCoding>


@end

