//
//  LoginViewController.m
//  RongCloud
//
//  Created by Liv on 14/11/5.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//
#import "RCDLoginViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDCommonDefine.h"
#import "RCDFindPswViewController.h"
#import "RCDMainTabBarViewController.h"
#import "RCDNavigationViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDRegisterViewController.h"
#import "RCDTextFieldValidate.h"
#import "RCDUtilities.h"
#import "RCUnderlineTextField.h"
#import "UIColor+RCColor.h"
#import "UITextFiled+Shake.h"
#import "RCDIndicateTextField.h"
#import "RCDCountryListController.h"
#import "RCDCountry.h"
#import "RCDLanguageManager.h"
#import "AppDelegate.h"
#import "RCDBuglyManager.h"
#import "RCDLoginManager.h"
#import "RCDCommonString.h"
#import "RCDUserInfoManager.h"
#import "RCDIMService.h"
#import "NSUserDefaults+Category.h"
#import "WKWebViewController.h"

#define UserTextFieldTag 1000
#define PassWordFieldTag 1001

@interface RCDLoginViewController () <UITextFieldDelegate, RCDCountryListControllerDelegate>

@property (nonatomic, strong) RCAnimatedImagesView *animatedImagesView;
@property (nonatomic, strong) RCDIndicateTextField *countryTextField;
@property (nonatomic, strong) RCDIndicateTextField *phoneTextField;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) NSTimer *retryTimer;
@property (nonatomic, strong) UIImageView *rongLogoView;//about_rong
@property (nonatomic, strong) UIView *inputBackground;
@property (nonatomic, strong) UIView *bottomBackground;
@property (nonatomic, strong) UILabel *errorMsgLb;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *settingButton;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIView *userProtocolButton;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIButton *forgetPswButton;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, assign) int loginFailureTimes;
@property (nonatomic, strong) NSString *loginUserName;
@property (nonatomic, strong) NSString *loginUserId;
@property (nonatomic, strong) NSString *loginToken;
@property (nonatomic, strong) NSString *loginPassword;
@property (nonatomic, strong) RCDCountry *currentRegion;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *chatLabel;
@property (nonatomic, strong) RCUnderlineTextField *verificationCodeField;
@property (nonatomic, strong) UIButton *sendCodeButton;
@property (nonatomic, strong) UILabel *vCodeTimerLb;
@property (nonatomic, strong) NSTimer *countDownTimer;
@property (nonatomic, assign) int seconds;

@end

@implementation RCDLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);//[UIColor whiteColor];//
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    self.currentRegion = [[RCDCountry alloc] initWithDict:[DEFAULTS objectForKey:RCDCurrentCountryKey]];
    self.loginFailureTimes = 0;
    [self initSubviews];
    [self setLayout];
    [self addNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
//    [self.animatedImagesView startAnimating];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopRetryTimerIfNeed];
//    [self.animatedImagesView stopAnimating];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidUnload {
    [self setAnimatedImagesView:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - action
- (void)loginEvent:(id)sender {
    [self startRetryTimer];

    NSString *userName = self.phoneTextField.textField.text;
    NSString *userPwd = self.passwordTextField.text;

    [self login:userName password:userPwd];
}

- (void)login:(NSString *)userName password:(NSString *)password {

    RCNetworkStatus status = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];

    if (RC_NotReachable == status) {
        self.errorMsgLb.text = RCDLocalizedString(@"network_can_not_use_please_check");
        return;
    } else {
        self.errorMsgLb.text = @"";
    }

    if ([self validateUserName:userName userPwd:password]) {
        self.hud.labelText = RCDLocalizedString(@"logining");
        [self.hud show:YES];
        [DEFAULTS removeObjectForKey:RCDUserCookiesKey];
        
        [RCDLoginManager loginWithPhone:userName
            password:password
            region:self.currentRegion.phoneCode
            success:^(NSString *_Nonnull token, NSString *_Nonnull userId) {
                [self loginRongCloud:userName userId:userId token:token password:password];
            }
            error:^(RCDLoginErrorCode errorCode) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.hud hide:YES];
                    if (errorCode == RCDLoginErrorCodeWrongPassword) {
                        self.errorMsgLb.text = RCDLocalizedString(@"mobile_number_or_password_error");
                        [self.pwdTextField shake];
                    } else if (errorCode == RCDLoginErrorCodeUserNotRegistered) {
                        self.errorMsgLb.text = RCDLocalizedString(@"UserNotRegistered");
                    } else {
                        self.errorMsgLb.text = RCDLocalizedString(@"Login_fail_please_check_network");
                    }
                });
            }];
    } else {
        self.errorMsgLb.text = RCDLocalizedString(@"please_check_mobile_number_and_password");
    }
}

