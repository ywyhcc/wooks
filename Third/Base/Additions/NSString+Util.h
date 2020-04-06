//
//  NSString+Util.h
//  FirstP2P
//
//  Created by Jason on 14-1-2.
//  Copyright (c) 2014年 FirstP2P. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Util)
- (bool)isEmpty;
- (BOOL)isPureInt;
- (NSString *)trim;
- (NSString *)stringByDeletingPrefixWhiteSpace;
- (NSString *)stringByDeletingSuffixWhiteSpace;
- (CGSize)suggestedSizeWithFont:(UIFont *)font;
- (CGSize)suggestedSizeWithFont:(UIFont *)font width:(CGFloat)width;
- (CGSize)suggestedSizeWithFont:(UIFont *)font size:(CGSize)size;
- (CGSize)sizeWithFontCompatible:(UIFont *)font constrainedToWidth:(CGFloat)width;

// 字符串格式化为货币形式
- (NSString *)moneyFormat;

// 字符串格式化为货币形式 （指定小数位数）
- (NSString *)moneyFormatWithDecimalCnt:(NSInteger)decimalCnt;

//股票价格如果返回是小数点三位则小数点三位全显示
- (NSString *)stockMoneyFormat;

- (NSAttributedString *)attributedStringWithMoneyFont:(CGFloat)moneyFont
                                            otherFont:(CGFloat)otherFont
                                           moneyColor:(UIColor *)moneyColor
                                           otherColor:(UIColor *)otherColor;

// 字符串加法
- (NSString *)plusWithString:(NSString *)bStr;
// 参数解析 key1=val1&key2=val2
- (NSDictionary *)getParamDic;

// 微信支付参数解析 key1=val1&key2=val2=val2&
- (NSDictionary *)getWXPayParamDic;

+ (NSString *)transactionNumberFromAmount:(CGFloat)amount;
+ (NSString *)transactionMoneyToHundredMillion:(CGFloat)money;

- (NSString *)stringByReplacingCharactersInRange:(NSRange)range withRecurrenceChar:(char)c;

/**
 *  URLEncode
 */
- (NSString *)URLEncodedString;

/**
 *  URLDecode
 */
-(NSString *)URLDecodedString;

// 数字转万截取2位小数
+ (NSString *)transactionMoneyForTenThousand:(CGFloat)amount;


@end
