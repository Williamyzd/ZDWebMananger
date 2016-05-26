//
//  ZDWebMananger.m
//  ZDWebView
//
//  Created by william on 16/5/26.
//  Copyright © 2016年 william. All rights reserved.
//


#import "ZDWebMananger.h"
#import "WebViewJavascriptBridge.h"
#import "SDWebImageManager+ZDWebImg.h"
#import "ZDFixHtmlTool.h"

@interface ZDWebMananger ()
@property (nonatomic,weak)UIWebView *webView;
@property (nonatomic, strong) NSMutableArray *imgSrcArr;//解析html里面src的参数
//js桥接
@property (nonatomic, strong) WebViewJavascriptBridge *bridge;
//图片下载
@property (nonatomic, strong)SDWebImageManager  *imgManager;

@property(nonatomic,copy)NSString*   htmlUrl;
@end
@implementation ZDWebMananger

#pragma --mark -----------------------初始化方法-----------------------------
-(instancetype)initWithWebView:(UIWebView*)webview webViewDelegate:(id)delegate{
    self = [super init];
    if (self) {
        webview.delegate = delegate;
        [self setWebBridgeWithWeb:webview webDelegate:delegate];
        self.webView = webview;
    }
    return self;
}
//建立桥接
-(void)setWebBridgeWithWeb:(UIWebView*)webView webDelegate:(id)delegate{
    [WebViewJavascriptBridge enableLogging];
    _bridge =
    [WebViewJavascriptBridge bridgeForWebView:webView webViewDelegate:delegate handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"初始化了");
        
    }];
    
    [_bridge registerHandler:@"downloadImg" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"正在加载");
        [self.imgManager loadImageWithUrlString:data jsBride:_bridge];
    }];
}
//初始化图片下载管理器
- (SDWebImageManager *)imgManager{
    if (!_imgManager) {
        _imgManager = [SDWebImageManager sharedManager];
        //可有可无,可能sdweb内部做了相似的准换处理
        //        [[SDWebImageManager sharedManager] setCacheKeyFilter:^(NSURL *url) {
        //            url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
        //            //NSString *str = [self replaceUrlSpecialString:[url absoluteString]];
        //            return url.absoluteString;
        //        }];
        
        
    }
    return _imgManager;
}

- (NSString *)defaultImg{
    if (!_defaultImg.length) {
        _defaultImg= [NSString stringWithFormat:@"loading.jpg"];
        
    }
    return _defaultImg;
}

-(NSMutableArray *)imgSrcArr{
    if (!_imgSrcArr) {
        _imgSrcArr= [NSMutableArray array];
    }
    return _imgSrcArr;
}

#pragma --mark -----------------------处理html---------------------------
-(void)loadHtmlWithUrl:(NSString*)url  isPhoneNetwork:(BOOL)isPhoneNetwork{
    self.htmlUrl = url;
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if(!(html.length>2))
        {
            NSLog(@"详情加载失败!");
            return;
        }
        else
        {
            NSLog(@"详情加载成功!");
        }
        
        //替换IMG标签,添加id
       // html =  [self fixHtmlStringWithImge:self.defaultImg Html:html];
        ZDFixHtmlTool *htmlTool = [[ZDFixHtmlTool alloc]initWithHtmlUrl:url];
        [htmlTool fixHtml:html defaultImage:self.defaultImg finishBlock:^(NSString *endHtml, NSArray *imgAddresses) {
            //注入js代码
            NSString *ahtml=  [self joinTheJScodeWithFileName:@"js.txt" html:endHtml];
            //加载页面
            dispatch_async(dispatch_get_main_queue(), ^{
                 [self.webView loadHTMLString:ahtml baseURL:nil];
            });
           
            //下载图片
            [self.imgManager loadImageWithImgArray:imgAddresses isPhoneNetwork:isPhoneNetwork jsBride:_bridge];
        }];
        
        
        
    }] resume];
}

#pragma --mark -----------------------注入js代码---------------------------
- (NSString*)joinTheJScodeWithHtml:(NSString*)html{
    html=  [self joinTheJScodeWithFileName:@"js.txt" html:html];
    return html;
    
}
- (NSString*)joinTheJScodeWithFileName:(NSString*)fileName html:(NSString*)html{
    NSString *jsPaht = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSString *jsStr = [[NSString alloc]initWithContentsOfURL:[NSURL fileURLWithPath:jsPaht] encoding:NSUTF8StringEncoding error:nil];
    html = [html stringByReplacingOccurrencesOfString:@"</body>"  withString:jsStr];
    
    return html;
}


#pragma --mark -----------------------图片下载逻辑-----------------------------

////根据img地址数组下载图片
- (void)loadImageWithImgArray:(NSArray*)imgArr  isPhoneNetwork:(BOOL)isPhoneNet{
    [self.imgManager loadImageWithImgArray:imgArr isPhoneNetwork:isPhoneNet jsBride:_bridge];
    
    }



@end