- (void)loginSuccess:(NSString *)userName
              userId:(NSString *)userId
               token:(NSString *)token
            password:(NSString *)password {
    [self stopRetryTimerIfNeed];
    [DEFAULTS setObject:userName forKey:RCDUserNameKey];
    [DEFAULTS setObject:password forKey:RCDUserPasswordKey];
    [DEFAULTS setObject:token forKey:RCDIMTokenKey];
    [DEFAULTS setObject:userId forKey:RCDUserIdKey];
    [DEFAULTS synchronize];
    
    MProfile *profile = [[MProfile alloc] initWithDictionary:[ProfileUtil getUserInfo]];
    RCDUserInfo *userInfo = [[RCDUserInfo alloc] initWithUserId:profile.userId name:profile.nickName portrait:profile.avaterUrl];
    [RCIM sharedRCIM].currentUserInfo = userInfo;
    [RCDBuglyManager
        setUserIdentifier:[NSString stringWithFormat:@"%@ - %@", userInfo.userId, userInfo.name]];
    [DEFAULTS setObject:userInfo.portraitUri forKey:RCDUserPortraitUriKey];
    [DEFAULTS setObject:userInfo.name forKey:RCDUserNickNameKey];
//    [DEFAULTS setObject:userInfo.stAccount forKey:RCDSealTalkNumberKey];
    if ([userInfo.gender isEqualToString:@"1"]) {
        [DEFAULTS setObject:@"female" forKey:RCDUserGenderKey];
    }
    else if ([userInfo.gender isEqualToString:@"2"]) {
        [DEFAULTS setObject:@"male" forKey:RCDUserGenderKey];
    }
    
    [DEFAULTS synchronize];
//    [RCDUserInfoManager
//        getUserInfoFromServer:userId
//                     complete:^(RCDUserInfo *userInfo) {
//                         [RCIM sharedRCIM].currentUserInfo = userInfo;
//                         [RCDBuglyManager
//                             setUserIdentifier:[NSString stringWithFormat:@"%@ - %@", userInfo.userId, userInfo.name]];
//                         [DEFAULTS setObject:userInfo.portraitUri forKey:RCDUserPortraitUriKey];
//                         [DEFAULTS setObject:userInfo.name forKey:RCDUserNickNameKey];
//                         [DEFAULTS setObject:userInfo.stAccount forKey:RCDSealTalkNumberKey];
//                         [DEFAULTS setObject:userInfo.gender forKey:RCDUserGenderKey];
//                         [DEFAULTS synchronize];
//                     }];

    [RCDDataSource syncAllData];
    dispatch_async(dispatch_get_main_queue(), ^{
        RCDMainTabBarViewController *mainTabBarVC = [[RCDMainTabBarViewController alloc] init];
        RCDNavigationViewController *rootNavi =
            [[RCDNavigationViewController alloc] initWithRootViewController:mainTabBarVC];
        [UIApplication sharedApplication].delegate.window.rootViewController = rootNavi;
    });
}

- (void)loginRongCloud:(NSString *)userName
                userId:(NSString *)userId
                 token:(NSString *)token
              password:(NSString *)password {
    self.loginUserName = userName;
    self.loginUserId = userId;
    self.loginToken = token;
    self.loginPassword = password;

    [[RCDIMService sharedService] connectWithToken:token
        dbOpened:^(RCDBErrorCode code) {
            NSLog(@"RCDBOpened %@", code ? @"failed" : @"success");
        }
        success:^(NSString *userId) {
            NSLog([NSString stringWithFormat:@"token is %@  userId is %@", token, userId], nil);
            self.loginUserId = userId;
            [self loginSuccess:self.loginUserName
                        userId:self.loginUserId
                         token:self.loginToken
                      password:self.loginPassword];
        }
        error:^(RCConnectErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hud hide:YES];
                NSLog(@"RCConnectErrorCode is %ld", (long)status);
                _errorMsgLb.text =
                    [NSString stringWithFormat:@"%@ Status: %zd", RCDLocalizedString(@"Login_fail"), status];
                [_pwdTextField shake];
            });
        }
        tokenIncorrect:^{
            NSLog(@"IncorrectToken");

            if (self.loginFailureTimes < 1) {
                self.loginFailureTimes++;
                [RCDLoginManager getToken:^(BOOL success, NSString *_Nonnull token, NSString *_Nonnull userId) {
                    if (success) {
                        [self loginRongCloud:userName userId:userId token:token password:password];
                    } else {
                        rcd_dispatch_main_async_safe(^{
                            [self.hud hide:YES];
                            NSLog(@"Token无效");
                            _errorMsgLb.text = RCDLocalizedString(@"can_not_connect_server");
                        });
                    }
                }];
            }
        }];
}

/*阅读用户协议*/
- (void)userProtocolEvent {
}

/*注册*/
- (void)registerEvent {
    RCDRegisterViewController *temp = [[RCDRegisterViewController alloc] init];
    [self.navigationController pushViewController:temp animated:YES];
}

/*找回密码*/
- (void)forgetPswEvent {
    RCDFindPswViewController *temp = [[RCDFindPswViewController alloc] init];
    [self.navigationController pushViewController:temp animated:YES];
}

// timer
- (void)retryConnectionFailed {
    [[RCIM sharedRCIM] disconnect];
    [self stopRetryTimerIfNeed];
    [self.hud hide:YES];
}

- (void)didTapCountryTextField {
    RCDCountryListController *countryListVC = [[RCDCountryListController alloc] init];
    countryListVC.delegate = self;
    [self.navigationController pushViewController:countryListVC animated:YES];
}

