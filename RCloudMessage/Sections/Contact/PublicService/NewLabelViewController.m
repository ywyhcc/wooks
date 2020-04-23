//
//  NewLabelViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "NewLabelViewController.h"
#import "NewLabelMemberViewController.h"
#import "RCDAddressBookTableViewCell.h"
#import "LabelEditNameViewController.h"
#import "RCDFriendInfo.h"
#import "RCDUIBarButtonItem.h"
#import "RCDPersonDetailViewController.h"
#import "RCDUserInfoAPI.h"
#define CellHeight 70.0f

@interface NewLabelViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIButton *nameBtn;

//新添加的人
@property (nonatomic, strong) NSMutableArray *addMemberArr;
//新添加人的id
@property (nonatomic, strong) NSArray *addMemberIDs;

//所有的人
@property (nonatomic, strong) NSArray *allArray;

@property (nonatomic, strong) RCDUIBarButtonItem *rightBtn;

@end

@implementation NewLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.addMemberArr = [NSMutableArray arrayWithCapacity:0];
    self.view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    [self setupNavi];
    [self requestAllMembers];
    
    
    [self createHeaderView];
    
    [self requestDetailLabel];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, RCDScreenHeight - 64 - RCDExtraTopHeight - RCDExtraBottomHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
}

- (void)createHeaderView{
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [RCDAddressBookTableViewCell cellHeight] * 3)];
    self.headerView.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH, 30)];
    firstLabel.text = @"标签名字";
    firstLabel.font = [UIFont systemFontOfSize:14];
    firstLabel.textColor = [FPStyleGuide lightGrayTextColor];
    [self.headerView addSubview:firstLabel];
    
    self.nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nameBtn.frame = CGRectMake(0, firstLabel.bottom, SCREEN_WIDTH, [RCDAddressBookTableViewCell cellHeight] - firstLabel.height);
    [self.nameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.nameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.nameBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    self.nameBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [self.nameBtn addTarget:self action:@selector(nameBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.nameBtn.backgroundColor = [UIColor whiteColor];
    if (self.nameStr.length > 0) {
        [self.nameBtn setTitle:self.nameStr forState:UIControlStateNormal];
    }
    
    [self.headerView addSubview:self.nameBtn];
    
    UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.nameBtn.bottom, SCREEN_WIDTH, 40)];
    secondLabel.text = @"标签成员";
    secondLabel.font = [UIFont systemFontOfSize:14];
    secondLabel.textColor = [FPStyleGuide lightGrayTextColor];
    [self.headerView addSubview:secondLabel];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, secondLabel.bottom, SCREEN_WIDTH, [RCDAddressBookTableViewCell cellHeight]);
    addBtn.backgroundColor = [UIColor whiteColor];
    [addBtn addTarget:self action:@selector(addMembers) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:addBtn];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, addBtn.bottom - 0.3, SCREEN_WIDTH, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.headerView addSubview:line];
    
    UILabel *imgLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (addBtn.height - 20) / 2, 20, 20)];
    imgLabel.text = @"+";
    imgLabel.layer.borderColor = [FPStyleGuide weichatGreenColor].CGColor;
    imgLabel.layer.borderWidth = 1;
    imgLabel.layer.cornerRadius = 10;
    imgLabel.textAlignment = NSTextAlignmentCenter;
    imgLabel.textColor = [FPStyleGuide weichatGreenColor];
    imgLabel.clipsToBounds = YES;
    [addBtn addSubview:imgLabel];
    
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgLabel.right + 10, (addBtn.height - 20) / 2, SCREEN_WIDTH, 20)];
    newLabel.font = [UIFont systemFontOfSize:15];
    newLabel.text = @"添加成员";
    newLabel.textColor = [UIColor colorWithHex:0x24db5a];
    [addBtn addSubview:newLabel];
    
    self.headerView.height = addBtn.bottom;
    
    UIView *bline = [[UIView alloc] initWithFrame:CGRectMake(15, self.headerView.bottom - 0.3, SCREEN_WIDTH, 0.3)];
    bline.backgroundColor = [UIColor lightGrayColor];
    [self.headerView addSubview:bline];
    
}

