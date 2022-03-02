//
//  TFWxManager.m
//  TFThirdLib
//
//  Created by Daniel on 15/10/21.
//  Updated by SunXiaoFei on 20/08/25.
//  Copyright (c) 2020年 daniel.xiaofei@gmail.com All rights reserved.
//

#import "TFWxManager.h"
#import <Aspects/Aspects.h>
#import <objc/runtime.h>
#import "TFThirdLib.h"

#import "WXApi.h"
#import "WXApiObject.h"

@implementation TFWxPayReq

@end

@implementation TFWxShareReq

@end

@implementation TFWxMiniAppReq

@end

@implementation TFWxAuthReq

@end

@implementation TFWXOpenBusinessViewReq

@end

@interface TFWxManager()<WXApiDelegate>

@end
@implementation TFWxManager

static const void *TFWxManagerSendMessageSuccessBlockKey        = &TFWxManagerSendMessageSuccessBlockKey;
static const void *TFWxManagerSendMessageFailureBlockKey        = &TFWxManagerSendMessageFailureBlockKey;
static const void *TFWxManagerSendMessageCancelBlockKey         = &TFWxManagerSendMessageCancelBlockKey;

static const void *TFWxManagerPaySuccessBlockKey                = &TFWxManagerPaySuccessBlockKey;
static const void *TFWxManagerPayFailureBlockKey                = &TFWxManagerPayFailureBlockKey;
static const void *TFWxManagerPayCancelBlockKey                 = &TFWxManagerPayCancelBlockKey;

static const void *TFWxManagerAuthCodeCallbackBlockKey          = &TFWxManagerAuthCodeCallbackBlockKey;

static const void *TFWxManagerOpenBusinessViewSuccessBlockKey   = &TFWxManagerOpenBusinessViewSuccessBlockKey;
static const void *TFWxManagerOpenBusinessViewFailureBlockKey   = &TFWxManagerOpenBusinessViewFailureBlockKey;
static const void *TFWxManagerOpenBusinessViewCancelBlockKey    = &TFWxManagerOpenBusinessViewCancelBlockKey;

+ (void)load {
    [super load];
    
    [[self class] checkAppDelegate];
    [[self class] trackAppDelegate];
}

+ (void)checkAppDelegate {
    Class cls = NSClassFromString([TFThirdLib appDelegateClassString]);
    
    SEL cmd1 = @selector(application:handleOpenURL:);
    SEL cmd2 = @selector(application:openURL:sourceApplication:annotation:);
    
    Method method1 = class_getInstanceMethod(cls, cmd1);
    Method method2 = class_getInstanceMethod(cls, cmd2);
    
    if (!method1) {
        class_addMethod(cls, cmd1, (IMP)dynamicMethod1_tfwxpay, "v@:@@");
    }
    
    if (!method2) {
        class_addMethod(cls, cmd2, (IMP)dynamicMethod2_tfwxpay, "v@:@@@@");
    }
}

BOOL dynamicMethod1_tfwxpay(id _self, SEL cmd,UIApplication *application ,NSURL *url) {
    return YES;
}

BOOL dynamicMethod2_tfwxpay(id _self, SEL cmd,UIApplication *application ,NSURL *url, NSString *sourceApplication,id annotation) {
    return YES;
}

