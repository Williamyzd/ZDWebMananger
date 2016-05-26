//
//  ZDFixHtmlTool.m
//  ZDWebView
//
//  Created by william on 16/5/26.
//  Copyright © 2016年 william. All rights reserved.
//

#import "ZDFixHtmlTool.h"
#import "SDWebImageManager.h"
@interface ZDFixHtmlTool ()
@property (nonatomic, strong) SDWebImageManager *imgManager;
@property (nonatomic, strong) NSMutableArray *imgSrcArr;//解析html里面src的参数
@property(nonatomic,copy)NSString*   htmlUrl;
//@property(nonatomic,copy)NSString*   html;
@end
@implementation ZDFixHtmlTool

- (instancetype)initWithHtmlUrl:(NSString *)url{
 
    self = [super init];
    if (self) {
        self.htmlUrl = url;
        self.imgSrcArr = [NSMutableArray array];
        self.imgManager = [SDWebImageManager sharedManager];
    }
    return self;

}
- (void)fixHtml:(NSString*)html defaultImage:(NSString*)defaultImage finishBlock:(void(^)(NSString* endHtml, NSArray *imgAddresses)) finishBlock{
     //self.html = html;
      NSArray *imgTags =   [self getImgElementsFrom:html];
      NSString* endHtml = [self fixImgElementsWithDefaultImg:defaultImage elementArrays:imgTags html:html];
    if (finishBlock) {
        finishBlock(endHtml,self.imgSrcArr);
    }
}
//获取标签数组
- (NSArray*)getImgElementsFrom:(NSString*)html{
   
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
    return mImgArr.copy;

    
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
            NSLog(@"--临时标签:%@",temptImgHtml);
            newString = [temptImgHtml stringByReplacingOccurrencesOfString:@"src" withString:newString];
            html = [html stringByReplacingOccurrencesOfString:imgHtml withString:newString];
            // NSLog(@"%@",html);
            
        }
    }
    
    return html;
}


@end
