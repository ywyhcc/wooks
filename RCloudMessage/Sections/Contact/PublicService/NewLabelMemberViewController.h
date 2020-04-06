//
//  NewLabelMemberViewController.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDViewController.h"
#import "RCDContactSelectedTableViewController.h"
#import <RongIMLib/RongIMLib.h>

@class RCDFriendInfo;

@interface NewLabelMemberViewController : RCDViewController

@property (nonatomic, strong) NSString *groupId;

@property (nonatomic, strong) NSMutableArray *orignalGroupMembers;

@property (nonatomic, assign) RCDContactSelectedGroupOptionType groupOptionType;

@property (nonatomic, copy) void (^callBack)(NSArray *userIDs);

//进入页面以后选中的userId的集合
@property (nonatomic, strong) NSArray *selectList;

- (instancetype)initWithTitle:(NSString *)title isAllowsMultipleSelection:(BOOL)isAllowsMultipleSelection;



@end
