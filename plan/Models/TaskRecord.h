//
//  TaskRecord.h
//  plan
//
//  Created by Fengzy on 15/11/29.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "ModelBase.h"

@interface TaskRecord : ModelBase <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *recordId;
@property (nonatomic, strong) NSString *createTime;

@end
