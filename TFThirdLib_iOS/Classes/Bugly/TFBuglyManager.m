//
//  TFBuglyManager.m
//  TFThirdLib
//
//  Created by sunxiaofei on 15/9/19.
//  Copyright (c) 2020年 daniel.xiaofei@gmail.com All rights reserved.
//

#import "TFBuglyManager.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "Aspects.h"

#import <Bugly/Bugly.h>

@implementation TFBuglyManager

+ (void)load {
    [super load];
    [[self class] checkAppDelegate];
    [[self class] trackAppDelegate];
}

+ (void)checkAppDelegate {
    
}

+ (void)trackAppDelegate {
    [NSClassFromString(@"AppDelegate")
     aspect_hookSelector:@selector(application:didFinishLaunchingWithOptions:)
     withOptions:AspectPositionBefore
     usingBlock:^(id<AspectInfo> aspectInfo, id application,id launchOptions){
         /// Required
        NSString *appid = [[self class] _buglyAppId];
        if (appid == nil || [appid length] <= 0) {
            return;
        }
        
        [Bugly startWithAppId:appid];
     }
     error:NULL];
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static TFBuglyManager *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TFBuglyManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    
    return self;
}

+ (NSString*)_buglyAppId {
    return [[self class] _thirdConfigWithRootKey:@"Bugly" subKey:@"APP_ID"];
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

@end
