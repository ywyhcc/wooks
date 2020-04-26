//
//  RCDUserInfoAPI.m
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDUserInfoAPI.h"
#import "RCDHTTPUtility.h"
#import "RCDCommonString.h"
@implementation RCDUserInfoAPI

+ (void)getUserInfo:(NSString *)userId anotherUserID:(NSString *)otherId complete:(void (^)(RCDUserInfo *))completeBlock {
    if (!userId || !otherId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(nil);
        }
        return;
    }
    if ([ProfileUtil getUserAccountID] == nil) {
        return;
    }
    
    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"toUserAccountId":otherId};
    
    [SYNetworkingManager postWithURLString:GetInfo parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            
            RCDUserInfo *userInfo = [[RCDUserInfo alloc] init];
            userInfo.userId = otherId;
            userInfo.name = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"nickName"];
            userInfo.portraitUri = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"avaterUrl"];
            userInfo.stAccount = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"woostalkId"];
//            userInfo.gender = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"gender"];
            if ([[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"gender"] isEqualToString:@"1"]) {
                userInfo.gender = @"female";
            }
            if ([[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"gender"] isEqualToString:@"2"]) {
                userInfo.gender = @"male";
            }
            if (completeBlock) {
                completeBlock(userInfo);
            }
        }
        else {
            if (completeBlock) {
                completeBlock(nil);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(nil);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
//                                URLString:[NSString stringWithFormat:@"user/%@", userId]
//                               parameters:nil
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         RCDUserInfo *userInfo = [[RCDUserInfo alloc] init];
//                                         userInfo.userId = userId;
//                                         userInfo.name = result.content[@"nickname"];
//                                         userInfo.portraitUri = result.content[@"portraitUri"];
//                                         userInfo.stAccount = result.content[@"stAccount"];
//                                         userInfo.gender = result.content[@"gender"];
//                                         if (completeBlock) {
//                                             completeBlock(userInfo);
//                                         }
//                                     } else {
//                                         if (completeBlock) {
//                                             completeBlock(nil);
//                                         }
//                                     }
//                                 }];
}

+ (void)getFriendInfo:(NSString *)userId complete:(void (^)(RCDFriendInfo *))completeBlock {
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(nil);
        }
        return;
    }
    
    
    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"toUserAccountId":userId};
    
    [SYNetworkingManager postWithURLString:GetInfo parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            
            RCDFriendInfo *friendInfo = [[RCDFriendInfo alloc] init];
            friendInfo.userId = userId;
            if ([data stringValueForKey:@"friendRemark"].length > 0) {
                friendInfo.displayName = [data stringValueForKey:@"friendRemark"];
            }
            friendInfo.sparePhone = [data stringValueForKey:@"friendPhone"];//备注手机号(备注的)
            friendInfo.showPhone = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"sparePhoneNumber"];//用户备用用手机号
            friendInfo.district = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"district"];
            friendInfo.name = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"nickName"];
            friendInfo.portraitUri = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"avaterUrl"];
            friendInfo.status = RCDFriendStatusAgree;
            if ([data boolValueForKey:@"isAddBlackList"]) {
                friendInfo.status = RCDFriendStatusBlock;
            }
            friendInfo.phoneNumber = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"telphone"];
//            friendInfo.updateDt = [userDic[@"updatedTime"] longLongValue];
            friendInfo.stAccount = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"woostalkId"];
            friendInfo.isHidePhone = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"isHidePhone"];
            if ([[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"gender"] isEqualToString:@"1"]) {
                friendInfo.gender = @"female";
            }
            if ([[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"gender"] isEqualToString:@"2"]) {
                friendInfo.gender = @"male";
            }
//            friendInfo.gender = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"gender"];
            if (completeBlock) {
                completeBlock(friendInfo);
            }
        }
        else {
            if (completeBlock) {
                completeBlock(nil);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(nil);
        }
    }];
    
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
//                                URLString:[NSString stringWithFormat:@"friendship/%@/profile", userId]
//                               parameters:nil
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         RCDFriendInfo *friendInfo = [[RCDFriendInfo alloc] init];
//                                         friendInfo.userId = userId;
//                                         friendInfo.displayName = result.content[@"displayName"];
//                                         NSDictionary *userDic = result.content[@"user"];
//                                         friendInfo.name = userDic[@"nickname"];
//                                         friendInfo.portraitUri = userDic[@"portraitUri"];
//                                         friendInfo.status = RCDFriendStatusAgree;
//                                         friendInfo.phoneNumber = userDic[@"phone"];
//                                         friendInfo.updateDt = [userDic[@"updatedTime"] longLongValue];
//                                         friendInfo.stAccount = userDic[@"stAccount"];
//                                         friendInfo.gender = userDic[@"gender"];
//                                         if (completeBlock) {
//                                             completeBlock(friendInfo);
//                                         }
//                                     } else {
//                                         if (completeBlock) {
//                                             completeBlock(nil);
//                                         }
//                                     }
//                                 }];
}

