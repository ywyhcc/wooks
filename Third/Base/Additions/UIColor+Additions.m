//
//  UIColor+Additions.m
//  FirstP2P
//
//  Created by LCL on 4/22/13.
//  Copyright (c) 2013 FirstP2P. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)

+ (UIColor *)colorWithHex:(int)hex
{
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0xFF00) >> 8))/255.0
                            blue:((float)(hex & 0xFF))/255.0 alpha:1.0];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    const char *cString = [hexString cStringUsingEncoding: NSASCIIStringEncoding];
    int hex;
    
    // if the string contains hash tag (#) then remove
    // hash tag and convert the C string to a base-16 int
    if ( cString[0] == '#' )
    {
        hex = (int)strtol(cString + 1, NULL, 16);
    }
    else
    {
        hex = (int)strtol(cString, NULL, 16);
    }
    
    UIColor *color = [self colorWithHex: hex];
    return color;
}

+ (UIColor *)colorWithRGBARed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a
{
    return [UIColor colorWithRed: r/255.0 green: g/255.0 blue: b/255.0 alpha:a];
}


+ (UIColor *)colorWithString:(NSString *)colorString with:(CGFloat)alph
{
    if ([colorString length] != 7 || ![colorString hasPrefix:@"#"]) {
        return nil;
    }
    UIColor *color = nil;
    NSScanner *scanner = [[NSScanner alloc] initWithString:[colorString substringFromIndex:1]];
    unsigned hexValue;
    if ([scanner scanHexInt:&hexValue] && [scanner isAtEnd]) {
        int r = ((hexValue & 0xFF0000) >> 16);
        int g = ((hexValue & 0x00FF00) >>  8);
        int b = ( hexValue & 0x0000FF)       ;
        color = [self colorWithRed:((float)r / 255)
                             green:((float)g / 255)
                              blue:((float)b / 255)
                             alpha:alph];
    }
    return color;
}

@end
