//
//  ZDFixHtmlTool.h
//  ZDWebView
//
//  Created by william on 16/5/26.
//  Copyright © 2016年 william. All rights reserved.
//

#import <Foundation/Foundation.h>
//运用正则以及字符串操作,将html字符串的img标签的图片地址换做本地地址,并且生成一个以真实图片地址为值的id属性
@interface ZDFixHtmlTool : NSObject

- (instancetype)initWithHtmlUrl:(NSString *)url;
- (void)fixHtml:(NSString*)html defaultImage:(NSString*)defaultImage finishBlock:(void(^)(NSString* endHtml, NSArray *imgAddresses)) finishBlock;
@end
