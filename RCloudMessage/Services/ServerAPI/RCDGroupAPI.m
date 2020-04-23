//
//  RCDGroupAPI.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/12.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupAPI.h"
#import "RCDHTTPUtility.h"
#import "RCDUtilities.h"
#import "RCDGroupAnnouncement.h"

@implementation RCDGroupAPI
#pragma mark - Group
+ (void)createGroup:(NSString *)groupName
        portraitUri:(NSString *)portraitUri
          memberIds:(NSArray *)memberIds
           complete:(void (^)(NSString *groupId, RCDGroupAddMemberStatus status))complete {
    if (!groupName || !memberIds) {
        SealTalkLog(@"groupName or memberIds is nil");
        if (complete) {
            complete(nil, 0);
        }
        return;
    }
    NSMutableArray *muArray = [NSMutableArray arrayWithArray:memberIds];
    for (NSString *selfID in memberIds) {
        if ([selfID isEqualToString:[ProfileUtil getUserAccountID]]) {
            [muArray removeObject:selfID];
        }
    }
    
    
    NSDictionary *params = @{ @"userAccountId": [ProfileUtil getUserAccountID],@"groupName" : groupName, @"members" : muArray };
    if (portraitUri.length > 0) {
        params = @{ @"userAccountId": [ProfileUtil getUserAccountID], @"groupName" : groupName, @"members" : muArray, @"groupCover" : portraitUri };
    }
    
    [SYNetworkingManager postWithURLString:CreateGroup parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSString *groupID = [[data dictionaryValueForKey:@"group"] stringValueForKey:@"id"];
            if (complete) {
                complete(groupID,RCDGroupAddMemberStatusInviteeApproving);
//                complete(result.content[@"id"],
//                         [self getGroupAddMemberStatus:result.content[@"userStatus"]]);
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"新建群组失败");
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/create"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         if (complete) {
//                                             complete(result.content[@"id"],
//                                                      [self getGroupAddMemberStatus:result.content[@"userStatus"]]);
//                                         }
//                                     } else {
//                                         if (complete) {
//                                             complete(nil, 0);
//                                         }
//                                     }
//                                 }];
}

+ (void)copyGroup:(NSString *)groupId
        groupName:(NSString *)groupName
      portraitUri:(NSString *)portraitUri
         complete:(void (^)(NSString *, RCDGroupAddMemberStatus))complete
            error:(void (^)(RCDGroupErrorCode))errorb {
    if (!groupName || !groupId) {
        SealTalkLog(@"groupName or groupId is nil");
        if (errorb) {
            complete(nil, 0);
        }
        return;
    }
    NSDictionary *params = @{ @"optUserAccountId" : [ProfileUtil getUserAccountID], @"groupId" : groupId,@"groupCover": portraitUri,@"groupName": groupName };
    if (portraitUri.length > 0) {
//        params = @{ @"name" : groupName, @"groupId" : groupId, @"portraitUri" : portraitUri };
    }
    
    //可能需要groupID
    [SYNetworkingManager requestPUTWithURLStr:CopyGroup paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete([[data dictionaryValueForKey:@"newGroup"] stringValueForKey:@"id"],
                         RCDGroupAddMemberStatusInviteeApproving);
            }
        }
    } failure:^(NSError *error) {
        if (errorb) {
            errorb(error.code);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/copy_group"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         if (complete) {
//                                             complete(result.content[@"id"],
//                                                      [self getGroupAddMemberStatus:result.content[@"userStatus"]]);
//                                         }
//                                     } else {
//                                         if (error) {
//                                             error(result.errorCode);
//                                         }
//                                     }
//                                 }];
}

+ (void)setGroupPortrait:(NSString *)portraitUri groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId || !portraitUri) {
        SealTalkLog(@"groupId or portraitUri is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    
    NSDictionary *params = @{ @"groupId" : groupId, @"groupCover" : portraitUri ,@"optUserAccountId":[ProfileUtil getUserAccountID]};
    
    [SYNetworkingManager requestPUTWithURLStr:ChangeGroupInfo paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
    
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/set_portrait_uri"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

//修改群组名称
+ (void)resetGroupName:(NSString *)groupName groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId || !groupName) {
        SealTalkLog(@"groupId or groupName is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    
    NSDictionary *params = @{ @"groupId" : groupId, @"groupName" : groupName ,@"optUserAccountId":[ProfileUtil getUserAccountID]};
    
    [SYNetworkingManager requestPUTWithURLStr:ChangeGroupInfo paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
    
    
//    NSDictionary *params = @{ @"groupId" : groupId, @"name" : groupName };
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/rename"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

//获取群信息
+ (void)getGroupInfo:(NSString *)groupId complete:(void (^)(RCDGroupInfo *groupInfo))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(nil);
        }
        return;
    }
    NSDictionary *params = @{@"groupId":groupId};
        [SYNetworkingManager getWithURLString:GetGroupInfo parameters:params success:^(NSDictionary *data) {
            if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                NSDictionary *groupInfo = [[data dictionaryValueForKey:@"groupInfo"] dictionaryValueForKey:@"group"];
                NSArray *users = [[data dictionaryValueForKey:@"groupInfo"] arrayValueForKey:@"users"];
                
                RCDGroupInfo *group = [[RCDGroupInfo alloc] init];
                group.groupId = [groupInfo stringValueForKey:@"id"];
                group.groupName = [groupInfo stringValueForKey:@"groupName"];
                group.portraitUri = [groupInfo stringValueForKey:@"groupCover"];
                group.creatorId = [ProfileUtil getUserAccountID];
                group.introduce = [groupInfo stringValueForKey:@"groupComments"];
                if (!group.introduce) {
                    group.introduce = @"";
                }
                group.number = [NSString stringWithFormat:@"%lu",(unsigned long)users.count];
//                group.maxNumber = [json objectForKey:@"max_number"];
                
                if ([[groupInfo stringValueForKey:@"status"] isEqualToString:@"-1"]) {
                    group.isDismiss = YES;
                } else {
                    group.isDismiss = NO;
                }
                group.mute = [groupInfo boolValueForKey:@"isBanTalk"];
                group.needCertification = [groupInfo boolValueForKey:@"isGroupAuthentication"];
                group.memberProtection = [groupInfo boolValueForKey:@"isGroupMemberProtect"];
                group.isOpenScreenshotsNotice = [groupInfo boolValueForKey:@"isOpenScreenshotsNotice"];
                
                if ([group.groupId isEqualToString:groupId] && complete) {
                    complete(group);
                }
            }
            else{
                if (complete) {
                    complete(nil);
                }
            }
        } failure:^(NSError *error) {
            if (complete) {
                complete(nil);
            }
        }];
    
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
//                                URLString:[NSString stringWithFormat:@"group/%@", groupId]
//                               parameters:nil
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         NSDictionary *content = result.content;
//                                         RCDGroupInfo *group = [[RCDGroupInfo alloc] initWithJson:content];
//                                         if ([group.groupId isEqualToString:groupId] && complete) {
//                                             complete(group);
//                                         } else if (complete) {
//                                             complete(nil);
//                                         }
//                                     } else {
//                                         if (complete) {
//                                             complete(nil);
//                                         }
//                                     }
//                                 }];
}

//退出群组
+ (void)quitGroup:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    
    NSDictionary *params = @{ @"groupId" : groupId ,@"optUserAccountId":[ProfileUtil getUserAccountID]};
    
    [SYNetworkingManager deleteWithURLString:ExitGroup parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/quit"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

//解散群组
+ (void)dismissGroup:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    
    NSDictionary *params = @{ @"groupId" : groupId ,@"userAccountId":[ProfileUtil getUserAccountID]};
    
    [SYNetworkingManager deleteWithURLString:DelGroup parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/dismiss"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

//发布群公告
+ (void)publishGroupAnnouncement:(NSString *)content
                         groupId:(NSString *)groupId
                        complete:(void (^)(BOOL success))complete {
    if (!groupId || !content) {
        SealTalkLog(@"groupId or content is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    
    NSDictionary *params = @{ @"groupId" : groupId, @"groupNotice" : content ,@"optUserAccountId":[ProfileUtil getUserAccountID]};
    
    [SYNetworkingManager requestPUTWithURLStr:ChangeGroupInfo paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
    
    
//    NSDictionary *params = @{ @"groupId" : groupId, @"bulletin" : content };
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/set_bulletin"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

+ (void)getGroupAnnouncement:(NSString *)groupId complete:(void (^)(RCDGroupAnnouncement *announcement))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(nil);
        }
        return;
    }
    
    NSDictionary *params = @{@"groupId":groupId};
    [SYNetworkingManager getWithURLString:GetGroupInfo parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSDictionary *groupInfo = [[data dictionaryValueForKey:@"groupInfo"] dictionaryValueForKey:@"group"];
            NSString *announeMent = [groupInfo stringValueForKey:@"groupComments"];
            RCDGroupAnnouncement *announe = [[RCDGroupAnnouncement alloc] init];
            announe.content = announeMent;
            if (complete) {
                complete(announe);
            }
        }
        else{
            if (complete) {
                complete(nil);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(nil);
        }
    }];

//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
//                                URLString:@"group/get_bulletin"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         NSDictionary *json = result.content;
//                                         RCDGroupAnnouncement *announe =
//                                             [[RCDGroupAnnouncement alloc] initWithJson:json];
//                                         if (complete) {
//                                             complete(announe);
//                                         }
//                                     } else {
//                                         if (complete) {
//                                             complete(nil);
//                                         }
//                                     }
//                                 }];
}

+ (void)setGroupAllMute:(BOOL)mute groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"banTalkStatus" : @(mute ? 1 : -1) };
    [SYNetworkingManager requestPUTWithURLStr:GroupMute paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/mute_all"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

+ (void)setGroupCertification:(BOOL)open groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    
    NSDictionary *params = @{ @"groupId" : groupId, @"isGroupAuthentication" : @(open ? 0 : 1),@"optUserAccountId":[ProfileUtil getUserAccountID] };
    
    [SYNetworkingManager requestPUTWithURLStr:ChangeGroupInfo paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
    
//    NSDictionary *params = @{ @"groupId" : groupId, @"certiStatus" : @(open ? 0 : 1) };
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/set_certification"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

+ (void)getGroupNoticeList:(void (^)(NSArray<RCDGroupNotice *> *))complete {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"group/notice_info"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSArray *array = result.content;
                                         NSMutableArray *list = [NSMutableArray array];
                                         for (NSDictionary *dic in array) {
                                             RCDGroupNotice *notice = [[RCDGroupNotice alloc] initWithJson:dic];
                                             [list addObject:notice];
                                         }
                                         if (complete) {
                                             complete(list.copy);
                                         }
                                     } else {
                                         if (complete) {
                                             complete(nil);
                                         }
                                     }
                                 }];
}

+ (void)clearGroupNoticeList:(void (^)(BOOL))complete {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/clear_notice"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)setGroupApproveAction:(RCDGroupInviteActionType)type
                     targetId:(NSString *)targetId
                      groupId:(NSString *)groupId
                     complete:(void (^)(BOOL))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"status" : @(type), @"receiverId" : targetId };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/agree"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (complete) {
                                         complete(result.success);
                                     }
                                 }];
}

