//
//  Messages.h
//  plan
//
//  Created by Fengzy on 15/12/10.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "ModelBase.h"

@interface Messages : ModelBase

/** 消息编号 */
@property (nonatomic, strong) NSString *messageId;
/** 标题 */
@property (nonatomic, strong) NSString *title;
/** 内容 */
@property (nonatomic, strong) NSString *content;
/** 详情链接 */
@property (nonatomic, strong) NSString *detailURL;
/** 图片组链接 */
@property (nonatomic, strong) NSArray *imgURLArray;
/** 0未读，1已读 */
@property (nonatomic, strong) NSString *hasRead;
/** 0不可分享，1可分享 */
@property (nonatomic, strong) NSString *canShare;
/** 1系统消息 2回复点赞消息 */
@property (nonatomic, strong) NSString *messageType;
/** 创建时间 */
@property (nonatomic, strong) NSString *createTime;

@end