- (void)didTapSwitchLanguage:(UIButton *)button {
    NSString *currentLanguage = [RCDLanguageManager sharedRCDLanguageManager].currentLanguage;
    if ([currentLanguage isEqualToString:@"en"]) {
        [[RCDLanguageManager sharedRCDLanguageManager] setLocalizableLanguage:@"zh-Hans"];
    } else if ([currentLanguage isEqualToString:@"zh-Hans"]) {
        [[RCDLanguageManager sharedRCDLanguageManager] setLocalizableLanguage:@"en"];
    }
    RCDLoginViewController *temp = [[RCDLoginViewController alloc] init];
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;        //可更改为其他方式
    transition.subtype = kCATransitionFromLeft; //可更改为其他方式
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:temp animated:NO];
}

#pragma mark - RCDCountryListControllerDelegate
- (void)fetchCountryPhoneCode:(RCDCountry *)country {
    [DEFAULTS setObject:[country getModelJson] forKey:RCDCurrentCountryKey];
    self.currentRegion = country;
    self.countryTextField.textField.text = country.countryName;
    self.phoneTextField.indicateInfoLabel.text = [NSString stringWithFormat:@"+%@", self.currentRegion.phoneCode];
}

#pragma mark UITextFieldDelegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    switch (textField.tag) {
    case UserTextFieldTag:
        [DEFAULTS removeObjectForKey:RCDUserNameKey];
        self.passwordTextField.text = nil;
    case PassWordFieldTag:
        [DEFAULTS removeObjectForKey:RCDUserPasswordKey];
        break;
    default:
        break;
    }
    return YES;
}

//验证用户信息格式
- (BOOL)validateUserName:(NSString *)userName userPwd:(NSString *)userPwd {
    NSString *alertMessage = nil;
    if (userName.length == 0) {
        alertMessage = RCDLocalizedString(@"username_can_not_nil");
    } else if (userPwd.length == 0) {
        alertMessage = RCDLocalizedString(@"password_can_not_nil");
    }

    if (alertMessage) {
        _errorMsgLb.text = alertMessage;
        [_pwdTextField shake];
        return NO;
    }
    if ([RCDTextFieldValidate validatePassword:userPwd] == NO) {
        return NO;
    }
    return YES;
}

- (NSUInteger)animatedImagesNumberOfImages:(RCAnimatedImagesView *)animatedImagesView {
    return 2;
}

- (UIImage *)animatedImagesView:(RCAnimatedImagesView *)animatedImagesView imageAtIndex:(NSUInteger)index {
    return [UIImage imageNamed:@""];//login_background.png
}

/*获取用户账号*/
- (NSString *)getDefaultUserName {
    NSString *defaultUser = [DEFAULTS objectForKey:RCDUserNameKey];
    return defaultUser;
}

/*获取用户密码*/
- (NSString *)getDefaultUserPwd {
    NSString *defaultUserPwd = [DEFAULTS objectForKey:RCDUserPasswordKey];
    return defaultUserPwd;
}

// timer
- (void)stopRetryTimerIfNeed {
    if (self.retryTimer && [self.retryTimer isValid]) {
        [self.retryTimer invalidate];
        self.retryTimer = nil;
    }
}

- (void)startRetryTimer {
    [self stopRetryTimerIfNeed];
    self.retryTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                       target:self
                                                     selector:@selector(retryConnectionFailed)
                                                     userInfo:nil
                                                      repeats:NO];
}

//键盘升起时动画
- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect keyboardBounds = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat space =
        self.inputBackground.frame.origin.y + CGRectGetMaxY(self.passwordTextField.frame) - keyboardBounds.origin.y;
    if (space > 0) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.view.frame =
                                 CGRectMake(0.f, -space, self.view.frame.size.width, self.view.frame.size.height);
                         }
                         completion:nil];
    }
}

//键盘关闭时动画
- (void)keyboardWillHide:(NSNotification *)notif {
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.frame =
                             CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:nil];
}

- (void)didConnectStatusUpdate:(NSNotification *)notifi {
    RCConnectionStatus status = [notifi.object integerValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == ConnectionStatus_Connected) {
            [RCIM sharedRCIM].connectionStatusDelegate =
                (id<RCIMConnectionStatusDelegate>)[UIApplication sharedApplication].delegate;
            [self loginSuccess:self.loginUserName
                        userId:self.loginUserId
                         token:self.loginToken
                      password:self.loginPassword];
        } else if (status == ConnectionStatus_NETWORK_UNAVAILABLE) {
            self.errorMsgLb.text = RCDLocalizedString(@"network_can_not_use_please_check");
        } else if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
            self.errorMsgLb.text = RCDLocalizedString(@"accout_kicked");
        } else if (status == ConnectionStatus_TOKEN_INCORRECT) {
            NSLog(@"Token无效");
            self.errorMsgLb.text = RCDLocalizedString(@"can_not_connect_server");
            if (self.loginFailureTimes < 1) {
                self.loginFailureTimes++;
                [RCDLoginManager getToken:^(BOOL success, NSString *_Nonnull token, NSString *_Nonnull userId) {
                    if (success) {
                        [self loginRongCloud:self.loginUserName userId:userId token:token password:self.loginPassword];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.hud hide:YES];
                            NSLog(@"Token无效");
                            self.errorMsgLb.text = RCDLocalizedString(@"can_not_connect_server");
                        });
                    }
                }];
            }
        } else {
            NSLog(@"RCConnectErrorCode is %zd", status);
        }
    });
}

#pragma mark - private method

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectStatusUpdate:)
                                                 name:RCKitDispatchConnectionStatusChangedNotification
                                               object:nil];
}

