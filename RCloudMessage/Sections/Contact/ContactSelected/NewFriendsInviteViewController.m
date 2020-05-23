//
//  NewFriendsInviteViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/28.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "NewFriendsInviteViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDChatViewController.h"
#import "RCDContactSelectedCollectionViewCell.h"
#import "RCDContactSelectedTableViewCell.h"
#import "RCDCreateGroupViewController.h"
#import "RCDNoFriendView.h"
#import "RCDRCIMDataSource.h"
#import "RCDUIBarButtonItem.h"
#import "RCDUserInfoManager.h"
#import "RCDGroupManager.h"
#import "RCDUtilities.h"
#import "UIColor+RCColor.h"
#import "RCDForwardManager.h"
#import "UIView+MBProgressHUD.h"
#import "RCDSearchBar.h"
#import "RCDTableView.h"
#import "RCDSearchFriendController.h"
#import "AddContactFriendsTableViewController.h"
#import "RCDCommonString.h"
#import <ContactsUI/ContactsUI.h>
#import "RCDAddFriendListViewController.h"
#import "RCDGroupNotificationMessage.h"

@interface NewFriendsInviteViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,
UICollectionViewDelegate, UITableViewDelegate,
UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate,CNContactPickerDelegate>

@property (nonatomic, strong) NSMutableDictionary *allFriendsDict;
@property (nonatomic, strong) NSArray *allKeys;

@property (strong, nonatomic) NSMutableArray *friendArray;
@property (nonatomic, strong) NSMutableArray *collectionViewResource;
//进入页面以后选中的userId的集合
@property (nonatomic, strong) NSMutableArray *selectUserList;
//搜索出的结果数据集合
@property (nonatomic, strong) NSMutableArray *matchSearchList;

@property (nonatomic, strong) NSString *searchContent;

//是否是显示搜索的结果
@property (nonatomic, assign) BOOL isSearchResult;
//判断当前操作是否是删除操作
@property (nonatomic, assign) BOOL isDeleteUser;
@property (nonatomic, assign) BOOL isAllowsMultipleSelection;
// collectionView展示的最大数量
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;

@property (nonatomic, strong) RCDNoFriendView *noFriendView;
@property (nonatomic, strong) RCDUIBarButtonItem *rightBtn;
@property (nonatomic, strong) UICollectionView *selectedUsersCollectionView;
@property (nonatomic, strong) RCDTableView *tableView;
@property (nonatomic, strong) RCDSearchBar *searchBar;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) UIView *searchFieldLeftView;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) NSMutableArray *phoneList;

@end

@implementation NewFriendsInviteViewController
#pragma mark - Life Cycle

- (instancetype)initWithTitle:(NSString *)title isAllowsMultipleSelection:(BOOL)isAllowsMultipleSelection {
    if (self = [super init]) {
        self.phoneList = [NSMutableArray arrayWithCapacity:0];
        self.navigationItem.title = title;
        self.isAllowsMultipleSelection = isAllowsMultipleSelection;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavi];
    [self initData];
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.allFriendsDict count] <= 0) {
        [self getAllData];
    }
}

- (void)addNewFriend{
    RCDAddFriendListViewController *addFriendListVC = [[RCDAddFriendListViewController alloc] init];
    [self.navigationController pushViewController:addFriendListVC animated:YES];
//    RCDSearchFriendController *searchFirendVC = [[RCDSearchFriendController alloc] init];
//    [self.navigationController pushViewController:searchFirendVC animated:YES];
}

- (void)viewDidLayoutSubviews {
    self.noFriendView.frame = CGRectMake(0, 0, RCDScreenWidth, RCDScreenHeight - 64);
    self.tableView.frame =
        CGRectMake(0, 54, RCDScreenWidth, RCDScreenHeight - 64 - 54 - RCDExtraTopHeight - RCDExtraBottomHeight);
    
    self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [RCDContactSelectedTableViewCell cellHeight] * 2)];
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, SCREEN_WIDTH, [RCDContactSelectedTableViewCell cellHeight] - 10)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self.headView addSubview:whiteView];
    
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 30, 30)];
    leftView.image = [UIImage imageNamed:@"new_friend_call"];
    [self.headView addSubview:leftView];
    
    UIButton *contractBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    contractBtn.frame = CGRectMake(leftView.right + 10, 0, (SCREEN_WIDTH - 40) / 2, [RCDContactSelectedTableViewCell cellHeight]);
    contractBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    contractBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    contractBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [contractBtn setTitle:@"添加通讯录中的朋友" forState:UIControlStateNormal];
    [contractBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [contractBtn addTarget:self action:@selector(getMailListAction) forControlEvents:UIControlEventTouchUpInside];
    [self.headView addSubview:contractBtn];
    
    UIButton *allAgreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    allAgreeBtn.frame = CGRectMake((SCREEN_WIDTH - 220) / 2, [RCDContactSelectedTableViewCell cellHeight] + 20, 100, [RCDContactSelectedTableViewCell cellHeight] - 40);
    allAgreeBtn.backgroundColor = [FPStyleGuide weichatGreenColor];
    allAgreeBtn.layer.cornerRadius = 5;
    allAgreeBtn.clipsToBounds = YES;
    [allAgreeBtn addTarget:self action:@selector(allAgreeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [allAgreeBtn setTitle:@"一键同意" forState:UIControlStateNormal];
    [self.headView addSubview:allAgreeBtn];
    
    UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    agreeBtn.frame = CGRectMake(allAgreeBtn.right + 20, [RCDContactSelectedTableViewCell cellHeight] + 20, 100, [RCDContactSelectedTableViewCell cellHeight] - 40);
    agreeBtn.backgroundColor = [FPStyleGuide weichatGreenColor];
    agreeBtn.layer.cornerRadius = 5;
    agreeBtn.clipsToBounds = YES;
    [agreeBtn addTarget:self action:@selector(agreeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
    [self.headView addSubview:agreeBtn];
    
    self.tableView.tableHeaderView = self.headView;
}

- (void)pushContactVC{
    CNContactPickerViewController * contactPickerVc = [CNContactPickerViewController new];

    contactPickerVc.delegate = self;
    contactPickerVc.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:contactPickerVc animated:YES completion:nil];

}
#pragma mark - 获取所有联系人列表
- (void)getMailListAction{
    
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError*  _Nullable error) {
            if (error) {
                //无权限
                [self showAlertViewAboutNotAuthorAccessContact];
            } else {
                //有权限
                [self openContact];
            }
        }];
    } else if(status == CNAuthorizationStatusRestricted) {
        //无权限
        [self showAlertViewAboutNotAuthorAccessContact];
    } else if (status == CNAuthorizationStatusDenied) {
        //无权限
        [self showAlertViewAboutNotAuthorAccessContact];
    } else if (status == CNAuthorizationStatusAuthorized) {
        //有权限
        [self openContact];
    }
    
}

