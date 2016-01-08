//
//  PlaceholderTextView.h
//  plan
//
//  Created by Fengzy on 16/1/7.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceholderTextView : UITextView

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIFont   *placeholderFont;

- (void)setUpPlaceholderLabel:(NSString *)placeholder;
- (void)checkShouldHidePlaceholder;

@end
