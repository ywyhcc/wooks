//
//  RCDUserSetting.m
//  SealTalk
//
//  Created by 张改红 on 2019/7/11.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDUserSetting.h"
#import <RongIMKit/RongIMKit.h>
@implementation RCDUserSetting
- (instancetype)initWithJson:(NSDictionary *)json {
    if (self = [super init]) {
        self.userId = json[@"id"];
        self.allowMobileSearch = [json[@"isAllowFindmeByTelphone"] boolValue];
        self.allowSTAccountSearch = [json[@"isAllowFindmeByWoostalk"] boolValue];
        self.needAddFriendVerify = [json[@"isOpenFriendAuthentication"] boolValue];
        self.needJoinGroupVerify = [json[@"isAllowAddGroup"] boolValue];
    }
    return self;
}
@end
