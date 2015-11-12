//
//  HelpViewController.m
//  plan
//
//  Created by Fengzy on 15/9/9.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@property (nonatomic, strong) UIWebView *webView;

@end


@implementation HelpViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.title = str_More_Help;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.webView) {
        [self loadCustomView];
    }
}

- (void)loadCustomView {
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.backgroundColor = [UIColor whiteColor];
    webView.opaque = YES;
    [self.view addSubview:webView];
    self.webView = webView;
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"help"
                                                         ofType:@"html"
                                                    inDirectory:@"Questions"];
    
    NSURL *url = [NSURL fileURLWithPath:htmlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

@end
