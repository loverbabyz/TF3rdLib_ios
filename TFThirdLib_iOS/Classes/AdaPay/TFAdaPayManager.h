//
//  TFAdaPayManager.h
//  TFThirdLib
//
//  Created by sunxiaofei on 15/9/19.
//  Copyright (c) 2020年 daniel.xiaofei@gmail.com All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TFAdaPayReq : NSObject

/**
 *  支付信息
 */
@property(nonatomic, strong) id payInfo;

/**
 * 支付VC
 */
@property(nonatomic, strong) UIViewController *viewController;

@end

/**
 *  Ada支付管理类
 */
@interface TFAdaPayManager : NSObject

/**
 * 支付完成回调
 */
typedef void (^TFAdaPayManagerCompletionBlock) (NSString *errorCode, NSDictionary *result);


/**
 *  支付接口
 *
 *  @param data         req
 *  @param completion 支付完成回调
 */
+ (void)pay:(TFAdaPayReq*)data completion:(TFAdaPayManagerCompletionBlock)completion;

@end
