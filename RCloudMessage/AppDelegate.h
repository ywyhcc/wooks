//
//  AppDelegate.h
//  RongCloud
//
//  Created by Liv on 14/10/31.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, RCIMConnectionStatusDelegate, RCIMReceiveMessageDelegate>

@property (strong, nonatomic) UIWindow *window;

// 用于记录当前点击的评论frame
@property (nonatomic, assign) CGRect convertRect;

+ (AppDelegate *)sharedInstance;

@end
