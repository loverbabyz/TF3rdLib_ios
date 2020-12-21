//
//  TFAdaPayManager.m
//  TFThirdLib
//
//  Created by sunxiaofei on 15/9/19.
//  Copyright (c) 2020年 daniel.xiaofei@gmail.com All rights reserved.
//

#import "TFAdaPayManager.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "Aspects.h"

#import <AdaPay/AdaPay.h>

@implementation TFAdaPayReq

@end;

@interface TFAdaPayManager()<AdaPayDelegate>

@end
@implementation TFAdaPayManager

static const void *TFAdaPayManagerCompletionBlockKey     = &TFAdaPayManagerCompletionBlockKey;

+ (void)load {
    [super load];
    [[self class] checkAppDelegate];
    [[self class] trackAppDelegate];
}

+ (void)checkAppDelegate {
    Class cls=NSClassFromString(@"AppDelegate");
    
    SEL cmd1 = @selector(application:handleOpenURL:);
    SEL cmd2 = @selector(application:openURL:sourceApplication:annotation:);
    
    Method method1 = class_getInstanceMethod(cls, cmd1);
    Method method2 = class_getInstanceMethod(cls, cmd2);
    
    if (!method1) {
        class_addMethod(cls, cmd1, (IMP)dynamicMethod1_tfalipay , "v@:@@");
    }
    
    if (!method2) {
        class_addMethod(cls, cmd2, (IMP)dynamicMethod2_tfalipay , "v@:@@@@");
    }
}

BOOL dynamicMethod1_tfalipay(id _self, SEL cmd,UIApplication *application ,NSURL *url) {
    return YES;
}

BOOL dynamicMethod2_tfalipay(id _self, SEL cmd,UIApplication *application ,NSURL *url, NSString *sourceApplication,id annotation) {
    return YES;
}

+ (void)trackAppDelegate {

}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static TFAdaPayManager *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TFAdaPayManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    
    return self;
}

+ (void)pay:(TFAdaPayReq*)data completion:(TFAdaPayManagerCompletionBlock)completion {
    [[[self class] sharedManager] pay: data completion:completion];
}

- (void)pay:(TFAdaPayReq*)data completion:(TFAdaPayManagerCompletionBlock)completion {
    [self setCompletionBlock:completion];
    
    static NSString *payType = @"alipay";

    AdaPay *adaPay = [AdaPay shareInstance];
    adaPay.queryTimeout = 60;
    adaPay.delegate = self;
    
    if ([payType isEqualToString:@"alipay"]) {
        adaPay.scheme = @"alipaydemo";
    } else{
        adaPay.scheme = @"union_pay_demo";
        adaPay.viewController = data.viewController;
    }
    
    [adaPay doPay:data.payInfo];
}

#pragma mark - AdaPayDelegate

- (void)handlePayResult:(NSString *)result_code orderInfo:(NSDictionary *)order_info{
    /// resultCode 交易结果码
    NSLog(@"resultCode,,,,,,%@",result_code);
    
    /// 订单信息 payInfo
    NSLog(@"payInfo,,,,,,%@",order_info);
    
    TFAdaPayManagerCompletionBlock block = self.completionBlock;
    if (block) {
        block(result_code, order_info);
    }
}

#pragma mark- Block setting/getting methods

- (void)setCompletionBlock:(TFAdaPayManagerCompletionBlock)block {
    objc_setAssociatedObject(self, TFAdaPayManagerCompletionBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (TFAdaPayManagerCompletionBlock)completionBlock {
    return objc_getAssociatedObject(self, TFAdaPayManagerCompletionBlockKey);
}

@end
