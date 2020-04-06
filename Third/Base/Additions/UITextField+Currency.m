//
//  UITextField.m
//  FirstP2P
//
//  Created by Guo Donghao on 14-7-8.
//  Copyright (c) 2014年 9888. All rights reserved.
//

#import "UITextField+Currency.h"

@implementation UITextField (Current)

//旧代码
//金额文本框规范 默认整数位支持8位 小数位支持两位
//+(BOOL)currentTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if (string.length == 0) {
//        //删除操作不检查字符串格式
//        return YES;
//    }
//    
//    NSMutableString *tempString = [NSMutableString stringWithString:textField.text];
//    //假设先处理完字符串，再看处理完的字符串满不满足要求
//    [tempString deleteCharactersInRange:range];
//    [tempString insertString:string atIndex:range.location];
//    //以点为分隔进行分组
//    NSArray *components = [tempString componentsSeparatedByString:@"."];
//    if (components.count <= 1) {
//        //处理后没有点
//        if (tempString.length > 8) {
//            return NO;
//        }
//    }
//    else if (components.count == 2) {
//        //处理后有一个点
//        if (((NSString*)components[0]).length > 8) {
//            return NO;
//        }
//        if (((NSString*)components[1]).length > 2) {
//            return NO;
//        }
//    }
//    else {
//        //处理后多于一个点
//        return NO;
//    }
//    return YES;
//}

+(BOOL)currentTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [UITextField currentTextField:textField shouldChangeCharactersInRange:range replacementString:string integerSize:8 desimalSize:2];
}

//限制金额文本框的整数位和小数位
+(BOOL)currentTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string integerSize:(NSInteger)integerSize desimalSize:(NSInteger)desimalSize
{
    if (string.length == 0) {
        //删除操作不检查字符串格式(fix删除键不灵的bug)
        return YES;
    }
    
    NSString *tempString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    //以点为分隔进行分组
    NSArray *components = [tempString componentsSeparatedByString:@"."];

    //限制小数点的位数
    if (components.count == 2) {
        
        //不能以小数点开头
        if([tempString hasPrefix:@"."]){
            return NO;
        }
        
        if (((NSString*)components[1]).length > desimalSize) {
            return NO;
        }
        
        //如果desimalSize=0 不准输入小数点
        if(desimalSize==0 && ([string rangeOfString:@"."].location != NSNotFound)){
            return NO;
        }
        
    }else if(components.count>2){
        //限制只能输入一个小数点
        return NO;
    }
    
    //限制整数位的位数
    if (((NSString *)[components objectAtIndex:0]).length > integerSize) {
        // 限制整数位位数
        return NO;
    }
    
    return YES;
}

@end
