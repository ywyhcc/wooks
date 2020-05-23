//
//  Common.h
//  FirstP2P
//
//  Created by LCL on 13-10-22.
//  Copyright (c) 2013年 FirstP2P. All rights reserved.
//



//#define BaseURL                             @"http://api.woostalk.cn:6060"  //线上
#define BaseURL                             @"http://120.27.250.124:6060" //test

#define QiniuCloudBaseURL                   @"http://resources.woostalk.com/"


#define RongCloudAPPKEY                     @"uwd1c0sxu5p01"

//
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//判断ios版本是否高于等于11.0
#define WX_IOS11_OR_LATER (DeviceSystemMajorVersion() >= 11)

//判断ios版本是否高于等于10.0
#define WX_IOS10_OR_LATER (DeviceSystemMajorVersion() >= 10)

//判断ios版本是否高于等于9.0
#define WX_IOS9_OR_LATER (DeviceSystemMajorVersion() >= 9)

//判断ios版本是否高于等于8.0
#define WX_IOS8_OR_LATER (DeviceSystemMajorVersion() >= 8)

//判断ios版本是否高于等于7.0
#define WX_IOS7_OR_LATER (DeviceSystemMajorVersion() >= 7)

//判断终端是否是iphone5式的长屏
#define IPHONE5_OR_LATER ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ([[UIScreen mainScreen] currentMode].size.width >= 640 && [[UIScreen mainScreen] currentMode].size.height >= 1136) : NO)

//判断终端是否是iphone6以后设备（iPhone6,plus）
#define IPHONE6_OR_LATER ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ([[UIScreen mainScreen] currentMode].size.width >= 750 && [[UIScreen mainScreen] currentMode].size.height >= 1334) : NO)

//判断终端是否是iphone6plus以后设备（iPhone6,plus）
#define IPHONE6PLUS_OR_LATER ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ([[UIScreen mainScreen] currentMode].size.width >= 1242 && [[UIScreen mainScreen] currentMode].size.height >= 2208) : NO)

#define IS_IPHONEX (DeviceUtil.topSafeHeight > 20)

//屏幕宽
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

//屏幕高
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

//状态栏高
#define WX_STATUSBAR_HEIGHT 20

//导航栏高
#define NAVIGATIONBAR_HEIGHT 44

//tabBar高
#define WX_TABBAR_HEIGHT         (49 + IS_IPHONEX * 34)

#define GL_iPhone_X          (SCREEN_WIDTH == 375 && SCREEN_HEIGHT == 812)

#define GL_iPhone_X_Max         (SCREEN_WIDTH == 414 && SCREEN_HEIGHT == 896)

/** 是否是异形屏 */
#define IS_HETERO_SCREEN            (GL_iPhone_X || GL_iPhone_X_Max)

#define Nav_topH                    (IS_HETERO_SCREEN ? 88.0 : 64.0)    // 导航栏+状态栏高度

#define NavMustAdd                 (IS_HETERO_SCREEN ? 34.0 : 0.0)     // 异形屏上方安全高度


//基金流Cell高度
#define kFundList_Cell_Height             (140)

//资金记录Section高度
#define kFund_Section_Height   35

//账户总览 cell 高度
#define kAccount_Cell_Height   50

//每次拉取个数
#define PULL_COUNT                              10

#define LARGE_PULL_COUNT                        20

#define MAX_TIMELING_NUM 241
#define MAX_FIVETIMELING_NUM 245