- (void)initSubviews {
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    //添加动态图
    [self.view addSubview:self.animatedImagesView];
    [self.animatedImagesView addSubview:[self getSwitchLanguageBtn]];
    [self.view addSubview:self.rongLogoView];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.chatLabel];
    //中部内容输入区
    [self.view addSubview:self.inputBackground];
    [self.view addSubview:self.errorMsgLb];
//    [self.inputBackground addSubview:self.countryTextField];
    //用户名
    self.phoneTextField.textField.text = [self getDefaultUserName];
    [self.inputBackground addSubview:self.phoneTextField];
    //密码
    [self.inputBackground addSubview:self.passwordTextField];
    self.passwordTextField.text = [self getDefaultUserPwd];
    [self.inputBackground addSubview:self.loginButton];
    
    [self.inputBackground addSubview:self.verificationCodeField];
    [self.inputBackground addSubview:self.sendCodeButton];
    [self.inputBackground addSubview:self.vCodeTimerLb];
    //设置按钮
    [_inputBackground addSubview:self.settingButton];
    self.settingButton.hidden = YES;
    [self.view addSubview:self.userProtocolButton];
    [self.view addSubview:self.bottomBackground];
    //底部按钮区
    [self.bottomBackground addSubview:self.registerButton];
    [self.bottomBackground addSubview:self.forgetPswButton];
    [self.bottomBackground addSubview:self.footerLabel];
}

- (void)setLayout {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_sendCodeButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_verificationCodeField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-7]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_sendCodeButton
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_verificationCodeField
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-7]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_vCodeTimerLb
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_verificationCodeField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-7]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_vCodeTimerLb
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_verificationCodeField
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-7]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_vCodeTimerLb
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_verificationCodeField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-7]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_vCodeTimerLb
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_sendCodeButton
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_vCodeTimerLb
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_sendCodeButton
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bottomBackground
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:20]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_rongLogoView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
//     attribute:NSLayoutAttributeCenterX
//     relatedBy:NSLayoutRelationEqual
//        toItem:self.view
//     attribute:NSLayoutAttributeCenterX
//    multiplier:1.0
//      constant:0]];
//
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_chatLabel
//     attribute:NSLayoutAttributeCenterX
//     relatedBy:NSLayoutRelationEqual
//        toItem:self.view
//     attribute:NSLayoutAttributeCenterX
//    multiplier:1.0
//      constant:0]];

    NSDictionary *views = NSDictionaryOfVariableBindings(_errorMsgLb, _rongLogoView, _inputBackground,
                                                         _userProtocolButton, _bottomBackground);

    NSArray *viewConstraints = [[[[[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-41-[_inputBackground]-41-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:views]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:|-70-[_rongLogoView(100)]-100-["
                                                                      @"_errorMsgLb(==15)]-20-["
                                                                      @"_inputBackground(240)]-20-["
                                                                      @"_userProtocolButton(==20)]"
                                                              options:0
                                                              metrics:nil
                                                                views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bottomBackground(==50)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_bottomBackground]-10-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]]
                                   
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_errorMsgLb]-10-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]]
                                 
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rongLogoView(100)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]];

    [self.view addConstraints:viewConstraints];

    NSLayoutConstraint *userProtocolLabelConstraint = [NSLayoutConstraint constraintWithItem:_userProtocolButton
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.view
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                  multiplier:1.f
                                                                                    constant:0];
    [self.view addConstraint:userProtocolLabelConstraint];
    NSDictionary *inputViews = NSDictionaryOfVariableBindings( _phoneTextField, _passwordTextField,_verificationCodeField,_sendCodeButton,_vCodeTimerLb,
                                                              _loginButton, _settingButton);

    NSArray *inputViewConstraints = [[[[[[[
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_phoneTextField]|" options:0 metrics:nil views:inputViews]
                                        
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_passwordTextField]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_verificationCodeField]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:
            [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_verificationCodeField]-(<=0)-[_sendCodeButton(80)]"
                                                    options:0
                                                    metrics:nil
                                                      views:inputViews]]
        arrayByAddingObjectsFromArray:
            [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_verificationCodeField]-(<=0)-[_vCodeTimerLb]"
                                                    options:0
                                                    metrics:nil
                                                      views:inputViews]]
                                          
        arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:|-[_phoneTextField("
                                                                      @"60)]-[_verificationCodeField(50)]-[_passwordTextField(60)]-[_loginButton("
                                                                      @"50)]-40-[_settingButton(50)]"
                                                              options:0
                                                              metrics:nil
                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_loginButton]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_settingButton]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]];

    _userProtocolButton.width = SCREEN_WIDTH;
    [_inputBackground addConstraints:inputViewConstraints];
    
}

- (void)updateNameAndChatLabel{
//    self.nameLabel.top = self.rongLogoView.bottom;
//    self.chatLabel.top = self.nameLabel.bottom;
}

#pragma mark - Getters and setters
- (UIButton *)getSwitchLanguageBtn {
    UIButton *switchLanguage =
        [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 30, 70, 40)];
    [switchLanguage setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    switchLanguage.titleLabel.font = [UIFont systemFontOfSize:16.];
    NSString *currentlanguage = [RCDLanguageManager sharedRCDLanguageManager].currentLanguage;
    if ([currentlanguage isEqualToString:@"en"]) {
        [switchLanguage setTitle:@"简体中文" forState:(UIControlStateNormal)];
    } else if ([currentlanguage isEqualToString:@"zh-Hans"]) {
        [switchLanguage setTitle:@"EN" forState:(UIControlStateNormal)];
    }
    [switchLanguage addTarget:self
                       action:@selector(didTapSwitchLanguage:)
             forControlEvents:(UIControlEventTouchUpInside)];
    return switchLanguage;
}

