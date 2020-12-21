//
//  TFUMengSocialManager.m
//  TFThirdLib
//
//  Created by sunxiaofei on 15/9/19.
//  Copyright © 2020年 daniel.xiaofei@gmail.com All rights reserved.
//

#import "TFUMengSocialManager.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "Aspects.h"

#import <UMCommon/UMCommon.h>

@implementation TFUMengSocialManager

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
        // Required
        NSString *appKey=[[self class] _umengappkey];
        if (appKey == nil || [appKey length] <= 0)
        {
            return;
        }
        
        [UMConfigure initWithAppkey:appKey channel:@"App Store"];
     }
     error:NULL];
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static TFUMengSocialManager *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TFUMengSocialManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    
    return self;
}

+ (NSString*)_umengappkey {
    return [[self class] _thirdConfigWithRootKey:@"UMengSocial" subKey:@"APP_KEY"];
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
