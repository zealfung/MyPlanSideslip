//
//  Messages.h
//  plan
//
//  Created by Fengzy on 15/12/10.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "ModelBase.h"

@interface Messages : ModelBase <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *messageId; //消息编号
@property (nonatomic, strong) NSString *title;//标题
@property (nonatomic, strong) NSString *content;//内容
@property (nonatomic, strong) NSString *detailURL;//详情链接
@property (nonatomic, strong) NSArray *imgURLArray;//图片组链接
@property (nonatomic, strong) NSString *hasRead;//0未读，1已读
@property (nonatomic, strong) NSString *canShare;//0不可分享，1可分享
@property (nonatomic, strong) NSString *readTimes; //阅读次数
@property (nonatomic, strong) NSString *createTime;

@end
