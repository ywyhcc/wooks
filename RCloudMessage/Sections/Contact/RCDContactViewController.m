//
//  RCDContactViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/16.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDContactViewController.h"
#import "RCDAddressBookViewController.h"
#import "RCDCommonDefine.h"
#import "RCDContactTableViewCell.h"
#import "RCDGroupViewController.h"
#import "RCDPersonDetailViewController.h"
#import "RCDPublicServiceListViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDAddFriendListViewController.h"
#import "RCDUIBarButtonItem.h"
#import "RCDUserInfoManager.h"
#import "RCDUtilities.h"
#import <Masonry/Masonry.h>
#import "UITabBar+badge.h"
#import "RCDCommonString.h"
#import "RCDSelectContactViewController.h"
#import "RCDSearchBar.h"
#import "NewFriendsInviteViewController.h"
#import "LabelViewController.h"
#import "RCDUserInfoAPI.h"
#import "KxMenu.h"
#import "RCDScanQRCodeController.h"

@interface RCDContactViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,
                                        UISearchControllerDelegate>
@property (nonatomic, strong) RCDTableView *friendsTabelView;
@property (nonatomic, strong) RCDSearchBar *searchFriendsBar;
@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic, strong) NSArray *allFriendArray;
@property (nonatomic, strong) NSArray *resultKeys;
@property (nonatomic, strong) NSDictionary *resultSectionDict;
@property (nonatomic, strong) NSMutableArray *matchFriendList;

@property (nonatomic, strong) NSArray *defaultCellsTitle;
@property (nonatomic, strong) NSArray *defaultCellsPortrait;
@property (nonatomic, assign) BOOL hasSyncFriendList;
@property (nonatomic, assign) BOOL isBeginSearch;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSArray *serverFriendsArray;

@end

@implementation RCDContactViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self initData];
    [self addObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.titleView = nil;
    self.tabBarController.navigationItem.title = RCDLocalizedString(@"contacts");
    self.tabBarController.navigationItem.leftBarButtonItems = nil;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tabBarController.navigationItem.leftBarButtonItems = nil;
//    });
    if ([UIDevice currentDevice].systemVersion.floatValue < 10.0) {
        self.tabBarController.navigationItem.leftBarButtonItems = nil;
    }
    
    [self setupNavi];
    [self.searchFriendsBar resignFirstResponder];
    [self sortAndRefreshWithList:[self getAllFriendList]];
    [RCDUserInfoManager getFriendListFromServer:^(NSArray<RCDFriendInfo *> *friendList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.hasSyncFriendList = YES;
            if (friendList) {
                self.allFriendArray = [self getAllFriendList];
                [self sortAndRefreshWithList:self.allFriendArray];
            }
        });
    }];
    [self getServerFriends];
    [self updateFriendNum];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_isBeginSearch == YES) {
        [self sortAndRefreshWithList:self.allFriendArray];
        [self resetSearchBarAndMatchFriendList];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateFriendNum{
    UILabel *bottomView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45)];
    bottomView.text = [NSString stringWithFormat:@"%lu位朋友及联系人",(unsigned long)self.allFriendArray.count];
    bottomView.textColor = [FPStyleGuide lightGrayTextColor];
    bottomView.textAlignment = NSTextAlignmentCenter;
    self.friendsTabelView.tableFooterView = bottomView;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (section == 0) {
        if (_isBeginSearch == YES) {
            rows = 0;
        } else {
            rows = 3;
        }
    } else {
        NSString *letter = self.resultKeys[section - 1];
        rows = [self.resultSectionDict[letter] count];
    }
    return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.resultKeys.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 21.f;
}

