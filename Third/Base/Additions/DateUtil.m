//
//  DateUtil.m
//  FirstP2P
//
//  Created by Jason on 14-1-2.
//  Copyright (c) 2014年 FirstP2P. All rights reserved.
//

#import "DateUtil.h"

@implementation DateUtil

+ (int)getDistanceDayFromNow:(NSDate*)date
{
    if (!date) return 0;
    NSDate *nowDate = [NSDate date];
    NSTimeInterval time = [nowDate timeIntervalSinceDate:date];
    int day = abs(((int)time)/(3600*24));
    return day;
}

+ (NSInteger)daysBetweenDateAndNowInCalendar:(NSDate *)fromDate
{
    NSDate     *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:[NSDate date]];
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    NSInteger days = [difference day];
    return days;
}

+ (NSDate *)dateFromString:(NSString *)string
{
    NSString *format = @"yyyyMMdd";
    return [DateUtil dateFromString:string format:format];
}

+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)format
{
    if (string.length <= 0) {
        return [NSDate date];
    }
    if (format.length <= 0) {
        format = @"yyyyMMdd";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:string];
    if (!date) {
        return [NSDate date];
    }
    return date;
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    NSString *format = @"yyyyMMdd";
    return [DateUtil stringFromDate:date format:format];
}

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format
{
    if (!date) {
        date = [NSDate date];
    }
    if (format.length <= 0) {
        format = @"yyyyMMdd";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *string = [formatter stringFromDate:date];
    if (string.length <= 0) {
        return @"";
    }
    return string;
}

+ (NSDateComponents *)dateComponentWithString:(NSString *)str formate:(NSString *)formate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:formate];
	NSDate *date = [formatter dateFromString:str];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    return dateComponent;
}

+ (BOOL)date:(NSDate *)date isBetweenMinDate:(NSDate *)minDate maxDate:(NSDate *)maxDate
{
    if (!date) {
        return NO;
    }
    if ([date timeIntervalSinceDate:minDate] >= 0 && [date timeIntervalSinceDate:maxDate] <= 0) {
        return YES;
    }
    return NO;
}

+(NSString *)getNowTimeTimestamp2{

    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];

    NSTimeInterval a=[dat timeIntervalSince1970];

    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型

    ;

return timeString;

}

+(NSString *)getNowTimeTimestamp3{

    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式

    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970]*1000)];

    return timeSp;
}

@end
