//
//  AddContactFriendsTableViewCell.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "AddContactFriendsTableViewCell.h"
#import <Masonry/Masonry.h>
#import "RCDUserInfoManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDUtilities.h"
#import "ContactAddUserModel.h"
#import "UIView+MBProgressHUD.h"

@interface AddContactFriendsTableViewCell()

@property (nonatomic, strong)UILabel *rightLabel;

@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, strong) UILabel *wtLabel;

@property (nonatomic, strong) ContactAddUserModel *selectModel;

@end

@implementation AddContactFriendsTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    AddContactFriendsTableViewCell *cell =
        (AddContactFriendsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:AddContactFriendsTableViewCellID];
    if (!cell) {
        cell = [[AddContactFriendsTableViewCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)setModel:(ContactAddUserModel*)model{
    self.selectModel = model;
    self.nameLabel.text = model.nickName;
    self.wtLabel.text = model.woostalkId;
    [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:model.avaterUrl]];
    if (model.status.length > 0) {
        self.rightBtn.hidden = YES;
        self.rightLabel.hidden = NO;
        if ([model.status isEqualToString:@"0"]) {
            self.rightLabel.text = @"已发送";
        }
        else if ([model.status isEqualToString:@"1"]) {
            self.rightLabel.text = @"已通过";
        }
        else if ([model.status isEqualToString:@"-1"]) {
            self.rightLabel.text = @"被拒绝";
        }
        else if ([model.status isEqualToString:@"2"]) {
            self.rightLabel.text = @"审核中";
        }
        else if ([model.status isEqualToString:@"3"]) {
            self.rightLabel.text = @"已添加";
        }
        else if ([model.status isEqualToString:@"-2"]) {
            self.rightLabel.text = @"已拒绝";
        }
        else if ([model.status isEqualToString:@"-3"]) {
            self.rightBtn.hidden = NO;
            self.rightLabel.hidden = YES;
        }
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubviews];
    }
    return self;
}


- (void)addSubviews {
    [self.contentView addSubview:self.portraitImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.rightLabel];
    [self.contentView addSubview:self.rightBtn];
    [self.contentView addSubview:self.wtLabel];
    [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(12);
        make.height.width.offset(40);
    }];
    
    [self.wtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-10);
        make.left.equalTo(self.portraitImageView.mas_right).offset(9);
        make.height.offset(15);
        make.width.offset(150);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.portraitImageView.mas_right).offset(9);
        make.width.offset(150);
        make.height.offset(15);
    }];
    
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right);
        make.centerY.equalTo(self.contentView);
        make.width.offset(100);
        make.height.offset(23);
    }];
    
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right);
        make.centerY.equalTo(self.contentView);
        make.width.offset(70);
        make.height.offset(35);
    }];
}

#pragma mark - getter
- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        _portraitImageView.layer.cornerRadius = 2.f;
        _portraitImageView.layer.masksToBounds = YES;
        _portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _portraitImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
    }
    return _nameLabel;
}

- (UILabel *)wtLabel {
    if (!_wtLabel) {
        _wtLabel = [[UILabel alloc] init];
        _wtLabel.font = [UIFont systemFontOfSize:14];
        _wtLabel.textColor = [FPStyleGuide lightGrayTextColor];
    }
    return _wtLabel;
}

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.font = [UIFont systemFontOfSize:16];
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.textColor = RCDDYCOLOR(0x939393, 0x666666);
    }
    return _rightLabel;
}

- (void)addFriends{
    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"toUserAccountId":self.selectModel.userAccountId};
    [SYNetworkingManager postWithURLString:AddFriend parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            
            if (self.callbackBlock) {
                self.callbackBlock();
            }
        }
        else{
            [self showHUDMessage:[data stringValueForKey:@"message"]];
        }
        
        
    } failure:^(NSError *error) {
    }];
}

- (UIButton *)rightBtn{
    if (!_rightBtn) {
        
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.font = [UIFont systemFontOfSize:16];
        _rightBtn.layer.cornerRadius = 3;
        _rightBtn.layer.masksToBounds = YES;
        _rightBtn.backgroundColor = [FPStyleGuide weichatGreenColor];
        [_rightBtn setTitle:@"添加" forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(addFriends) forControlEvents:UIControlEventTouchUpInside];
        [_rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
    }
    return _rightBtn;
}

@end