//如果没有该方法，tableView会默认显示footerView，其高度与headerView等高
//另外如果return 0或者0.0f是没有效果的
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width, 21);
    view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.frame = CGRectMake(13, 3, 15, 15);
    title.font = [UIFont systemFontOfSize:15.f];
    title.textColor = RCDDYCOLOR(0x999999, 0x9f9f9f);
    [view addSubview:title];

    if (section == 0) {
        title.text = nil;
    } else {
        title.text = self.resultKeys[section - 1];
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDContactTableViewCell";
    RCDContactTableViewCell *cell =
        [self.friendsTabelView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDContactTableViewCell alloc] init];
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 3) {
            [cell setModel:[RCIM sharedRCIM].currentUserInfo];
        } else {
            cell.nicknameLabel.text = [_defaultCellsTitle objectAtIndex:indexPath.row];
            [cell.portraitView
                setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", [_defaultCellsPortrait
                                                                                   objectAtIndex:indexPath.row]]]];
            if (indexPath.row == 0) {
                int allRequesteds = [RCDUserInfoManager getFriendRequesteds];
                if (allRequesteds > 0) {
                    [cell showNoticeLabel:allRequesteds];
                }
            }
        }
    } else {
        NSString *letter = self.resultKeys[indexPath.section - 1];
        NSArray *sectionUserInfoList = self.resultSectionDict[letter];
        RCDFriendInfo *userInfo = sectionUserInfoList[indexPath.row];
        if (userInfo) {
            [cell setModel:userInfo];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __weak typeof(self) weakSelf = self;
    cell.longPressBlock = ^(NSString *userId) {
        RCDSelectContactViewController *selectContactVC =
            [[RCDSelectContactViewController alloc] initWithContactSelectType:RCDContactSelectTypeDelete];
        [weakSelf.navigationController pushViewController:selectContactVC animated:YES];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.5;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.resultKeys;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.friendsTabelView deselectRowAtIndexPath:indexPath animated:YES];
    RCDFriendInfo *user = nil;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
        case 0: {
            NewFriendsInviteViewController *contactSelectedVC =
                [[NewFriendsInviteViewController alloc] initWithTitle:@"新的朋友"
                                                   isAllowsMultipleSelection:YES];
            [self.navigationController pushViewController:contactSelectedVC animated:YES];
//            RCDAddressBookViewController *addressBookVC = [[RCDAddressBookViewController alloc] init];
//            [self.navigationController pushViewController:addressBookVC animated:YES];
        } break;
        case 1: {
            RCDGroupViewController *groupVC = [[RCDGroupViewController alloc] init];
            [self.navigationController pushViewController:groupVC animated:YES];
        } break;
        case 2: {
            LabelViewController *nextVC = [[LabelViewController alloc] init];
            [self.navigationController pushViewController:nextVC animated:YES];
            
//            RCDPublicServiceListViewController *publicServiceVC = [[RCDPublicServiceListViewController alloc] init];
//            [self.navigationController pushViewController:publicServiceVC animated:YES];
        } break;
        case 3: {
            [self pushUserDetailVC:[RCIM sharedRCIM].currentUserInfo.userId];
        } break;
        default:
            break;
        }
    } else {
        NSString *letter = self.resultKeys[indexPath.section - 1];
        NSArray *sectionUserInfoList = self.resultSectionDict[letter];
        user = sectionUserInfoList[indexPath.row];
        if (user == nil) {
            return;
        }
        [self pushUserDetailVC:user.userId];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchFriendsBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
//  执行 delegate 搜索好友
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.matchFriendList removeAllObjects];
    if (searchText.length <= 0) {
        [self sortAndRefreshWithList:self.allFriendArray];
    } else {
        for (RCDFriendInfo *userInfo in self.allFriendArray) {
            NSString *name = userInfo.name;
            if ([userInfo isKindOfClass:[RCDFriendInfo class]] && userInfo.displayName.length > 0) {
                name = userInfo.displayName;
            }
            // //忽略大小写去判断是否包含
            if ([name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [[RCDUtilities hanZiToPinYinWithString:name] rangeOfString:searchText options:NSCaseInsensitiveSearch]
                        .location != NSNotFound) {
                [self.matchFriendList addObject:userInfo];
            }
        }
        [self sortAndRefreshWithList:self.matchFriendList];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self resetSearchBarAndMatchFriendList];
    [self sortAndRefreshWithList:self.allFriendArray];
    [self reloadView];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (_isBeginSearch == NO) {
        _isBeginSearch = YES;
        [self reloadView];
    }
    self.searchFriendsBar.showsCancelButton = YES;
    for (UIView *view in [[[self.searchFriendsBar subviews] objectAtIndex:0] subviews]) {
        if ([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            UIButton *cancel = (UIButton *)view;
            [cancel setTitle:RCDLocalizedString(@"cancel") forState:UIControlStateNormal];
            break;
        }
    }
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - Private Method
- (void)setupView {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    [self.view addSubview:self.friendsTabelView];
    [self.view addSubview:self.searchFriendsBar];
    [self.friendsTabelView addSubview:self.emptyLabel];
    [self.friendsTabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchFriendsBar.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];

    [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.width.height.equalTo(self.friendsTabelView);
        make.centerY.equalTo(self.friendsTabelView).offset(-30);
    }];

    [self.searchFriendsBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
    }];
    [self updateBadgeForTabBarItem];
}

