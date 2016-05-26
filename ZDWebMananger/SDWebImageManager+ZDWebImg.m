//
//  SDWebImageManager+ZDWebImg.m
//  ZDWebView
//
//  Created by william on 16/5/26.
//  Copyright © 2016年 william. All rights reserved.
//

#import "SDWebImageManager+ZDWebImg.h"

@implementation SDWebImageManager (ZDWebImg)
//根据img地址数组下载图片
- (void)loadImageWithImgArray:(NSArray*)imgArr  isPhoneNetwork:(BOOL)isPhoneNet jsBride:(WebViewJavascriptBridge*)bridge{
    if (!imgArr.count) {
        NSLog(@"图片地址数组无数据!!!!");
        return;
    }
    for (NSString*url in imgArr) {
        [self loadImageWithUrlString:url isPhoneNetwork:isPhoneNet jsBride:bridge];
    }
}
//根据网络类型判断是否加载
- (void)loadImageWithUrlString:(NSString*)url isPhoneNetwork:(BOOL)isPhoneNet jsBride:(WebViewJavascriptBridge*)bridge{
    NSURL *imageUrl = [NSURL URLWithString:url];
    //如果图片已经存在,直接加载
    NSString *cacheKey = [self cacheKeyForURL:imageUrl];
    NSString *imagePaths = [self.imageCache defaultCachePathForKey:cacheKey];
    // NSLog(@"imagePaths === %@",imagePaths);
    
    if ([self diskImageExistsForURL:imageUrl]) {
        [bridge send:[NSString stringWithFormat:@"replaceimage%@,file://%@",url,imagePaths]];
        /*!
         *  如果图片不存爱,进行下载
         */
    }else {
        //为手机网络
        if (isPhoneNet) {
            [bridge send:[NSString stringWithFormat:@"setClick%@,file://%@",url,imagePaths]];
        }else{
            [self loadImageWithUrlString:url jsBride:bridge];
            
        }
    }
    
    
}

//下载图片,并更新图片
- (void)loadImageWithUrlString:(NSString*)url jsBride:(WebViewJavascriptBridge*)bridge{
    if (url) {
        
        NSURL *imageUrl = [NSURL URLWithString:url];
        [self downloadImageWithURL:imageUrl options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
            
            if (image && finished) {//如果下载成功
                NSString *cacheKey = [self cacheKeyForURL:imageUrl];
                NSString *imagePaths = [self.imageCache defaultCachePathForKey:cacheKey];
                //NSLog(@"imagePaths === %@",imagePaths);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [bridge send:[NSString stringWithFormat:@"replaceimage%@,file://%@",url,imagePaths]];
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
