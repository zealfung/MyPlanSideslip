//
//  DataCenter.h
//  plan
//
//  Created by Fengzy on 15/10/3.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "BmobQuery.h"

@interface DataCenter : NSObject

+ (void)startSyncData;

+ (void)IsAllUploadFinished;

+ (void)syncServerToLocalForSettings:(BmobObject *)obj;

+ (void)addSettingsToServer;

+ (void)getMessagesFromServer;

@end
