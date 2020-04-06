//
//  NSString+Draw.m
//  FirstP2P
//
//  Created by fengquanwang on 28/11/2016.
//  Copyright © 2016 9888. All rights reserved.
//

#import "NSString+Draw.h"

@implementation NSString (Draw)

- (CGSize)usizeWithFont:(UIFont *)font{
    NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
    if (font)[attDic setObject:font forKey:NSFontAttributeName];
    return [self sizeWithAttributes:attDic];
}

- (CGSize)usizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size{
    return [self usizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize)usizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode{
    NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
    if (font)[attDic setObject:font forKey:NSFontAttributeName];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = lineBreakMode;
    [attDic setObject:style forKey:NSParagraphStyleAttributeName];
    
    return [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attDic context:nil].size;
}

- (void)udrawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment{
    [self udrawInRect:rect withFont:font textColor:nil lineBreakMode:lineBreakMode alignment:alignment];
}

- (void)udrawInRect:(CGRect)rect withFont:(UIFont *)font textColor:(UIColor*)color lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment{
    NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
    if (font)[attDic setObject:font forKey:NSFontAttributeName];
    if (color)[attDic setObject:color forKey:NSForegroundColorAttributeName];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = lineBreakMode;
    style.alignment = alignment;
    [attDic setObject:style forKey:NSParagraphStyleAttributeName];
    
    [self drawInRect:rect withAttributes:attDic];
}

@end
