//
//  DateUtil.h
//  FirstP2P
//
//  Created by Jason on 14-1-2.
//  Copyright (c) 2014年 FirstP2P. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const STAPIDateFormat = @"yyyyMMdd";
static NSString *const STDatePickerDateFormat = @"yyyy-M-d eeee";
static NSString *const STLogDateFormat = @"yyyy-M-d";

@interface DateUtil : NSObject
+ (int)getDistanceDayFromNow:(NSDate*)date;
+ (NSInteger)daysBetweenDateAndNowInCalendar:(NSDate *)fromDate;

// 从格式为 yyyyMMdd 的字符串中获取日期
+ (NSDate *)dateFromString:(NSString*)string;
// 从格式为 format 的字符串中获取日期
+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)format;

// 返回格式为 yyyyMMdd 的日期
+ (NSString *)stringFromDate:(NSDate *)date;
// 返回格式为 format 的日期
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format;

+ (NSDateComponents*)dateComponentWithString:(NSString *)str formate:(NSString *)formate;

+ (BOOL)date:(NSDate *)date isBetweenMinDate:(NSDate *)minDate maxDate:(NSDate *)maxDate;

//获取当前时间单位：秒
+(NSString *)getNowTimeTimestamp2;

//获取当前时间戳单位：毫秒
+(NSString *)getNowTimeTimestamp3;
@end
