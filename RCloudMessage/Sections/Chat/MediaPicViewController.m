//
//  MediaPicViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/26.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "MediaPicViewController.h"

@interface MediaPicViewController ()

@end

@implementation MediaPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showAlertViewWithMessage:@"您当前手机版本过低，无法查看单张图片大图，请升级系统后重试"];
    
}

- (void)showAlertViewWithMessage:(NSString *)message {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
