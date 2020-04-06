//
//  AddContactFriendsTableViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "AddContactFriendsTableViewController.h"
#import "RCDContactTableViewCell.h"
#import "RCDPersonDetailViewController.h"
#import "RCDUIBarButtonItem.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUserInfoManager.h"
#import "AddContactFriendsTableViewCell.h"
#import "RCDGroupManager.h"
#import "ContactAddUserModel.h"

@interface AddContactFriendsTableViewController ()<UISearchResultsUpdating>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResultList;

@end

@implementation AddContactFriendsTableViewController
#pragma mark - life cycle

- (void)requestUsers{
    NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:0];
    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"telphones":self.phoneMembers};
    [SYNetworkingManager postWithURLString:GetPhoneAllUser parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSArray *allPhoneUser = [data arrayValueForKey:@"allPhoneUser"];
            for (NSDictionary *dic in allPhoneUser) {
                bool isFriend = [dic boolValueForKey:@"isMyFriend"];
                NSDictionary *userInfo = [dic dictionaryValueForKey:@"userInfo"];
                
                ContactAddUserModel *model = [[ContactAddUserModel alloc] initWithDictionary:userInfo];
                model.isMyFriend = isFriend;
                [muArr addObject:model];
            }
            self.userMembers = muArr;
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通讯录中的好友";
    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                                             target:self
                                                                             action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = leftBtn;

    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self requestUsers];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return self.searchResultList.count;
    }
    return self.userMembers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddContactFriendsTableViewCell *cell = [AddContactFriendsTableViewCell cellWithTableView:tableView];
    ContactAddUserModel *userInfo = self.userMembers[indexPath.row];
    if (self.searchController.active) {
        userInfo = self.searchResultList[indexPath.row];
    }
    [cell setModel:userInfo];
    cell.callbackBlock = ^{
        [self requestUsers];
    };

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *userId = self.userMembers[indexPath.row];
//    if (self.searchController.active) {
//        userId = self.searchResultList[indexPath.row];
//    }
//    UIViewController *vc = [RCDPersonDetailViewController configVC:userId groupId:self.groupId];
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UISearchController Delegate -
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //谓词搜索过滤
    NSString *searchString = [self.searchController.searchBar text].lowercaseString;
    [self.searchResultList removeAllObjects];
    for (ContactAddUserModel *model in self.userMembers) {
        if ([model.nickName containsString:searchString]) {
            [self.searchResultList addObject:model];
        }
    }
    
//    for (NSString *userId in self.groupMembers) {
//        RCUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
//        RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userId];
//        RCDGroupMember *member = [RCDGroupManager getGroupMember:userId groupId:self.groupId];
//        if ([user.name.lowercaseString containsString:searchString] ||
//            [friend.displayName.lowercaseString containsString:searchString] ||
//            [member.groupNickname containsString:searchString]) {
//            [self.searchResultList addObject:userId];
//        }
//    }
    [self.tableView reloadData];
}

#pragma mark - target action
- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - getter
- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        //提醒字眼
        _searchController.searchBar.placeholder = NSLocalizedStringFromTable(@"ToSearch", @"RongCloudKit", nil);
        //设置顶部搜索栏的背景色
        _searchController.searchBar.barTintColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
        _searchController.dimsBackgroundDuringPresentation = NO;
    }
    return _searchController;
}

- (NSMutableArray *)searchResultList {
    if (!_searchResultList) {
        _searchResultList = [NSMutableArray array];
    }
    return _searchResultList;
}
@end
