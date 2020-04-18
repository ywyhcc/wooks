//
//  AddContactMembersViewController.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/17.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDViewController.h"
#import <RongIMLib/RongIMLib.h>

typedef NS_ENUM(NSUInteger, RCDContactSelectedGroupOptionType) {
    RCDContactSelectedGroupOptionTypeCreate = 0,
    RCDContactSelectedGroupOptionTypeAdd,
    RCDContactSelectedGroupOptionTypeDelete,
};

@class RCDFriendInfo;

@interface AddContactMembersViewController : RCDViewController

@property (nonatomic, copy) void (^rightCallBack)(NSArray *members); 

@property (nonatomic, strong) NSString *groupId;

@property (nonatomic, strong) NSMutableArray *orignalGroupMembers;

@property (nonatomic, strong) NSArray *selectArr;

@property (nonatomic, assign) RCDContactSelectedGroupOptionType groupOptionType;

- (instancetype)initWithTitle:(NSString *)title isAllowsMultipleSelection:(BOOL)isAllowsMultipleSelection;

@end

