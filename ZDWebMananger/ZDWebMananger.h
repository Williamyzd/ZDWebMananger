//
//  ZDWebMananger.h
//  ZDWebView
//
//  Created by william on 16/5/26.
//  Copyright © 2016年 william. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ZDWebMananger : NSObject
/*!
 *  默认的图片名称,会根据图片名称获取本地地址 supportFiles中有默认图片
 */
@property (nonatomic, copy) NSString*defaultImg;
//**********如果为常规html只需调用前两个方法

/*!
 *  初始化管理器
 *
 *  @param webview  要加载的webview
 *  @param delegate  webview的代理,也可为空
 *
 *  @return 实例
 */
-(instancetype)initWithWebView:(UIWebView*)webview webViewDelegate:(id)delegate;

/*!
 *  替换标签,插入js并根据网络状况处理图片
 *
 *  @param url html所在地址
 *
 *  @param url isPhoneNetwork  是否为手机网络,若为手机网络点击图片之后才会下载并加载
 */
-(void)loadHtmlWithUrl:(NSString*)url  isPhoneNetwork:(BOOL)isPhoneNetwork;


//**********如果为json拼的html,且img标签id为图片互联网地址,并需要设置默认图片,则只需插入js文件,并手动选择图片处理逻辑所在位置
/*!
 *  默认注入的JS代码
 *
 *  @param html html字符串
 *
 *  @return 返回注入后的字符串
 */
- (NSString*)joinTheJScodeWithHtml:(NSString*)html;

/*!
 *  自定义注入js文件
 *
 *  @param fileName 文件名
 *  @param html     html字符串
 *
 *  @return 返回注入后的html字符串
 */
- (NSString*)joinTheJScodeWithFileName:(NSString*)fileName html:(NSString*)html;

/*!
 *  根据图片地址数组和网络状态处理图片
 *
 *  @param imgArr     图片地址数组
 *  @param isPhoneNet 网络状态
 */
- (void)loadImageWithImgArray:(NSArray*)imgArr  isPhoneNetwork:(BOOL)isPhoneNet;

@end
