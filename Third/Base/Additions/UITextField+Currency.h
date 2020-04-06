//
//  UITextField.h
//  FirstP2P
//
//  Created by Guo Donghao on 14-7-8.
//  Copyright (c) 2014年 9888. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Current)

//金额文本框规范 默认整数位支持8位 小数位支持两位
+(BOOL)currentTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

//限制金额文本框的整数位和小数位
+(BOOL)currentTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string integerSize:(NSInteger)integerSize desimalSize:(NSInteger)desimalSize;

@end
