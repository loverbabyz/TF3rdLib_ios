//
//  AdaPay.h
//  AdaPay
//
//  Created by willwang on 2019/7/16.
//  Copyright © 2019 com.huifu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@protocol AdaPayDelegate <NSObject>

@optional

/**
 交易结果处理回调

 @param result_code 返回码
 @param order_info 订单信息
 */
-(void)handlePayResult:(NSString *)result_code orderInfo:(NSDictionary *)order_info;

@end

@interface AdaPay : NSObject


/**
 回调结果处理代理
 */
@property(nonatomic, weak) id <AdaPayDelegate> delegate ;

/**
 查询支付结果的超时时间，默认为 120s
 */
@property(nonatomic, assign)NSInteger queryTimeout;

/**
 唤起支付时的启动页面
*/
@property(nonatomic, strong)UIViewController * viewController;
    
/**
 支付结果回调 APP scheme
 */
@property(nonatomic, strong)NSString * scheme;
/**
 获取 AdaPay 实例（单例对象）

 @return AdaPay 实例
 */
+(AdaPay *)shareInstance;

/**
 传入支付信息，异步回调等待支付结果
 
 @param payment 服务端返回的支付信息
 */
-(void)doPay:(NSString * _Nonnull)payment;



@end

NS_ASSUME_NONNULL_END