- (void)nameBtnClicked{
    __weak NewLabelViewController *weakSelf = self;
    LabelEditNameViewController *nextVC = [[LabelEditNameViewController alloc] init];
    nextVC.callBack = ^(NSString *name){
        weakSelf.nameStr = name;
        [self.nameBtn setTitle:name forState:UIControlStateNormal];
    };
    nextVC.nameStr = self.nameStr;
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)addMembers{
    NewLabelMemberViewController *nextVC = [[NewLabelMemberViewController alloc] initWithTitle:@"新建标签" isAllowsMultipleSelection:YES];
    nextVC.selectList = self.addMemberArr;
    nextVC.callBack = ^(NSArray *userIDs){
        self.addMemberIDs = userIDs;
        [self.addMemberArr removeAllObjects];
        for (RCDFriendInfo *friend in self.allArray) {
            if ([self.addMemberIDs containsObject:friend.userId]) {
                [self.addMemberArr addObject:friend];
            }
        }
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)setupNavi {
    self.navigationItem.title = self.titleStr;
    
    self.rightBtn = [[RCDUIBarButtonItem alloc]
        initWithbuttonTitle:@"完成"//RCDLocalizedString(@"save")
                 titleColor:[RCDUtilities generateDynamicColor:[UIColor blackColor]
                                                     darkColor:[UIColor whiteColor]]
                buttonFrame:CGRectMake(0, 0, 50, 30)
                     target:self
                     action:@selector(createLabelRequest)];
    [self.rightBtn buttonIsCanClick:YES
                        buttonColor:[RCDUtilities generateDynamicColor:[UIColor blackColor]
                                                             darkColor:[UIColor whiteColor]]
                      barButtonItem:self.rightBtn];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

//#params MARK delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addMemberArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellReuseIdentifier = @"RCDAddressBookTableViewCell";
    RCDAddressBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (!cell) {
        cell = [[RCDAddressBookTableViewCell alloc] init];
    }
    cell.hideRight = YES;
    RCDFriendInfo *user = self.addMemberArr[indexPath.row];

    //给控件填充数据
    [cell setModel:user];
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.addMemberArr removeObjectAtIndex:indexPath.row];
        NSMutableArray *muIds = [NSMutableArray arrayWithCapacity:0];
        for (RCDFriendInfo *temp in self.addMemberArr) {
            [muIds addObject:temp.userId];
        }
        self.addMemberIDs = muIds;
        [self.tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RCDAddressBookTableViewCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDFriendInfo *user = self.addMemberArr[indexPath.row];
    [self pushUserDetailVC:user.userId];
    
}

- (void)pushUserDetailVC:(NSString *)userId {
    RCDPersonDetailViewController *personDetailVC = [[RCDPersonDetailViewController alloc] init];
    personDetailVC.userId = userId;
    if (self.addMemberArr.count > 0) {
        for (RCDFriendInfo *info in self.addMemberArr) {
            if ([info.userId isEqualToString:userId]) {
                personDetailVC.friendID = info.stAccount;
            }
        }
        [self.navigationController pushViewController:personDetailVC animated:YES];
    }
    else{
        [RCDUserInfoAPI getMailFriendList:^(NSArray<RCDFriendInfo *> *friendList) {
            for (RCDFriendInfo *info in friendList) {
                if ([info.userId isEqualToString:userId]) {
                    personDetailVC.friendID = info.stAccount;
                }
            }
            [self.navigationController pushViewController:personDetailVC animated:YES];
        }];
    }
}

- (void)requestAllMembers{
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
            self.allArray = friendList;
            [self.tableView reloadData];
        }
        
    } failure:^(NSError *error) {
    }];
}

- (void)createLabelRequest{
    if (self.nameStr.length == 0) {
        return;
    }
    if (self.addMemberIDs.count == 0) {
        return;
    }
    if ([self.titleStr isEqualToString:@"设置标签"]) {
        NSDictionary *params = @{@"userAccountIds": self.addMemberIDs,@"labelName":self.nameStr,@"optUserAccountId":[ProfileUtil getUserAccountID],@"labelId": self.labelID};
        [SYNetworkingManager requestPUTWithURLStr:EditLabelInfo paramDic:params success:^(NSDictionary *data) {
            if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(NSError *error) {
            
        }];
    }
    else{
        NSDictionary *params = @{@"userAccountIds":self.addMemberIDs,@"optUserAccountId": [ProfileUtil getUserAccountID],@"labelName": self.nameStr};
        
        [SYNetworkingManager postWithURLString:CreateLabel parameters:params success:^(NSDictionary *data) {
            if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)requestDetailLabel{
    if (self.labelID.length > 0) {
        NSDictionary *params = @{@"labelId":self.labelID};
        [SYNetworkingManager getWithURLString:GetLabelInfo parameters:params success:^(NSDictionary *data) {
            if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                NSDictionary *labelInfo = [[data dictionaryValueForKey:@"label"] dictionaryValueForKey:@"label"];
                
                NSMutableArray *friendList = [NSMutableArray arrayWithCapacity:0];
                NSArray *userArray = [[data dictionaryValueForKey:@"label"] arrayValueForKey:@"labelUser"];
                for (NSDictionary *userDic in userArray) {
                    RCDFriendInfo *friendInfo = [[RCDFriendInfo alloc] init];
                    friendInfo.userId = userDic[@"userAccountId"];
                    friendInfo.district = [userDic stringValueForKey:@"district"];
                    friendInfo.name = userDic[@"nickName"];
                    friendInfo.portraitUri = userDic[@"avaterUrl"];
                    friendInfo.displayName = [userDic stringValueForKey:@"userRemarks"];
                    friendInfo.status = 20;
                    friendInfo.phoneNumber = userDic[@"telphone"];
                    friendInfo.stAccount = userDic[@"friendId"];
//                    friendInfo.gender = userDic[@"gender"];
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
                self.addMemberArr = friendList;
                
                NSMutableArray *muIds = [NSMutableArray arrayWithCapacity:0];
                for (RCDFriendInfo *temp in self.addMemberArr) {
                    [muIds addObject:temp.userId];
                }
                self.addMemberIDs = muIds;
                [self.tableView reloadData];
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

@end
