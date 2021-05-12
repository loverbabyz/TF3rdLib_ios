//
//  TFViewController.m
//  TFThirdLib_iOS
//
//  Created by SunXiaofei on 08/25/2020.
//  Copyright (c) 2020 SunXiaofei. All rights reserved.
//

#import "TFViewController.h"
//#import <TFThirdLib_iOS/TFWxShareManager.h>
//#import <TFThirdLib_iOS/TFWxManager.h>

@interface TFViewController ()

@end

@implementation TFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    BOOL flag = [TFWxManager isWXAppInstalled];
//    NSLog(@"%@", flag ? @"1" : @"0");
    
    BOOL result = [self matches:@"ikey"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)matches:(NSString *)bleNamePrefix {
    NSString *name = @"ikeyas";
    NSString *sn = nil;
    NSString* n1 = bleNamePrefix;
   if (!name || (name.length < n1.length)) {
       return NO;
       
   }
    NSString* n2 = [name substringFromIndex:n1.length];
    if ([name hasPrefix:n1] && [sn containsString:n2]) {
        return YES;
    }
    
    return NO;
}

@end

@implementation NSString (ext)

- (BOOL)containsString:(NSString *)string {
    if (string == nil) return NO;
    return [self rangeOfString:string].location != NSNotFound;
}

@end
