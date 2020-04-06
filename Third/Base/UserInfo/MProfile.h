//
//  MProfile.h
//  Momonts
//
//  Created by zhangzhendong on 2020/3/14.
//  Copyright © 2020 zhangzhendong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MProfile : NSObject

@property(nonatomic, strong)NSString *userAccountId;

@property(nonatomic, strong)NSString *region;

@property(nonatomic, strong)NSString *userId;

@property(nonatomic, strong)NSString *userInfoID;

@property(nonatomic, strong)NSString *telphone;

@property(nonatomic, strong)NSString *username;

@property(nonatomic, strong)NSString *avaterUrl;

@property(nonatomic, strong)NSString *birthday;

@property(nonatomic, strong)NSString *nickName;

@property(nonatomic, strong)NSString *token;

@property(nonatomic, strong)NSString *gender;

@property(nonatomic, strong)NSString *inviteCode;

@property(nonatomic, strong)NSArray *notDisturbAndTopUsers;             //勿扰对象


- (id)initWithDictionary:(NSDictionary*)dic;

@end

NS_ASSUME_NONNULL_END
