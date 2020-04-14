//
//  PhoneMoreTableViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/9.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "PhoneMoreTableViewController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDBlackListViewController.h"
#import "UIColor+RCColor.h"
#import "RCDUserInfoManager.h"
#import "UIView+MBProgressHUD.h"
#import "EditPhoneViewController.h"

#define RCDHidePhoneTag 310
//#define RCDSearchBySTAccountTag 311
//#define RCDAddFriendAuthTag 312
//#define RCDAddGroupAuthTag 313

@interface PhoneMoreTableViewController ()<RCDBaseSettingTableViewCellDelegate>

@property (nonatomic, strong) NSArray *titleData;

@property (nonatomic) BOOL hidePhone;
@property (nonatomic, strong)NSString *displayPhone;

@end

@implementation PhoneMoreTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleData =
        @[
           @"隐藏我的手机号",
           @"备用手机号",

    ];
    self.navigationItem.title = RCDLocalizedString(@"SecurityAndprivacy");
    [self getMyInfo];
}

- (void)getMyInfo{
    __weak PhoneMoreTableViewController *weakSelf = self;
    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID]};
    [SYNetworkingManager postWithURLString:GetInfo parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            weakSelf.hidePhone = [[data dictionaryValueForKey:@"userInfo"] boolValueForKey:@"isHidePhone"];
            weakSelf.displayPhone = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"sparePhoneNumber"];
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
    }];
}

- (void)viewDidLayoutSubviews {
    self.tableView.frame = self.view.frame;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDBaseSettingTableViewCell";
    RCDBaseSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    NSString *title = self.titleData[indexPath.row];
    cell.leftLabel.text = title;
    cell.baseSettingTableViewDelegate = self;
    if ([title isEqualToString:@"隐藏我的手机号"]) {
        [cell setCellStyle:SwitchStyle];
        cell.switchButton.tag = RCDHidePhoneTag;
        if (self.hidePhone) {
            cell.switchButton.on = YES;
        }
        else{
            cell.switchButton.on = NO;
        }
    }
    else {
        [cell setCellStyle:DefaultStyle];
        cell.rightLabel.text = self.displayPhone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.titleData[indexPath.row];
    if ([title isEqualToString:@"备用手机号"]) {
        EditPhoneViewController *vc = [[EditPhoneViewController
                                        alloc] init];
        vc.displayPhone = self.displayPhone;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - RCDBaseSettingTableViewCellDelegate
- (void)onClickSwitchButton:(id)sender {
    UISwitch *swit = (UISwitch *)sender;
    if (swit.tag == RCDHidePhoneTag) {
        [self setSearchMeByMobile:swit];
        
    }
}

- (void)setSearchMeByMobile:(UISwitch *)sender {
    __weak typeof(self) weakSelf = self;
    NSDictionary *params = @{@"isHidePhone":sender.on ? @"1" : @"0",@"userInfoId":[ProfileUtil getUserProfile].userInfoID};
    [SYNetworkingManager requestPUTWithURLStr:UpdateMyInfo paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            weakSelf.hidePhone = sender.on;
            [weakSelf.view showHUDMessage:RCDLocalizedString(@"setting_success")];
        }
        else {
            sender.on = !sender.on;
            [weakSelf.view showHUDMessage:RCDLocalizedString(@"SetFailure")];
        }
    } failure:^(NSError *error) {
        
    }];
}
@end
