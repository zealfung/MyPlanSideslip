//
//  PlaceholderTextView.m
//  plan
//
//  Created by Fengzy on 16/1/7.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "ReactiveCocoa.h"
#import "PlaceholderTextView.h"

@interface PlaceholderTextView ()

@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation PlaceholderTextView

- (void)setUpPlaceholderLabel:(NSString *)placeholder {
    _placeholderLabel = [UILabel new];
    _placeholderLabel.textColor = [UIColor lightGrayColor];
    _placeholderLabel.backgroundColor = [UIColor clearColor];
    _placeholderLabel.text = placeholder;
    [self addSubview:_placeholderLabel];
    
    _placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(_placeholderLabel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_placeholderLabel]-6-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[_placeholderLabel]"   options:0 metrics:nil views:views]];
    
    
    RAC(_placeholderLabel, hidden) = [self.rac_textSignal map:^(NSString *text) {
        return @(text.length > 0);
    }];
}

- (void)checkShouldHidePlaceholder {
    _placeholderLabel.hidden = [self hasText];
}

#pragma mark - property accessor
#pragma mark placeholder

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholderLabel.text = placeholder;
}

- (NSString *)placeholder {
    return _placeholderLabel.text;
}

#pragma mark placeholderFont
- (void)setPlaceholderFont:(UIFont *)placeholderFont {
    _placeholderLabel.font = placeholderFont;
}

- (UIFont *)placeholderFont {
    return _placeholderLabel.font;
}

@end
