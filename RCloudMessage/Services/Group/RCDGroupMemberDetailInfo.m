//
//  RCDGroupMemberDetailInfo.m
//  SealTalk
//
//  Created by 张改红 on 2019/8/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupMemberDetailInfo.h"
@interface RCDGroupMemberDetailInfo ()
@property (nonatomic, strong) NSString *describeStr;
@end
@implementation RCDGroupMemberDetailInfo
- (instancetype)initWithJson:(NSDictionary *)json {
    if (self = [super init]) {
        self.groupNickname = [json objectForKey:@"groupNickname"];
        self.phone = [json objectForKey:@"phone"];
        self.region = [json objectForKey:@"region"];
        self.weChatAccount = [json objectForKey:@"WeChat"];
        self.alipayAccount = [json objectForKey:@"Alipay"];
        id describes = [json objectForKey:@"memberDesc"];
        if ([describes isKindOfClass:NSArray.class]) {
            self.describeArray = describes;
        }
    }
    return self;
}

- (NSDictionary *)decode {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:(self.groupMemberID ? self.groupMemberID : self.groupMemberID) forKey:@"groupMemberId"];
    [dic setObject:(self.groupNickname ? self.groupNickname : @"") forKey:@"newNickName"];
//    [dic setObject:(self.region ? self.region : @"") forKey:@"region"];
    [dic setObject:(self.phone ? self.phone : @"") forKey:@"memberTelphone"];
//    [dic setObject:(self.weChatAccount ? self.weChatAccount : @"") forKey:@"WeChat"];
//    [dic setObject:(self.alipayAccount ? self.alipayAccount : @"") forKey:@"Alipay"];
    if (self.describeArray.count > 0) {
        [dic setObject:self.describeArray[0] forKey:@"memberDescribe"];
    }
    return dic;
}

- (NSString *)describeStr {
    if (self.describeArray) {
        NSData *data =
            [NSJSONSerialization dataWithJSONObject:self.describeArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return jsonStr;
    }
    return nil;
}
@end