+ (void)trackAppDelegate {
    [NSClassFromString([TFThirdLib appDelegateClassString])
     aspect_hookSelector:@selector(application:didFinishLaunchingWithOptions:)
     withOptions:AspectPositionBefore
     usingBlock:^(id<AspectInfo> aspectInfo, id application,id launchOptions){
         /// Required
        NSString *appid = [[self class] _wxappid];
        if (appid == nil || [appid length] <= 0) {
            [[self class] log:@"APP_ID未配置"];
            
            return;
        }
        
        NSString *universalLink = [[self class] _universalLink];
        if (universalLink == nil || [universalLink length] <= 0) {
            [[self class] log:@"UNIVERSAL_LINK未配置"];
            
            return;
        }
#if DEBUG
        //在register之前打开log, 后续可以根据log排查问题
        [WXApi startLogByLevel:WXLogLevelDetail logBlock:^(NSString *log) {
            [[self class] log:[NSString stringWithFormat:@"WeChatSDK: %@", log]];
        }];
#endif
        BOOL result = NO;
        /// 向微信注册
        result = [WXApi registerApp:appid universalLink:universalLink];
        
#if DEBUG
        /// 必须放在DEBUG模式，否则每次都会跳转到微信
        if (result) {
            //调用自检函数之前必须要先注册
//            [WXApi checkUniversalLinkReady:^(WXULCheckStep step, WXCheckULStepResult* result) {
//                [[self class] log:[NSString stringWithFormat:@"%@, %u, %@, %@", @(step), result.success, result.errorInfo, result.suggestion]];
//            }];
        }
#endif
     }
     error:NULL];
    
    [NSClassFromString([TFThirdLib appDelegateClassString])
     aspect_hookSelector:@selector(application:handleOpenURL:)
     withOptions:AspectPositionBefore
     usingBlock:^(id<AspectInfo> aspectInfo, id application, id url){
        [[self class] log:[NSString stringWithFormat:@"application:handleOpenURL:===%@", url]];
        
         // Required
        return [WXApi handleOpenURL:url delegate:[[self class] sharedManager]];
     }
     error:NULL];
    
    [NSClassFromString([TFThirdLib appDelegateClassString])
     aspect_hookSelector:@selector(application:openURL:sourceApplication:annotation:)
     withOptions:AspectPositionBefore
     usingBlock:^(id<AspectInfo> aspectInfo, id application, id url, id sourceApplication, id annotation){
        [[self class] log:[NSString stringWithFormat:@"application:openURL:sourceApplication:annotation:===%@", url]];
        
         // Required
        return [WXApi handleOpenURL:url delegate:[[self class] sharedManager]];
     }
     error:NULL];
    
    /// NOTE: 9.0以后使用新API接口
    [NSClassFromString([TFThirdLib appDelegateClassString])
     aspect_hookSelector:@selector(application:openURL:options:)
     withOptions:AspectPositionBefore
     usingBlock:^(id<AspectInfo> aspectInfo, id application, id url, id options) {
        [[self class] log:[NSString stringWithFormat:@"application:openURL:options:===%@", url]];
        
        return  [WXApi handleOpenURL:url delegate:[[self class] sharedManager]];
    }
     error:NULL];
    
    [NSClassFromString([TFThirdLib appDelegateClassString])
     aspect_hookSelector:@selector(application:continueUserActivity:restorationHandler:)
     withOptions:AspectPositionBefore
     usingBlock:^(id<AspectInfo> aspectInfo, id application, id userActivity, id restorationHandler) {
        return [WXApi handleOpenUniversalLink:userActivity delegate:[[self class] sharedManager]];
    }
     error:NULL];
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static TFWxManager *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TFWxManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
    
    }
    
    return self;
}

/// 输出log
/// @param message message
+ (void)log:(NSString *)message {
    NSLog(@"[%@] 🤖 %@", [self class], message);
}

