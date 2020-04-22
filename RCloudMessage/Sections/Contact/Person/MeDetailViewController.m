//
//  MeDetailViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/22.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "MeDetailViewController.h"
#import "RCDUIBarButtonItem.h"
#import "MomentListViewController.h"
#import "RCDPersonInfoView.h"
#import "RCDUserInfoManager.h"
#import "RCDFriendInfo.h"
#import "RCDPersonDetailCell.h"
#import "UIColor+RCColor.h"
#import "DetailMomentViewController.h"


@interface MeDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) RCDUIBarButtonItem *rightBtn;

@property (nonatomic, strong) RCDPersonInfoView *infoView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) RCDFriendInfo *userInfo;

@end

@implementation MeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNaviItem];
    
    [self createUI];
    
    [self setData];
    
    
}

- (void)createUI{
    [self.view addSubview:self.infoView];
    self.infoView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 105);
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.infoView.bottom, SCREEN_WIDTH, 200) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    self.tableView.separatorColor = RCDDYCOLOR(0xdfdfdf, 0x1a1a1a);
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
}

- (void)setData{
    __weak typeof(self) weakSelf = self;
    NSString *currentUserId = [RCIM sharedRCIM].currentUserInfo.userId;
    [RCDUserInfoManager getUserInfoFromServer:currentUserId
    complete:^(RCDUserInfo *userInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.userInfo = [[RCDFriendInfo alloc]init];
            weakSelf.userInfo.gender = userInfo.gender;
            weakSelf.userInfo.userId = userInfo.userId;
            weakSelf.userInfo.name = userInfo.name;
            weakSelf.userInfo.portraitUri = userInfo.portraitUri;
            [weakSelf.infoView setUserInfo:weakSelf.userInfo];
        });
    }];
}

- (void)setNaviItem {
    self.rightBtn = [[RCDUIBarButtonItem alloc]
        initWithbuttonTitle:@"好友互动"
                 titleColor:[RCDUtilities generateDynamicColor:[UIColor whiteColor]
                                                     darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                buttonFrame:CGRectMake(0, 0, 70, 30)
                     target:self
                     action:@selector(showMessageList)];
    self.rightBtn.button.backgroundColor = [FPStyleGuide weichatGreenColor];
    self.rightBtn.button.layer.cornerRadius = 7;
    self.rightBtn.button.clipsToBounds = YES;
    [self.rightBtn buttonIsCanClick:YES
                        buttonColor:[UIColor whiteColor]
                      barButtonItem:self.rightBtn];
    self.rightBtn.button.titleLabel.font = [UIFont systemFontOfSize:15];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

- (void)showMessageList{
    MomentListViewController *momentVC = [[MomentListViewController alloc] init];
    [self.navigationController pushViewController:momentVC animated:YES];
}

- (RCDPersonInfoView *)infoView {
    if (!_infoView) {
        _infoView = [[RCDPersonInfoView alloc] init];
    }
    return _infoView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RCDPersonDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonDetailSettingReuseIdentifier"];
    if (!cell) {
        cell = [[RCDPersonDetailCell alloc] init];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailLabel.textColor = [UIColor colorWithHexString:@"0099FF" alpha:1];
    [cell setCellStyle:Style_Title_Detail];
    cell.titleLabel.text = @"蜜友圈";
    cell.detailLabel.userInteractionEnabled = YES;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, 15)];
    view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailMomentViewController *momentVC = [[DetailMomentViewController alloc] init];
    momentVC.userAccoutID = [ProfileUtil getUserAccountID];
    [self.navigationController pushViewController:momentVC animated:YES];
}

@end