+ (void)setCurrentUserName:(NSString *)name complete:(void (^)(BOOL))completeBlock {
    if (!name) {
        SealTalkLog(@"name is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    
    NSDictionary *params = @{@"userInfoId":[ProfileUtil getUserProfile].userInfoID,@"nickName":name};
    [SYNetworkingManager requestPUTWithURLStr:UpdateMyInfo paramDic:params success:^(NSDictionary *data) {
        if (name.length > 0) {
            if (completeBlock) {
                completeBlock(YES);
            }
        }
        else{
            if (completeBlock) {
                completeBlock(NO);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(NO);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"user/set_nickname"
//                               parameters:@{
//                                   @"nickname" : name
//                               }
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         if (completeBlock) {
//                                             completeBlock(YES);
//                                         }
//                                     } else {
//                                         if (completeBlock) {
//                                             completeBlock(NO);
//                                         }
//                                     }
//                                 }];
}

+ (void)setCurrentUserPortrait:(NSString *)portraitUri complete:(void (^)(BOOL))completeBlock {
    if (!portraitUri) {
        SealTalkLog(@"portraitUri is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    NSDictionary *params = @{@"userInfoId":[ProfileUtil getUserProfile].userInfoID,@"avaterUrl":portraitUri};
    [SYNetworkingManager requestPUTWithURLStr:UpdateMyInfo paramDic:params success:^(NSDictionary *data) {
        if (portraitUri.length > 0) {
            if (completeBlock) {
                completeBlock(YES);
            }
        }
        else{
            if (completeBlock) {
                completeBlock(NO);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(NO);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"user/set_portrait_uri"
//                               parameters:@{
//                                   @"portraitUri" : portraitUri
//                               }
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         if (completeBlock) {
//                                             completeBlock(YES);
//                                         }
//                                     } else {
//                                         if (completeBlock) {
//                                             completeBlock(NO);
//                                         }
//                                     }
//                                 }];
}

+ (void)setFriendNickname:(NSString *)nickname byUserId:(NSString *)userId complete:(void (^)(BOOL))completeBlock {
    if (!userId || !nickname) {
        SealTalkLog(@"userId or nickname is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"friendship/set_display_name"
                               parameters:@{
                                   @"friendId" : userId,
                                   @"displayName" : nickname
                               }
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if (completeBlock) {
                                             completeBlock(YES);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(NO);
                                         }
                                     }
                                 }];
}

+ (void)setSTAccount:(NSString *)stAccount
            complete:(void (^)(BOOL success))completeBlock
               error:(void (^)(RCDUserErrorCode errorCode))errorBlock {
    if (!stAccount) {
        SealTalkLog(@"stAccount is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    
    NSDictionary *params = @{@"userInfoId":[ProfileUtil getUserProfile].userInfoID,@"woostalkId":stAccount};
    [SYNetworkingManager requestPUTWithURLStr:UpdateMyInfo paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            [DEFAULTS setObject:stAccount forKey:WoosTalkID];
            [DEFAULTS setObject:@"1" forKey:EditChangeWoosTalkID];
            [DEFAULTS setObject:stAccount forKey:RCDSealTalkNumberKey];
            if (completeBlock) {
                completeBlock(YES);
            }else {
                errorBlock(RCDUserErrorCodeUnknown);
            }
        }
    } failure:^(NSError *error) {
        errorBlock(RCDUserErrorCodeUnknown);
        
    }];
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"user/set_st_account"
//                               parameters:@{
//                                   @"stAccount" : stAccount
//                               }
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         if (completeBlock) {
//                                             completeBlock(YES);
//                                         }
//                                     } else {
//                                         if (result.httpCode == 400) {
//                                             errorBlock(RCDUserErrorCodeInvalidFormat);
//                                         } else if (result.errorCode == 1000) {
//                                             errorBlock(RCDUserErrorCodeStAccountIsExist);
//                                         } else {
//                                             errorBlock(RCDUserErrorCodeUnknown);
//                                         }
//                                     }
//                                 }];
}

+ (void)setGender:(NSString *)gender complete:(void (^)(BOOL success))completeBlock {
    if (!gender) {
        SealTalkLog(@"stAccount is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    
    NSDictionary *params = @{@"userInfoId":[ProfileUtil getUserProfile].userInfoID,@"gender": gender};
    [SYNetworkingManager requestPUTWithURLStr:UpdateMyInfo paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (completeBlock) {
                completeBlock(YES);
            }
        }
        else {
            if (completeBlock) {
                completeBlock(NO);
            }
        }
        
//        NSLog(@"成功");
//        [DEFAULTS setObject:gender forKey:RCDUserGenderKey];
//        [self.navigationController popViewControllerAnimated:YES];
//        [self.view showHUDMessage:RCDLocalizedString(@"setting_success")];
    } failure:^(NSError *error) {
//        NSLog(@"失败");
//        [self.view showHUDMessage:RCDLocalizedString(@"set_fail")];
    }];
    
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"user/set_gender"
//                               parameters:@{
//                                   @"gender" : gender
//                               }
//                                 response:^(RCDHTTPResult *result) {
//                                     if (completeBlock) {
//                                         completeBlock(result.success);
//                                     }
//                                 }];
}
//获取申请列表
+ (void)getApplyList:(void (^)(NSArray<RCDFriendInfo *> *))completeBlock {
    if ([ProfileUtil getUserAccountID].length == 0) {
        return;
    }
    NSDictionary *params = @{@"userAccountId":[ProfileUtil getUserAccountID]};
   [SYNetworkingManager getWithURLString:ApplyRecord parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSMutableArray *friendList = [[NSMutableArray alloc] init];
            NSArray *respFriendList = [data arrayValueForKey:@"myFriends"];
            for (NSDictionary *userDic in respFriendList) {

                RCDFriendInfo *friendInfo = [[RCDFriendInfo alloc] init];
                friendInfo.userId = [userDic stringValueForKey:@"userAccountId"];
                friendInfo.name = [userDic stringValueForKey:@"nickName"];
                friendInfo.portraitUri = [userDic stringValueForKey:@"avaterUrl"];
                friendInfo.displayName = [userDic stringValueForKey:@"userRemarks"];
                
                //好友审核状态(我发送的好友请求:0.已发送1.已通过-1.被拒绝) 别人加我的好友请求(2.正在审核中3.同意-2.拒绝)
                
                if ([[userDic stringValueForKey:@"friendAplyStatus"] isEqualToString:@"0"]) {
                    friendInfo.status = 10;
                }
                else if ([[userDic stringValueForKey:@"friendAplyStatus"] isEqualToString:@"1"]){
                    friendInfo.status = 20;
                }
                else if ([[userDic stringValueForKey:@"friendAplyStatus"] isEqualToString:@"2"]){
                    friendInfo.status = 11;
                }
                else if ([[userDic stringValueForKey:@"friendAplyStatus"] isEqualToString:@"3"]){
                    friendInfo.status = 52;
                }
                else if ([[userDic stringValueForKey:@"friendAplyStatus"] isEqualToString:@"-2"]){
                    friendInfo.status = 21;
                }
                else if ([[userDic stringValueForKey:@"friendAplyStatus"] isEqualToString:@"-1"]){
                    friendInfo.status = 51;
                }
                else {
                    friendInfo.status = 20;
                }
                friendInfo.phoneNumber = [userDic stringValueForKey:@"telphone"];
                friendInfo.stAccount = [userDic stringValueForKey:@"friendId"];
                friendInfo.friendID = [userDic stringValueForKey:@"friendId"];
//                friendInfo.gender = [userDic stringValueForKey:@"gender"];
                if ([[userDic stringValueForKey:@"gender"] isEqualToString:@"1"]) {
                    friendInfo.gender = @"female";
                }
                if ([[userDic stringValueForKey:@"gender"] isEqualToString:@"2"]) {
                    friendInfo.gender = @"male";
                }
                //暂时没有用到（***我的标记***）
//                friendInfo.updateDt = [userDic[@"updateDate"] longLongValue];
                [friendList addObject:friendInfo];
            }
            if (completeBlock) {
                completeBlock(friendList);
            }
        }
        else{
            if (completeBlock) {
                completeBlock(nil);
            }
        }
   } failure:^(NSError *error) {
       if (completeBlock) {
           completeBlock(nil);
       }
   }];
}

+ (void)getFriendList:(void (^)(NSArray<RCDFriendInfo *> *))completeBlock {
    if ([ProfileUtil getUserAccountID].length <= 0) {
        return;
    }
    
    NSDictionary *params = @{@"userAccountId":[ProfileUtil getUserAccountID]};
    [SYNetworkingManager getWithURLString:ApplyRecord parameters:params success:^(NSDictionary *data) {
         if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
             NSLog(@"----%@",data);
             NSMutableArray *friendList = [[NSMutableArray alloc] init];
             NSArray *respFriendList = [data arrayValueForKey:@"myFriends"];
             for (NSDictionary *userDic in respFriendList) {

                 RCDFriendInfo *friendInfo = [[RCDFriendInfo alloc] init];
                 friendInfo.userId = userDic[@"userAccountId"];
                 friendInfo.name = userDic[@"nickName"];
                 friendInfo.portraitUri = userDic[@"avaterUrl"];
                 friendInfo.displayName = userDic[@"userRemarks"];
                 friendInfo.district = [userDic stringValueForKey:@"district"];
                 
                 //好友审核状态(我发送的好友请求:0.已发送1.已通过-1.被拒绝) 别人加我的好友请求(2.正在审核中3.同意-2.拒绝)
                 
                 if ([[userDic stringValueForKey:@"friendAplyStatus"] isEqualToString:@"0"]) {
                     friendInfo.status = 10;
                 }
                 else if ([[userDic stringValueForKey:@"friendAplyStatus"] isEqualToString:@"1"]){
                     friendInfo.status = 20;
                 }
                 else if ([[userDic stringValueForKey:@"friendAplyStatus"] isEqualToString:@"2"]){
                     friendInfo.status = 11;
                 }
                 else if ([[userDic stringValueForKey:@"friendAplyStatus"] isEqualToString:@"3"]){
                     friendInfo.status = 20;
                 }
                 else if ([[userDic stringValueForKey:@"friendAplyStatus"] isEqualToString:@"-2"]){
                     friendInfo.status = 21;
                 }
                 else if ([[userDic stringValueForKey:@"friendAplyStatus"] isEqualToString:@"-1"]){
                     friendInfo.status = 51;
                 }
                 else {
                     friendInfo.status = 20;
                 }
                 friendInfo.phoneNumber = userDic[@"telphone"];
                 friendInfo.stAccount = userDic[@"friendId"];
                 friendInfo.friendID = userDic[@"friendId"];
//                 friendInfo.gender = userDic[@"gender"];
                 if ([[userDic stringValueForKey:@"gender"] isEqualToString:@"1"]) {
                     friendInfo.gender = @"female";
                 }
                 if ([[userDic stringValueForKey:@"gender"] isEqualToString:@"2"]) {
                     friendInfo.gender = @"male";
                 }
                 //暂时没有用到（***我的标记***）
 //                friendInfo.updateDt = [userDic[@"updateDate"] longLongValue];
                 [friendList addObject:friendInfo];
             }
             [RCDUserInfoAPI getMailFriendList:^(NSArray<RCDFriendInfo *> *mfriendList) {
                 for (RCDFriendInfo *mFriend in mfriendList) {
                     BOOL exit = NO;
                     for (RCDFriendInfo *tempFriend in friendList) {
                         if ([mFriend.userId isEqualToString:tempFriend.userId]) {
                             exit = YES;
                         }
                     }
                     if (!exit) {
                         [friendList addObject:mFriend];
                     }
                 }
                 if (completeBlock) {
                     completeBlock(friendList);
                 }
             }];
         }
         else{
             if (completeBlock) {
                 completeBlock(nil);
             }
         }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(nil);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
//                                URLString:@"friendship/all"
//                               parameters:nil
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         NSArray *respFriendList = result.content;
//                                         NSMutableArray *friendList = [[NSMutableArray alloc] init];
//                                         for (NSDictionary *respFriend in respFriendList) {
//                                             NSDictionary *userDic = respFriend[@"user"];
//                                             RCDFriendInfo *friendInfo = [[RCDFriendInfo alloc] init];
//                                             friendInfo.userId = userDic[@"id"];
//                                             friendInfo.name = userDic[@"nickname"];
//                                             friendInfo.portraitUri = userDic[@"portraitUri"];
//                                             friendInfo.displayName = respFriend[@"displayName"];
//                                             friendInfo.status = [respFriend[@"status"] integerValue];
//                                             friendInfo.phoneNumber = userDic[@"phone"];
//                                             friendInfo.stAccount = userDic[@"stAccount"];
//                                             friendInfo.gender = userDic[@"gender"];
//                                             friendInfo.updateDt = [respFriend[@"updatedTime"] longLongValue];
//                                             [friendList addObject:friendInfo];
//                                         }
//                                         if (completeBlock) {
//                                             completeBlock(friendList);
//                                         }
//                                     }
//                                 }];
}

+ (void)getMailFriendList:(void (^)(NSArray<RCDFriendInfo *> *))completeBlock{
    
    NSDictionary *params = @{@"userAccountId":[ProfileUtil getUserAccountID]};
    [SYNetworkingManager getWithURLString:GetMailList parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSArray *respFriendList = [data arrayValueForKey:@"myFriends"];
            NSMutableArray *friendList = [[NSMutableArray alloc] init];
            for (NSDictionary *userDic in respFriendList) {
                
                RCDFriendInfo *friendInfo = [[RCDFriendInfo alloc] init];
                friendInfo.userId = userDic[@"userAccountId"];
                friendInfo.name = userDic[@"nickName"];
                friendInfo.portraitUri = userDic[@"avaterUrl"];
                friendInfo.displayName = userDic[@"userRemarks"];
                friendInfo.status = 20;
                friendInfo.phoneNumber = userDic[@"telphone"];
                friendInfo.district = [userDic stringValueForKey:@"district"];
                friendInfo.stAccount = userDic[@"friendId"];
//                friendInfo.gender = userDic[@"gender"];
                if ([[userDic stringValueForKey:@"gender"] isEqualToString:@"1"]) {
                    friendInfo.gender = @"female";
                }
                if ([[userDic stringValueForKey:@"gender"] isEqualToString:@"2"]) {
                    friendInfo.gender = @"male";
                }
                friendInfo.friendID = userDic[@"friendId"];
                //暂时没有用到（***我的标记***）
                //                friendInfo.updateDt = [userDic[@"updateDate"] longLongValue];
                [friendList addObject:friendInfo];
            }
            if (completeBlock) {
                completeBlock(friendList);
            }
        }
        else{
            if (completeBlock) {
                completeBlock(nil);
            }
        }
        
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(nil);
        }
    }];
}

+ (void)inviteFriend:(NSString *)userId
         withMessage:(NSString *)message
            complete:(void (^)(BOOL, NSString *))completeBlock {
    if (!userId || !message) {
        SealTalkLog(@"userId or message is nil");
        if (completeBlock) {
            completeBlock(NO, @"");
        }
        return;
    }//AddDirectly
    
    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"toUserAccountId":userId};
    [SYNetworkingManager postWithURLString:AddFriend parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSString *action = @"AddDirectly";
            if (completeBlock) {
                completeBlock(YES, action);
            }
        }
        else{
            if (completeBlock) {
                completeBlock(NO, [data stringValueForKey:@"message"]);
            }
        }
        
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(NO, @"请求错误");
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"friendship/invite"
//                               parameters:@{
//                                   @"friendId" : userId,
//                                   @"message" : message
//                               }
//                                 response:^(RCDHTTPResult *result) {
//                                     NSString *action = result.content[@"action"];
//                                     if (completeBlock) {
//                                         completeBlock(result.success, action);
//                                     }
//                                 }];
}

+ (void)acceptFriendRequest:(NSArray *)userIds complete:(void (^)(BOOL))completeBlock {
    if (!userIds) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    
    NSDictionary *params = @{@"friendIds":userIds,@"optCode":@"1"};
    [SYNetworkingManager requestPUTWithURLStr:AcceptFriends paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (completeBlock) {
                completeBlock(YES);
            }
        }
        else{
            if (completeBlock) {
                completeBlock(NO);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(NO);
        }
    }];
    
//    //status -1不同意，1同意
//    NSDictionary *params = @{@"friendId":[ProfileUtil getUserAccountID],@"status":@"1"};
//    [SYNetworkingManager requestPUTWithURLStr:CheckFriend paramDic:params success:^(NSDictionary *data) {
//        if (completeBlock) {
//            completeBlock(YES);
//        }
//        else{
//            if (completeBlock) {
//                completeBlock(NO);
//            }
//        }
//    } failure:^(NSError *error) {
//        if (completeBlock) {
//            completeBlock(NO);
//        }
//    }];
    
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"friendship/agree"
//                               parameters:@{
//                                   @"friendId" : userId
//                               }
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         if (completeBlock) {
//                                             completeBlock(YES);
//                                         }
//                                     } else {
//                                         if (completeBlock) {
//                                             completeBlock(NO);
//                                         }
//                                     }
//                                 }];
}

+ (void)ignoreFriendRequest:(NSString *)userId complete:(void (^)(BOOL success))completeBlock {
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    
    NSDictionary *params = @{@"friendIds":@[userId],@"optCode":@"2"};
    [SYNetworkingManager requestPUTWithURLStr:AcceptFriends paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (completeBlock) {
                completeBlock(YES);
            }
        }
        else{
            if (completeBlock) {
                completeBlock(NO);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(NO);
        }
    }];
    
//    //status -1不同意，1同意
//    NSDictionary *params = @{@"friendId":[ProfileUtil getUserAccountID],@"status":@"-1"};
//    [SYNetworkingManager requestPUTWithURLStr:CheckFriend paramDic:params success:^(NSDictionary *data) {
//        if (completeBlock) {
//            completeBlock(YES);
//        }
//        else{
//            if (completeBlock) {
//                completeBlock(NO);
//            }
//        }
//    } failure:^(NSError *error) {
//        if (completeBlock) {
//            completeBlock(NO);
//        }
//    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"friendship/ignore"
//                               parameters:@{
//                                   @"friendId" : userId
//                               }
//                                 response:^(RCDHTTPResult *result) {
//                                     if (completeBlock) {
//                                         completeBlock(result.success);
//                                     }
//                                 }];
}

+ (void)deleteFriend:(NSString *)userId complete:(void (^)(BOOL))completeBlock {
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    
    NSDictionary *params = @{@"friendId":userId};
    [SYNetworkingManager deleteWithURLString:DeleteFriend parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (completeBlock) {
                completeBlock(YES);
            }
        }
        else{
            if (completeBlock) {
                completeBlock(NO);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(NO);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"friendship/delete"
//                               parameters:@{
//                                   @"friendId" : userId
//                               }
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         if (completeBlock) {
//                                             completeBlock(YES);
//                                         }
//                                     } else {
//                                         if (completeBlock) {
//                                             completeBlock(NO);
//                                         }
//                                     }
//                                 }];
}

+ (void)findUserByPhone:(NSString *)phone
                 region:(NSString *)region
            orStAccount:(NSString *)stAccount
               complete:(void (^)(RCDUserInfo *))completeBlock {
    if (!phone) {
        SealTalkLog(@"phone region and stAccount is nil");
        if (completeBlock) {
            completeBlock(nil);
        }
        return;
    }
    
    
    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"telphone":phone};
    [SYNetworkingManager postWithURLString:SearchFriend parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            
            RCDUserInfo *userInfo = [[RCDUserInfo alloc] init];
            userInfo.userId = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"userAccountId"];
            userInfo.name = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"nickName"];
            userInfo.portraitUri = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"avaterUrl"];
            userInfo.stAccount = @"";//[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"userAccountId"];
//            userInfo.gender = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"gender"];
            if ([[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"gender"] isEqualToString:@"1"]) {
                userInfo.gender = @"female";
            }
            if ([[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"gender"] isEqualToString:@"2"]) {
                userInfo.gender = @"male";
            }
            if (completeBlock) {
                completeBlock(userInfo);
            }
        }
        else {
            if (completeBlock) {
                completeBlock(nil);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(nil);
        }
    }];
    
//    NSString *params = @"";
//    if (stAccount) {
//        params = [NSString stringWithFormat:@"st_account=%@", stAccount];
//    } else {
//        params = [NSString stringWithFormat:@"region=%@&phone=%@", region, phone];
//    }
//
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
//                                URLString:[NSString stringWithFormat:@"user/find_user?%@", params]
//                               parameters:nil
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         RCDUserInfo *userInfo = [[RCDUserInfo alloc] init];
//                                         userInfo.userId = result.content[@"id"];
//                                         userInfo.name = result.content[@"nickname"];
//                                         userInfo.portraitUri = result.content[@"portraitUri"];
//                                         userInfo.stAccount = result.content[@"stAccount"];
//                                         userInfo.gender = result.content[@"gender"];
//                                         if (completeBlock) {
//                                             completeBlock(userInfo);
//                                         }
//                                     } else {
//                                         if (completeBlock) {
//                                             completeBlock(nil);
//                                         }
//                                     }
//                                 }];
}

+ (void)findUserByPhone:(NSString *)phone region:(NSString *)region complete:(void (^)(RCDUserInfo *))completeBlock {
    if (!phone) {
        SealTalkLog(@"phone or region is nil");
        if (completeBlock) {
            completeBlock(nil);
        }
        return;
    }
    
    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"telphone":phone};
    [SYNetworkingManager postWithURLString:SearchFriend parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            
            RCDUserInfo *userInfo = [[RCDUserInfo alloc] init];
            userInfo.userId = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"userAccountId"];
            userInfo.name = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"nickName"];
            userInfo.portraitUri = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"avaterUrl"];
            userInfo.stAccount = @"";//[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"userAccountId"];
//            userInfo.gender = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"gender"];
            if ([[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"gender"] isEqualToString:@"1"]) {
                userInfo.gender = @"female";
            }
            if ([[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"gender"] isEqualToString:@"2"]) {
                userInfo.gender = @"male";
            }
            if (completeBlock) {
                completeBlock(userInfo);
            }
        }
        else {
            if (completeBlock) {
                completeBlock(nil);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(nil);
        }
    }];
    
    
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
//                                URLString:[NSString stringWithFormat:@"user/find/%@/%@", region, phone]
//                               parameters:nil
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         RCDUserInfo *userInfo = [[RCDUserInfo alloc] init];
//                                         userInfo.userId = result.content[@"id"];
//                                         userInfo.name = result.content[@"nickname"];
//                                         userInfo.portraitUri = result.content[@"portraitUri"];
//                                         userInfo.stAccount = result.content[@"stAccount"];
//                                         userInfo.gender = result.content[@"gender"];
//                                         if (completeBlock) {
//                                             completeBlock(userInfo);
//                                         }
//                                     } else {
//                                         if (completeBlock) {
//                                             completeBlock(nil);
//                                         }
//                                     }
//                                 }];
}

+ (void)getContactsInfo:(NSArray *)phoneNumberList complete:(void (^)(NSArray *contactsList))completeBlock {
    
//    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"telphones":phoneNumberList};
//    [SYNetworkingManager postWithURLString:GetPhoneAllUser parameters:params success:^(NSDictionary *data) {
//        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
//            NSArray *allPhoneUser = [data arrayValueForKey:@"allPhoneUser"];
//            if (completeBlock) {
//                completeBlock(allPhoneUser);
//            }
//        }
//    } failure:^(NSError *error) {
//
//    }];
    
    
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"friendship/get_contacts_info"
                               parameters:@{
                                   @"contactList" : phoneNumberList
                               }
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSArray *list = result.content;
                                         if (completeBlock) {
                                             completeBlock(list);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(nil);
                                         }
                                     }
                                 }];
}

