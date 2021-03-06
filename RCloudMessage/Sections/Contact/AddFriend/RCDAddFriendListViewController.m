//
//  RCDAddFriendListViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/7/9.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDAddFriendListViewController.h"
#import "RCDAddFriendListCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+RCColor.h"
#import "RCDQRCodeController.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDSearchBar.h"
#import "RCDSearchFriendController.h"
#import "RCDScanQRCodeController.h"
#import "RCDSelectAddressBookViewController.h"
#import "RCDAddressBookFriendsViewController.h"
#import "UIView+MBProgressHUD.h"
#import "RCDMyQRCodeView.h"
#import "RCDForwardSelectedViewController.h"
#import "RCDTableView.h"
#import "RCDCommonString.h"
#import <ContactsUI/ContactsUI.h>
#import "AddContactFriendsTableViewController.h"
#define RCDAddFriendListCellIdentifier @"RCDAddFriendListCell"

@interface RCDAddFriendListViewController () <UITableViewDelegate, UITableViewDataSource,
                                              UISearchBarDelegate, RCDMyQRCodeViewDelegate>

@property (nonatomic, strong) RCDSearchBar *searchBar;

@property (nonatomic, strong) UIView *myQRCodeView;
@property (nonatomic, strong) UILabel *myQRCodeLabel;
@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) RCDTableView *tableView;

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *detailArray;

@property (nonatomic, strong) RCDMyQRCodeView *QRCodeView;
@property (nonatomic, strong) NSMutableArray *phoneList;

@end

@implementation RCDAddFriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneList = [NSMutableArray arrayWithCapacity:0];
    [self setupNavi];
    [self setupUI];
    [self setupData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDAddFriendListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RCDAddFriendListCellIdentifier];
    if (cell == nil) {
        cell = [[RCDAddFriendListCell alloc] init];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.headerImgView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    cell.titleLabel.text = RCDLocalizedString(self.titleArray[indexPath.row]);
    cell.detailLabel.text = RCDLocalizedString(self.detailArray[indexPath.row]);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
    case 0: {
        [self getMailListAction];
//        RCDAddressBookFriendsViewController *vc = [[RCDAddressBookFriendsViewController alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
    } break;
    case 1: {
        RCDScanQRCodeController *qrcodeVC = [[RCDScanQRCodeController alloc] init];
        [self.navigationController pushViewController:qrcodeVC animated:YES];
    } break;
    case 2: {
        [self shareUrlToWeChat];
//        [self showAlert:RCDLocalizedString(@"InviteWeChatFriend")
//                   message:RCDLocalizedString(@"ToInviteWeChatFriend")
//            cancelBtnTitle:RCDLocalizedString(@"cancel")
//             otherBtnTitle:RCDLocalizedString(@"ConfirmBtnTitle")];
    } break;
    case 3: {
        RCDSelectAddressBookViewController *vc = [[RCDSelectAddressBookViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } break;
    default:
        break;
    }
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
        AddContactFriendsTableViewController *nextVC = [[AddContactFriendsTableViewController alloc] init];
        nextVC.phoneMembers = self.phoneList;
        [self.navigationController pushViewController:nextVC animated:YES];
    }
    
}


#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    RCDSearchFriendController *searchFirendVC = [[RCDSearchFriendController alloc] init];
    [self.navigationController pushViewController:searchFirendVC animated:YES];
    return NO;
}

#pragma mark - RCDWeChatManagerDelegate
- (void)wxSharedSucceed {
    [self.view showHUDMessage:RCDLocalizedString(@"ShareSuccess")];
}

- (void)wxSharedFailure {
    [self.view showHUDMessage:RCDLocalizedString(@"ShareFailure")];
}

#pragma mark - RCDMyQRCodeViewDelegate
- (void)myQRCodeViewShareSealTalk {
    RCDForwardSelectedViewController *forwardSelectedVC = [[RCDForwardSelectedViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:forwardSelectedVC];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:navi animated:YES completion:nil];
}

#pragma mark - Private Method
- (void)setupNavi {
    self.navigationItem.title = RCDLocalizedString(@"add_contacts");
}

- (void)setupUI {
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.myQRCodeView];
    [self.view addSubview:self.tableView];

    [self.myQRCodeView addSubview:self.myQRCodeLabel];
    [self.myQRCodeView addSubview:self.imgView];

    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.offset(44);
    }];

    [self.myQRCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(44);
        make.left.right.equalTo(self.view);
        make.height.offset(44);
    }];

    [self.myQRCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.myQRCodeView);
        make.height.offset(20);
    }];

    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.myQRCodeLabel.mas_right).offset(5);
        make.centerY.equalTo(self.myQRCodeLabel);
        make.height.width.offset(12);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(88);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)setupData {
    self.imageArray = @[ @"add_phonebook", @"add_scan", @"add_wechat", @"add_invite_phonebook" ];
    self.titleArray = @[ @"Phonebook_Title", @"Scan_Title", @"Wx_Title", @"Invite_Phonebook_Title" ];
    self.detailArray = @[ @"Phonebook_Detail", @"Scan_Detail", @"Wx_Detail", @"Invite_Phonebook_Detail" ];
}

