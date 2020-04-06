//
//  NSString+Util.m
//  FirstP2P
//
//  Created by Jason on 14-1-2.
//  Copyright (c) 2014年 FirstP2P. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSString (Util)


- (bool)isEmpty
{
    return self.length == 0;
}

- (BOOL)isPureInt
{
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (NSString *)trim
{
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

- (NSString *)stringByDeletingPrefixWhiteSpace
{
    NSString *result = self;
    while ([result hasPrefix:@" "]) {
        result = [result substringFromIndex:1];
    }
    return result;
}

- (NSString *)stringByDeletingSuffixWhiteSpace
{
    NSString *result = self;
    while ([result hasSuffix:@" "]) {
        result = [result substringToIndex:result.length-1];
    }
    return result;
}

- (CGSize)suggestedSizeWithFont:(UIFont *)font
{
    CGSize size = CGSizeZero;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    if ([self respondsToSelector:@selector(sizeWithAttributes:)]) {
        size = [self sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,  nil]];
    }
#endif
    return size;
}

- (CGSize)suggestedSizeWithFont:(UIFont *)font size:(CGSize)size
{
    return [self suggestedSizeWithFont:font
                                 width:size.width];
}

- (CGSize)suggestedSizeWithFont:(UIFont *)font width:(CGFloat)width
{
    CGSize size = CGSizeZero;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        CGRect bounds = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,  nil]
                                           context:nil];
        size = bounds.size;
    }
#endif
    return size;
}

- (CGSize)sizeWithFontCompatible:(UIFont *)font constrainedToWidth:(CGFloat)width
{
    NSDictionary *attribute = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:CGSizeMake(width, 0)
                              options:NSStringDrawingTruncatesLastVisibleLine
            | NSStringDrawingUsesLineFragmentOrigin
            | NSStringDrawingUsesFontLeading
                           attributes:attribute
                              context:nil]
    .size;
}

// 字符串格式化为货币形式
- (NSString *)moneyFormat
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [formatter setPositiveFormat:@"###,##0.00;"];
    if ([self hasPrefix:@"+"]) {
        [formatter setPositivePrefix:@"+"];
    }
    
    NSString *money = [self stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSNumber *number = [formatter numberFromString:money];
    NSString *resultString = [formatter stringFromNumber:number];
    
    return resultString;
}

// 字符串格式化为货币形式 （指定小数位数）
- (NSString *)moneyFormatWithDecimalCnt:(NSInteger)decimalCnt
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSMutableString *formatStr = [[NSMutableString alloc] init];
    [formatStr appendFormat:@"###,##0"];
    for(NSInteger i =0;i<decimalCnt;i++){
        if(i==0){
            [formatStr appendFormat:@"."];
        }
        [formatStr appendFormat:@"0"];
        if (i==decimalCnt-1) {
            [formatStr appendFormat:@";"];
        }
    }
    [formatter setPositiveFormat:formatStr];
    
    if ([self hasPrefix:@"+"]) {
        [formatter setPositivePrefix:@"+"];
    }
    
    NSString *money = [self stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSNumber *number = [formatter numberFromString:money];
    NSString *resultString = [formatter stringFromNumber:number];
    
    return resultString;
}

//股票价格如果返回是小数点三位以上则小数点三位以上全显示
- (NSString *)stockMoneyFormat
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [formatter setPositiveFormat:@"###,##0.00##;"];
    if ([self hasPrefix:@"+"]) {
        [formatter setPositivePrefix:@"+"];
    }
    
    NSString *money = [self stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSNumber *number = [formatter numberFromString:money];
    NSString *resultString = [formatter stringFromNumber:number];
    
    return resultString;
}

// 字符串加法
- (NSString *)plusWithString:(NSString *)bStr
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [formatter setPositiveFormat:@"###,##0.00;"];
    
    NSNumber *aNumber = [formatter numberFromString:self];
    NSNumber *bNumber = [formatter numberFromString:bStr];
    NSNumber *resultNumber = [NSNumber numberWithDouble:aNumber.doubleValue+bNumber.doubleValue];
    NSString *resultString = [formatter stringFromNumber:resultNumber];
    
    if ([resultString isEqualToString:@"0,00"]) {
        NSString *aString = [self stringByReplacingOccurrencesOfString:@"," withString:@""];
        NSString *bString = [bStr stringByReplacingOccurrencesOfString:@"," withString:@""];
        resultNumber = [NSNumber numberWithDouble:[aString doubleValue]+[bString doubleValue]];
        resultString = [formatter stringFromNumber:resultNumber];
    }
    
    return resultString;
}

// 参数解析 key1=val1&key2=val2
- (NSDictionary *)getParamDic
{
    NSArray *paramArray = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    for (NSString *param in paramArray) {
        //解析参数
        NSArray *array = [param componentsSeparatedByString:@"="];
        if (array.count > 1) {
            NSString *key = array[0];
            NSString *val = array[1];
            [paramDic setObject:val forKey:key];
        }
    }
    return paramDic;
}

