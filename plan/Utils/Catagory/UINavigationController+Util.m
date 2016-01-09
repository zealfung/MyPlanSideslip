//
//  UINavigationController+Util.m
//  plan
//
//  Created by Fengzy on 15/11/21.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "UINavigationController+Util.h"


@implementation UINavigationController (Util)

- (BOOL)shouldAutorotate {
    
    return self.topViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (void)navigationBarOptimize {
    [self.view setBackgroundColor:[CommonFunction getGenderColor]];
    [self.navigationBar setBarTintColor:[CommonFunction getGenderColor]];
}

- (void)navCtrlConfig {
    NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionaryWithDictionary:self.navigationBar.titleTextAttributes];
    UIColor *color = [UIColor whiteColor];
    [titleTextAttributes setObject:color forKey:UITextAttributeTextColor];
    [titleTextAttributes setObject:font_Normal_16 forKey:UITextAttributeFont];
    UIOffset offset = UIOffsetMake(0, 0);
    [titleTextAttributes setObject:[NSValue valueWithUIOffset:offset] forKey:UITextAttributeTextShadowOffset];
    [titleTextAttributes setObject:[UIColor clearColor] forKey:UITextAttributeTextShadowColor];
    self.navigationBar.titleTextAttributes = titleTextAttributes;
    
    [self.view setBackgroundColor:[CommonFunction getGenderColor]];
    [self.navigationBar setBarTintColor:[CommonFunction getGenderColor]];
}

@end


@implementation UINavigationController (StatusBarStyleController)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma clang diagnostic pop

@end


@implementation UINavigationController (AutorotateController)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationPortrait == toInterfaceOrientation;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end


@implementation AutorotateOrientationNavigationController

- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [self.topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

@end