//
//  AddContactFriendsTableViewCell.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDTableViewCell.h"
#import "ContactAddUserModel.h"
@class RCUserInfo;

static NSString *AddContactFriendsTableViewCellID = @"AddContactFriendsTableViewCellID";

@interface AddContactFriendsTableViewCell : RCDTableViewCell

@property (nonatomic, copy) void (^callbackBlock)();
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *portraitImageView;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)setModel:(ContactAddUserModel*)model;

@end


