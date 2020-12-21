//
//  TFWxShareManager.m
//  TFThirdLib
//
//  Created by Daniel on 16/5/17.
//  Copyright © 2020年 daniel.xiaofei@gmail.com All rights reserved.
//

#import "TFWxShareManager.h"

@implementation TFWxShareManager

+ (void)share:(TFWxShareReq*)data
    success:(TFWxManagerSuccessBlock)successBlock
    failure:(TFWxManagerFailureBlock)failureBlock
     cancel:(TFWxManagerCancelBlock)cancelBlock
{
    [TFWxManager share:data success:successBlock failure:failureBlock cancel:cancelBlock];
}

+ (void)shareToMiniApp:(TFWxMiniAppReq*)data
               success:(TFWxManagerSuccessBlock)successBlock
               failure:(TFWxManagerFailureBlock)failureBlock
                cancel:(TFWxManagerCancelBlock)cancelBlock {
    [TFWxManager shareToMiniApp:data success:successBlock failure:failureBlock cancel:cancelBlock];
}

@end
