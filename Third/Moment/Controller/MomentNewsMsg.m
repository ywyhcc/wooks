//
//  MomentNewsMsg.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/24.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "MomentNewsMsg.h"

@implementation MomentNewsMsg

static MomentNewsMsg *_instance = nil;

+ (MomentNewsMsg *)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return _instance;
}

@end
