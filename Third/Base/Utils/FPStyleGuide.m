//
//  ZCStyleGuide.m
//  FirstP2P
//
//  Created by Jason on 13-12-30.
//  Copyright (c) 2013年 FirstP2P. All rights reserved.
//

#import "FPStyleGuide.h"
#import "UIColor+Additions.h"

@implementation FPStyleGuide

#pragma mark - 边框

//输入框边框
+ (UIColor *)inputBorderColor
{
    return [UIColor colorWithHexString:@"#cccccc"];
}

//Cell边框
+ (UIColor*)cellBorderColor
{
    return [UIColor colorWithHexString:@"#d9d9d9"];
}

#pragma mark - 文字

//深灰色文字，用于亮色背景
+ (UIColor *)deepGrayTextColor
{
    return [UIColor colorWithHexString:@"#41474d"];
}

//浅灰色文字，用于亮色背景
+ (UIColor*)lightGrayTextColor
{
    return [UIColor colorWithHexString:@"#909ba8"];
}

//蓝色文字
+ (UIColor *)blueTextColor
{
    return [UIColor colorWithHexString:@"#5ca9e4"];
}

//绿色文字
+ (UIColor *)greenTextColor
{
    return [UIColor colorWithHexString:@"#3cb025"];
}

//白色文字
+ (UIColor *)whiteTextColor
{
    return [UIColor whiteColor];
}

//红色文字
+ (UIColor *)redTextColor
{
    return [UIColor colorWithHexString:@"#ef0000"];
}


#pragma mark - 背景

//通用背景色
+ (UIColor *)commonBackgroundColor
{
	return [UIColor colorWithHex:0xF5F5FA];
}

//白色背景（更多页）
+ (UIColor *)whiteBackgroundColor
{
    return [UIColor whiteColor];
}

//cell背景颜色
+ (UIColor *)cellBackgroundColor
{
    return [UIColor colorWithHexString:@"#fafafa"];
}

//蓝色背景色，与蓝色文字颜色相同
+ (UIColor *)blueBackgroundColor
{
    return [UIColor colorWithHexString:@"#5ABBF6"];
}

#pragma mark - 组件

//navigationbar的标题颜色
+ (UIColor *)appTitleColor
{
    return [UIColor colorWithHexString:@"#333333"];
}

//主题颜色，如navigationbar，tabbar，toolbar等
+ (UIColor *)appThemeColor
{
    return [UIColor colorWithHexString:@"#fafafa"];
}

//分割线颜色，如table等
+ (UIColor *)seperatorLineColor
{
    return [UIColor colorWithHex:0xE6E6E6];
}

//表头颜色
+ (UIColor*)tableHeaderColor
{
    return [self commonBackgroundColor];
}

#pragma mark - Corner

+ (CGFloat)cornerRadiusSmall
{
    return 2;
}

+ (CGFloat)cornerRadiusBig
{
    return 5;
}

#pragma mark - 股票

//股票 橙红色
+ (UIColor *)stockOrangeColor
{
    return [UIColor colorWithHexString:@"#ee4634"];
}

//股票 绿色
+ (UIColor *)stockGreenColor
{
    return [UIColor colorWithHexString:@"#48BE84"];
}

//股票 灰色
+ (UIColor *)stockGrayColor
{
    return [UIColor colorWithHexString:@"#a9a9a9"];
}

//股票 咖啡色
+ (UIColor *)stockCoffeeColor
{
    return [UIColor colorWithHexString:@"#d3834e"];
}

//股票 蓝色
+ (UIColor *)stockBlueColor
{
    return [UIColor colorWithHexString:@"#0079fe"];
}

//股票 淡蓝色
+ (UIColor *)stockLightBlueColor
{
    return [UIColor colorWithHexString:@"#4a91e3"];
}

//股票 灰色文字
+ (UIColor *)stockGrayTextColor
{
    return [UIColor colorWithHexString:@"#909090"];
}

//股票 深灰色文字
+ (UIColor *)stockDarkGrayTextColor
{
    return [UIColor colorWithHexString:@"#606060"];
}

//股票UI主题颜色
+ (UIColor *)stockThemeColor
{
    return [UIColor colorWithHexString:@"#eb473b"];
}

