//
//  ZDWebMananger.m
//  ZDWebView
//
//  Created by william on 16/5/26.
//  Copyright © 2016年 william. All rights reserved.
//


#import "ZDWebMananger.h"
#import "WebViewJavascriptBridge.h"
#import "SDWebImageManager.h"

@interface ZDWebMananger ()
@property (nonatomic,weak)UIWebView *webView;
@property (nonatomic, strong) NSMutableArray *imgSrcArr;//解析html里面src的参数
//js桥接
@property (nonatomic, strong) WebViewJavascriptBridge *bridge;
//图片下载
@property (nonatomic, strong) SDWebImageManager *imgManager;

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
        [self loadImageWithUrlString:data];
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
        //转换文字
        html =    [self fixHtmlStringWithImge:self.defaultImg Html:html];
        [self.webView loadHTMLString:html baseURL:nil];
        [self loadImageWithImgArray:self.imgSrcArr isPhoneNetwork:isPhoneNetwork];
        
    }] resume];
}
//替换成本地图片
- (NSString*)fixHtmlStringWithImge:(NSString*)defaultImg Html:(NSString*)html{
    
    //正则获取图片标签
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<img[^>]*/>" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    NSArray *result = [regex matchesInString:html options:NSMatchingReportCompletion range:NSMakeRange(0, html.length)];
    
    //将图片标签存起来以方便替换
    NSMutableArray *mImgArr = [NSMutableArray array];
    // 此处需要考虑是否有不需要替换的图片
    for (int index=0; index<result.count; index++) {
        NSTextCheckingResult *item = result[index];
        NSString *imgHtml = [html substringWithRange:[item rangeAtIndex:0]];
        [mImgArr addObject:imgHtml];
        NSLog(@"第%d个标签:%@",index,imgHtml);
    }
    //替换图片
    html  =  [self fixImgElementsWithDefaultImg:defaultImg elementArrays:mImgArr.copy html:html];
    
    return html;
}
//根据标签数组来获取图片链接以及本地图片替换
- (NSString*)fixImgElementsWithDefaultImg:(NSString*)defaultImg elementArrays:(NSArray*)mImgArr  html:(NSString*) html{
    NSString *iconpath = [[NSBundle mainBundle] pathForResource:defaultImg ofType:nil];
    NSURL *logoImgUrl = [NSURL fileURLWithPath:iconpath];
    if (mImgArr.count) {
        for (NSString *imgHtml in mImgArr) {
            NSArray *tmpArray = nil;
            NSString *localImgPath;
            NSString *temptImgHtml = [NSString stringWithFormat:@"%@",imgHtml];
            //分割字符串
            if ([imgHtml rangeOfString:@"src=\""].location != NSNotFound) {
                tmpArray = [imgHtml componentsSeparatedByString:@"src=\""];
            } else if ([imgHtml rangeOfString:@"src="].location != NSNotFound) {
                tmpArray = [imgHtml componentsSeparatedByString:@"src="];
            }
            if (tmpArray.count >= 2) {
                NSString *src = nil;
                for (NSString *strign in tmpArray) {
                    //                        if([strign containsString:@"http"])
                    if([strign hasSuffix:@"/>"]){
                        src = strign;
                        
                    }
                }
                
                NSUInteger loc = [src rangeOfString:@"\""].location;
                if (loc != NSNotFound) {
                    src = [src substringToIndex:loc];
                    //是否是相对地址,将相对地址改为绝对地址
                    if ([src hasPrefix:@"./"]) {
                        NSString *tempt = [src stringByReplacingOccurrencesOfString:@"./" withString:@""];
                        tempt = [[NSString  stringWithFormat:@"%@",self.htmlUrl] stringByAppendingString:tempt];
                        temptImgHtml = [temptImgHtml stringByReplacingOccurrencesOfString:src withString:tempt];
                        src = tempt;
                    }
                    NSLog(@"正确解析出来的SRC为：%@", src);
                    if (src.length > 0) {
                        [self.imgSrcArr addObject:src];
                        NSURL *imageUrl = [NSURL URLWithString:src];
                        NSString *cacheKey = [self.imgManager cacheKeyForURL:imageUrl];
                        NSString *imagePaths = [self.imgManager.imageCache defaultCachePathForKey:cacheKey];
                        if ([self.imgManager diskImageExistsForURL:imageUrl]) {
                            
                            localImgPath =[NSURL fileURLWithPath:imagePaths].absoluteString;
                        }else{
                            localImgPath = logoImgUrl.absoluteString;
                            //                                [self loadImageWithUrlString:src NetType:0];
                        }
                        // NSLog(@"取得图片链接时的本地地址 === %@",localImgPath);
                        
                    }
                }
            }
            NSString *newString = [NSString stringWithFormat:@"src='%@' id",localImgPath];
            //           NSString  *newImgHtml= [imgHtml stringByReplacingOccurrencesOfString:@"oldsrc" withString:@"oldimg"];
            NSLog(@"--临时标签:%@",temptImgHtml);
            newString = [temptImgHtml stringByReplacingOccurrencesOfString:@"src" withString:newString];
            // NSLog(@"%@",newImgHtml);
            html = [html stringByReplacingOccurrencesOfString:imgHtml withString:newString];
            // NSLog(@"%@",html);
            
        }
    }
    //注入js代码
    
    html=  [self joinTheJScodeWithFileName:@"js.txt" html:html];
    
    
    return html;
}

//注入js代码

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

//根据img地址数组下载图片
- (void)loadImageWithImgArray:(NSArray*)imgArr  isPhoneNetwork:(BOOL)isPhoneNet{
    if (!imgArr.count) {
        NSLog(@"图片地址数组无数据!!!!");
        return;
    }
    for (NSString*url in imgArr) {
        [self loadImageWithUrlString:url isPhoneNetwork:isPhoneNet];
    }
}
//根据网络类型判断是否加载
- (void)loadImageWithUrlString:(NSString*)url isPhoneNetwork:(BOOL)isPhoneNet{
    NSURL *imageUrl = [NSURL URLWithString:url];
    //如果图片已经存在,直接加载
    NSString *cacheKey = [_imgManager cacheKeyForURL:imageUrl];
    NSString *imagePaths = [_imgManager.imageCache defaultCachePathForKey:cacheKey];
    // NSLog(@"imagePaths === %@",imagePaths);
    
    if ([self.imgManager diskImageExistsForURL:imageUrl]) {
        [_bridge send:[NSString stringWithFormat:@"replaceimage%@,file://%@",url,imagePaths]];
        /*!
         *  如果图片不存爱,进行下载
         */
    }else {
        //为手机网络
        if (isPhoneNet) {
            [_bridge send:[NSString stringWithFormat:@"setClick%@,file://%@",url,imagePaths]];
        }else{
            [self loadImageWithUrlString:url];
            
        }
    }
    
    
}

//下载图片,并更新图片
- (void)loadImageWithUrlString:(NSString*)url{
    if (url) {
        
        NSURL *imageUrl = [NSURL URLWithString:url];
        [self.imgManager downloadImageWithURL:imageUrl options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
            
            if (image && finished) {//如果下载成功
                NSString *cacheKey = [_imgManager cacheKeyForURL:imageUrl];
                NSString *imagePaths = [_imgManager.imageCache defaultCachePathForKey:cacheKey];                    //NSLog(@"imagePaths === %@",imagePaths);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_bridge send:[NSString stringWithFormat:@"replaceimage%@,file://%@",url,imagePaths]];
                });
                
            }else {
                NSLog(@"远程图片下载失败!");
            }
        }];
    }else{
        NSLog(@"图片链接为空");
    }
    
    
}



@end