- (void)showAlert:(NSString *)title
          message:(NSString *)message
   cancelBtnTitle:(NSString *)cBtnTitle
    otherBtnTitle:(NSString *)oBtnTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController
            addAction:[UIAlertAction actionWithTitle:cBtnTitle style:UIAlertActionStyleDefault handler:nil]];
        if (oBtnTitle) {
            [alertController addAction:[UIAlertAction actionWithTitle:oBtnTitle
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *_Nonnull action) {
                                                                    
                                                                  [self shareUrlToWeChat];
                                                              }]];
        }
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)shareUrlToWeChat {
    RCDQRCodeController *qrCodeVC =
    [[RCDQRCodeController alloc] initWithTargetId:[RCIM sharedRCIM].currentUserInfo.userId
                                 conversationType:ConversationType_PRIVATE];
    UIImage *img = [qrCodeVC captureCurrent];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIImage *aimg = [qrCodeVC captureCurrent];
        if (aimg == nil) {
            return;
        }
        
        NSArray *activityItems = @[aimg];

        UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems
                                                                                    applicationActivities:nil];

        activityVC.completionWithItemsHandler = ^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){

                NSLog(@" 111activityType = %@ \n completed = %d",activityType,completed);

                if (completed) {

                    if ([activityType isEqualToString:@"com.tencent.xin.sharetimeline"]) {

                        NSLog(@"分享有效");

                    }

                }

            };

            activityVC.excludedActivityTypes = @[   //除去的分享平台
                                                 UIActivityTypePostToFacebook
                                                 ,UIActivityTypePostToTwitter
                                                 ,UIActivityTypePostToWeibo
                                                 ,UIActivityTypeMessage
                                                 ,UIActivityTypeMail
                                                 ,UIActivityTypePrint
                                                 ,UIActivityTypeCopyToPasteboard
                                                 ,UIActivityTypeAssignToContact
                                                 ,UIActivityTypeSaveToCameraRoll
                                                 ,UIActivityTypeAddToReadingList
                                                 ,UIActivityTypePostToFlickr
                                                 ,UIActivityTypePostToVimeo
                                                 ,UIActivityTypeAirDrop
                                                 ,UIActivityTypeOpenInIBooks
                                                 ,UIActivityTypePostToTencentWeibo
                                                 ];

            [self presentViewController:activityVC animated:TRUE completion:nil];
    });
    
//    NSString *textToShare = @"分享分享分享分享";

//    UIGraphicsBeginImageContext([UIScreen mainScreen].bounds.size);//设置截屏的范围，起点为当前视图的（0，0，0，0）
//    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *screenShotImage=UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    UIImage *imageToShare = screenShotImage;//截取的当前屏幕的图片可以作为如下imageToShare图片分享出去

    
    
//    UIImage *logoImage = [UIImage imageNamed:@"57x57_logo"];
//    if ([RCDWeChatManager weChatCanShared]) {
//        [[RCDWeChatManager sharedManager] sendLinkContent:RCDQRCodeContentInfoUrl
//                                                    title:RCDLocalizedString(@"WXShare_RC_Title")
//                                              description:RCDLocalizedString(@"WXShare_RC_Detail")
//                                               thumbImage:logoImage
//                                                  atScene:WXSceneSession];
//    } else {
//        [self showAlert:nil
//                   message:RCDLocalizedString(@"NotInstalledWeChat")
//            cancelBtnTitle:RCDLocalizedString(@"ConfirmBtnTitle")
//             otherBtnTitle:nil];
//    }
}

#pragma mark - Target Action
- (void)tapMyQRCode {

    [self.QRCodeView show];

    [UIView animateWithDuration:0.2
                     animations:^{
                         self.QRCodeView.hidden = NO;
                     }];
}

#pragma mark - Setter && Getter
- (RCDSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[RCDSearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.placeholder = RCDLocalizedString(@"PhoneOrSealTalkNumber");
    }
    return _searchBar;
}

- (UIView *)myQRCodeView {
    if (!_myQRCodeView) {
        _myQRCodeView = [[UIView alloc] init];
        _myQRCodeView.userInteractionEnabled = YES;

        UITapGestureRecognizer *tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMyQRCode)];
        [_myQRCodeView addGestureRecognizer:tap];
    }
    return _myQRCodeView;
}

- (UILabel *)myQRCodeLabel {
    if (!_myQRCodeLabel) {
        _myQRCodeLabel = [[UILabel alloc] init];
        _myQRCodeLabel.font = [UIFont systemFontOfSize:14];
        _myQRCodeLabel.textColor = RCDDYCOLOR(0x333333, 0x9f9f9f);
        _myQRCodeLabel.text = RCDLocalizedString(@"My_QR");
    }
    return _myQRCodeLabel;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.image = [UIImage imageNamed:@"add_qr_code"];
    }
    return _imgView;
}

- (RCDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[RCDTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (RCDMyQRCodeView *)QRCodeView {
    if (!_QRCodeView) {
        _QRCodeView = [[RCDMyQRCodeView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
//        _QRCodeView.backgroundColor = [UIColor redColor];
        _QRCodeView.hidden = YES;
        _QRCodeView.delegate = self;
    }
    return _QRCodeView;
}

@end
