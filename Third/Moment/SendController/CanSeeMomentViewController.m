//
//  CanSeeMomentViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "CanSeeMomentViewController.h"
#import "CanSeeCellView.h"
#import "IJSUConst.h"
#import "CanSeeTableViewCell.h"
#import "CanSeePersonTableViewCell.h"
#import "LabelModel.h"
#import "RCDFriendInfo.h"
#import "AddContactMembersViewController.h"
#import "RCDUIBarButtonItem.h"

@interface CanSeeMomentViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic)BOOL isSomeCanSee;

@property (nonatomic, strong)UIView *headView;

@property (nonatomic, strong)CanSeeCellView *allView;

@property (nonatomic, strong)CanSeeCellView *someView;

@property (nonatomic, strong)NSArray *labelArray;

@property (nonatomic, strong)NSMutableArray *labelSelectArray;

@property (nonatomic, strong)NSArray *personArray;

@property (nonatomic, strong)NSMutableArray *personSelectArray;

@property (nonatomic, strong) RCDUIBarButtonItem *rightBtn;

@end

@implementation CanSeeMomentViewController

- (void)loadView{
    [super loadView];
    
    self.labelSelectArray = [NSMutableArray arrayWithCapacity:0];
    self.personSelectArray = [NSMutableArray arrayWithCapacity:0];
    
    [self createHeadView];
    
    [self createTableView];
    
    [self requestAllLabels];
    
    [self getContactMembers];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setnav];
    
}

- (void)setnav{
    self.title = @"谁可以看";
    self.rightBtn = [[RCDUIBarButtonItem alloc]
        initWithbuttonTitle:@"确定"
                 titleColor:[UIColor blackColor]
                buttonFrame:CGRectMake(0, 0, 50, 30)
                     target:self
                     action:@selector(confirmBtnClicked)];
    [self.rightBtn buttonIsCanClick:YES
                        buttonColor:[UIColor blackColor]
                      barButtonItem:self.rightBtn];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

- (void)confirmBtnClicked{
    if (self.canSeeCallBack) {
        NSMutableArray *personIDs = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *labelIDs = [NSMutableArray arrayWithCapacity:0];
        for (RCDFriendInfo *friend in self.personSelectArray) {
            [personIDs addObject:friend.userId];
        }
        for (LabelModel *model in self.labelSelectArray) {
            [labelIDs addObject:model.labelid];
        }
        
        self.canSeeCallBack(personIDs, self.isSomeCanSee, labelIDs);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)requestAllLabels{
    NSDictionary *params = @{@"userAccountId":[ProfileUtil getUserAccountID]};
    [SYNetworkingManager getWithURLString:GetAllLabels parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSMutableArray *labels = [NSMutableArray arrayWithCapacity:0];
            NSArray *allLabel = [data arrayValueForKey:@"labels"];
            for (NSDictionary *labelDic in allLabel) {
                NSDictionary *detailLabel = [labelDic dictionaryValueForKey:@"allLabel"];
                LabelModel *model = [[LabelModel alloc] init];
                model.count = [labelDic stringValueForKey:@"labelUserSize"];
                model.labelid = [detailLabel stringValueForKey:@"id"];
                model.labelName = [detailLabel stringValueForKey:@"labelName"];
                [labels addObject:model];
            }
            self.labelArray = labels;
            [self tableViewReloadData];
        }
    } failure:^(NSError *error) {
        NSLog(@"失败");
    }];
}

- (void)getContactMembers{
    NSDictionary *params = @{@"userAccountId":[ProfileUtil getUserAccountID]};
    [SYNetworkingManager getWithURLString:GetMailList parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSArray *respFriendList = [data arrayValueForKey:@"myFriends"];
            NSMutableArray *friendList = [[NSMutableArray alloc] init];
            for (NSDictionary *userDic in respFriendList) {
                
                RCDFriendInfo *friendInfo = [[RCDFriendInfo alloc] init];
                friendInfo.userId = userDic[@"userAccountId"];
                friendInfo.name = userDic[@"nickName"];
                friendInfo.portraitUri = userDic[@"avaterUrl"];
                friendInfo.displayName = [userDic stringValueForKey:@"userRemarks"];
                friendInfo.district = [userDic stringValueForKey:@"district"];
                friendInfo.status = 20;
                friendInfo.phoneNumber = userDic[@"telphone"];
                friendInfo.stAccount = userDic[@"friendId"];
                if ([[userDic stringValueForKey:@"gender"] isEqualToString:@"1"]) {
                    friendInfo.gender = @"female";
                }
                if ([[userDic stringValueForKey:@"gender"] isEqualToString:@"2"]) {
                    friendInfo.gender = @"male";
                }
                
                //暂时没有用到（***我的标记***）
                //                friendInfo.updateDt = [userDic[@"updateDate"] longLongValue];
                [friendList addObject:friendInfo];
            }
            self.personArray = friendList;
            [self tableViewReloadData];
        }
        
    } failure:^(NSError *error) {
    }];
}

