//
//  BaseItem.h
//  plan
//
//  Created by Fengzy on 17/1/17.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import <YYModel/YYModel.h>
#import <Foundation/Foundation.h>

@interface BaseItem : NSObject <YYModel>

/**
 *  dictionary to model
 */
+(instancetype )modelWithDictionary:(NSDictionary *)dictionary;

/**
 *  json to model，json(NSString,NSData,NSDictionary)
 */
+(instancetype )modelWithJson:(id )json;

@end



#pragma mark - NSArray to models
@interface NSArray(BaseItem)

/**
 *  传入模型class，将数组转化成模型数组
 *
 *  @param cls 模型的class
 *
 *  @return 建好的模型数组
 */
-(NSArray *)modelArrayWithClass:(Class )cls;

@end



#pragma mark - NSMutableArray to models
@interface NSMutableArray(BaseItem)

/**
 *  传入模型class，将数组转化成模型数组
 *
 *  @param cls 模型的class
 *
 *  @return 建好的模型数组
 */
-(NSMutableArray *)modelMutableArrayWithClass:(Class )cls;

@end