// 批量删除好友
+ (void)batchFriendDelete:(NSArray *)friendIds complete:(void (^)(BOOL success))completeBlock {
    if (!friendIds) {
        SealTalkLog(@"friendIds is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    
    NSDictionary *params = @{@"friendIds":friendIds};
    [SYNetworkingManager deleteWithURLString:DeleteBetchFriend parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (completeBlock) {
                completeBlock(YES);
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"批量删除好友失败");
    }];
    
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"friendship/batch_delete"
//                               parameters:@{
//                                   @"friendIds" : friendIds
//                               }
//                                 response:^(RCDHTTPResult *result) {
//                                     if (completeBlock) {
//                                         completeBlock(result.success);
//                                     }
//                                 }];
}

//将某个用户加入黑名单
+ (void)addToBlacklist:(NSString *)userId complete:(void (^)(BOOL success))completeBlock {
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    
    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"toUserAccountId":userId};
    [SYNetworkingManager postWithURLString:AddBlackList parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (completeBlock) {
                completeBlock(YES);
            }
        }
        else {
            if (completeBlock) {
                completeBlock(NO);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(NO);
        }
    }];
    
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"user/add_to_blacklist"
//                               parameters:@{
//                                   @"friendId" : userId
//                               }
//                                 response:^(RCDHTTPResult *result) {
//                                     if (completeBlock) {
//                                         completeBlock(result.success);
//                                     }
//                                 }];
}