- (RCAnimatedImagesView *)animatedImagesView {
    if (!_animatedImagesView) {
        _animatedImagesView = [[RCAnimatedImagesView alloc]
            initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _animatedImagesView.delegate = self;
    }
    return _animatedImagesView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 190, SCREEN_WIDTH, 20)];
        _nameLabel.text = @"WoosTalk";
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.userInteractionEnabled = NO;
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont boldSystemFontOfSize:20];
        
    }
    return _nameLabel;
}

- (UILabel*)chatLabel {
    if (!_chatLabel) {
        _chatLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 230, SCREEN_WIDTH, 20)];
        _chatLabel.text = @"换一种沟通方式!";
        _chatLabel.textAlignment = NSTextAlignmentCenter;
        _chatLabel.userInteractionEnabled = NO;
        _chatLabel.textColor = [FPStyleGuide weichatGreenColor];
        _chatLabel.font = [UIFont boldSystemFontOfSize:20];
        
    }
    return _chatLabel;
}

- (RCDIndicateTextField *)countryTextField {
    if (!_countryTextField) {
        _countryTextField = [[RCDIndicateTextField alloc] init];
        _countryTextField.indicateInfoLabel.text = RCDLocalizedString(@"country");
        _countryTextField.textField.text = self.currentRegion.countryName;
        _countryTextField.textField.userInteractionEnabled = NO;
        _countryTextField.textField.textColor = [UIColor blackColor];
        [_countryTextField indicateIconShow:YES];
        UITapGestureRecognizer *tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCountryTextField)];
        [_countryTextField addGestureRecognizer:tap];
        _countryTextField.userInteractionEnabled = YES;
        _countryTextField.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _countryTextField;
}

- (RCDIndicateTextField *)phoneTextField {
    if (!_phoneTextField) {
        _phoneTextField = [[RCDIndicateTextField alloc] initWithFrame:CGRectZero];
        _phoneTextField.backgroundColor = [UIColor clearColor];
        _phoneTextField.tag = UserTextFieldTag;
        _phoneTextField.indicateInfoLabel.text = [NSString stringWithFormat:@"+%@", self.currentRegion.phoneCode];
        _phoneTextField.indicateInfoLabel.textColor = [UIColor blackColor];
        _phoneTextField.textField.textColor = [UIColor blackColor];
        _phoneTextField.userInteractionEnabled = YES;
        _phoneTextField.textField.adjustsFontSizeToFitWidth = YES;
        _phoneTextField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneTextField.textField.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:@"请输入手机号"
                                        attributes:@{NSForegroundColorAttributeName : [FPStyleGuide lightGrayTextColor]}];
        if (_phoneTextField.textField.text.length > 0) {
            [_phoneTextField.textField setFont:[UIFont fontWithName:@"Heiti SC" size:25.0]];
        }
        _phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _phoneTextField;
}

- (RCUnderlineTextField *)verificationCodeField {
    if (!_verificationCodeField) {
        RCUnderlineTextField *verificationCodeField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];

        verificationCodeField.backgroundColor = [UIColor clearColor];
        UIColor *color = [FPStyleGuide lightGrayTextColor];
        verificationCodeField.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:RCDLocalizedString(@"phone_message_code")
                                            attributes:@{NSForegroundColorAttributeName : color}];
        verificationCodeField.textColor = [UIColor blackColor];
        verificationCodeField.delegate = self;
        verificationCodeField.translatesAutoresizingMaskIntoConstraints = NO;
        verificationCodeField.keyboardType = UIKeyboardTypeNumberPad;
        _verificationCodeField = verificationCodeField;
    }
    return _verificationCodeField;
}

- (UIButton *)sendCodeButton {
    if (!_sendCodeButton) {
        UIButton *sendCodeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [sendCodeButton
            setBackgroundColor:[[UIColor alloc] initWithRed:133 / 255.f green:133 / 255.f blue:133 / 255.f alpha:1]];
        [sendCodeButton setTitle:RCDLocalizedString(@"send_verification_code") forState:UIControlStateNormal];
        [sendCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sendCodeButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [sendCodeButton addTarget:self action:@selector(sendCodeEvent) forControlEvents:UIControlEventTouchUpInside];
        sendCodeButton.translatesAutoresizingMaskIntoConstraints = NO;
        _sendCodeButton = sendCodeButton;
    }
    return _sendCodeButton;
}

- (UILabel *)vCodeTimerLb {
    if (!_vCodeTimerLb) {
        UILabel *vCodeTimerLb = [[UILabel alloc] initWithFrame:CGRectZero];
        vCodeTimerLb.text = RCDLocalizedString(@"after_60_seconds_obtain");
        vCodeTimerLb.font = [UIFont fontWithName:@"Heiti SC" size:13.0];
        vCodeTimerLb.translatesAutoresizingMaskIntoConstraints = NO;
        //  vCodeTimerLb.textColor =
        //      [[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5];
        [vCodeTimerLb
            setBackgroundColor:[[UIColor alloc] initWithRed:133 / 255.f green:133 / 255.f blue:133 / 255.f alpha:1]];
        vCodeTimerLb.textColor = [UIColor whiteColor];
        vCodeTimerLb.textAlignment = UITextAlignmentCenter;
        vCodeTimerLb.hidden = YES;
        _vCodeTimerLb = vCodeTimerLb;
    }
    return _vCodeTimerLb;
}


- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        RCUnderlineTextField *passwordTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];
        passwordTextField.tag = PassWordFieldTag;
        passwordTextField.textColor = [UIColor blackColor];
        passwordTextField.returnKeyType = UIReturnKeyDone;
        passwordTextField.secureTextEntry = YES;
        passwordTextField.delegate = self;
        passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

        passwordTextField.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:RCDLocalizedString(@"password")
                                            attributes:@{NSForegroundColorAttributeName : [FPStyleGuide lightGrayTextColor]}];

        passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordTextField = passwordTextField;
    }
    return _passwordTextField;
}