- (void)showAlertViewAboutNotAuthorAccessContact{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请授权通讯录权限" message:@"请在iPhone的\"设置-隐私-通讯录\"选项中,允许花解解访问你的通讯录" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:OKAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)openContact{
    [self.phoneList removeAllObjects];
    NSArray *keysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        
        NSString * firstName = contact.familyName;
        NSString * lastName = contact.givenName;
        
        //电话
        NSArray * phoneNums = contact.phoneNumbers;
        CNLabeledValue *labelValue = phoneNums.firstObject;
        NSString *phoneValue = [labelValue.value stringValue];
        phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@"+86" withString:@""];
        phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
        phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@"(" withString:@""];
        phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@")" withString:@""];
        phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@" " withString:@""];
        phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSLog(@"姓名：%@%@ 电话：%@", firstName, lastName, phoneValue);
        if (phoneValue.length > 0) {
            [self.phoneList addObject:phoneValue];
        }
        
    }];
    
    if (self.phoneList.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AddContactFriendsTableViewController *nextVC = [[AddContactFriendsTableViewController alloc] init];
            nextVC.phoneMembers = self.phoneList;
            [self.navigationController pushViewController:nextVC animated:YES];
        });
        
    }
    
}




#pragma mark - 选中一个联系人

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{

    NSLog(@"contact:%@",contact);

    //phoneNumbers 包含手机号和家庭电话等

    for(CNLabeledValue * labeledValue in contact.phoneNumbers) {

        CNPhoneNumber * phoneNumber = labeledValue.value;

        NSLog(@"phoneNum:%@", phoneNumber.stringValue);

    }

}

#pragma mark - 选中一个联系人属性

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty{

    NSLog(@"contactProperty:%@",contactProperty);

}

#pragma mark - 选中一个联系人的多个属性

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperties:(NSArray*)contactProperties{

    NSLog(@"contactPropertiescontactProperties:%@",contactProperties);

}

#pragma mark - 选中多个联系人

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray*)contacts{
    
    NSLog(@"contactscontacts:%@",contacts);
    
    NSMutableArray *phoneArray = [NSMutableArray arrayWithCapacity:0];
    
    for(CNContact * labeledValue in contacts) {

        NSArray * phoneNumbers = labeledValue.phoneNumbers;
        
        for(CNLabeledValue * labeledValue in phoneNumbers) {

            CNPhoneNumber * phoneNumber = labeledValue.value;
            
            [phoneArray addObject:phoneNumber.stringValue];
            NSLog(@"phoneNum:----------%@", phoneNumber.stringValue);

        }

    }

}

- (void)allAgreeBtnClicked{
    NSMutableArray *seletedUsersId = [NSMutableArray new];
    for (RCDFriendInfo *user in self.friendArray) {
        [seletedUsersId addObject:user.friendID];
    }
    //好友审核状态(我发送的好友请求:0.已发送1.已通过-1.被拒绝) 别人加我的好友请求(2.正在审核中3.同意-2.拒绝)
    NSMutableArray *seletedAccoutId = [NSMutableArray new];
    for (RCDFriendInfo *user in self.friendArray) {
        if (user.status == 11) {
            [seletedAccoutId addObject:user.userId];
        }
    }
    
    [RCDUserInfoManager acceptFriendRequest:seletedUsersId
    complete:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [[NSNotificationCenter defaultCenter]
                postNotificationName:RCDContactsRequestKey
                              object:nil];
                [self getUserInfoFromServer];
                if (seletedAccoutId.count > 0) {
                    for (NSString *userID in seletedAccoutId) {
                        RCTextMessage *txtMsg = [RCTextMessage messageWithContent:@"我们已经是好友了，快来聊天吧"];
                        [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE
                        targetId:userID
                        content:txtMsg
                        pushContent:nil
                        pushData:nil
                        success:^(long messageId) {
                            dispatch_async(dispatch_get_main_queue(), ^{

                            });
                        }
                        error:^(RCErrorCode nErrorCode, long messageId){

                        }];
                    }
                }
            } else {
                [self.hud hide:YES];
            }
        });
    }];
}

