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
    
    NSString *hexInterval = @"0x606FB3A4";
    NSData *timestampData = [self convertHexStrToData:@"0x606FB3A4"];
    
    unsigned res = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexInterval];
    [scanner scanHexInt:&res];
    NSTimeInterval interval = (NSTimeInterval)res;
    // Once you have an interval, use your code:
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    BOOL result = [self matches:@"ikey"];
}

// 16进制转NSData
- (NSData *)convertHexStrToData:(NSString *)str
{
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
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
