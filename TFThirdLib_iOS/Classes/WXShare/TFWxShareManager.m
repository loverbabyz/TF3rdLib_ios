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
    success:(TFWxManagerSendMessageSuccessBlock)successBlock
    failure:(TFWxManagerSendMessageFailureBlock)failureBlock
     cancel:(TFWxManagerSendMessageCancelBlock)cancelBlock
{
    [TFWxManager share:data success:successBlock failure:failureBlock cancel:cancelBlock];
}

+ (void)shareToMiniApp:(TFWxMiniAppReq*)data
               success:(TFWxManagerSendMessageSuccessBlock)successBlock
               failure:(TFWxManagerSendMessageFailureBlock)failureBlock
                cancel:(TFWxManagerSendMessageCancelBlock)cancelBlock {
    [TFWxManager shareToMiniApp:data success:successBlock failure:failureBlock cancel:cancelBlock];
}

@end
