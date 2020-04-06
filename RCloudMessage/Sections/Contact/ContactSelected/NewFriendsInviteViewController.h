//
//  NewFriendsInviteViewController.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/28.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDViewController.h"
#import "RCDContactSelectedTableViewController.h"

#import <RongIMLib/RongIMLib.h>

//typedef NS_ENUM(NSUInteger, RCDContactSelectedGroupOptionType) {
//    RCDContactSelectedGroupOptionTypeCreate = 0,
//    RCDContactSelectedGroupOptionTypeAdd,
//    RCDContactSelectedGroupOptionTypeDelete,
//};
@class RCDFriendInfo;

@interface NewFriendsInviteViewController : RCDViewController

@property (nonatomic, strong) NSString *groupId;

@property (nonatomic, strong) NSMutableArray *orignalGroupMembers;

@property (nonatomic, assign) RCDContactSelectedGroupOptionType groupOptionType;

- (instancetype)initWithTitle:(NSString *)title isAllowsMultipleSelection:(BOOL)isAllowsMultipleSelection;


@end