+ (void)setGroupMemberProtection:(BOOL)open groupId:(NSString *)groupId complete:(void (^)(BOOL))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    
    NSDictionary *params = @{ @"groupId" : groupId,@"optUserAccountId":[ProfileUtil getUserAccountID], @"isOpenScreenshotsNotice" : @(open ? 0 : 1) };
    
    [SYNetworkingManager requestPUTWithURLStr:ChangeGroupInfo paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
    
    
//    NSDictionary *params = @{ @"groupId" : groupId, @"memberProtection" : @(open ? 1 : 0) };
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/set_member_protection"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

+ (void)getGroupLeftMemberList:(NSString *)groupId complete:(void (^)(NSArray<RCDGroupLeftMember *> *))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(nil);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId };
    
    [SYNetworkingManager postWithURLString:GetLeaveGroupList parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSArray *members = [data arrayValueForKey:@"leaveMembers"];
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (NSDictionary *memberInfo in members) {
                RCDGroupLeftMember *member = [[RCDGroupLeftMember alloc] init];
//                member.operatorId =
                member.userId = [memberInfo stringValueForKey:@"userAccountId"];
//                self.reason = [json[@"quitReason"] intValue];
                member.time = [[memberInfo stringValueForKey:@"leaveGroupDate"] longLongValue];
                [array addObject:member];
            }
            if (complete) {
                complete(array.copy);
            }
        } else {
            if (complete) {
                complete(nil);
            }
        }
        
    } failure:^(NSError *error) {
        if (complete) {
            complete(nil);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/exited_list"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         NSArray *list = result.content;
//                                         NSMutableArray *array = [[NSMutableArray alloc] init];
//                                         for (NSDictionary *dic in list) {
//                                             RCDGroupLeftMember *member = [[RCDGroupLeftMember alloc] initWithJson:dic];
//                                             [array addObject:member];
//                                         }
//                                         if (complete) {
//                                             complete(array.copy);
//                                         }
//                                     } else {
//                                         if (complete) {
//                                             complete(nil);
//                                         }
//                                     }
//                                 }];
}

#pragma mark - Group member
//+ (void)getGroupManagers:(NSString *)groupId
//complete:(void (^)(NSArray<RCDGroupMember *> *memberList))complete
//                   error:(void (^)(RCDGroupErrorCode errorCode))errorBlock{
//    if (!groupId) {
//        SealTalkLog(@"groupId is nil");
//        if (errorBlock) {
//            errorBlock(RCDGroupErrorCodeUnknown);
//        }
//        return;
//    }
//
//    NSDictionary *params = @{@"groupId":groupId};
//    [SYNetworkingManager postWithURLString:GetGroupManagers parameters:params success:^(NSDictionary *data) {
//        <#code#>
//    } failure:^(NSError *error) {
//        <#code#>
//    }];
//}

//获取群组成员列表
+ (void)getGroupMembers:(NSString *)groupId
               complete:(void (^)(NSArray<RCDGroupMember *> *_Nonnull))complete
                  error:(void (^)(RCDGroupErrorCode))errorBlock {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (errorBlock) {
            errorBlock(RCDGroupErrorCodeUnknown);
        }
        return;
    }
    
    NSDictionary *params = @{@"groupId":groupId};
    [SYNetworkingManager getWithURLString:GetGroupInfo parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSDictionary *groupInfo = [data dictionaryValueForKey:@"groupInfo"];
            NSMutableArray *array = [[NSMutableArray alloc] init];
            NSArray *users = [groupInfo arrayValueForKey:@"users"];
            NSDictionary *groupDetailInfo = [groupInfo dictionaryValueForKey:@"group"];
            for (NSDictionary *dic in users) {
                
                RCDGroupMember *member = [[RCDGroupMember alloc] initWithJson:dic];
                NSDictionary *userinfo = [dic dictionaryValueForKey:@"userInfo"];
                member.userId = [userinfo stringValueForKey:@"userAccountId"];
                member.name = [userinfo stringValueForKey:@"nickName"];
                member.portraitUri = [userinfo stringValueForKey:@"avaterUrl"];
                member.groupMemberID = [dic stringValueForKey:@"groupMemberId"];
//                member.gender = [userinfo stringValueForKey:@"gender"];
                if ([[userinfo stringValueForKey:@"gender"] isEqualToString:@"1"]) {
                    member.gender = @"female";
                }
                if ([[userinfo stringValueForKey:@"gender"] isEqualToString:@"2"]) {
                    member.gender = @"male";
                }
                if ([dic stringValueForKey:@"groupMemberNickName"].length > 0) {
                    member.groupNickname = [dic stringValueForKey:@"groupMemberNickName"];
                }
                else{
                    member.groupNickname = [userinfo stringValueForKey:@"nickName"];//[groupDetailInfo stringValueForKey:@"groupName"];
                }
                if ([dic boolValueForKey:@"isGroupMaster"]) {
                    member.role = RCDGroupMemberRoleOwner;
                }
                else if ([dic boolValueForKey:@"isGroupManager"]) {
                    member.role = RCDGroupMemberRoleManager;
                }
                else {
                    member.role = RCDGroupMemberRoleMember;
                }
//                self.createDt = [json[@"timestamp"] longLongValue];
//                self.updateDt = [json[@"updatedTime"] longLongValue];
                member.groupId = groupId;
                [array addObject:member];
            }
            if (complete) {
                complete(array.copy);
            }
        }
        else{
            if (errorBlock) {
                //这里强行写一个
                errorBlock(RCDGroupErrorCodeNotInGroup);
            }
        }
    } failure:^(NSError *error) {
        if (errorBlock) {
            errorBlock(RCDGroupErrorCodeNotInGroup);
        }
    }];
    
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
//                                URLString:[NSString stringWithFormat:@"group/%@/members", groupId]
//                               parameters:nil
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         NSArray *list = result.content;
//                                         NSMutableArray *array = [[NSMutableArray alloc] init];
//                                         for (NSDictionary *dic in list) {
//                                             RCDGroupMember *member = [[RCDGroupMember alloc] initWithJson:dic];
//                                             member.groupId = groupId;
//                                             [array addObject:member];
//                                         }
//                                         if (complete) {
//                                             complete(array.copy);
//                                         }
//                                     } else {
//                                         if (errorBlock) {
//                                             errorBlock(result.httpCode);
//                                         }
//                                     }
//                                 }];
}