#pragma mark -
#pragma mark WXApiDelegate

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp *messageResp = (SendMessageToWXResp *)resp;
        
        NSLog(@"%@", messageResp);
        switch (resp.errCode) {
            case WXSuccess:
            {
                TFWxManagerSendMessageSuccessBlock block = self.sendMessageSuccessBlock;
                if (block) {
                    block();
                }
                
                break;
            }
            case WXErrCodeUserCancel:
            {
                TFWxManagerSendMessageFailureBlock block = self.sendMessageFailureBlock;
                if (block) {
                    block(resp.errCode,resp.errStr);
                }
                
                break;
            }
            default:
            {
                TFWxManagerSendMessageCancelBlock block = self.sendMessageCancelBlock;
                if (block) {
                    block();
                }
                
                break;
            }
        }
    } else if([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *sendAuthResp = (SendAuthResp *)resp;
        TFWxManagerAuthCodeCallbackBlock block = self.authCodeCallbackBlockBlock;
        if (block) {
            block(sendAuthResp.code);
        }
        NSLog(@"%@", sendAuthResp);
    } else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]]) {
        NSLog(@"%@", resp);
    } else if ([resp isKindOfClass:[WXChooseCardResp class]]) {
        NSLog(@"%@", resp);
    } else if ([resp isKindOfClass:[WXChooseInvoiceResp class]]){
        NSLog(@"%@", resp);
    } else if ([resp isKindOfClass:[WXSubscribeMsgResp class]]){
        NSLog(@"%@", resp);
    } else if ([resp isKindOfClass:[WXLaunchMiniProgramResp class]]){
        NSLog(@"%@", resp);
    } else if([resp isKindOfClass:[WXInvoiceAuthInsertResp class]]){
        NSLog(@"%@", resp);
    } else if([resp isKindOfClass:[WXNontaxPayResp class]]){
        NSLog(@"%@", resp);
    } else if ([resp isKindOfClass:[WXPayInsuranceResp class]]){
        NSLog(@"%@", resp);
    }  else if([resp isKindOfClass:[PayResp class]]) {
        PayResp *payResp = (PayResp *)resp;
        
        NSLog(@"%@", payResp);
        switch (resp.errCode) {
            case WXSuccess:
            {
                TFWxManagerPaySuccessBlock block = self.paySuccessBlock;
                if (block) {
                    block();
                }
                
                break;
            }
            case WXErrCodeUserCancel:
            {
                TFWxManagerPayCancelBlock block = self.payCancelBlock;
                if (block) {
                    block();
                }
                
                break;
            }
            default:
            {
                TFWxManagerPayFailureBlock block = self.payFailureBlock;
                if (block) {
                    block(resp.errCode, resp.errStr);
                }
                
                break;
            }
        }
    }
    else if ([resp isKindOfClass:[WXOpenBusinessViewReq class]]) {
        WXOpenBusinessViewReq *busResp = (WXOpenBusinessViewReq *)resp;
        
        NSLog(@"%@", busResp);
        switch (resp.errCode) {
            case WXSuccess:
            {
                TFWxManagerOpenBusinessViewSuccessBlock block = self.openBusinessViewSuccessBlock;
                if (block) {
                    block();
                }
                
                break;
            }
            case WXErrCodeUserCancel:
            {
                TFWxManagerOpenBusinessViewCancelBlock block = self.openBusinessViewCancelBlock;
                if (block) {
                    block();
                }
                
                break;
            }
            default:
            {
                TFWxManagerOpenBusinessViewFailureBlock block = self.openBusinessViewFailureBlock;
                if (block) {
                    block(resp.errCode, resp.errStr);
                }
                
                break;
            }
        }
    }
}

- (void)onReq:(BaseReq *)req {
    if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {
//        if (_delegate
//            && [_delegate respondsToSelector:@selector(managerDidRecvShowMessageReq:)]) {
//            ShowMessageFromWXReq *showMessageReq = (ShowMessageFromWXReq *)req;
//            [_delegate managerDidRecvShowMessageReq:showMessageReq];
//        }
    } else if ([req isKindOfClass:[LaunchFromWXReq class]]) {
//        if (_delegate
//            && [_delegate respondsToSelector:@selector(managerDidRecvLaunchFromWXReq:)]) {
//            LaunchFromWXReq *launchReq = (LaunchFromWXReq *)req;
//            [_delegate managerDidRecvLaunchFromWXReq:launchReq];
//        }
    }
    NSLog(@"req:%@", req);
}

