//
//  UIColor+Additions.h
//  FirstP2P
//
//  Created by LCL on 4/22/13.
//  Copyright (c) 2013 FirstP2P. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Additions)

+ (UIColor *)colorWithRGBARed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a;
+ (UIColor *)colorWithHex:(int)hex;
+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (UIColor *)colorWithString:(NSString *)colorString with:(CGFloat)alph;

@end
