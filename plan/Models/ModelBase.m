//
//  ModelBase.m
//  plan
//
//  Created by Fengzy on 15/8/29.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "ModelBase.h"
#import "NSString+Util.h"

@implementation ModelBase

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict {
    return [[[self class] alloc] initWithDictionary:dict];
}


- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    return self;
}


- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

@end


@implementation NSDictionary (ModelBase)

- (id)objectOrNilForKey:(id)aKey {
    id object = [self objectForKey:aKey];
    object = [object isEqual:[NSNull null]] ? nil : object;
    if ([object isKindOfClass:[NSString class]] && [object sameToString:@"null"]) {
        object = nil;
    }
    return object;
}

@end