- (void)agreeBtnClicked{
        // get seleted users
    NSMutableArray *seletedUsersId = [NSMutableArray new];
    NSMutableArray *selectedAccoutID = [NSMutableArray arrayWithCapacity:0];
    for (RCDFriendInfo *user in self.collectionViewResource) {
        [seletedUsersId addObject:user.friendID];
        [selectedAccoutID addObject:user.userId];
    }
    [RCDUserInfoManager acceptFriendRequest:seletedUsersId
    complete:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self getUserInfoFromServer];
                for (NSString *userID in selectedAccoutID) {
                    RCTextMessage *txtMsg = [RCTextMessage messageWithContent:@"我们已经是好友了，快来聊天吧"];
                    [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE
                    targetId:userID
                    content:txtMsg
                    pushContent:nil
                    pushData:nil
                    success:^(long messageId) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                        });
                    }
                    error:^(RCErrorCode nErrorCode, long messageId){

                    }];
                }
            } else {
                [self.hud hide:YES];
            }
        });
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.rightBtn buttonIsCanClick:YES buttonColor:[UIColor blackColor] barButtonItem:self.rightBtn];
    [self.hud hide:YES];
}

#pragma mark - Private Method
- (void)setupNavi {
    self.navigationItem.leftBarButtonItem =
        [[RCDUIBarButtonItem alloc] initWithLeftBarButton:@""//RCDLocalizedString(@"back")
                                                   target:self
                                                   action:@selector(clickBackBtn)];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

- (void)setupSubviews {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.selectedUsersCollectionView];
    [self.view addSubview:self.searchBar];
}

- (void)initData {
    self.isDeleteUser = NO;
    self.matchSearchList = [NSMutableArray new];
    self.selectUserList = [NSMutableArray new];
    self.collectionViewResource = [NSMutableArray new];
    self.allFriendsDict = [NSMutableDictionary new];
    self.allKeys = [NSMutableArray new];
    self.friendArray = [NSMutableArray new];
    self.searchContent = @"";

    if (RCDScreenWidth < 375) {
        self.maxCount = 5;
    } else if (RCDScreenWidth >= 375 && RCDScreenWidth < 414) {
        self.maxCount = 6;
    } else {
        self.maxCount = 7;
    }

    if (self.groupOptionType == RCDContactSelectedGroupOptionTypeCreate && self.orignalGroupMembers.count > 0) {
        [self.collectionViewResource addObjectsFromArray:self.orignalGroupMembers];
        [self setCollectonViewAndSearchBarFrame:self.collectionViewResource.count];
        [self.selectedUsersCollectionView reloadData];
    }
}

// 获取好友并且排序
- (void)getAllData {
//    NSMutableArray *friends = [NSMutableArray arrayWithArray:[RCDUserInfoManager getAllFriends]];
//    if (friends == nil || friends.count < 1) {
//        [self getUserInfoFromServer];
//    } else {
//        [self dealWithFriendList:friends];
//    }
    [self getUserInfoFromServer];
}

- (void)getUserInfoFromServer {
    [RCDUserInfoManager getApplyListFromServer:^(NSArray<RCDFriendInfo *> *friendList) {
        NSMutableArray *friends;
        if (friendList.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.noFriendView != nil) {
                    [self.noFriendView removeFromSuperview];
                }
            });
            friends = [friendList mutableCopy];
        }
        [self dealWithFriendList:friends];
    }];
}

- (void)dealWithFriendList:(NSMutableArray *)friends {
    self.friendArray = friends;
    if (self.friendArray.count < 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view addSubview:self.noFriendView];
            [self.view bringSubviewToFront:self.noFriendView];
        });
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self deleteGroupMembers];
            NSMutableDictionary *resultDic = [RCDUtilities sortedArrayWithPinYinDic:self.friendArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.allFriendsDict = resultDic[@"infoDic"];
                self.allKeys = resultDic[@"allKeys"];
                [self.tableView reloadData];
            });
        });
    }
}

- (void)deleteGroupMembers {
    if (self.orignalGroupMembers.count > 0 && self.groupOptionType == RCDContactSelectedGroupOptionTypeDelete) {
        self.friendArray = self.orignalGroupMembers;
    }
}

- (BOOL)isContain:(NSString *)userId {
    BOOL contain = NO;
    NSArray *userList;
    if (self.orignalGroupMembers.count > 0 && self.groupOptionType != RCDContactSelectedGroupOptionTypeDelete) {
        userList = self.orignalGroupMembers;
    }
    for (id member in userList) {
        NSString *memberId;
        if ([member isKindOfClass:[RCUserInfo class]]) {
            RCUserInfo *user = (RCUserInfo *)member;
            memberId = user.userId;
        } else {
            memberId = member;
        }
        if ([userId isEqualToString:memberId]) {
            contain = YES;
            break;
        }
    }
    return contain;
}

