//
//  UIView+Util.m
//  plan
//
//  Created by Fengzy on 15/11/12.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "UIView+Util.h"
#import "NSLayoutConstraint+Util.h"

@implementation UIView (Util)

- (void)setDop_x:(CGFloat)dop_x {
    CGRect frame = self.frame;
    frame.origin.x = dop_x;
    self.frame = frame;
}

- (CGFloat)dop_x {
    return self.frame.origin.x;
}

- (void)setDop_y:(CGFloat)dop_y {
    CGRect frame = self.frame;
    frame.origin.y = dop_y;
    self.frame = frame;
}

- (CGFloat)dop_y {
    return self.frame.origin.y;
}

- (void)setDop_width:(CGFloat)dop_width {
    CGRect frame = self.frame;
    frame.size.width = dop_width;
    self.frame = frame;
}

- (CGFloat)dop_width {
    return self.frame.size.width;
}

- (void)setDop_height:(CGFloat)dop_height {
    CGRect frame = self.frame;
    frame.size.height = dop_height;
    self.frame = frame;
}

- (CGFloat)dop_height {
    return self.frame.size.height;
}

- (void)setDop_size:(CGSize)dop_size {
    CGRect frame = self.frame;
    frame.size = dop_size;
    self.frame = frame;
}

- (CGSize)dop_size {
    return self.frame.size;
}

- (void)setDop_origin:(CGPoint)dop_origin {
    CGRect frame = self.frame;
    frame.origin = dop_origin;
    self.frame = frame;
}

- (CGPoint)dop_origin {
    return self.frame.origin;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

- (void)setBorderWidth:(CGFloat)width andColor:(UIColor *)color {
    self.layer.borderWidth = width;
    self.layer.borderColor = color.CGColor;
}

- (void)setVisibility:(UIViewVisibility)visibility {
    [self setVisibility:visibility affectedMarginDirections:UIViewMarginDirectionNone];
}

- (void)setVisibility:(UIViewVisibility)visibility affectedMarginDirections:(UIViewMarginDirection)affectedMarginDirections {
    switch (visibility) {
        case UIViewVisibilityVisible:
            self.hidden = NO;
            [[self findConstraintFromView:self forLayoutAttribute:NSLayoutAttributeWidth] restore];
            [[self findConstraintFromView:self forLayoutAttribute:NSLayoutAttributeHeight] restore];
            [self restoreMarginForDirections:affectedMarginDirections];
            break;
        case UIViewVisibilityInvisible:
            self.hidden = YES;
            break;
        case UIViewVisibilityGone:
            self.hidden = YES;
            [[self findConstraintFromView:self forLayoutAttribute:NSLayoutAttributeWidth] clear];
            [[self findConstraintFromView:self forLayoutAttribute:NSLayoutAttributeHeight] clear];
            [self clearMarginForDirections:affectedMarginDirections];
            break;
        default:
            break;
    }
    
    if (visibility != UIViewVisibilityInvisible) {
        [self layoutIfNeeded];
    }
}

- (void)clearMarginForDirections:(UIViewMarginDirection)affectedMarginDirections {
    if (affectedMarginDirections == UIViewMarginDirectionNone) {
        return;
    }
    
    if (UIViewMarginDirectionTop & affectedMarginDirections) {
        [[self findConstraintFromView:self.superview forLayoutAttribute:NSLayoutAttributeTop] clear];
    }
    if (UIViewMarginDirectionLeft & affectedMarginDirections) {
        [[self findConstraintFromView:self.superview forLayoutAttribute:NSLayoutAttributeLeading] clear];
    }
    if (UIViewMarginDirectionBottom & affectedMarginDirections) {
        [[self findConstraintFromView:self.superview forLayoutAttribute:NSLayoutAttributeBottom] clear];
    }
    if (UIViewMarginDirectionRight & affectedMarginDirections) {
        [[self findConstraintFromView:self.superview forLayoutAttribute:NSLayoutAttributeTrailing] clear];
    }
}

- (void)restoreMarginForDirections:(UIViewMarginDirection)affectedMarginDirections {
    if (affectedMarginDirections == UIViewMarginDirectionNone) {
        return;
    }
    
    if (UIViewMarginDirectionTop & affectedMarginDirections) {
        [[self findConstraintFromView:self.superview forLayoutAttribute:NSLayoutAttributeTop] restore];
    }
    if (UIViewMarginDirectionLeft & affectedMarginDirections) {
        [[self findConstraintFromView:self.superview forLayoutAttribute:NSLayoutAttributeLeading] restore];
    }
    if (UIViewMarginDirectionBottom & affectedMarginDirections) {
        [[self findConstraintFromView:self.superview forLayoutAttribute:NSLayoutAttributeBottom] restore];
    }
    if (UIViewMarginDirectionRight & affectedMarginDirections) {
        [[self findConstraintFromView:self.superview forLayoutAttribute:NSLayoutAttributeTrailing] restore];
    }
}

- (NSLayoutConstraint *)findConstraintFromView:(UIView *)view forLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    for (NSLayoutConstraint *constraint in view.constraints) {
        if ((constraint.firstItem == self && constraint.firstAttribute == layoutAttribute) ||
            (constraint.secondItem == self && constraint.secondAttribute == layoutAttribute)) {
            return constraint;
        }
    }
    
    return nil;
}

- (UIView *)getInputAccessoryView
{
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] applicationFrame]), 44)];
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    
    NSMutableArray *items = [NSMutableArray array];
    {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [items addObject:barButtonItem];
    }
    {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(endInputAction:)];
        [items addObject:barButtonItem];
    }
    
    toolBar.items = items;
    
    return toolBar;
}

- (void)endInputAction:(UIBarButtonItem *)barButtonItem
{
    [self endEditing:YES];
}

@end
