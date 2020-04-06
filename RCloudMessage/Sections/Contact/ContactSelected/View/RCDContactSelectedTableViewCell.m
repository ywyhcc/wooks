//
//  RCDContactSelectedTableViewCell.m
//  RCloudMessage
//
//  Created by Jue on 16/3/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDContactSelectedTableViewCell.h"
#import "RCDFriendInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <RongIMKit/RongIMKit.h>
#import <Masonry/Masonry.h>
#import "RCDUserInfoManager.h"
#import "RCDUtilities.h"
#import "RCDUserInfoAPI.h"
#define CellHeight 70.0f
@interface RCDContactSelectedTableViewCell()

@property (nonatomic, strong)RCDFriendInfo *currentUserInfo;

@end

@implementation RCDContactSelectedTableViewCell

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSubviews];
    }
    return self;
}

#pragma mark - Private Method
- (void)initSubviews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.selectedImageView];
    [self.contentView addSubview:self.portraitImageView];
    [self.contentView addSubview:self.nicknameLabel];
    [self.contentView addSubview:self.rightLabel];
    [self.contentView addSubview:self.ignoreButton];
    [self.contentView addSubview:self.acceptBtn];

    [self.selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(27);
        make.centerY.equalTo(self.contentView);
        make.height.width.offset(21);
    }];

    [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.selectedImageView.mas_right).offset(8);
        make.centerY.equalTo(self.contentView);
        make.height.width.offset(40);
    }];

    [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.portraitImageView.mas_right).offset(8);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-27);
        make.height.offset(CellHeight - 15 - 17);
    }];
    
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-40);
        make.centerY.equalTo(self.contentView);
        make.width.offset(80);
        make.height.offset(CellHeight - 16.5 - 16);
    }];

    [self.ignoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.acceptBtn.mas_left).offset(-10);
        make.height.offset(CellHeight - 16.5 - 16 - 8);
    }];

    [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-8);
        make.height.offset(CellHeight - 16.5 - 16 - 8);
    }];
}

#pragma mark - Public Method
+ (CGFloat)cellHeight {
    return CellHeight;
}

- (void)setModel:(RCDFriendInfo *)user hideRight:(BOOL)hide{
    self.currentUserInfo = user;
    if (user) {
        if (self.groupId.length > 0) {
            __weak typeof(self) weakSelf = self;
            [RCDUtilities getGroupUserDisplayInfo:user.userId
                                          groupId:self.groupId
                                           result:^(RCUserInfo *user) {
                                               weakSelf.nicknameLabel.text = user.name;
                                               [weakSelf.portraitImageView
                                                   sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                                                     placeholderImage:[UIImage imageNamed:@"contact"]];
                                           }];
        } else {
            
//            [RCDUserInfoAPI getUserInfo:@"" anotherUserID:user.userId complete:^(RCDUserInfo *userInfo) {
                self.nicknameLabel.text = user.name;
                [self.portraitImageView
                 sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                 placeholderImage:[UIImage imageNamed:@"contact"]];
        }
        //好友审核状态(我发送的好友请求:0.已发送1.已通过-1.被拒绝) 别人加我的好友请求(2.正在审核中3.同意-2.拒绝)
        if (user.status == 20) {
            self.rightLabel.text = @"已添加";
            self.rightLabel.hidden = NO;
            self.acceptBtn.hidden = YES;
            self.ignoreButton.hidden = YES;
        }
        else if (user.status == 10){
            self.rightLabel.text = @"等待验证";
            self.rightLabel.hidden = NO;
            self.acceptBtn.hidden = YES;
            self.ignoreButton.hidden = YES;
        }
        else if (user.status == 21){
            self.rightLabel.text = @"已忽略";
            self.rightLabel.hidden = NO;
            self.acceptBtn.hidden = YES;
            self.ignoreButton.hidden = YES;
        }
        else if (user.status == 52){
            self.rightLabel.text = @"已接受";
            self.rightLabel.hidden = NO;
            self.acceptBtn.hidden = YES;
            self.ignoreButton.hidden = YES;
        }
        else if (user.status == 51){
            self.rightLabel.text = @"已拒绝";
            self.rightLabel.hidden = NO;
            self.acceptBtn.hidden = YES;
            self.ignoreButton.hidden = YES;
        }
        else if (user.status == 11){
            self.rightLabel.hidden = YES;
            self.acceptBtn.hidden = NO;
            self.ignoreButton.hidden = NO;
        }
    }
    if (hide) {
        self.rightLabel.hidden = YES;
        self.acceptBtn.hidden = YES;
        self.ignoreButton.hidden = YES;
    }
}

#pragma mark - Override
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        _selectedImageView.image = [UIImage imageNamed:@"select"];
    } else {
        _selectedImageView.image = [UIImage imageNamed:@"unselected_full"];
    }
    // Configure the view for the selected state
}

- (void)doAccept {
    if (self.acceptBlock) {
        self.acceptBlock(self.currentUserInfo.friendID);
    }
}

- (void)doIgnore {
    if (self.ignoreBlock) {
        self.ignoreBlock(self.currentUserInfo.friendID);
    }
}

#pragma mark - Setter && Getter
- (UIImageView *)selectedImageView {
    if (!_selectedImageView) {
        _selectedImageView = [[UIImageView alloc] init];
        _selectedImageView.image = [UIImage imageNamed:@"unselected_full"];
    }
    return _selectedImageView;
}

- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _portraitImageView.layer.cornerRadius = 20.f;
        } else {
            _portraitImageView.layer.cornerRadius = 5.f;
        }
        _portraitImageView.layer.masksToBounds = YES;
        _portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _portraitImageView;
}

- (UILabel *)nicknameLabel {
    if (!_nicknameLabel) {
        _nicknameLabel = [[UILabel alloc] init];
        _nicknameLabel.font = [UIFont fontWithName:@"Heiti SC" size:14.0];
        _nicknameLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    }
    return _nicknameLabel;
}

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.font = [UIFont systemFontOfSize:14];
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    }
    return _rightLabel;
}

- (UIButton *)acceptBtn {
    if (!_acceptBtn) {
        _acceptBtn = [[UIButton alloc] init];
        [_acceptBtn setTitle:RCDLocalizedString(@"Agree") forState:(UIControlStateNormal)];
        [_acceptBtn setTitleColor:HEXCOLOR(0x3098fc) forState:(UIControlStateNormal)];
        [_acceptBtn addTarget:self action:@selector(doAccept) forControlEvents:(UIControlEventTouchUpInside)];
        _acceptBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _acceptBtn;
}

- (UIButton *)ignoreButton {
    if (!_ignoreButton) {
        _ignoreButton = [[UIButton alloc] init];
        [_ignoreButton setTitle:RCDLocalizedString(@"Ignore") forState:(UIControlStateNormal)];
        [_ignoreButton setTitleColor:RCDDYCOLOR(0x333333, 0x9f9f9f) forState:(UIControlStateNormal)];
        [_ignoreButton addTarget:self action:@selector(doIgnore) forControlEvents:(UIControlEventTouchUpInside)];
        _ignoreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _ignoreButton;
}


@end