- (void)setupNavi {
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.navigationItem.title = RCDLocalizedString(@"contacts");
    RCDUIBarButtonItem *rightBtn = [[RCDUIBarButtonItem alloc] initContainImage:[UIImage imageNamed:@"right_add_friend"]
                                                                 imageViewFrame:CGRectMake(8.5, 8.5, 17, 17)
                                                                    buttonTitle:nil
                                                                     titleColor:nil
                                                                     titleFrame:CGRectZero
                                                                    buttonFrame:CGRectMake(0, 0, 40, 40)
                                                                         target:self
                                                                         action:@selector(showMenu)];
    self.tabBarController.navigationItem.rightBarButtonItems = @[rightBtn ];//setTranslation:rightBtn translation:-6
    
//    RCDUIBarButtonItem *rightBtn = [[RCDUIBarButtonItem alloc] initContainImage:[UIImage imageNamed:@"right_add_friend"]
//                                                                 imageViewFrame:CGRectMake(8.5, 8.5, 17, 17)
//                                                                    buttonTitle:nil
//                                                                     titleColor:nil
//                                                                     titleFrame:CGRectZero
//                                                                    buttonFrame:CGRectMake(0, 0, 34, 34)
//                                                                         target:self
//                                                                         action:@selector(showMenu)];
//    self.tabBarController.navigationItem.rightBarButtonItems = @[ rightBtn ];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor],
                                                                         NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:18]}];
}

#pragma mark - target action
/**
 *  弹出层
 *
 *  @param sender sender description
 */
- (void)showMenu {
    NSArray *menuItems = @[
        [KxMenuItem menuItem:RCDLocalizedString(@"start_chatting")
                       image:[UIImage imageNamed:@"home_right3"]
                      target:self
                      action:@selector(pushChat:)],

        [KxMenuItem menuItem:RCDLocalizedString(@"create_groups")
                       image:[UIImage imageNamed:@"home_right4"]
                      target:self
                      action:@selector(pushContactSelected:)],

        [KxMenuItem menuItem:RCDLocalizedString(@"add_contacts")
                       image:[UIImage imageNamed:@"home_right2"]
                      target:self
                      action:@selector(pushAddFriend:)],

        [KxMenuItem menuItem:RCDLocalizedString(@"qr_scan")
                       image:[UIImage imageNamed:@"home_right1"]
                      target:self
                      action:@selector(pushToQRScan)]
    ];

    UIBarButtonItem *rightBarButton = self.tabBarController.navigationItem.rightBarButtonItems[0];
    CGRect targetFrame = [self.navigationController.view convertRect:rightBarButton.customView.frame
                                                            fromView:rightBarButton.customView.superview];
    targetFrame.origin.y = targetFrame.origin.y - 15 - 8.5;
    targetFrame.size.width = targetFrame.size.width + 20;
//    [KxMenu setTintColor:HEXCOLOR(0x000000)];
    [KxMenu setTintColor:[UIColor whiteColor]];
    [KxMenu setTitleFont:[UIFont systemFontOfSize:17]];
    [KxMenu showMenuInView:self.tabBarController.navigationController.navigationBar.superview
                  fromRect:targetFrame
                 menuItems:menuItems];
}

