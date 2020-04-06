//
//  BaseUserInfoModel.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "BaseUserInfoModel.h"

@implementation BaseUserInfoModel

- (id)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        
        self.avaterUrl = [dic stringValueForKey:@"avaterUrl"];
        
        self.comments = [dic stringValueForKey:@"comments"];
        
        self.telphone = [dic stringValueForKey:@"telphone"];
        
        if ([[dic stringValueForKey:@"gender"] isEqualToString:@"1"]) {
            self.gender = @"female";
        }
        if ([[dic stringValueForKey:@"gender"] isEqualToString:@"2"]) {
            self.gender = @"male";
        }
        
        self.nickName = [dic stringValueForKey:@"nickName"];
        
        self.userAccountId = [dic stringValueForKey:@"userAccountId"];
        
        self.woostalkId = [dic stringValueForKey:@"woostalkId"];
        
    }
    return self;
}

@end
