//
//  RequestHeader.m
//  Momonts
//
//  Created by zhangzhendong on 2020/3/14.
//  Copyright © 2020 zhangzhendong. All rights reserved.
//

#import "RequestHeader.h"

@implementation RequestHeader

+ (NSDictionary*)getHederDic{
    
    NSMutableDictionary *muDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [muDic setValue:@"1111" forKey:@"token"];
    return muDic;
    
}

@end
