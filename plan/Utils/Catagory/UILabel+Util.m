//
//  UILabel+Util.m
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "UILabel+Util.h"

@implementation UILabel (Util)

- (CGSize)boundingRectWithSize:(CGSize)size {
    NSDictionary *attribute = @{NSFontAttributeName:self.font};
    CGSize retSize;
    
    if (iOS7_LATER) {
        retSize = [self.text boundingRectWithSize:size
                                          options:\
                   NSStringDrawingTruncatesLastVisibleLine |
                   NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading
                                       attributes:attribute
                                          context:nil].size;
        
    } else {
        retSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    }
    return retSize;
}

@end
