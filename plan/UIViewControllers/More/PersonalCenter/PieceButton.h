//
//  PieceButton.h
//  plan
//
//  Created by Fengzy on 15/11/2.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPieceButtonWidth WIDTH_FULL_SCREEN / 2
#define kPieceButtonHeight WIDTH_FULL_SCREEN / 4

@interface PieceButton : UIButton {
    
    UIImageView *imgViewIcon;
    UILabel *labelTitle;
    UILabel *labelContent;

}

- (id)initWithTitle:(NSString *)title content:(NSString *)content icon:(UIImage *)icon bgColor:(UIColor *)bgColor;
- (void)setTitle:(NSString *)title content:(NSString *)content icon:(UIImage *)icon bgColor:(UIColor *)bgColor;

@end
