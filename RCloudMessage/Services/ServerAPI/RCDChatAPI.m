//
//  RCDChatAPI.m
//  SealTalk
//
//  Created by 张改红 on 2019/7/10.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDChatAPI.h"
#import "RCDHTTPUtility.h"
@implementation RCDChatAPI

+ (void)setChatConfigWithConversationType:(RCConversationType)conversationType
                                 targetId:(NSString *)targetId
                screenCaptureNotification:(BOOL)open
                                 complete:(void (^)(BOOL))complete {
    if (!targetId) {
        SealTalkLog(@"targetId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    if (conversationType != ConversationType_PRIVATE && conversationType != ConversationType_GROUP) {
        complete(NO);
        return;
    }
    if (conversationType == ConversationType_PRIVATE) {
        NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"toUserAccountId":targetId,@"isOpenScreenshotsNotice":@(open ? 1 : 0)};
        [SYNetworkingManager requestPUTWithURLStr:ResetDisturb paramDic:params success:^(NSDictionary *data) {
            if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                if (complete) {
                    complete(YES);
                }
            }
        } failure:^(NSError *error) {
            NSLog(@"失败");
        }];
    }
    if (conversationType == ConversationType_GROUP) {
        NSDictionary *params = @{@"optUserAccountId":[ProfileUtil getUserAccountID],@"groupId":targetId,@"isOpenScreenshotsNotice":@(open ? 1 : 0)};
        [SYNetworkingManager requestPUTWithURLStr:ChangeGroupInfo paramDic:params success:^(NSDictionary *data) {
            if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                if (complete) {
                    complete(YES);
                }
            }
        } failure:^(NSError *error) {
            NSLog(@"失败");
        }];
    }
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"misc/set_screen_capture"
//                               parameters:@{
//                                   @"conversationType" : @(conversationType),
//                                   @"targetId" : targetId,
//                                   @"noticeStatus" : @(open ? 1 : 0)
//                               }
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

+ (void)getChatConfigWithConversationType:(RCConversationType)type
                                 targetId:(NSString *)targetId
                                  success:(void (^)(BOOL open))success
                                    error:(void (^)())error {
    if (!targetId) {
        SealTalkLog(@"targetId is nil");
        if (error) {
            error();
        }
        return;
    }
    
    if (type == ConversationType_PRIVATE) {
        NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"toUserAccountId":targetId};
            
        [SYNetworkingManager postWithURLString:GetInfo parameters:params success:^(NSDictionary *data) {
            if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                
                BOOL open = [data boolValueForKey:@"isOpenScreenshotsNotice"];
                if (success) {
                    success(open);
                }
            }
            else{
                if (error) {
                    error();
                }
            }
        } failure:^(NSError *error) {
            if (error) {
            }
        }];
    }
    else if (type == ConversationType_GROUP){
        NSDictionary *params = @{@"groupId":targetId};
        [SYNetworkingManager getWithURLString:GetGroupInfo parameters:params success:^(NSDictionary *data) {
            if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                NSDictionary *groupInfo = [[data dictionaryValueForKey:@"groupInfo"] dictionaryValueForKey:@"group"];
                BOOL open = [groupInfo boolValueForKey:@"isOpenScreenshotsNotice"];
                if (success) {
                    success(open);
                }
                
            }
            else{
                if (error) {
                    error();
                }
            }
        } failure:^(NSError *error) {
        }];
    }
//    NSDictionary *params = @{ @"conversationType" : @(type), @"targetId" : targetId };
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"misc/get_screen_capture"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         NSDictionary *dic = result.content;
//                                         BOOL open = [dic[@"status"] boolValue];
//                                         if (success) {
//                                             success(open);
//                                         }
//                                     } else {
//                                         if (error) {
//                                             error();
//                                         }
//                                     }
//                                 }];
}

+ (void)sendScreenCaptureNotification:(RCConversationType)conversationType
                             targetId:(NSString *)targetId
                             complete:(void (^)(BOOL))complete {
    if (!targetId) {
        SealTalkLog(@"targetId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    if (complete) {
        complete(YES);
    }
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"misc/send_sc_msg"
//                               parameters:@{
//                                   @"conversationType" : @(conversationType),
//                                   @"targetId" : targetId
//                               }
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

+ (void)setGroupMessageClearStatus:(RCDGroupMessageClearStatus)status
                           groupId:(NSString *)groupId
                          complete:(void (^)(BOOL))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"clearStatus" : @(status) };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/set_regular_clear"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)getGroupMessageClearStatus:(NSString *)groupId complete:(void (^)(RCDGroupMessageClearStatus))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/get_regular_clear"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if ([result.content isKindOfClass:NSNumber.class]) {
                                             if (complete) {
                                                 complete([result.content integerValue]);
                                             }
                                         } else {
                                             if (complete) {
                                                 complete([result.content[@"clearStatus"] integerValue]);
                                             }
                                         }
                                     } else {
                                         if (complete) {
                                             complete(RCDGroupMessageClearStatusUnknown);
                                         }
                                     }
                                 }];
}
@end
