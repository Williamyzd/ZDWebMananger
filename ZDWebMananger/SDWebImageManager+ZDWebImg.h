//
//  SDWebImageManager+ZDWebImg.h
//  ZDWebView
//
//  Created by william on 16/5/26.
//  Copyright © 2016年 william. All rights reserved.
//

#import "SDWebImageManager.h"
#import "WebViewJavascriptBridge.h"
@interface SDWebImageManager (ZDWebImg)
//根据数组和网络状态加载图片
- (void)loadImageWithImgArray:(NSArray*)imgArr  isPhoneNetwork:(BOOL)isPhoneNet  jsBride:(WebViewJavascriptBridge*)bridge;
//直接加载图片
- (void)loadImageWithUrlString:(NSString*)url jsBride:(WebViewJavascriptBridge*)bridge;
@end
