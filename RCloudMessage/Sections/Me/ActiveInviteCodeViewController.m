//
//  ActiveInviteCodeViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/24.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "ActiveInviteCodeViewController.h"
#import "RCDUserInfoManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDChatViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDUIBarButtonItem.h"
#import "UIColor+RCColor.h"
#import "RCDCommonString.h"

@interface ActiveInviteCodeViewController()

@property (nonatomic, strong) UITextField *userNameTextField;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) NSDictionary *subViews;
@property (nonatomic, strong) RCDUIBarButtonItem *rightBtn;
@property (nonatomic, strong) RCDUIBarButtonItem *leftBtn;
@property (nonatomic, strong) NSString *originNickName;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ActiveInviteCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    NSString *currentUserId = [RCIM sharedRCIM].currentUserInfo.userId;
    [[RCDRCIMDataSource sharedInstance] getUserInfoWithUserId:currentUserId
                                                   completion:^(RCUserInfo *userInfo) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
//                                                           self.userNameTextField.text = userInfo.name;
//                                                           self.originNickName = userInfo.name;
                                                       });
                                                   }];
}

- (void)updateCurrentUserInfo:(NSString *)name {
    [DEFAULTS setObject:name forKey:InviteCode];
    [DEFAULTS synchronize];
}

- (void)saveUserName:(id)sender {
    if ([self checkUserName]) {
        __weak __typeof(self) weakSelf = self;
        NSString *name = self.userNameTextField.text;
        [self.hud show:YES];
        
        NSDictionary *params = @{@"userAccountId":[ProfileUtil getUserAccountID],@"inviterId":name};
        [SYNetworkingManager requestPUTWithURLStr:ActiveInviteCode paramDic:params success:^(NSDictionary *data) {
            [self.hud hideAnimated:YES];
            if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                [weakSelf updateCurrentUserInfo:name];
                if (self.sendCallBack) {
                    self.sendCallBack();
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else{
                [self showAlertViewWithMessage:[data stringValueForKey:@"message"]];
            }
        } failure:^(NSError *error) {
            [weakSelf.hud hide:YES];
            [weakSelf showAlert:@"邀请码有误"
                 cancelBtnTitle:RCDLocalizedString(@"confirm")];
        }];
        
//        [RCDUserInfoManager setCurrentUserName:name
//                                      complete:^(BOOL success) {
//                                          dispatch_async(dispatch_get_main_queue(), ^{
//                                              if (success) {
//                                                  [weakSelf updateCurrentUserInfo:name];
//                                                  [weakSelf.navigationController popViewControllerAnimated:YES];
//                                              } else {
//                                                  [weakSelf.hud hide:YES];
//                                                  [weakSelf showAlert:RCDLocalizedString(@"modify_nickname_fail")
//                                                       cancelBtnTitle:RCDLocalizedString(@"confirm")];
//                                              }
//                                          });
//                                      }];
    }
}

- (BOOL)checkUserName {
    NSString *errorMsg = @"";
    if (self.userNameTextField.text.length == 0) {
        errorMsg = RCDLocalizedString(@"username_can_not_nil");
    } else if (self.userNameTextField.text.length > 32) {
        errorMsg = RCDLocalizedString(@"Username_cannot_be_greater_than_32_digits");
    }
    BOOL lagel = YES;
    if ([errorMsg length] > 0) {
        lagel = NO;
        [self showAlert:errorMsg cancelBtnTitle:RCDLocalizedString(@"confirm")];
    }
    return lagel;
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)beginEditNickname {
    [self.userNameTextField becomeFirstResponder];
}

- (void)textFieldDidChange:(UITextField *)textField {
    NSString *toBeString = textField.text;
    if (![toBeString isEqualToString:self.originNickName]) {
        [self.rightBtn buttonIsCanClick:YES buttonColor:[UIColor blackColor] barButtonItem:self.rightBtn];
    } else {
        [self.rightBtn
            buttonIsCanClick:NO
                 buttonColor:[FPStyleGuide lightGrayTextColor]
               barButtonItem:self.rightBtn];
    }
}

- (void)showAlert:(NSString *)message cancelBtnTitle:(NSString *)cBtnTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController
            addAction:[UIAlertAction actionWithTitle:cBtnTitle style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)initUI {
    [self setNavigationButton];
    [self setSubViews];
    self.navigationItem.title = @"激活邀请码";
}

- (void)setNavigationButton {
    self.leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:@""//RCDLocalizedString(@"back")
                                                              target:self
                                                              action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = self.leftBtn;

    self.rightBtn = [[RCDUIBarButtonItem alloc]
        initWithbuttonTitle:@"激活"
                 titleColor:[UIColor blackColor]
                buttonFrame:CGRectMake(0, 0, 50, 30)
                     target:self
                     action:@selector(saveUserName:)];
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[FPStyleGuide lightGrayTextColor]
                      barButtonItem:self.rightBtn];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

- (void)setSubViews {
    self.bgView = [UIView new];
    self.bgView.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                           darkColor:[HEXCOLOR(0x808080) colorWithAlphaComponent:0.2]];
    self.bgView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.bgView];

    UITapGestureRecognizer *clickbgView =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginEditNickname)];
    [self.bgView addGestureRecognizer:clickbgView];

    self.userNameTextField = [UITextField new];
    self.userNameTextField.borderStyle = UITextBorderStyleNone;
    self.userNameTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.userNameTextField.font = [UIFont systemFontOfSize:16.f];
    self.userNameTextField.textColor = RCDDYCOLOR(0x000000, 0x999999);
    self.userNameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.userNameTextField addTarget:self
                               action:@selector(textFieldDidChange:)
                     forControlEvents:UIControlEventEditingChanged];
    [self.bgView addSubview:self.userNameTextField];

    self.subViews = NSDictionaryOfVariableBindings(_bgView, _userNameTextField);

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_bgView(44)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.subViews]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bgView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.subViews]];

    [self.bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-9-[_userNameTextField]-3-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:self.subViews]];

    [self.bgView addConstraint:[NSLayoutConstraint constraintWithItem:_userNameTextField
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.bgView
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1
                                                             constant:0]];
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"激活中...";
        _hud = hud;
    }
    return _hud;
}

- (void)showAlertViewWithMessage:(NSString *)message {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
