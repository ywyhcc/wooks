//
//  RCDMeTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 14/11/28.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDMeTableViewController.h"
#import "RCDAboutRongCloudTableViewController.h"
#import "RCDCommonDefine.h"
#import "RCDCustomerServiceViewController.h"
#import "RCDMeCell.h"
#import "RCDMeDetailsCell.h"
#import "RCDMeInfoTableViewController.h"
#import "RCDSettingsTableViewController.h"
#import "UIColor+RCColor.h"
#import "RCDLanguageManager.h"
#import "RCDLanguageSettingViewController.h"
#import "RCDCommonString.h"
#import "RCDQRCodeController.h"
#import "ActiveInviteCodeViewController.h"
#import "VipRechargeViewController.h"
#import "VipRechargeViewController.h"
#import "MeHeadTableViewCell.h"

//#define SERVICE_ID @"KEFU146001495753714"
#define SERVICE_ID @"service"

@interface RCDMeTableViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *languageDic;
@end

@implementation RCDMeTableViewController
//- (instancetype)initWithStyle:(UITableViewStyle)style {
//    self = [super initWithStyle:UITableViewStyleGrouped];
//    if (self) {
//        [self.navigationController setNavigationBarHidden:NO];
//    }
//    return self;
//}

- (void)loadView{
    [super loadView];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, RCDScreenHeight - 64 - RCDExtraTopHeight - RCDExtraBottomHeight) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.1)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.1)];
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarAppearance];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:NO];
    self.languageDic = @{ @"en" : @"English", @"zh-Hans" : @"简体中文" };
    [self initUI];
}