//设置collectionView和searchBar实时显示的frame效果
- (void)setCollectonViewAndSearchBarFrame:(NSInteger)count {
    CGRect frame = CGRectZero;
    if (count == 0) {
        //只显示searchBar
        frame = CGRectMake(0, 0, 0, 54);
        self.selectedUsersCollectionView.frame = frame;
        self.searchBar.frame = [self getSearchBarFrame:frame];
        self.searchField.leftView = self.searchFieldLeftView;
        self.searchBar.placeholder = RCDLocalizedString(@"search");
    } else if (count == 1) {
        frame = CGRectMake(0, 0, 46, 54);
        self.selectedUsersCollectionView.frame = frame;
        self.searchBar.frame = [self getSearchBarFrame:frame];
        self.searchField.leftView = nil;
    } else if (count > 1 && count <= self.maxCount) {
        if (self.isDeleteUser == NO) {
            //如果是删除选中的联系人时候的处理
            frame = CGRectMake(0, 0, 46 + (count - 1) * 46, 54);
            self.selectedUsersCollectionView.frame = frame;
            self.searchBar.frame = [self getSearchBarFrame:frame];
        } else {
            if (count < self.maxCount) {
                //判断如果当前collectionView的显示数量小于最大展示数量的时候，collectionView和searchBar的frame都会改变
                frame = CGRectMake(0, 0, 61 + (count - 1) * 46, 54);
                self.selectedUsersCollectionView.frame = frame;
                self.searchBar.frame = [self getSearchBarFrame:frame];
            }
        }
    }
}

- (CGRect)getSearchBarFrame:(CGRect)frame {
    CGRect searchBarFrame = CGRectZero;
    frame.origin.x = frame.size.width;
    CGFloat searchBarWidth = RCDScreenWidth - frame.size.width;
    frame.size.width = searchBarWidth;
    searchBarFrame = frame;
    return searchBarFrame;
}

- (void)setDefaultDisplay {
    self.isSearchResult = NO;
    [self.tableView reloadData];
    if (self.collectionViewResource.count < 1) {
        self.searchField.leftView = self.searchFieldLeftView;
    }
    self.searchBar.placeholder = RCDLocalizedString(@"search");
    self.searchBar.text = @"";
    self.searchContent = @"";
    [self.searchBar resignFirstResponder];
}

- (void)setRightButton {
    NSString *titleStr;
    if (self.selectUserList.count > 0) {
        titleStr = [NSString stringWithFormat:@"%@(%zd)", RCDLocalizedString(@"confirm"), [self.selectUserList count]];
        [self.rightBtn buttonIsCanClick:YES buttonColor:[UIColor blackColor] barButtonItem:self.rightBtn];
    } else {
        titleStr = RCDLocalizedString(@"confirm");

        [self.rightBtn
            buttonIsCanClick:YES
                 buttonColor:[RCDUtilities generateDynamicColor:[UIColor blackColor]
                                                      darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
               barButtonItem:self.rightBtn];
    }
    [self.rightBtn.button setTitle:@"添加好友" forState:UIControlStateNormal];
}

- (void)dealWithSelectUserIdListWithUser:(RCDFriendInfo *)user {
    if (self.selectUserList.count > 0) {
        RCDFriendInfo *friendInfo = self.selectUserList[0];
        if ([friendInfo.userId isEqualToString:user.userId]) {
            [self.selectUserList removeAllObjects];
        } else {
            [self.selectUserList removeAllObjects];
            [self.selectUserList addObject:user];
        }
    } else {
        [self.selectUserList addObject:user];
    }
}

- (void)showAlertViewWithMessage:(NSString *)message {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)pushChatVCWithUserInfo:(RCDFriendInfo *)userInfo {
    RCDChatViewController *chat = [[RCDChatViewController alloc] init];
    chat.targetId = userInfo.userId;
    chat.userName = userInfo.name;
    chat.conversationType = ConversationType_PRIVATE;
    chat.title = userInfo.name;
    chat.needPopToRootView = YES;
    chat.displayUserNameInCell = NO;
    [self.navigationController pushViewController:chat animated:YES];
}

- (void)closeKeyboard {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    if (self.collectionViewResource.count < 1) {
        self.searchField.leftView = self.searchFieldLeftView;
    }
    if (self.searchContent.length < 1) {
        self.searchBar.placeholder = RCDLocalizedString(@"search");
    }
    if (self.isSearchResult == YES) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setDefaultDisplay];
        });
    }
}