- (void)pushChat:(id)sender {
    RCDContactSelectedTableViewController *contactSelectedVC =
        [[RCDContactSelectedTableViewController alloc] initWithTitle:RCDLocalizedString(@"start_chatting")
                                           isAllowsMultipleSelection:NO];
    [self.navigationController pushViewController:contactSelectedVC animated:YES];
}
/**
 *  创建群组
 *
 *  @param sender sender description
 */
- (void)pushContactSelected:(id)sender {
    RCDContactSelectedTableViewController *contactSelectedVC =
        [[RCDContactSelectedTableViewController alloc] initWithTitle:RCDLocalizedString(@"select_contact")
                                           isAllowsMultipleSelection:YES];
    contactSelectedVC.groupOptionType = RCDContactSelectedGroupOptionTypeCreate;
    [self.navigationController pushViewController:contactSelectedVC animated:YES];
}

/**
 *  添加好友
 *
 *  @param sender sender description
 */
- (void)pushAddFriend:(id)sender {
    RCDAddFriendListViewController *addFriendListVC = [[RCDAddFriendListViewController alloc] init];
    [self.navigationController pushViewController:addFriendListVC animated:YES];
}

- (void)pushAddressBook {
    RCDAddressBookViewController *addressBookVC = [[RCDAddressBookViewController alloc] init];
    [self.navigationController pushViewController:addressBookVC animated:YES];
}

- (void)pushToQRScan {
    RCDScanQRCodeController *qrcodeVC = [[RCDScanQRCodeController alloc] init];
    [self.navigationController pushViewController:qrcodeVC animated:YES];
}

- (void)initData {
    self.matchFriendList = [[NSMutableArray alloc] init];
    self.resultSectionDict = [[NSDictionary alloc] init];
    self.defaultCellsTitle = [NSArray arrayWithObjects:RCDLocalizedString(@"new_friend"), RCDLocalizedString(@"group"),
                                                       @"标签", nil];
    self.defaultCellsPortrait = [NSArray arrayWithObjects:@"newFriend", @"defaultGroup", @"publicNumber", nil];
    self.isBeginSearch = NO;
    self.queue = dispatch_queue_create("sealtalksearch", DISPATCH_QUEUE_SERIAL);
    self.allFriendArray = [self getAllFriendList];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBadgeForTabBarItem)
                                                 name:RCDContactsRequestKey
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadContents)
                                                 name:RCDContactsUpdateUIKey
                                               object:nil];
}

- (void)extracted {
    [RCDUserInfoManager getFriendListFromServer:^(NSArray<RCDFriendInfo *> *friendList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.hasSyncFriendList = YES;
            if (friendList) {
                self.allFriendArray = [self getAllFriendList];
                [self sortAndRefreshWithList:self.allFriendArray];
            }
        });
    }];
}

- (void)reloadContents {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.allFriendArray = [self getAllFriendList];
        [self sortAndRefreshWithList:self.allFriendArray];
    });
}

// 获取好友并且排序
- (NSArray *)getAllFriendList {
    NSMutableArray *userInfoList = [NSMutableArray arrayWithArray:[RCDUserInfoManager getAllFriends]];
    if (userInfoList.count <= 0 && !self.hasSyncFriendList) {
        [self extracted];
    }
    return userInfoList;
}