//获取我的群组
+ (void)getMyGroupList:(void (^)(NSArray<RCDGroupInfo *> *groupList))complete {
    if ([ProfileUtil getUserAccountID] == nil) {
        return;
    }
    NSDictionary *params = @{@"userAccountId":[ProfileUtil getUserAccountID]};
    [SYNetworkingManager getWithURLString:GetAllGroups parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSMutableArray *groupList = [NSMutableArray new];
            NSArray *list = [data arrayValueForKey:@"groups"];
            for (NSDictionary *dic in list) {
                RCDGroupInfo *group = [[RCDGroupInfo alloc] init];
                group.groupId = [dic stringValueForKey:@"groupId"];
                group.groupName = [dic stringValueForKey:@"groupName"];
                group.portraitUri = [dic stringValueForKey:@"groupCover"];
                group.number = [dic stringValueForKey:@"count"];
                [groupList addObject:group];
            }
            if (complete) {
                complete(groupList.copy);
            }
        }
        
    } failure:^(NSError *error) {
        if (complete) {
            complete(nil);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
//                                URLString:@"user/favgroups"
//                               parameters:nil
//                                 response:^(RCDHTTPResult *result) {
//                                     if (result.success) {
//                                         NSMutableArray *groupList = [NSMutableArray new];
//                                         NSArray *list = result.content[@"list"];
//                                         for (NSDictionary *dic in list) {
//                                             RCDGroupInfo *group = [[RCDGroupInfo alloc] initWithJson:dic];
//                                             [groupList addObject:group];
//                                         }
//                                         if (complete) {
//                                             complete(groupList.copy);
//                                         }
//                                     } else {
//                                         if (complete) {
//                                             complete(nil);
//                                         }
//                                     }
//
//                                 }];
}

//加入群组
+ (void)joinGroup:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    
    NSDictionary *params = @{ @"groupId" : groupId,@"optUserAccountId":[ProfileUtil getUserAccountID], @"members" : @[[ProfileUtil getUserAccountID]] };
    
    [SYNetworkingManager requestPUTWithURLStr:AddGroupMember paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
        
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
    
//    NSDictionary *params = @{ @"groupId" : groupId };
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/join"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

//添加群组成员
+ (void)addUsers:(NSArray *)userIds
         groupId:(NSString *)groupId
        complete:(void (^)(BOOL success, RCDGroupAddMemberStatus status))complete {
    if (!groupId || !userIds) {
        SealTalkLog(@"groupId or userIds is nil");
        if (complete) {
            complete(NO, 0);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId,@"optUserAccountId":[ProfileUtil getUserAccountID], @"members" : userIds };
    
    [SYNetworkingManager requestPUTWithURLStr:AddGroupMember paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES, RCDGroupAddMemberStatusInviteeApproving);
            }
        }
        else{
            if (complete) {
                complete(NO, RCDGroupAddMemberStatusInviteeApproving);
            }
        }
        
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO, RCDGroupAddMemberStatusInviteeApproving);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/add"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success, [self getGroupAddMemberStatus:result.content]);
//                                     }
//                                 }];
}

