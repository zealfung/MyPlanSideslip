//
//  BaseItem.m
//  plan
//
//  Created by Fengzy on 17/1/17.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "BaseItem.h"

@implementation BaseItem

#pragma mark - useful method
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary
{
    if (nil != dictionary)
    {
        return [[self class] yy_modelWithDictionary:dictionary];
    }
    return nil;
}

+ (instancetype)modelWithJson:(id )json
{
    if (nil != json)
    {
        return [[self class] yy_modelWithJSON:json];
    }
    return nil;
}

#pragma mark - init
- (instancetype)init
{
    if ([self isMemberOfClass:[BaseItem class]])
    {
        NSAssert(0, @"基类不能创建对象！");
        return nil;
    }
    return [super init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [[super allocWithZone:zone] init];
}

@end

#pragma mark - NSArray to models
@implementation NSArray(BaseItem)

- (NSArray *)modelArrayWithClass:(Class )cls
{
    if (self.count > 0)
    {
        NSObject *obj = self[0];
        if ([obj isMemberOfClass:cls])
        {
            return self;
        }
    }
    return [NSArray yy_modelArrayWithClass:cls json:self];
}

@end

#pragma mark - NSMutableArray to models
@implementation NSMutableArray(BaseItem)

- (NSMutableArray *)modelMutableArrayWithClass:(Class )cls
{
    if (self.count > 0)
    {
        NSObject *obj = self[0];
        if ([obj isMemberOfClass:cls])
        {
            return self;
        }
    }
    return [[self modelArrayWithClass:cls] mutableCopy];
}

@end
