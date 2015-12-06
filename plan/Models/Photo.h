//
//  Photo.h
//  plan
//
//  Created by Fengzy on 15/10/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "ModelBase.h"

@interface Photo : ModelBase <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *photoid;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *createtime;
@property (nonatomic, strong) NSString *phototime;//拍照时间
@property (nonatomic, strong) NSString *updatetime;
@property (nonatomic, strong) NSString *location; //拍照地点
@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic, strong) NSMutableArray *photoURLArray;
@property (nonatomic, strong) NSString *isdeleted; //是否已删除 1是 0否

@end
