//
//  NSUserDefaults+Category.m
//  Momonts
//
//  Created by zhangzhendong on 2020/3/14.
//  Copyright © 2020 zhangzhendong. All rights reserved.
//

#import "NSUserDefaults+Category.h"
#import "MProfile.h"


@implementation NSUserDefaults (Category)

- (void)saveUserInfo:(NSDictionary *)dic{
    [self setObject:dic forKey:@"userinfo"];
    [self synchronize];
}

- (NSDictionary *)getUserInfoFromMemory{
    return [self objectForKey:@"userinfo"];
}


@end