- (UIImageView *)rongLogoView {
    if (!_rongLogoView) {
        UIImage *rongLogoImage = [UIImage imageNamed:@"login_logo"];
        _rongLogoView = [[UIImageView alloc] initWithImage:rongLogoImage];
        _rongLogoView.contentMode = UIViewContentModeScaleAspectFit;
        _rongLogoView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _rongLogoView;
}

- (UIView *)inputBackground {
    if (!_inputBackground) {
        _inputBackground = [[UIView alloc] initWithFrame:CGRectZero];
        _inputBackground.translatesAutoresizingMaskIntoConstraints = NO;
        _inputBackground.userInteractionEnabled = YES;
    }
    return _inputBackground;
}

- (UILabel *)errorMsgLb {
    if (!_errorMsgLb) {
        _errorMsgLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _errorMsgLb.text = @"";
        _errorMsgLb.font = [UIFont fontWithName:@"Heiti SC" size:12.0];
        _errorMsgLb.translatesAutoresizingMaskIntoConstraints = NO;
        _errorMsgLb.textColor = [UIColor colorWithRed:204.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1];
    }
    return _errorMsgLb;
}

- (UIButton *)loginButton {
    if (!_loginButton) {

        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginButton addTarget:self action:@selector(loginEvent:) forControlEvents:UIControlEventTouchUpInside];
        //    [loginButton setBackgroundImage:[UIImage imageNamed:@"login_button"] forState:UIControlStateNormal];
        [loginButton setTitle:RCDLocalizedString(@"Login") forState:UIControlStateNormal];
        loginButton.backgroundColor = [FPStyleGuide weichatGreenColor];
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loginButton.layer.cornerRadius = 3;
        loginButton.titleLabel.font = [UIFont systemFontOfSize:23];
        loginButton.translatesAutoresizingMaskIntoConstraints = NO;
        _loginButton = loginButton;
    }
    return _loginButton;
}

- (UIButton *)settingButton {
    if (!_settingButton) {
        UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingButton setTitle:RCDLocalizedString(@"private_cloud_setting") forState:UIControlStateNormal];
        [settingButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                            forState:UIControlStateNormal];
        [settingButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:17.0]];
        settingButton.translatesAutoresizingMaskIntoConstraints = NO;
        _settingButton = settingButton;
    }
    return _settingButton;
}

- (UIView *)userProtocolButton {
    if (!_userProtocolButton) {
//        UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
//
//        NSString *firstStr = @"登录即表示同意";
//        NSString *personStr = @"《用户协议》";
//        NSString *hideStr = @"《隐私协议》";
//
//        CGSize firstSize = [firstStr suggestedSizeWithFont:[UIFont systemFontOfSize:10]];
//        CGSize personSize = [personStr suggestedSizeWithFont:[UIFont systemFontOfSize:10]];
//        CGSize hideSize = [hideStr suggestedSizeWithFont:[UIFont systemFontOfSize:10]];
//
//        CGFloat allWidth = firstSize.width + personSize.width + hideSize.width;
//
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - allWidth) / 2, 0, firstSize.width, 20)];
//        label.font = [UIFont systemFontOfSize:10];
//        label.textColor = [FPStyleGuide lightGrayTextColor];
//        label.text = firstStr;
//        [bgView addSubview:label];
//
//        UIButton *personBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [personBtn setTitle:personStr forState:UIControlStateNormal];
//        personBtn.frame = CGRectMake(label.right, 0, personSize.width, 20);
//        [personBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        personBtn.titleLabel.font = [UIFont systemFontOfSize:10];
//        [bgView addSubview:personBtn];
//
//        UIButton *hideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [hideBtn setTitle:hideStr forState:UIControlStateNormal];
//        hideBtn.frame = CGRectMake(personBtn.right, 0, personSize.width, 20);
//        [hideBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        hideBtn.titleLabel.font = [UIFont systemFontOfSize:10];
//        [bgView addSubview:hideBtn];
        
        
        UIButton *userProtocolButton = [[UIButton alloc] initWithFrame:CGRectZero];
            [userProtocolButton setTitle:@"登录即表示同意《用户协议》《隐私协议》"
            forState:UIControlStateNormal];
        [userProtocolButton setTitleColor:[UIColor blackColor]
                                 forState:UIControlStateNormal];

        [userProtocolButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [userProtocolButton addTarget:self
                               action:@selector(userProtocolEvent)
                     forControlEvents:UIControlEventTouchUpInside];
        userProtocolButton.translatesAutoresizingMaskIntoConstraints = NO;
        _userProtocolButton = userProtocolButton;
        
        NSString *firstStr = @"登录即表示同意";
        NSString *personStr = @"《用户协议》";
        NSString *hideStr = @"《隐私协议》";

        CGSize firstSize = [firstStr suggestedSizeWithFont:[UIFont systemFontOfSize:14]];
        CGSize personSize = [personStr suggestedSizeWithFont:[UIFont systemFontOfSize:14]];
        CGSize hideSize = [hideStr suggestedSizeWithFont:[UIFont systemFontOfSize:14]];

//        CGFloat allWidth = firstSize.width + personSize.width + hideSize.width;

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, firstSize.width, 20)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [FPStyleGuide lightGrayTextColor];
        label.text = firstStr;
        [_userProtocolButton addSubview:label];

        UIButton *personBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [personBtn addTarget:self action:@selector(personProtocol) forControlEvents:UIControlEventTouchUpInside];
        [personBtn setTitle:personStr forState:UIControlStateNormal];
        personBtn.frame = CGRectMake(label.right, 0, personSize.width, 20);
        [personBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        personBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_userProtocolButton addSubview:personBtn];

        UIButton *hideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [hideBtn setTitle:hideStr forState:UIControlStateNormal];
        [hideBtn addTarget:self action:@selector(hideProtocol) forControlEvents:UIControlEventTouchUpInside];
        hideBtn.frame = CGRectMake(personBtn.right, 0, hideSize.width, 20);
        [hideBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        hideBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_userProtocolButton addSubview:hideBtn];
        
