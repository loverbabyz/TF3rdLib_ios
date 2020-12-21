//
//  TFWxManager.h
//  TFThirdLib
//
//  Created by Daniel on 15/10/21.
//  Updated by SunXiaoFei on 20/08/25.
//  Copyright (c) 2020年 daniel.xiaofei@gmail.com All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/*! @brief 分享小程序类型
 *
 */
typedef NS_ENUM(NSUInteger, TFWXMiniProgramType) {
    TFWXMiniProgramTypeRelease  = 0,    //**< 正式版  */
    TFWXMiniProgramTypeTest     = 1,    //**< 开发版  */
    TFWXMiniProgramTypePreview  = 2,    //**< 体验版  */
};

/*! @brief 请求发送场景
 *
 */
enum TFWXScene {
    TFWXSceneSession          = 0,   /**< 聊天界面    */
    TFWXSceneTimeline         = 1,   /**< 朋友圈     */
    TFWXSceneFavorite         = 2,   /**< 收藏       */
    TFWXSceneSpecifiedSession = 3,   /**< 指定联系人  */
};

/// 微信支付请求模型
@interface TFWxPayReq : NSObject

/**
 *  商户号-微信支付分配的商户号
 */
@property(nonatomic, copy) NSString * partnerId;

/**
 *  预支付交易会话ID-微信返回的支付交易会话ID
 */
@property(nonatomic, copy) NSString * prepayId;

/**
 *  随机串，防重发
 */
@property(nonatomic, copy) NSString * nonceStr;

/**
 *  时间戳，防重发
 */
@property(nonatomic, copy) NSString * timeStamp;

/**
 *  商家根据微信开放平台文档对数据做的签名
 */
@property(nonatomic, copy) NSString * sign;

@end

/// 微信分享请求模型
@interface TFWxShareReq : NSObject

/**
 *  分享的文字
 */
@property(nonatomic, copy) NSString * title;

/** 描述内容
 * @note 长度不能超过1K
 */
@property (nonatomic, copy) NSString *desc;

/**
 *  分享的图片
 */
@property(nonatomic, strong) UIImage * image;

/**
 *  分享的链接
 */
@property(nonatomic, copy) NSString *URL;

/**
 *  商家根据微信开放平台文档对数据做的签名
 */
@property(nonatomic, assign) enum TFWXScene scene;

@end

/// 微信小程序请求模型
@interface TFWxMiniAppReq : NSObject

/**
 *  标题
 */
@property(nonatomic, copy) NSString * title;

/**
 *  描述
 */
@property(nonatomic, copy) NSString * desc;

/** 低版本网页链接
 * @attention 长度不能超过1024字节
 */
@property (nonatomic, copy) NSString *webpageUrl;

/** 小程序页面的路径
 * @attention 不填默认拉起小程序首页
 */
@property (nonatomic, copy) NSString *path;

/** 小程序新版本的预览图
 * @attention 大小不能超过128k
 */
@property (nonatomic, strong) NSData *hdImageData;

/** 是否使用带 shareTicket 的转发 */
@property (nonatomic, assign) BOOL withShareTicket;

/** 分享小程序的版本
 * @attention （正式，开发，体验）
 */
@property (nonatomic, assign) TFWXMiniProgramType miniProgramType;

/** 是否禁用转发 */
@property (nonatomic, assign) BOOL disableForward;

@end

/**
 *  微信支付管理类
 */
@interface TFWxManager : NSObject

/**
 * 支付成功回调
 */
typedef void (^TFWxManagerSuccessBlock) (void);

/**
 * 支付失败回调
 */
typedef void (^TFWxManagerFailureBlock) (int errorCode, NSString *errorMessage);

/**
 * 取消支付回调
 */
typedef void (^TFWxManagerCancelBlock) (void);

+ (instancetype)sharedManager;

/**
 *  微信支付接口
 *
 *  @param data         req
 *  @param successBlock 支付成功回调
 *  @param failureBlock 支付失败回调
 *  @param cancelBlock  取消支付回调
 */
+ (void)pay:(TFWxPayReq*)data
    success:(TFWxManagerSuccessBlock)successBlock
    failure:(TFWxManagerFailureBlock)failureBlock
     cancel:(TFWxManagerCancelBlock)cancelBlock;

/// 分享到微信接口
/// @param data req
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
/// @param cancelBlock 取消回调
+ (void)share:(TFWxShareReq*)data
    success:(TFWxManagerSuccessBlock)successBlock
    failure:(TFWxManagerFailureBlock)failureBlock
     cancel:(TFWxManagerCancelBlock)cancelBlock;

/// 分享小程序信息到微信接口
/// @param data req
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
/// @param cancelBlock 取消回调
+ (void)shareToMiniApp:(TFWxMiniAppReq*)data
               success:(TFWxManagerSuccessBlock)successBlock
               failure:(TFWxManagerFailureBlock)failureBlock
                cancel:(TFWxManagerCancelBlock)cancelBlock;

/**
 * 向微信终端程序注册第三方应用，需要在每次启动第三方应用程序时调用。
 *
 * @attention 请保证在主线程中调用此函数
 * @return 成功返回YES，失败返回NO。
 */
+ (BOOL)registerApp;

/// 拉起小程序
/// @param data 小程序需要的数据
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
/// @param cancelBlock 取消回调
+ (void)miniApp:(TFWxMiniAppReq*)data
        success:(TFWxManagerSuccessBlock)successBlock
        failure:(TFWxManagerFailureBlock)failureBlock
         cancel:(TFWxManagerCancelBlock)cancelBlock;

/*! @brief 检查微信是否已被用户安装
 *
 * @return 微信已安装返回YES，未安装返回NO。
 */
+(BOOL) isWXAppInstalled;

/*! @brief 判断当前微信的版本是否支持OpenApi
 *
 * @return 支持返回YES，不支持返回NO。
 */
+(BOOL) isWXAppSupportApi;

/*! @brief 获取微信的itunes安装地址
 *
 * @return 微信的安装地址字符串。
 */
+(NSString *) getWXAppInstallUrl;

/*! @brief 获取当前微信SDK的版本号
 *
 * @return 返回当前微信SDK的版本号
 */
+(NSString *) getApiVersion;

/*! @brief 打开微信
 *
 * @return 成功返回YES，失败返回NO。
 */
+(BOOL) openWXApp;

@end
