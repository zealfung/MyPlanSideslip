//
//  Photo.h
//  plan
//
//  Created by Fengzy on 15/10/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "ModelBase.h"

@interface Photo : ModelBase

/** 影像ID */
@property (nonatomic, strong) NSString *photoid;
/** 所属账号 */
@property (nonatomic, strong) NSString *account;
/** 内容 */
@property (nonatomic, strong) NSString *content;
/** 创建时间 */
@property (nonatomic, strong) NSString *createtime;
/** 拍照时间 */
@property (nonatomic, strong) NSString *phototime;
/** 更新时间 */
@property (nonatomic, strong) NSString *updatetime;
/** 拍照地点 */
@property (nonatomic, strong) NSString *location;
/** 照片数组 */
@property (nonatomic, strong) NSMutableArray *photoArray;
/** 照片地址数组 */
@property (nonatomic, strong) NSMutableArray *photoURLArray;
/** 是否已删除：0否，1是 */
@property (nonatomic, strong) NSString *isdeleted;

@end
