//
//  TFThirdLib.m
//  TFThirdLib
//
//  Created by sunxiaofei on 15/9/19.
//  Copyright (c) 2020年 daniel.xiaofei@gmail.com All rights reserved.
//

#import "TFThirdLib.h"

@implementation TFThirdLib

/// 获取AppDelegate的类名
+ (NSString *)appDelegateClassString {
    if (NSClassFromString(@"AppDelegate")) {
        /// obj-c
        return @"AppDelegate";
    } else {
        /// swift
        return [NSString stringWithFormat:@"%@.%@", NSBundle.mainBundle.infoDictionary[@"CFBundleExecutable"], @"AppDelegate"];;
    }
}

@end