#pragma mark - Target Action
- (void)clickedDone:(id)sender {

    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }

    [self.rightBtn buttonIsCanClick:YES
                        buttonColor:[RCDUtilities generateDynamicColor:[UIColor blackColor]
                                                             darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                      barButtonItem:self.rightBtn];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
    [self.hud show:YES];

    if (self.isAllowsMultipleSelection == NO) {
        RCDFriendInfo *user = self.selectUserList[0];
        [self pushChatVCWithUserInfo:user];
    } else {
        // get seleted users
        NSMutableArray *seletedUsersId = [NSMutableArray new];
        NSMutableArray *selectedNames = [NSMutableArray new];
        for (RCDFriendInfo *user in self.collectionViewResource) {
            [seletedUsersId addObject:user.userId];
            [selectedNames addObject:user.name];
        }

        if (seletedUsersId.count > 0 && self.groupOptionType == RCDContactSelectedGroupOptionTypeAdd) {
            [RCDGroupManager
                addUsers:seletedUsersId
                 groupId:self.groupId
                complete:^(BOOL success, RCDGroupAddMemberStatus status){
                rcd_dispatch_main_async_safe((^{
                    [self.hud hide:YES];
                    if (success == YES) {
                        NSString *nameStr = nil;
                        for (NSString *userName in selectedNames) {
                            if (nameStr.length > 0 && nameStr != nil) {
                                nameStr = [NSString stringWithFormat:@"%@、%@",nameStr,userName];
                            }
                            else{
                                nameStr = userName;
                            }
                        }
                        
                        RCDGroupNotificationMessage *message = [RCDGroupNotificationMessage messageWithTextMsg:[NSString stringWithFormat:@"群主将%@移出群聊",nameStr]];
                        
                        [message encode];
                        
                        [[RCIMClient sharedRCIMClient]
                         sendMessage:ConversationType_GROUP
                         targetId:self.groupId
                         content:message
                         pushContent:@""
                         pushData:@""
                         success:^(long messageId) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"aaaaa");
                            });
                        }
                         error:^(RCErrorCode nErrorCode, long messageId) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"bbbbb");
                            });
                        }];
                        
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        [self showAlertViewWithMessage:RCDLocalizedString(@"add_member_fail")];
                        [self.rightBtn buttonIsCanClick:YES
                                            buttonColor:[UIColor blackColor]
                                          barButtonItem:self.rightBtn];
                    }
                    if (status == RCDGroupAddMemberStatusInviteeApproving) {
                        //                            [self.view showHUDMessage:RCDLocalizedString(@"MemberInviteNeedConfirm")];
                    } else if (status == RCDGroupAddMemberStatusOnlyManagerApproving) {
                        [self.view showHUDMessage:RCDLocalizedString(@"MemberInviteNeedManagerConfirm")];
                    }
                }))}];
            return;
        }
        if (seletedUsersId.count > 0 && self.groupOptionType == RCDContactSelectedGroupOptionTypeDelete) {
            [RCDGroupManager kickUsers:seletedUsersId
                               groupId:self.groupId
                              complete:^(BOOL success){
                rcd_dispatch_main_async_safe((^{
                    [self.hud hide:YES];
                    if (success == YES) {
                        NSString *nameStr = nil;
                        for (NSString *userName in selectedNames) {
                            if (nameStr.length > 0 && nameStr != nil) {
                                nameStr = [NSString stringWithFormat:@"%@、%@",nameStr,userName];
                            }
                            else{
                                nameStr = userName;
                            }
                        }
                        
                        RCDGroupNotificationMessage *message = [RCDGroupNotificationMessage messageWithTextMsg:[NSString stringWithFormat:@"群主将%@踢出群聊",nameStr]];
                        
                        [message encode];
                        
                        [[RCIMClient sharedRCIMClient]
                         sendMessage:ConversationType_GROUP
                         targetId:self.groupId
                         content:message
                         pushContent:@""
                         pushData:@""
                         success:^(long messageId) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"aaaaa");
                            });
                        }
                         error:^(RCErrorCode nErrorCode, long messageId) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"bbbbb");
                            });
                        }];
                        
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        [self showAlertViewWithMessage:RCDLocalizedString(@"delete_member_fail")];
                        [self.rightBtn buttonIsCanClick:YES
                                            buttonColor:[UIColor blackColor]
                                          barButtonItem:self.rightBtn];
                    }
                }))}];
            return;
        }
        if (self.groupOptionType == RCDContactSelectedGroupOptionTypeCreate) {
            [self.hud hide:YES];
            if (self.orignalGroupMembers.count > 0) {
                for (RCDFriendInfo *friend in self.orignalGroupMembers) {
                    if (![seletedUsersId containsObject:friend.userId]) {
                        [seletedUsersId addObject:friend.userId];
                    }
                }
            }

            if (seletedUsersId.count == 1 && [RCDForwardManager sharedInstance].isForward) {
                [self.rightBtn buttonIsCanClick:YES
                                    buttonColor:[UIColor blackColor]
                                  barButtonItem:self.rightBtn];
                RCConversation *conversation = [[RCConversation alloc] init];
                conversation.targetId = seletedUsersId[0];
                conversation.conversationType = ConversationType_PRIVATE;
                if ([RCDForwardManager sharedInstance].selectConversationCompleted) {
                    [RCDForwardManager sharedInstance].selectConversationCompleted([@[ conversation ] copy]);
                    [[RCDForwardManager sharedInstance] forwardEnd];
                } else {
                    [self.rightBtn buttonIsCanClick:YES buttonColor:[UIColor blackColor] barButtonItem:self.rightBtn];
                    [RCDForwardManager sharedInstance].toConversation = conversation;
                    [[RCDForwardManager sharedInstance] showForwardAlertViewInViewController:self];
                }
            } else {
                RCDCreateGroupViewController *createGroupVC = [[RCDCreateGroupViewController alloc] init];
                createGroupVC.groupMemberIdList = seletedUsersId;
                [self.navigationController pushViewController:createGroupVC animated:YES];
            }
        }
    }
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    if (self.isSearchResult == NO) {
//        return [self.allKeys count];
//    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearchResult == NO) {
//        NSString *key = [self.allKeys objectAtIndex:section];
//        NSArray *arr = [self.allFriendsDict objectForKey:key];
//        return [arr count];
        return self.friendArray.count;
    }
    return self.matchSearchList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RCDContactSelectedTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellReuseIdentifier = @"RCDContactSelectedTableViewCell";
    RCDContactSelectedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (!cell) {
        cell = [[RCDContactSelectedTableViewCell alloc] init];
    }

    RCDFriendInfo *user;
    if (self.isSearchResult == NO) {
//        NSString *key = [self.allKeys objectAtIndex:indexPath.section];
//        NSArray *arrayForKey = [self.allFriendsDict objectForKey:key];
        
//        user = arrayForKey[indexPath.row];
        user = self.friendArray[indexPath.row];
    } else {
        if (self.matchSearchList.count > 0) {
            user = [self.matchSearchList objectAtIndex:indexPath.row];
        }
    }
    __weak typeof(self) weakSelf = self;
    cell.acceptBlock = ^(NSString *friend) {
        [weakSelf acceptInvite:friend];
    };

    cell.ignoreBlock = ^(NSString *friend) {
        [weakSelf ignoreInvite:friend];
    };

    cell.groupId = self.groupId;

    //给控件填充数据
    [cell setModel:user hideRight:NO];

    //设置选中状态
    BOOL isSelected = NO;
    for (RCDFriendInfo *friendInfo in self.selectUserList) {
        if ([user.userId isEqualToString:friendInfo.userId]) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            isSelected = YES;
        }
    }
    if (isSelected == NO) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    if (user.status != 11) {
        [cell setUserInteractionEnabled:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.selectedImageView.image = [UIImage imageNamed:@"disable_select"];
        });
    }