- (NSString *)genTimeStamp {
    return [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
}

+ (BOOL) isWXAppInstalled {
    return [WXApi isWXAppInstalled];
}

+ (BOOL) isWXAppSupportApi {
    return [WXApi isWXAppSupportApi];
}

+ (NSString *) getWXAppInstallUrl {
    return [WXApi getWXAppInstallUrl];
}

+ (NSString *) getApiVersion {
    return [WXApi getApiVersion];
}

+ (BOOL) openWXApp {
    return [WXApi openWXApp];
}

+ (void)pay:(TFWxPayReq*)data
    success:(TFWxManagerPaySuccessBlock)successBlock
    failure:(TFWxManagerPayFailureBlock)failureBlock
     cancel:(TFWxManagerPayCancelBlock)cancelBlock {
    [[[self class] sharedManager] pay:data success:successBlock failure:failureBlock cancel:cancelBlock];
}

+ (void)share:(TFWxShareReq*)data
      success:(TFWxManagerSendMessageSuccessBlock)successBlock
      failure:(TFWxManagerSendMessageFailureBlock)failureBlock
       cancel:(TFWxManagerSendMessageCancelBlock)cancelBlock {
    [[[self class] sharedManager] share:data success:successBlock failure:failureBlock cancel:cancelBlock];
}

+ (void)shareToMiniApp:(TFWxMiniAppReq*)data
               success:(TFWxManagerSendMessageSuccessBlock)successBlock
               failure:(TFWxManagerSendMessageFailureBlock)failureBlock
                cancel:(TFWxManagerSendMessageCancelBlock)cancelBlock {
    [[[self class] sharedManager] shareToMiniApp:data success:successBlock failure:failureBlock cancel:cancelBlock];
}

+ (void)miniApp:(TFWxMiniAppReq*)data
        success:(TFWxManagerSendMessageSuccessBlock)successBlock
        failure:(TFWxManagerSendMessageFailureBlock)failureBlock
         cancel:(TFWxManagerSendMessageCancelBlock)cancelBlock {
    [[[self class] sharedManager] miniApp:data success:successBlock failure:failureBlock cancel:cancelBlock];
}

+ (BOOL)registerApp {
    return [[[self class] sharedManager] registerApp];
}

+ (void)sendAuthReq:(TFWxAuthReq *)req
      callBackBlock:(TFWxManagerAuthCodeCallbackBlock)callBackBlock {
    [[[self class] sharedManager] sendAuthReq:req callBackBlock:callBackBlock];
}

+ (void)openBusinessViewReq: (TFWXOpenBusinessViewReq *)req
                    success:(TFWxManagerOpenBusinessViewSuccessBlock)successBlock
                    failure:(TFWxManagerOpenBusinessViewFailureBlock)failureBlock
                     cancel:(TFWxManagerOpenBusinessViewCancelBlock)cancelBlock {
    [[[self class] sharedManager] openBusinessViewReq:req success:successBlock failure:failureBlock cancel:cancelBlock];
}

- (void)pay:(TFWxPayReq*)data
    success:(TFWxManagerPaySuccessBlock)successBlock
    failure:(TFWxManagerPayFailureBlock)failureBlock
     cancel:(TFWxManagerPayCancelBlock)cancelBlock {
    //
    if (![WXApi isWXAppInstalled]||![WXApi isWXAppSupportApi]) {
        if (failureBlock) {
            failureBlock(-1000, @"您还没有安装微信客户端,或者版本太低");
        }
        
        return;
    }
    
    [self setPaySuccessBlock:successBlock];
    [self setPayFailureBlock:failureBlock];
    [self setPayCancelBlock:cancelBlock];
    
    PayReq *request   = [[PayReq alloc] init];
    request.sign = data.sign;
    request.package   = @"Sign=WXPay";
    request.timeStamp = data.timeStamp.intValue;
    request.nonceStr = data.nonceStr;
    request.prepayId = data.prepayId;
    request.partnerId = data.partnerId;
    
    [WXApi sendReq:request completion:^(BOOL success) {
        
    }];
}

- (void)share:(TFWxShareReq*)data
    success:(TFWxManagerSendMessageSuccessBlock)successBlock
    failure:(TFWxManagerSendMessageFailureBlock)failureBlock
     cancel:(TFWxManagerSendMessageCancelBlock)cancelBlock {
    //
    if (![WXApi isWXAppInstalled]||![WXApi isWXAppSupportApi]) {
        if (failureBlock) {
            failureBlock(-1000, @"您还没有安装微信客户端,或者版本太低");
        }
        
        return;
    }
    
    [self setSendMessageSuccessBlock:successBlock];
    [self setSendMessageFailureBlock:failureBlock];
    [self setSendMessageCancelBlock:cancelBlock];

    SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
    req.scene=data.scene;
    
    if (data.image != nil || data.URL != nil) {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = data.title;
        message.description = data.desc;

        [message setThumbImage: [self imageWithImage:data.image scaledToSize:CGSizeMake(80, 80)]];
        
        id mediaObject = nil;
        // WXImageObject
        if (data.image) {
            WXImageObject *imageObject = [WXImageObject object];
            imageObject.imageData = UIImagePNGRepresentation(data.image);
            
            mediaObject = imageObject;
        }
        
        // WXMusicObject
        // TODO:
        
        // WXVideoObject
        // TODO:
        
        // WXWebpageObject
        if (data.URL && data.URL.length > 0) {
            WXWebpageObject *webpageObject = [WXWebpageObject object];
            webpageObject.webpageUrl = data.URL;
            
            mediaObject = webpageObject;
        }
        
       
        if (mediaObject) {
            message.mediaObject = mediaObject;
        }
        
        req.message = message;
        req.bText = NO;
    } else {
        req.text = data.title;
        req.bText = YES;
    }
    
    [WXApi sendReq:req completion:^(BOOL success) {
        
    }];
}

- (void)shareToMiniApp:(TFWxMiniAppReq*)data
    success:(TFWxManagerSendMessageSuccessBlock)successBlock
    failure:(TFWxManagerSendMessageFailureBlock)failureBlock
     cancel:(TFWxManagerSendMessageCancelBlock)cancelBlock {
    //
    if (![WXApi isWXAppInstalled]||![WXApi isWXAppSupportApi]) {
        if (failureBlock) {
            failureBlock(-1000, @"您还没有安装微信客户端,或者版本太低");
        }
        
        return;
    }
    
    [self setSendMessageSuccessBlock:successBlock];
    [self setSendMessageFailureBlock:failureBlock];
    [self setSendMessageCancelBlock:cancelBlock];

    WXMiniProgramObject *object = [WXMiniProgramObject object];
    object.webpageUrl = data.webpageUrl;
    object.userName = [[self class] _wxminiappid];
    object.path = data.path;
    object.hdImageData = data.hdImageData;
    object.withShareTicket = data.withShareTicket;
    object.miniProgramType = (WXMiniProgramType)data.miniProgramType;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = data.title;
    message.description = data.desc;
    
    // 兼容旧版本节点的图片，小于32KB，新版本优先
    // 使用WXMiniProgramObject的hdImageData属性
    message.thumbData = nil;
    message.mediaObject = object;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;  //目前只支持会话

    [WXApi sendReq:req completion:^(BOOL success) {
        
    }];
}

- (void)miniApp:(TFWxMiniAppReq*)data
        success:(TFWxManagerSendMessageSuccessBlock)successBlock
        failure:(TFWxManagerSendMessageFailureBlock)failureBlock
         cancel:(TFWxManagerSendMessageCancelBlock)cancelBlock {
    //
    if (![WXApi isWXAppInstalled]||![WXApi isWXAppSupportApi]) {
        if (failureBlock) {
            failureBlock(-1000, @"您还没有安装微信客户端,或者版本太低");
        }
        
        return;
    }
    
    [self setSendMessageSuccessBlock:successBlock];
    [self setSendMessageFailureBlock:failureBlock];
    [self setSendMessageCancelBlock:cancelBlock];

    WXLaunchMiniProgramReq *req = [WXLaunchMiniProgramReq object];
    
    /// 拉起的小程序的username
    req.userName = [[self class] _wxminiappid];
    
    /// 拉起小程序页面的可带参路径，不填默认拉起小程序首页，对于小游戏，可以只传入 query 部分，来实现传参效果，如：传入 "?foo=bar"。
    req.path = data.path;
    
    /// 拉起小程序的类型（正式、开发、体验）
    req.miniProgramType = (WXMiniProgramType)data.miniProgramType;
    
    [WXApi sendReq:req completion:^(BOOL success) {
        
    }];
}

- (BOOL)registerApp {
    return [WXApi registerApp:[[self class] _wxappid] universalLink:[[self class] _universalLink]];
}

- (void)sendAuthReq:(TFWxAuthReq *)req
      callBackBlock:(TFWxManagerAuthCodeCallbackBlock)callBackBlock {
    
    [self setAuthCodeCallbackBlockBlock:callBackBlock];
    
    SendAuthReq *sendAuthReq = [[SendAuthReq alloc] init];
    sendAuthReq.scope = req.scope;
    sendAuthReq.state = req.state;
    
    [WXApi sendReq:sendAuthReq completion:^(BOOL success) {
            
    }];
}

- (void)openBusinessViewReq:(TFWXOpenBusinessViewReq *)req
                    success:(TFWxManagerOpenBusinessViewSuccessBlock)successBlock
                    failure:(TFWxManagerOpenBusinessViewFailureBlock)failureBlock
                     cancel:(TFWxManagerOpenBusinessViewCancelBlock)cancelBlock {
    [self setOpenBusinessViewSuccessBlock:successBlock];
    [self setOpenBusinessViewFailureBlock:failureBlock];
    [self setOpenBusinessViewCancelBlock:cancelBlock];
    
    WXOpenBusinessViewReq *openBusinessViewReq = [WXOpenBusinessViewReq object];
    openBusinessViewReq.businessType = req.businessType;
    openBusinessViewReq.query = req.query;
    openBusinessViewReq.extInfo = req.extInfo;
    openBusinessViewReq.extData = req.extData;
    
    /*
    req.businessType = @"wxpayScoreEnable";
    req.query = @"mch_id=1230000109&service_id=88888888000011&out_request_no=1234323JKHDFE1243252&timestamp=1530097563&nonce_str=zyx53Nkey8o4bHpxTQvd8m7e92nG5mG2&sign_type=HMAC-SHA256&sign=029B52F67573D7E3BE74904BF9AEA";
    req.extInfo = @"{\"miniProgramType\":0}";
    */
    
    [WXApi sendReq:openBusinessViewReq completion:^(BOOL success) {
            
    }];
}

#pragma mark- Block setting/getting methods

- (void)setSendMessageSuccessBlock:(TFWxManagerSendMessageSuccessBlock)block {
    objc_setAssociatedObject(self, TFWxManagerSendMessageSuccessBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (TFWxManagerSendMessageSuccessBlock)sendMessageSuccessBlock {
    return objc_getAssociatedObject(self, TFWxManagerSendMessageSuccessBlockKey);
}

- (void)setSendMessageFailureBlock:(TFWxManagerSendMessageFailureBlock)block {
    objc_setAssociatedObject(self, TFWxManagerSendMessageFailureBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (TFWxManagerSendMessageFailureBlock)sendMessageFailureBlock {
    return objc_getAssociatedObject(self, TFWxManagerSendMessageFailureBlockKey);
}

- (void)setSendMessageCancelBlock:(TFWxManagerSendMessageCancelBlock)block {
    objc_setAssociatedObject(self, TFWxManagerSendMessageCancelBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (TFWxManagerSendMessageCancelBlock)sendMessageCancelBlock {
    return objc_getAssociatedObject(self, TFWxManagerSendMessageCancelBlockKey);
}

- (void)setAuthCodeCallbackBlockBlock:(TFWxManagerAuthCodeCallbackBlock)block {
    objc_setAssociatedObject(self, TFWxManagerAuthCodeCallbackBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (TFWxManagerAuthCodeCallbackBlock)authCodeCallbackBlockBlock {
    return objc_getAssociatedObject(self, TFWxManagerAuthCodeCallbackBlockKey);
}

- (void)setPaySuccessBlock:(TFWxManagerPaySuccessBlock)block {
    objc_setAssociatedObject(self, TFWxManagerPaySuccessBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (TFWxManagerPaySuccessBlock)paySuccessBlock {
    return objc_getAssociatedObject(self, TFWxManagerPaySuccessBlockKey);
}

- (void)setPayFailureBlock:(TFWxManagerPayFailureBlock)block {
    objc_setAssociatedObject(self, TFWxManagerPayFailureBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (TFWxManagerPayFailureBlock)payFailureBlock {
    return objc_getAssociatedObject(self, TFWxManagerPayFailureBlockKey);
}

- (void)setPayCancelBlock:(TFWxManagerPayCancelBlock)block {
    objc_setAssociatedObject(self, TFWxManagerPayCancelBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (TFWxManagerPayCancelBlock)payCancelBlock {
    return objc_getAssociatedObject(self, TFWxManagerPayCancelBlockKey);
}

- (void)setOpenBusinessViewSuccessBlock:(TFWxManagerOpenBusinessViewSuccessBlock)block {
    objc_setAssociatedObject(self, TFWxManagerOpenBusinessViewSuccessBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (TFWxManagerOpenBusinessViewSuccessBlock)openBusinessViewSuccessBlock {
    return objc_getAssociatedObject(self, TFWxManagerOpenBusinessViewSuccessBlockKey);
}

- (void)setOpenBusinessViewFailureBlock:(TFWxManagerOpenBusinessViewFailureBlock)block {
    objc_setAssociatedObject(self, TFWxManagerOpenBusinessViewFailureBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (TFWxManagerOpenBusinessViewFailureBlock)openBusinessViewFailureBlock {
    return objc_getAssociatedObject(self, TFWxManagerOpenBusinessViewFailureBlockKey);
}

- (void)setOpenBusinessViewCancelBlock:(TFWxManagerOpenBusinessViewCancelBlock)block {
    objc_setAssociatedObject(self, TFWxManagerOpenBusinessViewCancelBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (TFWxManagerOpenBusinessViewCancelBlock)openBusinessViewCancelBlock {
    return objc_getAssociatedObject(self, TFWxManagerOpenBusinessViewCancelBlockKey);
}

#pragma mark - other

- (void)setAssociatedBlock:(void(^)(void))block usingKey:(NSString *)key {
    objc_setAssociatedObject(self, (__bridge void *)(key), block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(void))getAssociatedBlockForKey:(NSString *)key {
    return (__bridge void (^)(void))((__bridge void *)(objc_getAssociatedObject(self, (__bridge void *)(key))));
}

- (void)executeBlockIfExistForKey:(NSString *)key {
    void(^block)(void) = [self getAssociatedBlockForKey:key];
    if (block) {
        block();
    }
}

+ (NSString*)_wxappid {
    return [[self class] _thirdConfigWithRootKey:@"WeChat" subKey:@"APP_ID"];
}

+ (NSString*)_wxminiappid {
    return [[self class] _thirdConfigWithRootKey:@"WeChat" subKey:@"MINI_APP_ID"];
}

+ (NSString *)_universalLink {
    return [[self class] _thirdConfigWithRootKey:@"WeChat" subKey:@"UNIVERSAL_LINK"];
}

+ (NSString *)_thirdConfigWithRootKey:(NSString *)rootKey subKey:(NSString *)subKey {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ThirdConfig" ofType:@"plist"];
    NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    if (rootDict == nil) {
        return nil;
    }
    
    NSDictionary *configDict = [rootDict objectForKey:rootKey];
    if (configDict == nil) {
        return nil;
    }
    
    NSString *value = [configDict objectForKey:subKey];
    if(value == nil || [value length] <= 0) {
        return nil;
    }
    
    return value;
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

@end