//将某个用户移出黑名单
+ (void)removeFromBlacklist:(NSString *)userId complete:(void (^)(BOOL success))completeBlock {
    if (!userId) {
        SealTalkLog(@"userId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    
    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"toUserAccountId":userId};
    [SYNetworkingManager deleteWithURLString:RemoveBlackList parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (completeBlock) {
                completeBlock(YES);
            }
        }
        else {
            if (completeBlock) {
                completeBlock(NO);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(NO);
        }
    }];
    
    
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"user/remove_from_blacklist"
//                               parameters:@{
//                                   @"friendId" : userId
//                               }
//                                 response:^(RCDHTTPResult *result) {
//                                     if (completeBlock) {
//                                         completeBlock(result.success);
//                                     }
//                                 }];
}

// 查询已经设置的黑名单列表
+ (void)getBlacklist:(void (^)(NSArray<RCDUserInfo *> *blackUsers))completeBlock {
    
    NSDictionary *params = @{@"userAccountId":[ProfileUtil getUserAccountID]};
    [SYNetworkingManager getWithURLString:BlackList parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSArray *list = [data arrayValueForKey:@"blackUsers"];
            NSMutableArray *users = [NSMutableArray array];
            
            for (NSDictionary *dic in list) {
                RCDUserInfo *userInfo = [[RCDUserInfo alloc] init];
                userInfo.userId = dic[@"userAccountId"];
                userInfo.name = dic[@"nickName"];
                userInfo.portraitUri = dic[@"avaterUrl"];
//                userInfo.stAccount = dic[@"stAccount"];
//                userInfo.gender = dic[@"gender"];
                if ([[dic stringValueForKey:@"gender"] isEqualToString:@"1"]) {
                    userInfo.gender = @"female";
                }
                if ([[dic stringValueForKey:@"gender"] isEqualToString:@"2"]) {
                    userInfo.gender = @"male";
                }
                [users addObject:userInfo];
            }
            
            if (completeBlock) {
                completeBlock(users);
            }
        }
        else {
            if (completeBlock) {
                completeBlock(nil);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(nil);
        }
    }];
    
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
//                                URLString:@"user/blacklist"
//                               parameters:nil
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         NSArray *list = result.content;
//                                         NSMutableArray *users = [NSMutableArray array];
//                                         for (NSDictionary *userJson in list) {
//                                             NSDictionary *dic = userJson[@"user"];
//                                             RCDUserInfo *userInfo = [[RCDUserInfo alloc] init];
//                                             userInfo.userId = dic[@"id"];
//                                             userInfo.name = dic[@"nickname"];
//                                             userInfo.portraitUri = dic[@"portraitUri"];
//                                             userInfo.stAccount = dic[@"stAccount"];
//                                             userInfo.gender = dic[@"gender"];
//                                             [users addObject:userInfo];
//                                         }
//                                         if (completeBlock) {
//                                             completeBlock(users);
//                                         }
//                                     } else {
//                                         if (completeBlock) {
//                                             completeBlock(nil);
//                                         }
//                                     }
//                                 }];
}