//股票 line color
+ (UIColor *)stockLineColor
{
    return [UIColor colorWithHexString:@"#d9d9d9"];
}

//股票 button disabled color
+ (UIColor *)stockButtonDisabledColor
{
    return [UIColor colorWithHexString:@"#d8d8d8"];
}

#pragma mark - Stock Account

+ (UIColor *)stockAccountBlueColor
{
    return [UIColor colorWithHex:0x8fc6f2];
}

+ (UIColor *)stockAccountLightGrayColor
{
    return [UIColor colorWithHex:0xd0d0d0];
}

//开户 灰色文字
+ (UIColor *)stockAccountGrayTextColor
{
    return [UIColor colorWithHexString:@"#606060"];
}

//开户 浅灰色文字
+ (UIColor *)stockAccountLightGrayTextColor
{
    return [UIColor colorWithHexString:@"#D0D0D0"];
}

//开户 红色
+ (UIColor *)stockAccountRedColor
{
    return [UIColor colorWithHexString:@"#F57272"];
}

//开户 分割线颜色
+ (UIColor *)stockAccountLineViewColor
{
    return [UIColor colorWithHexString:@"#F8F8F8"];
}

//开户 拍照功能栏背景色
+ (UIColor *)stockAccountCameraBackgroundViewColor
{
    return [UIColor colorWithHexString:@"#272727"];
}

#pragma mark - 基金
+ (UIColor *)fundCellSelectionColor
{
    return [UIColor colorWithHex:0xfbfbfb];
}

+ (UIColor *)fundYieldRedColor
{
    return [self redColor];
}

+ (UIColor *)fundYieldGrayColor
{
    return [UIColor colorWithRGBARed:144 green:144 blue:144 alpha:1];
}

+ (UIColor *)fundYieldGreenColor
{
    return [UIColor colorWithRGBARed:129 green:202 blue:156 alpha:1];
}

#pragma mark - 3.2

+ (NSTimeInterval)animationDuration{
	return 0.35;
}

+ (UIColor *)shtColor
{
    return [UIColor colorWithHexString:@"#e4007f"];
}

+ (UIColor *)redColor
{
	return [UIColor colorWithHex:0xEE4634];
}

//粉色
+ (UIColor *)pinkColor
{
    return [UIColor colorWithHexString:@"#f54072"];
}

+ (UIColor *)greenColor{
	return [UIColor colorWithHex:0x388E3C];
}

+ (UIColor *)grayColor{
	return [UIColor colorWithHex:0xCCCCCC];
}

+ (UIColor *)btnDisableColor{
	return [UIColor colorWithHex:0xD8D8D8];
}

+ (UIColor *)lineColor{
	return [UIColor colorWithHex:0xE6E6E6];
}

+ (UIColor *)tableGrayTextColor{
	return [UIColor colorWithHex:0x8F8F8F];
}

+ (UIColor *)inviteGreenColor{
	return [UIColor colorWithHex:0x369100];
}

+ (UIColor *)gongyiYellowColor{
	return [UIColor colorWithHex:0xF6D066];
}

+ (UIColor *)medalYellowColor{
	return [UIColor colorWithHex:0xFFC848];
}

+ (CGFloat)gapWidth{
	return 15;
}

#pragma mark - 3.4
+ (UIColor *)navigationFrontColor{
	return [UIColor colorWithHex:0x363636];
}

+ (UIColor *)lightGrayColor{
    return [UIColor colorWithHex:0x909090];
}

#pragma mark - 4.0
+ (UIColor *)btnGrayColor{
    return [UIColor colorWithHex:0xBFBFBF];
}

#pragma mark - 4.0.1
+ (UIColor *)dotGrayColor{
    return [UIColor colorWithHex:0xEDEDED];
}

+ (UIColor *)transparentBackgroundColor{
    return [[UIColor blackColor] colorWithAlphaComponent:0.7];
}

+ (UIFont*)newZitiSize:(CGFloat)ofSize{
    return [UIFont fontWithName:@"NCFDIN-Bold" size:ofSize];
}

+ (UIColor*)newWhiteColor{
    return [UIColor colorWithHex:0xFFFFFF];
}

+ (UIColor*)weichatGreenColor{
    return [UIColor colorWithHex:0x45bf19];
}

@end