//    if ([self isContain:user.userId] == YES) {
//        [cell setUserInteractionEnabled:NO];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            cell.selectedImageView.image = [UIImage imageNamed:@"disable_select"];
//        });
//    }
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
        
        RCDFriendInfo *user;
        if (self.isSearchResult == YES) {
            user = [self.matchSearchList objectAtIndex:indexPath.row];
        } else {
            self.selectIndexPath = indexPath;
            user = self.friendArray[indexPath.row];
        }
        
        NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"friendId":user.friendID};
        
        [SYNetworkingManager requestPUTWithURLStr:DeleteFriendApplyRecord paramDic:params success:^(NSDictionary *data) {
            if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                [self getUserInfoFromServer];
            }
        } failure:^(NSError *error) {
        }];
        
        
//        NSString *key = [self.keys objectAtIndex:indexPath.section];
//        RCUserInfo *info = [[self.mDictData objectForKey:key] objectAtIndex:indexPath.row];
//
//        __weak typeof(self) weakSelf = self;
//        [RCDUserInfoManager removeFromBlacklist:info.userId
//                                       complete:^(BOOL success) {
//                                           if (success) {
//                                               dispatch_async(dispatch_get_main_queue(), ^{
//                                                   [RCDDataSource syncFriendList];
//                                                   [weakSelf getAllData];
//                                               });
//                                           } else {
//                                               NSLog(@" ... 解除黑名单失败 ... ");
//                                           }
//                                       }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}

- (void)acceptInvite:(NSString *)userId {
    if (userId.length == 0) {
        return;
    }
    
    NSString *accountID = nil;
    for (RCDFriendInfo *user in self.friendArray) {
        if ([user.friendID isEqualToString:userId]) {
            accountID = user.userId;
        }
    }
    self.hud.labelText = RCDLocalizedString(@"adding_friend");
    [self.hud show:YES];
    [RCDUserInfoManager acceptFriendRequest:@[userId]
                                   complete:^(BOOL success) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (success) {
                                               [[NSNotificationCenter defaultCenter]
                                               postNotificationName:RCDContactsRequestKey
                                                             object:nil];
                                               [self getUserInfoFromServer];
                                               if (accountID != nil) {
                                                   RCTextMessage *txtMsg = [RCTextMessage messageWithContent:@"我们已经是好友了，快来聊天吧"];
                                                   [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE
                                                   targetId:accountID
                                                   content:txtMsg
                                                   pushContent:nil
                                                   pushData:nil
                                                   success:^(long messageId) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{

                                                       });
                                                   }
                                                   error:^(RCErrorCode nErrorCode, long messageId){

                                                   }];
                                               }
                                               [self.hud hide:YES];
                                           } else {
                                               [self.hud hide:YES];
                                           }
                                       });
                                   }];
}

- (void)ignoreInvite:(NSString *)userId {
    if (userId.length == 0) {
        return;
    }
    self.hud.labelText = RCDLocalizedString(@"IgnoreFriendRequest");
    [self.hud show:YES];
    [RCDUserInfoManager ignoreFriendRequest:userId
                                   complete:^(BOOL success) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self.hud hide:YES];
                                           if (success) {
                                               [[NSNotificationCenter defaultCenter]
                                               postNotificationName:RCDContactsRequestKey
                                                             object:nil];
                                               [self getUserInfoFromServer];
                                           } else {
                                               
                                           }
                                       });
                                   }];
}

