//
//  RCDContactSelectedTableViewCell.h
//  RCloudMessage
//
//  Created by Jue on 16/3/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"
@class RCDFriendInfo;

@interface RCDContactSelectedTableViewCell : RCDTableViewCell


@property (nonatomic, copy) void (^acceptBlock)(NSString *userId);

@property (nonatomic, copy) void (^ignoreBlock)(NSString *userId);
/**
 *  获取cell的高度
 *
 */
+ (CGFloat)cellHeight;

- (void)setModel:(RCDFriendInfo *)user hideRight:(BOOL)hide;

@property (nonatomic, strong) NSString *groupId;

/**
 *  选中图片
 */
@property (nonatomic, strong) UIImageView *selectedImageView;

/**
 *  头像图片
 */
@property (nonatomic, strong) UIImageView *portraitImageView;

/**
 *  昵称
 */
@property (nonatomic, strong) UILabel *nicknameLabel;

//接受
@property (nonatomic, strong) UILabel *rightLabel;

/**
 *  “接受”按钮
 */
@property (nonatomic, strong) UIButton *acceptBtn;

@property (nonatomic, strong) UIButton *ignoreButton;

@end
