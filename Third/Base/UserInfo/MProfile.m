//
//  MProfile.m
//  Momonts
//
//  Created by zhangzhendong on 2020/3/14.
//  Copyright © 2020 zhangzhendong. All rights reserved.
//

#import "MProfile.h"

@implementation MProfile

- (id)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        
        self.userAccountId = [[dic dictionaryValueForKey:@"userAccount"] stringValueForKey:@"id"];
        self.region = [[dic dictionaryValueForKey:@"userAccount"] stringValueForKey:@"region"];
        self.telphone = [[dic dictionaryValueForKey:@"userAccount"] stringValueForKey:@"telphone"];
        self.username = [[dic dictionaryValueForKey:@"userAccount"] stringValueForKey:@"username"];
        self.inviteCode = [[dic dictionaryValueForKey:@"userAccount"] stringValueForKey:@"inviterId"];
        
        
        self.token = [dic stringValueForKey:@"loginToken"];
        self.userId = [[dic dictionaryValueForKey:@"rongyunToken"] stringValueForKey:@"userId"];
        
        if ([[[dic dictionaryValueForKey:@"userInfo"] stringValueForKey:@"gender"] isEqualToString:@"1"]) {
            self.gender = @"female";
        }
        if ([[[dic dictionaryValueForKey:@"userInfo"] stringValueForKey:@"gender"] isEqualToString:@"2"]) {
            self.gender = @"male";
        }
        
        self.avaterUrl = [[dic dictionaryValueForKey:@"userInfo"] stringValueForKey:@"avaterUrl"];
        self.birthday = [[dic dictionaryValueForKey:@"userInfo"] stringValueForKey:@"birthday"];
        self.nickName = [[dic dictionaryValueForKey:@"userInfo"] stringValueForKey:@"nickName"];
        self.userInfoID = [[dic dictionaryValueForKey:@"userInfo"] stringValueForKey:@"id"];
        
    }
    return self;
}

@end