#pragma mark - user setting
+ (void)setSearchMeByMobile:(BOOL)allow complete:(void (^)(BOOL))completeBlock {
    [self setUserPrivacy:@{ @"isAllowFindmeByTelphone" : @(allow ? 1 : 0) } complete:completeBlock];
}

+ (void)setSearchMeBySTAccount:(BOOL)allow complete:(void (^)(BOOL))completeBlock {
    [self setUserPrivacy:@{ @"isAllowFindmeByWoostalk" : @(allow ? 1 : 0) } complete:completeBlock];
}

+ (void)setAddFriendVerify:(BOOL)needVerify complete:(void (^)(BOOL))completeBlock {
    [self setUserPrivacy:@{ @"isOpenFriendAuthentication" : @(needVerify ? 1 : 0) } complete:completeBlock];
}

+ (void)setJoinGroupVerify:(BOOL)needVerify complete:(void (^)(BOOL))completeBlock {
    [self setUserPrivacy:@{ @"isAllowAddGroup" : @(needVerify ? 1 : 0) } complete:completeBlock];
}

+ (void)setReceivePokeMessage:(BOOL)allowReceive complete:(void (^)(BOOL))completeBlock {
    
    NSDictionary *params = @{@"userAccountId":[ProfileUtil getUserAccountID],@"isRecivePokeNotification":(allowReceive ? @"1" : @"0")};
    [SYNetworkingManager requestPUTWithURLStr:SetSeting paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (completeBlock) {
                completeBlock(YES);
            }
        }
        else{
            if (completeBlock) {
                completeBlock(NO);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(NO);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"user/set_poke"
//                               parameters:@{
//                                   @"pokeStatus" : @(allowReceive ? 1 : 0)
//                               }
//                                 response:^(RCDHTTPResult *result) {
//                                     if (completeBlock) {
//                                         completeBlock(result.success);
//                                     }
//                                 }];
}

+ (void)getReceivePokeMessageStatus:(void (^)(BOOL))success error:(void (^)())error {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"user/get_poke"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSDictionary *dic = result.content;
                                         BOOL allow = [dic[@"pokeStatus"] boolValue];
                                         if (success) {
                                             success(allow);
                                         }
                                     } else {
                                         if (error) {
                                             error();
                                         }
                                     }
                                 }];
}

