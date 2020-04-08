//
//  MeMoreInfoTableViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "MeMoreInfoTableViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDBaseSettingTableViewCell.h"
#import "RCDCommonDefine.h"
#import "RCDEditUserNameViewController.h"
#import "RCDUIBarButtonItem.h"
#import "RCDUtilities.h"
#import "UIColor+RCColor.h"
#import "UIImage+RCImage.h"
#import "RCDCommonString.h"
#import "RCDUserInfoManager.h"
#import "RCDUploadManager.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDSettingGenderViewController.h"
#import "RCDSetSealTalkNumViewController.h"
#import "QiniuQuery.h"
#import "LocationTableViewController.h"
#import "EditSignViewController.h"

@interface MeMoreInfoTableViewController ()

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation MeMoreInfoTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDBaseSettingTableViewCell";
    RCDBaseSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }

    switch (indexPath.row) {
    case 0: {
        NSString *gender = [DEFAULTS stringForKey:RCDUserGenderKey];
        [cell setCellStyle:DefaultStyle_RightLabel];
        cell.leftLabel.text = RCDLocalizedString(@"Gender");
        if ([gender isEqualToString:@"female"] || [gender isEqualToString:@"male"]) {
            cell.rightLabel.text = RCDLocalizedString(gender);
        } else {
            cell.rightLabel.text = @"未设置";//RCDLocalizedString(@"male");
        }
    } break;
    case 1: {
        NSString *sealTalkNumber = [DEFAULTS stringForKey:LocationInfo];;
        cell.leftLabel.text = @"地区";
        if (sealTalkNumber.length > 0) {
            [cell setCellStyle:DefaultStyle_RightLabel_WithoutRightArrow];
            cell.rightLabel.text = sealTalkNumber;
        } else {
            [cell setCellStyle:DefaultStyle_RightLabel];
            cell.rightLabel.text = RCDLocalizedString(@"NotSetting");
        }
    } break;
    case 2: {
        [cell setCellStyle:DefaultStyle_RightLabel_WithoutRightArrow];
        cell.leftLabel.text = @"个性签名";//RCDLocalizedString(@"mobile_number");
        cell.rightLabel.text = [DEFAULTS stringForKey:UserSingleSign];
    } break;
    default:
        break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.f;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 13.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        RCDSettingGenderViewController *settingGenderVC = [[RCDSettingGenderViewController alloc] init];
        [self.navigationController pushViewController:settingGenderVC animated:YES];
    } else if (indexPath.row == 1) {
        LocationTableViewController *nextVC = [[LocationTableViewController alloc] init];
        nextVC.type = provence;
        nextVC.locationID = @"1";
        [self.navigationController pushViewController:nextVC animated:YES];
    } else if (indexPath.row == 2) {
        EditSignViewController *nextVC = [[EditSignViewController alloc] init];
        [self.navigationController pushViewController:nextVC animated:YES];
//        // 设置 SealTalk 号
//        if ([DEFAULTS stringForKey:RCDSealTalkNumberKey].length <= 0) {
//            RCDSetSealTalkNumViewController *setSealTalkNumVC = [[RCDSetSealTalkNumViewController alloc] init];
//            [self.navigationController pushViewController:setSealTalkNumVC animated:YES];
//        }
    }
}


- (void)showAlertView:(NSString *)message cancelBtnTitle:(NSString *)cTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:cTitle style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)dealWithNetworkStatus {
    BOOL isconnected = NO;
    RCNetworkStatus networkStatus = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];
    if (networkStatus == 0) {
        [self showAlertView:NSLocalizedStringFromTable(@"ConnectionIsNotReachable", @"RongCloudKit", nil)
             cancelBtnTitle:RCDLocalizedString(@"confirm")];
        return isconnected;
    }
    return isconnected = YES;
}

- (void)initUI {
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.title = @"更多信息";

    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:@""//RCDLocalizedString(@"me")
                                                                             target:self
                                                                             action:@selector(clickBackBtn:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
        _hud.labelText = RCDLocalizedString(@"Uploading_avatar");
    }
    return _hud;
}

@end
