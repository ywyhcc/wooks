//
//  ZCStyleGuide.h
//  FirstP2P
//
//  Created by Jason on 13-12-30.
//  Copyright (c) 2013年 FirstP2P. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPStyleGuide : NSObject

#pragma mark - 边框

+ (UIColor *)inputBorderColor;

+ (UIColor*)cellBorderColor;//table view  cell 边框颜色

#pragma mark - 文字

//深灰色文字，用于亮色背景
+ (UIColor *)deepGrayTextColor;

//浅灰色文字，用于亮色背景
+ (UIColor*)lightGrayTextColor;

//蓝色文字
+ (UIColor *)blueTextColor;

//绿色文字
+ (UIColor *)greenTextColor;

//白色文字
+ (UIColor *)whiteTextColor;

//红色文字
+ (UIColor *)redTextColor;

#pragma mark - 背景

//通用背景色
+ (UIColor *)commonBackgroundColor;

//白色背景色
+ (UIColor *)whiteBackgroundColor;

//cell背景色
+ (UIColor *)cellBackgroundColor;

//蓝色背景色，与蓝色文字颜色相同
+ (UIColor *)blueBackgroundColor;

#pragma mark - 组件

//分割线颜色，如table等
+ (UIColor *)seperatorLineColor;

//navigationbar的标题颜色
+ (UIColor *)appTitleColor;

//主题颜色，如navigationbar，tabbar，toolbar等
+ (UIColor *)appThemeColor;

//表头颜色
+ (UIColor*)tableHeaderColor;

#pragma mark - 圆角

+ (CGFloat)cornerRadiusSmall;

+ (CGFloat)cornerRadiusBig;

#pragma mark - 股票开户

//开户 浅灰色
+ (UIColor *)stockAccountLightGrayTextColor;

//开户 分割线颜色
+ (UIColor *)stockAccountLineViewColor;

//开户 红色
+ (UIColor *)stockAccountRedColor;

//开户 灰色
+ (UIColor *)stockAccountGrayTextColor;

//开户 拍照功能栏背景色
+ (UIColor *)stockAccountCameraBackgroundViewColor;

+ (UIColor *)stockAccountBlueColor;

+ (UIColor *)stockAccountLightGrayColor;

#pragma mark - 股票

//股票 橙红色
+ (UIColor *)stockOrangeColor;

//股票 绿色
+ (UIColor *)stockGreenColor;

//股票 灰色
+ (UIColor *)stockGrayColor;

//股票 咖啡色
+ (UIColor *)stockCoffeeColor;

//股票 蓝色
+ (UIColor *)stockBlueColor;

//股票 蓝色
+ (UIColor *)stockLightBlueColor;

//股票 灰色文字
+ (UIColor *)stockGrayTextColor;

////股票 深灰色文字
+ (UIColor *)stockDarkGrayTextColor;

+ (UIColor *)stockThemeColor;//股票UI主题颜色

//股票 line color
+ (UIColor *)stockLineColor;

//股票 button disabled color
+ (UIColor *)stockButtonDisabledColor;

#pragma mark - 基金
+ (UIColor *)fundCellSelectionColor;

+ (UIColor *)fundYieldRedColor;

+ (UIColor *)fundYieldGrayColor;

+ (UIColor *)fundYieldGreenColor;

#pragma mark - 3.2

+ (NSTimeInterval)animationDuration;

+ (UIColor *)shtColor;

+ (UIColor *)redColor;

+ (UIColor *)pinkColor;

+ (UIColor *)greenColor;

+ (UIColor *)grayColor;

+ (UIColor *)btnDisableColor;

+ (UIColor *)lineColor;

+ (UIColor *)tableGrayTextColor;

+ (UIColor *)inviteGreenColor;

+ (UIColor *)gongyiYellowColor;

+ (UIColor *)medalYellowColor;

+ (CGFloat)gapWidth;

#pragma mark - 3.4
+ (UIColor *)navigationFrontColor;

+ (UIColor *)lightGrayColor;

#pragma mark - 4.0

+ (UIColor *)btnGrayColor;

#pragma mark - 4.0.1
+ (UIColor *)dotGrayColor;

+ (UIColor *)transparentBackgroundColor;

+ (UIFont*)newZitiSize:(CGFloat) ofSize;

+ (UIColor*)newWhiteColor;

+ (UIColor*)weichatGreenColor;

@end