+ (void)getUserPrivacy:(void (^)(RCDUserSetting *))completeBlock {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"user/get_privacy"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSDictionary *dic = result.content;
                                         RCDUserSetting *setting = [[RCDUserSetting alloc] initWithJson:dic];
                                         if (completeBlock) {
                                             completeBlock(setting);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(nil);
                                         }
                                     }
                                 }];
}

#pragma mark - Friend Description
+ (void)setDescriptionWithUserId:(NSString *)friendId
                          remark:(NSString *)remark
                          region:(NSString *)region
                           phone:(NSString *)phone
                            desc:(NSString *)desc
                        imageUrl:(NSString *)imageUrl
                        complete:(void (^)(BOOL success))completeBlock {
    if (!friendId) {
        SealTalkLog(@"friendId is nil");
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    NSDictionary *params = @{
        @"fromUserAccountId":[ProfileUtil getUserAccountID],
        @"toUserAccountId" : friendId,
        @"userRemarks" : remark,
//        @"region" : region,
        @"sparePhone" : phone,
        @"userDescribe" : desc,
        @"userCart" : imageUrl
    };
    //@"userRemarks":@"用户备注",@"sparePhone":@"备用手机号",@"userDescribe":@"用户描述",@"userCart":@"用户明信片"
    
    [SYNetworkingManager requestPUTWithURLStr:ChangeFriendInfo paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (completeBlock) {
                completeBlock(YES);
            }
        }
        else{
            if (completeBlock) {
                completeBlock(NO);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(NO);
        }
    }];
    

//    NSDictionary *params = @{
//        @"friendId" : friendId,
//        @"displayName" : remark,
//        @"region" : region,
//        @"phone" : phone,
//        @"description" : desc,
//        @"imageUri" : imageUrl
//    };
//
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"friendship/set_friend_description"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (completeBlock) {
//                                         completeBlock(result.success);
//                                     }
//                                 }];
}

+ (void)getDescriptionWithUserId:(NSString *)friendId
                        complete:(void (^)(RCDFriendDescription *friendDescription))completeBlock {
    if (!friendId) {
        SealTalkLog(@"friendId is nil");
        if (completeBlock) {
            completeBlock(nil);
        }
        return;
    }

    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"toUserAccountId":friendId};
    
    [SYNetworkingManager postWithURLString:GetInfo parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            
            RCDFriendDescription *description =
                [[RCDFriendDescription alloc] init];
            description.userId = friendId;
            description.friendDescribe = [data stringValueForKey:@"friendDescribe"];
            if ([data stringValueForKey:@"friendRemark"].length > 0) {
                description.displayName = [data stringValueForKey:@"friendRemark"];
//            }else {
//                description.displayName = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"nickName"];
            }
            description.sparePhone = [data stringValueForKey:@"friendPhone"];//备注手机号(备注的)
            description.showPhone = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"sparePhoneNumber"];//用户备用手机号
            description.phone = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"telphone"];
            description.desc = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"comments"];
            description.imageUrl = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"avaterUrl"];
            description.hidePhone = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"isHidePhone"];
            if (completeBlock) {
                completeBlock(description);
            }
            
        }
        else {
            if (completeBlock) {
                completeBlock(nil);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(nil);
        }
    }];
    
    
    
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"friendship/get_friend_description"
//                               parameters:@{
//                                   @"friendId" : friendId
//                               }
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         NSDictionary *dict = result.content;
//                                         RCDFriendDescription *description =
//                                             [[RCDFriendDescription alloc] initWithJson:dict];
//                                         description.userId = friendId;
//                                         if (completeBlock) {
//                                             completeBlock(description);
//                                         }
//                                     } else {
//                                         if (completeBlock) {
//                                             completeBlock(nil);
//                                         }
//                                     }
//                                 }];
}

#pragma mark - private
+ (void)setUserPrivacy:(NSDictionary *)param complete:(void (^)(BOOL success))completeBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params addEntriesFromDictionary:param];
    [params setObject:[ProfileUtil getUserAccountID] forKey:@"userAccountId"];
    [SYNetworkingManager requestPUTWithURLStr:SetSeting paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (completeBlock) {
                completeBlock(YES);
            }
        }
        else{
            if (completeBlock) {
                completeBlock(NO);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(NO);
        }
    }];
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"user/set_privacy"
//                               parameters:param
//                                 response:^(RCDHTTPResult *result) {
//                                     if (completeBlock) {
//                                         completeBlock(result.success);
//                                     }
//                                 }];
}
@end