//        _userProtocolButton = bgView;
    }
    return _userProtocolButton;
}

- (UIView *)bottomBackground {
    if (!_bottomBackground) {
        _bottomBackground = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomBackground.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _bottomBackground;
}

- (UIButton *)registerButton {
    if (!_registerButton) {
        UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, -16, 120, 50)];
        [registerButton setTitle:RCDLocalizedString(@"forgot_password") forState:UIControlStateNormal];
        [registerButton setTitleColor:[UIColor blackColor]
                             forState:UIControlStateNormal];
        registerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [registerButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
        [registerButton addTarget:self action:@selector(forgetPswEvent) forControlEvents:UIControlEventTouchUpInside];
        _registerButton = registerButton;
    }
    return _registerButton;
}

- (UIButton *)forgetPswButton {
    if (!_forgetPswButton) {
        UIButton *forgetPswButton =
            [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 100, -16, 80, 50)];
        [forgetPswButton setTitle:RCDLocalizedString(@"new_user") forState:UIControlStateNormal];
        [forgetPswButton setTitleColor:[UIColor blackColor]
                              forState:UIControlStateNormal];
        forgetPswButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [forgetPswButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
        [forgetPswButton addTarget:self action:@selector(registerEvent) forControlEvents:UIControlEventTouchUpInside];
        _forgetPswButton = forgetPswButton;
    }
    return _forgetPswButton;
}

- (UILabel *)footerLabel {
    if (!_footerLabel) {
        CGRect screenBounds = self.view.frame;
        UILabel *footerLabel = [[UILabel alloc] init];
        footerLabel.textAlignment = NSTextAlignmentCenter;
        footerLabel.frame = CGRectMake(screenBounds.size.width / 2 - 100, -2, 200, 21);
        footerLabel.text = @"Powered by woostalk";
        [footerLabel setFont:[UIFont systemFontOfSize:12.f]];
        [footerLabel setTextColor:[UIColor colorWithHexString:@"484848" alpha:1.0]];
        _footerLabel = footerLabel;
    }
    return _footerLabel;
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
        [self.view bringSubviewToFront:_hud];
        _hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
    }
    return _hud;
}

//获取邀请码
- (void)receiveInviteCode{
    [SYNetworkingManager getWithURLString:ReceiveInvite parameters:@{@"userAccountId":[ProfileUtil getUserAccountID]} success:^(NSDictionary *data) {
        NSLog(@"成功=%@",data);
//        NSString *inviteID = [data stringValueForKey:@"userInviterId"];
    } failure:^(NSError *error) {
        NSLog(@"失败");
    }];
}

- (void)sendCodeEvent {
    __weak RCDLoginViewController *weakSelf = self;
    [self.hud show:YES];
    self.errorMsgLb.text = @"";
    NSString *phoneNumber = self.phoneTextField.textField.text;
    if (phoneNumber.length > 0) {
        // check phone number
        __weak typeof(self) ws = self;
        
        [SYNetworkingManager getWithURLString:SendVerCode parameters:@{@"telphone":phoneNumber} success:^(NSDictionary *data) {
            [weakSelf.hud hide:YES];
            if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                [weakSelf getVerifyCode:self.currentRegion.phoneCode phoneNumber:phoneNumber];
            }
            else {
                ws.errorMsgLb.text = RCDLocalizedString(@"phone_number_type_error");
            }
        } failure:^(NSError *error) {
            [weakSelf.hud hide:YES];
            NSLog(@"失败");
        }];
        
        
        
        
//        [RCDLoginManager
//            checkPhoneNumberAvailable:self.currentRegion.phoneCode
//                          phoneNumber:phoneNumber
//                             complete:^(BOOL success, BOOL numberAvailable) {
//                                 rcd_dispatch_main_async_safe(^{
//                                     if (success) {
//                                         if (!numberAvailable) {
//                                             // get verify code
//                                             [ws getVerifyCode:self.currentRegion.phoneCode phoneNumber:phoneNumber];
//                                         } else {
//                                             [hud hide:YES];
//                                             ws.errorMsgLb.text = @"手机号未注册";
//                                         }
//                                     } else {
//                                         [hud hide:YES];
//                                         ws.errorMsgLb.text = RCDLocalizedString(@"phone_number_type_error");
//                                     }
//                                 });
//                             }];
    } else {
        [self.hud hide:YES];
        self.errorMsgLb.text = RCDLocalizedString(@"phone_number_type_error");
    }
}