// override delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDContactSelectedTableViewCell *cell =
        (RCDContactSelectedTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.isAllowsMultipleSelection == NO) {
        if (self.isSearchResult == YES) {
            RCDFriendInfo *user = [self.matchSearchList objectAtIndex:indexPath.row];
            [self dealWithSelectUserIdListWithUser:user];
        } else {
//            NSString *key = [self.allKeys objectAtIndex:indexPath.section];
//            NSArray *arrayForKey = [self.allFriendsDict objectForKey:key];
//            RCDFriendInfo *user = arrayForKey[indexPath.row];
            RCDFriendInfo *user = self.friendArray[indexPath.row];
            [self dealWithSelectUserIdListWithUser:user];
        }
        [self setRightButton];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } else {
        [cell setSelected:YES];
        if (self.selectIndexPath && [self.selectIndexPath compare:indexPath] == NSOrderedSame) {
            [cell setSelected:NO];
            self.selectIndexPath = nil;
        } else {
            RCDFriendInfo *user;
            if (self.isSearchResult == YES) {
                user = [self.matchSearchList objectAtIndex:indexPath.row];
            } else {
                self.selectIndexPath = indexPath;
//                NSString *key = [self.allKeys objectAtIndex:indexPath.section];
//                NSArray *arrayForKey = [self.allFriendsDict objectForKey:key];
                user = self.friendArray[indexPath.row];
            }
            
            [self.collectionViewResource addObject:user];
            NSInteger count = self.collectionViewResource.count;
            self.isDeleteUser = NO;
            [self setCollectonViewAndSearchBarFrame:count];
            [self.selectedUsersCollectionView reloadData];
            [self scrollToBottomAnimated:YES];
            [self.selectUserList addObject:user];
            [self setRightButton];
        }
        if (self.isSearchResult == YES) {
            [self setDefaultDisplay];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDContactSelectedTableViewCell *cell =
        (RCDContactSelectedTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.isAllowsMultipleSelection == YES) {
        if (self.isSearchResult == YES) {
            [self setDefaultDisplay];
            return;
        }
        [cell setSelected:NO];
        self.selectIndexPath = nil;
//        NSString *key = [self.allKeys objectAtIndex:indexPath.section];
//        NSArray *arrayForKey = [self.allFriendsDict objectForKey:key];
//        RCDFriendInfo *user = arrayForKey[indexPath.row];
        RCDFriendInfo *user = self.friendArray[indexPath.row];
        [self.collectionViewResource removeObject:user];
        [self.selectUserList removeObject:user];
        [self.selectedUsersCollectionView reloadData];
        NSInteger count = self.collectionViewResource.count;
        self.isDeleteUser = YES;
        [self setCollectonViewAndSearchBarFrame:count];
        [self setRightButton];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.isAllowsMultipleSelection == NO) {
        if ([self.searchBar isFirstResponder]) {
            [self.searchBar resignFirstResponder];
        }
    } else {
        if (self.searchField.text.length == 0 && self.searchContent.length < 1) {
            [self setDefaultDisplay];
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(36, 36);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                                 layout:(UICollectionViewLayout *)collectionViewLayout
    minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    return UIEdgeInsetsMake(10, 10, 10, 0);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.collectionViewResource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCDContactSelectedCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"RCDContactSelectedCollectionViewCell"
                                                  forIndexPath:indexPath];

    if (self.collectionViewResource.count > 0) {
        RCDFriendInfo *user = self.collectionViewResource[indexPath.row];
        [cell setUserModel:user];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self closeKeyboard];
    RCDFriendInfo *user = [self.collectionViewResource objectAtIndex:indexPath.row];
    [self.collectionViewResource removeObjectAtIndex:indexPath.row];
    [self.selectUserList removeObject:user];
    NSInteger count = self.collectionViewResource.count;
    self.isDeleteUser = YES;
    [self setCollectonViewAndSearchBarFrame:count];
    [self.selectedUsersCollectionView reloadData];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        RCDContactSelectedTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *name = user.displayName.length > 0 ? user.displayName : user.name;
        if ([cell.nicknameLabel.text isEqualToString:name]) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]
                                      withRowAnimation:UITableViewRowAnimationNone];
            });
        }
    }
    if (self.isAllowsMultipleSelection) {
        [self setRightButton];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    NSUInteger finalRow = MAX(0, [self.selectedUsersCollectionView numberOfItemsInSection:0] - 1);

    if (0 == finalRow) {
        return;
    }

    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
    [self.selectedUsersCollectionView scrollToItemAtIndexPath:finalIndexPath
                                             atScrollPosition:UICollectionViewScrollPositionRight
                                                     animated:animated];
}

