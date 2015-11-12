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

@property (nonatomic, strong) NSData *photo1NSData;
@property (nonatomic, strong) NSData *photo2NSData;
@property (nonatomic, strong) NSData *photo3NSData;
@property (nonatomic, strong) NSData *photo4NSData;
@property (nonatomic, strong) NSData *photo5NSData;
@property (nonatomic, strong) NSData *photo6NSData;
@property (nonatomic, strong) NSData *photo7NSData;
@property (nonatomic, strong) NSData *photo8NSData;
@property (nonatomic, strong) NSData *photo9NSData;
@property (nonatomic, strong) NSString *photo1URL;
@property (nonatomic, strong) NSString *photo2URL;
@property (nonatomic, strong) NSString *photo3URL;
@property (nonatomic, strong) NSString *photo4URL;
@property (nonatomic, strong) NSString *photo5URL;
@property (nonatomic, strong) NSString *photo6URL;
@property (nonatomic, strong) NSString *photo7URL;
@property (nonatomic, strong) NSString *photo8URL;
@property (nonatomic, strong) NSString *photo9URL;
@property (nonatomic, strong) NSString *isdeleted; //是否已删除 1是 0否

@end
