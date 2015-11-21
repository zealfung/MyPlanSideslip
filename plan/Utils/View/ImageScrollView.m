//
//  ImageScrollView.m
//  plan
//
//  Created by Fengzy on 15/11/21.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "ImageScrollView.h"

NSUInteger const kMinimumZoomScale = 1;
NSUInteger const kMaximumZoomScale = 3;

@implementation ImageScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.minimumZoomScale = kMinimumZoomScale;
        self.maximumZoomScale = kMaximumZoomScale;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        self.scaling = NO;
    }
    return self;
}

- (void)autoZoomScale {
    if (self.scaling) {
        [self setZoomScale:kMinimumZoomScale animated:YES];
    } else {
        [self setZoomScale:kMinimumZoomScale * 2 animated:YES];
    }
    self.scaling = !self.scaling;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
