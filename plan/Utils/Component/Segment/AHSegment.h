//
//  AHSegment.h
//  plan
//
//  Created by Fengzy on 2017/6/3.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AHSegment;

@protocol AHSegmentDelegate <NSObject>

- (void)AHSegment:(AHSegment*)segment didSelectedIndex:(NSInteger)index;

@end

@interface AHSegment : UIControl

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, weak) id<AHSegmentDelegate> delegate;

- (void)updateChannels:(NSArray*)array;
- (void)didChengeToIndex:(NSInteger)index;

@end


