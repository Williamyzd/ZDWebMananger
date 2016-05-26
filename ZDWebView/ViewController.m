//
//  ViewController.m
//  ZDWebView
//
//  Created by william on 16/5/25.
//  Copyright © 2016年 william. All rights reserved.
//
#define URL @"http://www.izijia.cn/shouji/shoujimdd/jgb6_5633/"
#import "ViewController.h"
#import "ZDWebMananger.h"
//#import "WebViewJavascriptBridge.h"
//#import "SDWebImageManager.h"
@interface ViewController ()<UIWebViewDelegate>
@property (nonatomic,weak)UIWebView *webView;
@end

@implementation ViewController
- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"web开始加载!");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
     NSLog(@"web成功加载!");
    
}
#pragma --mark -----------------------系统方法-----------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    UIWebView *webview  =[[UIWebView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:webview];
    self.webView = webview;
    ZDWebMananger* manager = [[ZDWebMananger alloc]initWithWebView:webview webViewDelegate:self];
    [manager loadHtmlWithUrl:URL isPhoneNetwork:YES];
   
    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
