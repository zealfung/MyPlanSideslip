//
//  MPTextView.h
//  plan
//
//  Created by Fengzy on 2017/4/24.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPTextView : UITextView

@property (nonatomic, copy) NSString *mptext;

@property (nonatomic, copy) NSString *placeHolder;

@property (nonatomic, copy) void(^textChange) (NSString *text);

@end