- (void)sortAndRefreshWithList:(NSArray *)friendList {
    dispatch_async(self.queue, ^{
        NSDictionary *resultDic = [[RCDUtilities sortedArrayWithPinYinDic:friendList] copy];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.resultKeys = resultDic[@"allKeys"];
            self.resultSectionDict = resultDic[@"infoDic"];
            [self reloadView];
        });
    });
}

- (void)resetSearchBarAndMatchFriendList {
    _isBeginSearch = NO;
    self.searchFriendsBar.showsCancelButton = NO;
    [self.searchFriendsBar resignFirstResponder];
    self.searchFriendsBar.text = @"";
    [self.matchFriendList removeAllObjects];
}

- (void)getServerFriends{
    [RCDUserInfoAPI getMailFriendList:^(NSArray<RCDFriendInfo *> *friendList) {
        self.serverFriendsArray = friendList;
    }];
}

- (void)pushUserDetailVC:(NSString *)userId {
    RCDPersonDetailViewController *personDetailVC = [[RCDPersonDetailViewController alloc] init];
    personDetailVC.userId = userId;
    if (self.serverFriendsArray.count > 0) {
        for (RCDFriendInfo *info in self.serverFriendsArray) {
            if ([info.userId isEqualToString:userId]) {
                personDetailVC.friendID = info.stAccount;
            }
        }
        [self.navigationController pushViewController:personDetailVC animated:YES];
    }
    else{
        [RCDUserInfoAPI getMailFriendList:^(NSArray<RCDFriendInfo *> *friendList) {
            self.serverFriendsArray = friendList;
            for (RCDFriendInfo *info in self.serverFriendsArray) {
                if ([info.userId isEqualToString:userId]) {
                    personDetailVC.friendID = info.stAccount;
                }
            }
            [self.navigationController pushViewController:personDetailVC animated:YES];
        }];
    }
}

- (void)updateBadgeForTabBarItem {
    __weak typeof(self) __weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [__weakSelf reloadView];
    });
}

- (void)reloadView {
    if (self.isBeginSearch) {
        self.emptyLabel.hidden = self.resultKeys.count != 0;
    } else {
        self.emptyLabel.hidden = YES;
    }
    [self.friendsTabelView reloadData];
    [self updateFriendNum];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tabBarController.navigationItem.leftBarButtonItems = nil;
//    });
}

#pragma mark - Target Action
- (void)pushAddFriendVC:(id)sender {
    RCDAddFriendListViewController *addFriendListVC = [[RCDAddFriendListViewController alloc] init];
    [self.navigationController pushViewController:addFriendListVC animated:YES];
}

- (void)forwardCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getter & Setter
- (RCDSearchBar *)searchFriendsBar {
    if (!_searchFriendsBar) {
        _searchFriendsBar = [[RCDSearchBar alloc] init];
        _searchFriendsBar.delegate = self;
        _searchFriendsBar.keyboardType = UIKeyboardTypeDefault;
        _searchFriendsBar.placeholder = RCDLocalizedString(@"search");
    }
    return _searchFriendsBar;
}

- (RCDTableView *)friendsTabelView {
    if (!_friendsTabelView) {
        _friendsTabelView = [[RCDTableView alloc] initWithFrame:CGRectZero style:(UITableViewStyleGrouped)];
        _friendsTabelView.delegate = self;
        _friendsTabelView.dataSource = self;
        _friendsTabelView.tableHeaderView =
            [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _friendsTabelView.bounds.size.width, 0.01f)];
        //设置右侧索引
        _friendsTabelView.sectionIndexBackgroundColor = [UIColor clearColor];
        _friendsTabelView.sectionIndexColor = HEXCOLOR(0x555555);
    }
    return _friendsTabelView;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.text = RCDLocalizedString(@"NoFriendsWereFound");
        _emptyLabel.textColor = HEXCOLOR(0x939393);
        _emptyLabel.font = [UIFont systemFontOfSize:17];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.hidden = YES;
    }
    return _emptyLabel;
}

@end
