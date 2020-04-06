//
//  NSURLRequest+Additions.m
//  FirstP2P
//
//  Created by LCL on 14-7-1.
//  Copyright (c) 2014年 9888. All rights reserved.
//

#import "NSURLRequest+Additions.h"

@implementation NSURLRequest (NSURLRequestWithIgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}

@end