// 参数解析 key1=val1&key2=val2=val2&
- (NSDictionary *)getWXPayParamDic
{
    NSArray *paramArray = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    for (NSString *param in paramArray) {
        //解析参数
        NSArray *array = [param componentsSeparatedByString:@"="];
        if (array.count > 2) {
            NSString *key = array[0];
            NSString *val = [[array[1] stringByAppendingString:@"="] stringByAppendingString:array[2]];
            [paramDic setObject:val forKey:key];
        } else if (array.count > 1) {
            NSString *key = array[0];
            NSString *val = array[1];
            [paramDic setObject:val forKey:key];
        }
    }
    return paramDic;
}

// 交易手数转整万
+ (NSString *)transactionNumberFromAmount:(CGFloat)amount
{
    CGFloat number = amount / 10000;
    if (number >= 1000) {
        return [NSString stringWithFormat:@"%.f万", number];
    } else if (number >= 100) {
        return [NSString stringWithFormat:@"%.1f万", number];
    } else if (number >= 10) {
        return [NSString stringWithFormat:@"%.2f万", number];
    } else if (number >= 1) {
        return [NSString stringWithFormat:@"%.3f万", number];
    } else {
        return [NSString stringWithFormat:@"%.f", amount];
    }
}

// 交易市值转亿
+ (NSString *)transactionMoneyToHundredMillion:(CGFloat)money
{
    CGFloat tMoney = money / 100000000;
    if (tMoney > 10000) {
        return [NSString stringWithFormat:@"%.2f万亿", tMoney/10000];
    } else {
        return [NSString stringWithFormat:@"%.2f亿", tMoney];
    }
}

- (NSString *)stringByReplacingCharactersInRange:(NSRange)range withRecurrenceChar:(char)c{
	NSString *str = @"";
	for (int i = 0; i < range.length; i ++) {
		str = [str stringByAppendingFormat:@"%c", c];
	}
	
	return [[self mutableCopy] stringByReplacingCharactersInRange:range withString:str];
}

/**
 *  URLEncode
 */
- (NSString *)URLEncodedString
{
    // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    // CharactersToLeaveUnescaped = @"[].";
    
    NSString *unencodedString = self;
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

/**
 *  URLDecode
 */
-(NSString *)URLDecodedString
{
    //NSString *decodedString = [encodedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
    NSString *encodedString = self;
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)encodedString,
                                                                                                                     CFSTR(""),
                                                                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

// 利用正则匹配，获取金额字符串Range
- (NSRange)getAmountRange
{
    NSString *numberRegex = @"-?(([1-9][0-9]*|0)(\\.[0-9]{1,2})?)";
    NSString *currencyRegex = @"-?(([1-9][0-9]{1,2})((\\,[0-9]{3})*)?|0)(\\.[0-9]{1,2})?";
    
    NSRange numberRange = [self rangeOfString:numberRegex options:NSRegularExpressionSearch];
    NSRange currencyRange = [self rangeOfString:currencyRegex options:NSRegularExpressionSearch];
    if (numberRange.length == NSNotFound && currencyRange.length == NSNotFound) {
        return NSMakeRange(0, 0);
    } else if (numberRange.length >= currencyRange.length) {
        return numberRange;
    } else {
        return currencyRange;
    }
}

- (NSAttributedString *)attributedStringWithMoneyFont:(CGFloat)moneyFont
                                            otherFont:(CGFloat)otherFont
                                           moneyColor:(UIColor *)moneyColor
                                           otherColor:(UIColor *)otherColor
{
    NSRange amountRange = [self getAmountRange];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:self];
    // other
    if (otherFont > 0) {
        [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:otherFont] range:NSMakeRange(0, self.length)];
    }
    if (otherColor) {
        [attString addAttribute:NSForegroundColorAttributeName value:otherColor range:NSMakeRange(0, self.length)];
    }
    // money
    if (moneyFont > 0) {
        [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:moneyFont] range:amountRange];
    }
    if (moneyColor) {
        [attString addAttribute:NSForegroundColorAttributeName value:moneyColor range:amountRange];
    }
    
    return attString;
}

// 数字转万截取2位小数
+ (NSString *)transactionMoneyForTenThousand:(CGFloat)amount
{
    CGFloat number = amount / 10000;
    if (number >= 1) {
        NSString *str = [[NSNumber numberWithDouble: number] stringValue];
        NSArray *strArr= [str componentsSeparatedByString:@"."];
        if (strArr.count > 1) {
            NSString *firstStr = strArr[0];
            NSString *secondStr = strArr[1];
            secondStr = [NSString stringWithFormat:@"0.%@", [secondStr substringToIndex:secondStr.length > 1 ? 2 : 1]];
            return [NSString stringWithFormat:@"%@万", [firstStr plusWithString:secondStr]];
        } else {
            return [NSString stringWithFormat:@"%@万", [str plusWithString:@"0.00"]];
        }
    } else {
        return [NSString stringWithFormat:@"%.f", amount];
    }
}


@end