#pragma mark - UISearchBarDelegate
/**
 *  执行delegate联系人
 *
 *  @param searchBar  searchBar description
 *  @param searchText searchText description
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.matchSearchList removeAllObjects];
    if ([searchText isEqualToString:@""]) {
        self.isSearchResult = NO;
        [self.tableView reloadData];
        return;
    } else {
        for (RCDFriendInfo *userInfo in [self.friendArray copy]) {
            //忽略大小写去判断是否包含
            NSString *name = userInfo.name;
            if (userInfo.displayName.length > 0) {
                name = userInfo.displayName;
            }

            RCDGroupMember *member;
            if (self.groupId.length > 0) {
                member = [RCDGroupManager getGroupMember:userInfo.userId groupId:self.groupId];
            }

            if ([name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [[RCDUtilities hanZiToPinYinWithString:name] rangeOfString:searchText options:NSCaseInsensitiveSearch]
                        .location != NSNotFound ||
                [member.groupNickname containsString:searchText]) {
                [self.matchSearchList addObject:userInfo];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isSearchResult = YES;
            [self.tableView reloadData];
        });
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if ([self.searchField.text isEqualToString:RCDLocalizedString(@"search")] ||
        [self.searchField.text isEqualToString:@"Search"]) {
        self.searchField.leftView = nil;
        self.searchField.text = @"";
    }
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if (self.collectionViewResource.count > 0) {
        self.searchField.leftView = nil;
    }
    return YES;
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if ([text isEqualToString:@""] && self.searchContent.length > 1) {
        self.searchContent = [self.searchContent substringWithRange:NSMakeRange(0, self.searchContent.length - 1)];
    } else if ([text isEqualToString:@""] && self.searchContent.length == 1) {
        self.searchContent = @"";
        self.isSearchResult = NO;
        [self.tableView reloadData];
        return YES;
    } else if ([text isEqualToString:@"\n"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchBar resignFirstResponder];
        });
        return YES;
    } else {
        self.searchContent = [NSString stringWithFormat:@"%@%@", self.searchContent, text];
    }
    [self.matchSearchList removeAllObjects];
    NSString *temp = [self.searchContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (temp.length <= 0) {
        self.matchSearchList = [self.friendArray mutableCopy];
    } else {
        for (RCDFriendInfo *userInfo in [self.friendArray copy]) {
            NSString *name = userInfo.name;
            if ([userInfo isMemberOfClass:[RCDFriendInfo class]] && userInfo.displayName.length > 0) {
                name = userInfo.displayName;
            }
            //忽略大小写去判断是否包含
            if ([name rangeOfString:temp options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [[RCDUtilities hanZiToPinYinWithString:name] rangeOfString:temp options:NSCaseInsensitiveSearch]
                        .location != NSNotFound) {
                [self.matchSearchList addObject:userInfo];
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isSearchResult = YES;
        [self.tableView reloadData];
    });
    return YES;
}

#pragma mark - Setter && Getter
- (RCDUIBarButtonItem *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [[RCDUIBarButtonItem alloc] initWithbuttonTitle:@"添加好友"
                                                         titleColor:[UIColor blackColor]
                                                        buttonFrame:CGRectMake(0, 0, 90, 30)
                                                             target:self
                                                             action:@selector(addNewFriend)];
        _rightBtn.button.titleLabel.font = [UIFont systemFontOfSize:16];
        [_rightBtn.button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
        [_rightBtn buttonIsCanClick:YES
                        buttonColor:[RCDUtilities generateDynamicColor:[UIColor blackColor]
                                                             darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                      barButtonItem:_rightBtn];
    }
    return _rightBtn;
}


- (RCDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[RCDTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.frame =
            CGRectMake(0, 54, RCDScreenWidth, RCDScreenHeight - 64 - 54 - RCDExtraTopHeight - RCDExtraBottomHeight);
        if ([_tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
            _tableView.cellLayoutMarginsFollowReadableWidth = NO;
        }
        UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, 1)];
        separatorLine.backgroundColor = [RCKitUtility
            generateDynamicColor:[UIColor colorWithRed:230 / 255.0 green:230 / 255.0 blue:230 / 255.0 alpha:1]
                       darkColor:HEXCOLOR(0x1a1a1a)];
        _tableView.tableHeaderView = separatorLine;
        _tableView.allowsMultipleSelection = _isAllowsMultipleSelection;
    }
    return _tableView;
}

- (UICollectionView *)selectedUsersCollectionView {
    if (!_selectedUsersCollectionView) {
        CGRect tempRect = CGRectMake(0, 0, 0, 54);
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _selectedUsersCollectionView =
            [[UICollectionView alloc] initWithFrame:tempRect collectionViewLayout:flowLayout];
        _selectedUsersCollectionView.delegate = self;
        _selectedUsersCollectionView.dataSource = self;
        _selectedUsersCollectionView.scrollEnabled = YES;
        _selectedUsersCollectionView.backgroundColor = RCDDYCOLOR(0xffffff, 0x000000);
        [_selectedUsersCollectionView registerClass:[RCDContactSelectedCollectionViewCell class]
                         forCellWithReuseIdentifier:@"RCDContactSelectedCollectionViewCell"];
        _selectedUsersCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _selectedUsersCollectionView;
}

- (RCDSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[RCDSearchBar alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, 54)];
        _searchBar.placeholder = NSLocalizedStringFromTable(@"ToSearch", @"RongCloudKit", nil);
        [_searchBar setDelegate:self];
        [_searchBar setKeyboardType:UIKeyboardTypeDefault];
    }
    return _searchBar;
}

- (RCDNoFriendView *)noFriendView {
    if (!_noFriendView) {
//        _noFriendView = [[RCDNoFriendView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, RCDScreenHeight - 64)];
//        _noFriendView.displayLabel.text = RCDLocalizedString(@"no_friend");
    }
    return _noFriendView;
}
@end