- (void)setNavigationBarAppearance {
    //统一导航条样式
    UIFont *font = [UIFont systemFontOfSize:19.f];
    NSDictionary *textAttributes =
        @{NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor blackColor]};//RCDDYCOLOR(0xffffff, 0xA8A8A8)
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setBarTintColor:RCDDYCOLOR(0xf0f0f6, 0x000000)];//RCDDYCOLOR(0x0099ff, 0x000000)

    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(2, 1)
                                                         forBarMetrics:UIBarMetricsDefault];
    UIImage *tmpImage = [UIImage imageNamed:@"back_nav"];
    CGSize newSize = CGSizeMake(10, 17);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
    [tmpImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *backButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[UINavigationBar appearance] setBackIndicatorImage:backButtonImage];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backButtonImage];
    if (IOS_FSystenVersion >= 8.0) {
        [UINavigationBar appearance].translucent = NO;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.titleView = nil;
    self.tabBarController.navigationItem.title = RCDLocalizedString(@"me");
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)),
//    dispatch_get_main_queue(), ^{
//        [self.navigationController setNavigationBarHidden:YES animated:animated];
//    });
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.1)];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (0 == section) {
        rows = 1;
    } else if (1 == section) {
        rows = 4;
    }
    return rows;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        static NSString *detailsCellWithIdentifier = @"MeHeadTableViewCell";
        MeHeadTableViewCell *detailsCell = [self.tableView dequeueReusableCellWithIdentifier:detailsCellWithIdentifier];
        if (detailsCell == nil) {
            detailsCell = [[MeHeadTableViewCell alloc] init];
        }
        return detailsCell;
    }

    static NSString *reusableCellWithIdentifier = @"RCDMeCell";
    RCDMeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];

    if (cell == nil) {
        cell = [[RCDMeCell alloc] init];
    }
    if (1 == indexPath.section) {
        
//        if ([[DEFAULTS valueForKey:ShowPayPage] isEqualToString:@"1"]) {
//            if (indexPath.row == 0) {
//                [cell setCellWithImageName:@"vip_card" labelName:@"会员缴费" rightLabelName:[DEFAULTS objectForKey:@""]];
//            }
//            else if (indexPath.row == 1){
//                [cell setCellWithImageName:@"mixin_ic_vip" labelName:@"会员到期" rightLabelName:[DEFAULTS objectForKey:@""]];
//            }
//            else if (indexPath.row == 2) {
//                [cell setCellWithImageName:@"mixin_ic_invited_code" labelName:@"邀请码" rightLabelName:[DEFAULTS objectForKey:InviteCode]];
//            }
//            else if (indexPath.row == 3) {
//                [cell setCellWithImageName:@"qr_setting" labelName:RCDLocalizedString(@"My_QR") rightLabelName:@""];
//            }
//            else if (4 == indexPath.row) {
//                [cell setCellWithImageName:@"setting_up"
//                                 labelName:RCDLocalizedString(@"account_setting")
//                            rightLabelName:@""];
//            }
//            else if (5 == indexPath.row) {
//                NSString *currentLanguage = [RCDLanguageManager sharedRCDLanguageManager].currentLanguage;
//                NSString *currentLanguageString = self.languageDic[currentLanguage];
//                NSString *rightString = currentLanguageString ? currentLanguageString : RCDLocalizedString(@"language");
//                [cell setCellWithImageName:@"icon_ multilingual"
//                                 labelName:RCDLocalizedString(@"language")
//                            rightLabelName:rightString];
//            }
//            else if (6 == indexPath.row) {
//                [cell setCellWithImageName:@"sevre_inactive" labelName:RCDLocalizedString(@"feedback") rightLabelName:@""];
//            } else if (7 == indexPath.row) {
//                [cell setCellWithImageName:@"about_rongcloud"
//                                 labelName:RCDLocalizedString(@"about_sealtalk")
//                            rightLabelName:@""];
//                BOOL isNeedUpdate = [[DEFAULTS objectForKey:RCDNeedUpdateKey] boolValue];
//                if (isNeedUpdate) {
//                    [cell addRedpointImageView];
//                }
//            }
//        }
//        else{
            if (indexPath.row == 0) {
                [cell setCellWithImageName:@"mixin_ic_invited_code" labelName:@"邀请码" rightLabelName:[DEFAULTS objectForKey:InviteCode]];
            }
            else if (indexPath.row == 1) {
                [cell setCellWithImageName:@"qr_setting" labelName:RCDLocalizedString(@"My_QR") rightLabelName:@""];
            }
            else if (2 == indexPath.row) {
                [cell setCellWithImageName:@"setting_up"
                                 labelName:RCDLocalizedString(@"account_setting")
                            rightLabelName:@""];
//            }
//            else if (3 == indexPath.row) {
//                NSString *currentLanguage = [RCDLanguageManager sharedRCDLanguageManager].currentLanguage;
//                NSString *currentLanguageString = self.languageDic[currentLanguage];
//                NSString *rightString = currentLanguageString ? currentLanguageString : RCDLocalizedString(@"language");
//                [cell setCellWithImageName:@"icon_ multilingual"
//                                 labelName:RCDLocalizedString(@"language")
//                            rightLabelName:rightString];
//            }
//            else if (4 == indexPath.row) {
//                [cell setCellWithImageName:@"sevre_inactive" labelName:RCDLocalizedString(@"feedback") rightLabelName:@""];
            } else if (3 == indexPath.row) {
                [cell setCellWithImageName:@"about_rongcloud"
                                 labelName:RCDLocalizedString(@"about_sealtalk")
                            rightLabelName:@""];
                BOOL isNeedUpdate = [[DEFAULTS objectForKey:RCDNeedUpdateKey] boolValue];
                if (isNeedUpdate) {
                    [cell addRedpointImageView];
                }
            }
//        }
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 120.f;
    }
    return 55.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        RCDMeInfoTableViewController *vc = [[RCDMeInfoTableViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (1 == indexPath.section) {
        
        NSInteger selectIndex = indexPath.row + 2;
//        if ([[DEFAULTS valueForKey:ShowPayPage] isEqualToString:@"0"]) {
//            selectIndex += 2;
//        }
        [self selectTableIndex:selectIndex];
        
    }
}

- (void)selectTableIndex:(NSInteger)index{
    if (index == 0) {
        VipRechargeViewController *nextVC = [[VipRechargeViewController alloc] init];
        [self.navigationController pushViewController:nextVC animated:YES];
    }
    else if (index == 1){
        VipRechargeViewController *rechargeVC = [[VipRechargeViewController alloc] init];
        [self.navigationController pushViewController:rechargeVC animated:YES];
    }
    else if (index == 2) {
        if ([DEFAULTS objectForKey:InviteCode]) {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"已填写邀请码" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                // 取消
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else{
            ActiveInviteCodeViewController *qrCodeVC =
                [[ActiveInviteCodeViewController alloc] init];
            [self.navigationController pushViewController:qrCodeVC animated:YES];
        }
    }
    else if (index == 3) {
        RCDQRCodeController *qrCodeVC =
            [[RCDQRCodeController alloc] initWithTargetId:[RCIM sharedRCIM].currentUserInfo.userId
                                         conversationType:ConversationType_PRIVATE];
        [self.navigationController pushViewController:qrCodeVC animated:YES];
    }
    else if (4 == index) {
        RCDSettingsTableViewController *vc = [[RCDSettingsTableViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
//    }
//    else if (5 == index) {
//        RCDLanguageSettingViewController *vc = [[RCDLanguageSettingViewController alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
//    else if (6 == index) {
//        [self chatWithCustomerService:SERVICE_ID];
    } else if (5 == index) {
        RCDAboutRongCloudTableViewController *vc = [[RCDAboutRongCloudTableViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    return view;
}

- (void)chatWithCustomerService:(NSString *)kefuId {
    RCDCustomerServiceViewController *chatService = [[RCDCustomerServiceViewController alloc] init];

    // live800  KEFU146227005669524   live800的客服ID
    // zhichi   KEFU146001495753714   智齿的客服ID
    chatService.conversationType = ConversationType_CUSTOMERSERVICE;

    chatService.targetId = kefuId;

    //上传用户信息，nickname是必须要填写的
    RCCustomerServiceInfo *csInfo = [[RCCustomerServiceInfo alloc] init];
    csInfo.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    csInfo.nickName = RCDLocalizedString(@"nickname");
    csInfo.loginName = @"登录名称";
    csInfo.name = [RCIMClient sharedRCIMClient].currentUserInfo.name;
    csInfo.grade = @"11级";
    csInfo.gender = @"男";
    csInfo.birthday = @"2016.5.1";
    csInfo.age = @"36";
    csInfo.profession = @"software engineer";
    csInfo.portraitUrl = [RCIMClient sharedRCIMClient].currentUserInfo.portraitUri;
    csInfo.province = @"beijing";
    csInfo.city = @"beijing";
    csInfo.memo = @"这是一个好顾客!";

    csInfo.mobileNo = @"13800000000";
    csInfo.email = @"test@example.com";
    csInfo.address = @"北京市北苑路北泰岳大厦";
    csInfo.QQ = @"88888888";
    csInfo.weibo = @"my weibo account";
    csInfo.weixin = @"myweixin";

    csInfo.page = @"卖化妆品的页面来的";
    csInfo.referrer = @"10001";
    csInfo.enterUrl = @"testurl";
    csInfo.skillId = @"技能组";
    csInfo.listUrl = @[ @"用户浏览的第一个商品Url", @"用户浏览的第二个商品Url" ];
    csInfo.define = @"自定义信息";

    chatService.csInfo = csInfo;
    chatService.title = RCDLocalizedString(@"feedback");

    [self.navigationController pushViewController:chatService animated:YES];
}

- (void)initUI {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}
- (void)getAppConfig{
    [SYNetworkingManager getWithURLString:AppConfig parameters:@{} success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSString *showPay = [[data dictionaryValueForKey:@"appGlobalConfig"] stringValueForKey:@"isObersivePayPage"];
            [DEFAULTS setValue:showPay forKey:ShowPayPage];
        }
    } failure:^(NSError *error) {
        
    }];
}


@end