- (void)createHeadView{
    self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 130)];
    self.headView.backgroundColor = [UIColor whiteColor];
    
    self.allView = [[CanSeeCellView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 55)];
    [self.allView updateTitle:@"公开" andDetail:@"所有朋友可见"];
    [self.allView updateSelect:YES];
    
    self.someView = [[CanSeeCellView alloc] initWithFrame:CGRectMake(0, self.allView.bottom, SCREEN_WIDTH, 55)];
    [self.someView updateTitle:@"部分可见" andDetail:@"选中朋友可见"];
    [self.someView updateSelect:NO];
    
    [self.headView addSubview:self.allView];
    [self.headView addSubview:self.someView];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap1Clicked:)];
    [self.allView addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap2Clicked:)];
    [self.someView addGestureRecognizer:tap2];
}

- (void)tap1Clicked:(UITapGestureRecognizer*)tap{
    self.isSomeCanSee = NO;
    [self updateHeadView];
    [self tableViewReloadData];
}

- (void)tap2Clicked:(UITapGestureRecognizer*)tap{
    self.isSomeCanSee = YES;
    [self updateHeadView];
    [self tableViewReloadData];
}

- (void)updateHeadView{
    if (self.isSomeCanSee) {
        [self.someView updateSelect:YES];
        [self.allView updateSelect:NO];
    }
    else {
        [self.someView updateSelect:NO];
        [self.allView updateSelect:YES];
    }
}

- (void)createTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - IJSGStatusBarAndNavigationBarHeight - IJSGTabbarHeight) style:UITableViewStylePlain];
    if (!IJSGiPhoneX) {
        self.tableView.height = SCREEN_HEIGHT - IJSGStatusBarAndNavigationBarHeight;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.headView;
    self.tableView.tableFooterView = [UIView new];
}

- (void)tableViewReloadData{
    [self.tableView reloadData];
}


#pragma table delegate datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isSomeCanSee) {
        if (section == 0) {
            return self.labelArray.count;
        }
        else {
            return self.personSelectArray.count;
        }
    }
    else{
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *cellID = @"CanSeeTableViewCell";
        CanSeeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[CanSeeTableViewCell alloc] init];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        LabelModel *model = self.labelArray[indexPath.row];
        BOOL selected = NO;
        if ([self.labelSelectArray containsObject:model]) {
            selected = YES;
        }
        [cell updateCellData:model selected:selected];
        return cell;
    }
    else {
        static NSString *cellID = @"CanSeePersonTableViewCell";
        CanSeePersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[CanSeePersonTableViewCell alloc] init];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        RCDFriendInfo *model = self.personSelectArray[indexPath.row];
        [cell setUserInfo:model];
        
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH, view.height)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:15];
    [view addSubview:titleLabel];
    if (section == 0) {
        titleLabel.text = @"标签";
    }
    else {
        titleLabel.text = @"添加通讯录联系人";
        titleLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onGotoContactClicked)];
        [titleLabel addGestureRecognizer:tap];
    }
    
    return view;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSomeCanSee) {
        return YES;
    }
    else {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        [self.personSelectArray removeObjectAtIndex:indexPath.row];
        [self tableViewReloadData];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        
        LabelModel *model = self.labelArray[indexPath.row];
        if ([self.labelSelectArray containsObject:model]) {
            [self.labelSelectArray removeObject:model];
        }
        else {
            [self.labelSelectArray addObject:model];
        }
        [self tableViewReloadData];
    }
}


- (void)onGotoContactClicked{
    if (!self.isSomeCanSee) {
        return;
    }
    __weak CanSeeMomentViewController *weakSelf = self;
    AddContactMembersViewController *nextVC = [[AddContactMembersViewController alloc] initWithTitle:@"添加联系人" isAllowsMultipleSelection:YES];
    nextVC.selectArr = self.personSelectArray;
    nextVC.rightCallBack = ^(NSArray *members) {
        for (RCDFriendInfo *friend in weakSelf.personArray) {
            if ([members containsObject:friend.userId]) {
                [weakSelf.personSelectArray addObject:friend];
            }
        }
        [weakSelf tableViewReloadData];
        NSLog(@"%@",members);
    };
    [self.navigationController pushViewController:nextVC animated:YES];
    
}

@end