//将用户踢出群组
+ (void)kickUsers:(NSArray *)userIds groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId || !userIds) {
        SealTalkLog(@"groupId or userIds is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId,@"optUserAccountId":[ProfileUtil getUserAccountID], @"members" : userIds };
    
    [SYNetworkingManager deleteWithURLString:RemoveGroupMember parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/kick"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

//群主转让
+ (void)transferGroupOwner:(NSString *)targetId groupId:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId || !targetId) {
        SealTalkLog(@"groupId or targetId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"userAccountId" : targetId ,@"optUserAccountId":[ProfileUtil getUserAccountID]};
    
    [SYNetworkingManager requestPUTWithURLStr:UpdateGroupMaster paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/transfer"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

+ (void)addGroupManagers:(NSArray<NSString *> *)userIds
                 groupId:(NSString *)groupId
                complete:(void (^)(BOOL success))complete {
    if (!groupId || !userIds) {
        SealTalkLog(@"groupId or userIds is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"userAccountIds" : userIds ,@"optUserAccountId":[ProfileUtil getUserAccountID]};
    
    [SYNetworkingManager requestPUTWithURLStr:AddGroupManager paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
    
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/set_manager"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

+ (void)removeGroupManagers:(NSArray<NSString *> *)userIds
                    groupId:(NSString *)groupId
                   complete:(void (^)(BOOL success))complete {
    if (!groupId || !userIds) {
        SealTalkLog(@"groupId or userIds is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"userAccountId" : userIds[0] ,@"optUserAccountId":[ProfileUtil getUserAccountID]};
    
    [SYNetworkingManager deleteWithURLString:RemoveGroupManager parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/remove_manager"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

+ (void)setGroupMemberDetailInfo:(RCDGroupMemberDetailInfo *)memberInfo
                         groupId:(NSString *)groupId
                        complete:(void (^)(BOOL))complete {
    if (!groupId || !memberInfo.userId) {
        SealTalkLog(@"groupId or userId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSMutableDictionary *params = [memberInfo decode].mutableCopy;
    [params setObject:groupId forKey:@"groupId"];
    
    [SYNetworkingManager requestPUTWithURLStr:ChangeMyInfoInGroup paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/set_member_info"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

+ (void)getGroupMemberDetailInfo:(NSString *)userId
                         groupId:(NSString *)groupId
                        complete:(void (^)(RCDGroupMemberDetailInfo *))complete {
    if (!groupId || !userId) {
        SealTalkLog(@"groupId or userId is nil");
        if (complete) {
            complete(nil);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId, @"memberId" : userId };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"group/get_member_info"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         RCDGroupMemberDetailInfo *member =
                                             [[RCDGroupMemberDetailInfo alloc] initWithJson:result.content];
                                         member.userId = userId;
                                         if (complete) {
                                             complete(member);
                                         }
                                     } else {
                                         if (complete) {
                                             complete(nil);
                                         }
                                     }
                                 }];
}
#pragma mark - My Group
// 添加到我的群组
+ (void)addToMyGroups:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    NSDictionary *params = @{ @"groupId" : groupId,@"memberId":[ProfileUtil getUserAccountID],@"isSaveContact":@"1" };
    
    [SYNetworkingManager requestPUTWithURLStr:ChangeGroupSetting paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
    
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
//                                URLString:@"group/fav"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

+ (void)removeFromMyGroups:(NSString *)groupId complete:(void (^)(BOOL success))complete {
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    
    NSDictionary *params = @{ @"groupId" : groupId,@"memberId":[ProfileUtil getUserAccountID],@"isSaveContact":@"0" };
    
    [SYNetworkingManager requestPUTWithURLStr:ChangeGroupSetting paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
    
//    NSDictionary *params = @{ @"groupId" : groupId };
//    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodDelete
//                                URLString:@"group/fav"
//                               parameters:params
//                                 response:^(RCDHTTPResult *result) {
//                                     if (complete) {
//                                         complete(result.success);
//                                     }
//                                 }];
}

#pragma mark - helper
+ (RCDGroupAddMemberStatus)getGroupAddMemberStatus:(NSArray *)array {
    RCDGroupAddMemberStatus addMemberStatus = 0;
    if (array.count > 0) {
        NSMutableArray *joinedArr = [NSMutableArray array];
        NSMutableArray *inviteeApprovingArr = [NSMutableArray array];
        NSMutableArray *managerApprovingArr = [NSMutableArray array];
        for (NSDictionary *dic in array) {
            NSString *userId = dic[@"id"];
            // 1 为已加入, 2 为等待管理员同意, 3 为等待被邀请者同意
            int status = [dic[@"status"] intValue];
            if (status == 1) {
                [joinedArr addObject:userId];
            } else if (status == 2) {
                [managerApprovingArr addObject:userId];
            } else if (status == 3) {
                [inviteeApprovingArr addObject:userId];
            }
        }
        if (inviteeApprovingArr.count > 0) {
            addMemberStatus = RCDGroupAddMemberStatusInviteeApproving;
        } else if (managerApprovingArr.count > 0) {
            addMemberStatus = RCDGroupAddMemberStatusOnlyManagerApproving;
        } else {
            addMemberStatus = RCDGroupAddMembersStatusAllJoined;
        }
    }
    return addMemberStatus;
}

+ (void)addAllFriendsToFriends:(NSString *)groupId complete:(void (^)(BOOL))complete{
    if (!groupId) {
        SealTalkLog(@"groupId is nil");
        if (complete) {
            complete(NO);
        }
        return;
    }
    
    NSDictionary *params = @{@"groupId":groupId,@"userAccountId":[ProfileUtil getUserAccountID]};
    [SYNetworkingManager postWithURLString:AddFriendsRequest parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (complete) {
                complete(YES);
            }
        }
        else{
            if (complete) {
                complete(NO);
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
}
@end
