//
//  MessagesDetailViewController.m
//  plan
//
//  Created by Fengzy on 15/12/10.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "MessagesDetailViewController.h"

@interface MessagesDetailViewController () {
    
    UIScrollView *scrollView;
}

@end

@implementation MessagesDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_ViewTitle_13;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!scrollView) {
        scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:scrollView];
        
        [self loadCustomView];
    }
}

- (void)loadCustomView {
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, WIDTH_FULL_SCREEN - 24, 50)];
    labelTitle.textColor = color_333333;
    labelTitle.font = font_Normal_18;
    labelTitle.numberOfLines = 2;
    labelTitle.text = self.message.title;
    [scrollView addSubview:labelTitle];
    
    UILabel *labelTime = [[UILabel alloc] initWithFrame:CGRectMake(12, 60, WIDTH_FULL_SCREEN - 24, 20)];
    labelTime.textColor = color_666666;
    labelTime.font = font_Normal_13;
    labelTime.text = self.message.createTime;
    [scrollView addSubview:labelTime];
    
    NSString *content = self.message.content;
    UILabel *labelContent = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    [labelContent setNumberOfLines:0];
    labelContent.lineBreakMode = NSLineBreakByWordWrapping;
    [labelContent setTextColor:color_666666];
    [labelContent setFont:font_Normal_16];
    [labelContent setText:content];
    CGSize size = CGSizeMake(WIDTH_FULL_SCREEN - 24, 2000);
    CGSize labelsize = [content sizeWithFont:font_Normal_16 constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    UITextView *txtViewContent = [[UITextView alloc] initWithFrame:CGRectMake(12, 80, labelsize.width, labelsize.height + 50)];
    txtViewContent.showsVerticalScrollIndicator = NO;
    txtViewContent.showsHorizontalScrollIndicator = NO;
    txtViewContent.editable = NO;
    txtViewContent.scrollEnabled = NO;
    txtViewContent.selectable = NO;
    txtViewContent.font = font_Normal_16;
    txtViewContent.textColor = color_666666;
    txtViewContent.text = content;
    [scrollView addSubview:txtViewContent];
    
    scrollView.contentSize = CGSizeMake(WIDTH_FULL_SCREEN, CGRectGetMaxY(txtViewContent.frame) + 64);
}

@end
