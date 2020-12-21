//
//  TFViewController.m
//  TFThirdLib_iOS
//
//  Created by SunXiaofei on 08/25/2020.
//  Copyright (c) 2020 SunXiaofei. All rights reserved.
//

#import "TFViewController.h"
#import <TFThirdLib_iOS/TFWxShareManager.h>
#import <TFThirdLib_iOS/TFWxManager.h>

@interface TFViewController ()

@end

@implementation TFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    BOOL flag = [TFWxManager isWXAppInstalled];
    NSLog(@"%@", flag ? @"1" : @"0");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
