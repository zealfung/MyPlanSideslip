//
//  WebViewController.m
//  plan
//
//  Created by Fengzy on 15/12/17.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate> {
    UIWebView *webView;
}

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadCustomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.url && self.url.length > 0) {
        [self showHUD];
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
        [webView loadRequest:request];
    }
}

- (void)loadCustomView {
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.opaque = NO;
    webView.delegate = self;
    webView.scalesPageToFit = YES;//自动对页面进行缩放以适应屏幕
    webView.backgroundColor = [UIColor clearColor];
    webView.contentMode = UIViewContentModeScaleToFill;
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];
}

//代理方法
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //返回YES，进行加载。通过UIWebViewNavigationType可以得到请求发起的原因
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //开始加载
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //完成加载
    [self hideHUD];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    //加载出错
    [self hideHUD];
    [self alertToastMessage:str_Common_Tips7];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
