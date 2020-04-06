//
//  NSString+Draw.h
//  FirstP2P
//
//  Created by fengquanwang on 28/11/2016.
//  Copyright © 2016 9888. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Draw)

- (CGSize)usizeWithFont:(UIFont *)font;
- (CGSize)usizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGSize)usizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;
- (void)udrawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment;
- (void)udrawInRect:(CGRect)rect withFont:(UIFont *)font textColor:(UIColor*)color lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment;

@end
