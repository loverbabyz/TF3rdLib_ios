//
//  TFWxShareManager.h
//  TFThirdLib
//
//  Created by Daniel on 16/5/17.
//  Copyright © 2020年 daniel.xiaofei@gmail.com All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "TFWxManager.h"

/**
 *  微信分享管理类
 */
@interface TFWxShareManager : NSObject

/**
 *  微信分享接口
 *
 *  @param data         req
 *  @param successBlock 分享成功回调
 *  @param failureBlock 分享失败回调
 *  @param cancelBlock  取消分享回调
 */
+ (void)share:(TFWxShareReq*)data
    success:(TFWxManagerSendMessageSuccessBlock)successBlock
    failure:(TFWxManagerSendMessageFailureBlock)failureBlock
     cancel:(TFWxManagerSendMessageCancelBlock)cancelBlock;

/**
 *  微信分享接口
 *
 *  @param data         req
 *  @param successBlock 分享成功回调
 *  @param failureBlock 分享失败回调
 *  @param cancelBlock  取消分享回调
 */
+ (void)shareToMiniApp:(TFWxMiniAppReq*)data
               success:(TFWxManagerSendMessageSuccessBlock)successBlock
               failure:(TFWxManagerSendMessageFailureBlock)failureBlock
                cancel:(TFWxManagerSendMessageCancelBlock)cancelBlock;

@end