- (void)getVerifyCode:(NSString *)phoneCode phoneNumber:(NSString *)phoneNumber {
    __weak typeof(self) ws = self;
    rcd_dispatch_main_async_safe(^{
        [ws.hud hide:YES];
        ws.vCodeTimerLb.hidden = NO;
        ws.sendCodeButton.hidden = YES;
        [ws countDown:60];
    });
}

- (void)countDown:(int)seconds {
    self.seconds = seconds;
    [self startCountDownTimer];
}

- (void)startCountDownTimer {
    [self stopCountDownTimerIfNeed];
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(timeFireMethod)
                                                         userInfo:nil
                                                          repeats:YES];
}
- (void)stopCountDownTimerIfNeed {
    if (self.countDownTimer && self.countDownTimer.isValid) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
}
- (void)timeFireMethod {
    self.seconds--;
    self.vCodeTimerLb.text = [NSString stringWithFormat:RCDLocalizedString(@"after_x_seconds_send"), self.seconds];
    if (self.seconds == 0) {
        [self stopCountDownTimerIfNeed];
        self.sendCodeButton.hidden = NO;
        self.vCodeTimerLb.hidden = YES;
        self.vCodeTimerLb.text = RCDLocalizedString(@"after_60_seconds_send");
    }
}

- (void)addAllFriendsInGroup{
    NSDictionary *params = @{@"groupId":@"",@"userAccountId":[ProfileUtil getUserAccountID]};
    [SYNetworkingManager postWithURLString:AddFriendsRequest parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            
        }
    } failure:^(NSError *error) {
        NSLog(@"");
    }];
}

//是否取消置顶，勿打扰
- (void)resetDisturb{
    //isNotDisturb   是否是勿打扰(0.否1.是)  ;isToTop   是否置顶(0.否1.是)
    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"toUserAccountId":@"aadddss",@"isNotDisturb":@"0",@"isToTop":@"0"};
    [SYNetworkingManager requestPUTWithURLStr:ResetDisturb paramDic:params success:^(NSDictionary *data) {
        NSLog(@"置顶成功=%@",data);
    } failure:^(NSError *error) {
        NSLog(@"失败");
    }];
}

//管理员登录(失败)
- (void)adminLogin{
    NSDictionary *params = @{@"username":@"aa",@"password":@"ff"};
    [SYNetworkingManager postWithURLString:AdminLogin parameters:params success:^(NSDictionary *data) {
        NSLog(@"管理员登录成功=%@",data);
    } failure:^(NSError *error) {
        NSLog(@"管理员登录失败");
    }];
}

- (void)changeGroupSettings{
    NSDictionary *params = @{@"groupId":@"",@"":@""};
    [SYNetworkingManager requestPUTWithURLStr:ChangeGroupSetting paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)changeFriendInfo{
    //@"userRemarks":@"用户备注",@"sparePhone":@"备用手机号",@"userDescribe":@"用户描述",@"userCart":@"用户明信片"
    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"toUserAccountId":@""};
    [SYNetworkingManager requestPUTWithURLStr:ChangeFriendInfo paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            
        }
    } failure:^(NSError *error) {
        NSLog(@"");
    }];
    
}

- (void)addBlackList{
    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"toUserAccountId":@""};
    [SYNetworkingManager postWithURLString:AddBlackList parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)removeBlackList{
    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"toUserAccountId":@""};
    [SYNetworkingManager deleteWithURLString:RemoveBlackList parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)blackList{
    NSDictionary *params = @{@"userAccountId":[ProfileUtil getUserAccountID]};
    [SYNetworkingManager getWithURLString:BlackList parameters:params success:^(NSDictionary *data) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)personProtocol{
    WKWebViewController *webVC = [[WKWebViewController alloc] init];
    webVC.url = @"http://www.woostalk.com/service_agreement.html";
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)hideProtocol{
    WKWebViewController *webVC = [[WKWebViewController alloc] init];
    webVC.url = @"http://www.woostalk.com/agreement.html";
    [self.navigationController pushViewController:webVC animated:YES];
}

- (UIImage *)getScreenShot{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(375, 667), NO, [UIScreen mainScreen].scale);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *shareImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return shareImage;
}

- (void)setSettings{
    NSDictionary *params = @{@"userAccountId":[ProfileUtil getUserAccountID]};
    [SYNetworkingManager requestPUTWithURLStr:SetSeting paramDic:params success:^(NSDictionary *data) {
        
    } failure:^(NSError *error) {
        
    }];
}


@end
