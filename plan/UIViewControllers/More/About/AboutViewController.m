//
//  AboutViewController.m
//  plan
//
//  Created by Fengzy on 15/9/1.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController()

@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UILabel *labelCompany;
@property (strong, nonatomic) UILabel *labelEnglishName;
@property (assign, nonatomic) NSUInteger xMiddle;
@property (assign, nonatomic) NSUInteger yOffset;

@end

@implementation AboutViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = str_More_About;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.bgImageView) {
        
        [self loadCustomView];
    }
}

- (void)loadCustomView {
    [self showLogo];
    
    {
        NSString *content = str_About_Name;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
        [label setNumberOfLines:0];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [label setTextColor:color_GrayLight];
        UIFont *font = font_Normal_16;
        [label setFont:font];
        [label setText:content];
        CGSize size = CGSizeMake(WIDTH_FULL_SCREEN - 60, 2000);
        CGFloat yLabel = self.yOffset;
        CGSize labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        label.frame = CGRectMake(self.xMiddle - labelsize.width/2, yLabel, labelsize.width, labelsize.height);
        [self.bgImageView addSubview:label];
        self.labelEnglishName = label;
        
        self.yOffset += labelsize.height + 10;
    }
    {
        NSString *content = str_About_Copyright;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
        [label setNumberOfLines:0];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [label setTextColor:color_GrayLight];
        UIFont *font = font_Normal_16;
        [label setFont:font];
        [label setText:content];
        CGSize size = CGSizeMake(WIDTH_FULL_SCREEN - 60, 2000);
        CGFloat yLabel = self.yOffset;
        CGSize labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        label.frame = CGRectMake(self.xMiddle - labelsize.width/2, yLabel, labelsize.width, labelsize.height);
        [self.bgImageView addSubview:label];
        self.labelCompany = label;
        
        self.yOffset += labelsize.height + 10;
    }

}

- (void)showLogo {
    
    self.xMiddle = WIDTH_FULL_SCREEN / 2;
    
    UIImage *image = [UIImage imageNamed:png_Bg_LaunchImage];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, HEIGHT_FULL_SCREEN)];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image = image;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    self.bgImageView = imageView;
 
    {
        NSString *version = [NSString stringWithFormat:@"%@%@", str_About_Version, [CommonFunction getAppVersion]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
        [label setNumberOfLines:0];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [label setTextColor:color_Blue];
        UIFont *font = font_Normal_16;
        [label setFont:font];
        [label setText:version];
        label.textAlignment = NSTextAlignmentCenter;
        CGSize size = CGSizeMake(WIDTH_FULL_SCREEN - 60, 2000);
        CGFloat yLabel = HEIGHT_FULL_SCREEN * 2 / 3 ;
        CGSize labelsize = [version sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        label.frame = CGRectMake(self.xMiddle - labelsize.width/2, yLabel, labelsize.width, labelsize.height);
        [self.bgImageView addSubview:label];
        
        self.yOffset = CGRectGetMaxY(label.frame) + 30;
    }
}


@end
