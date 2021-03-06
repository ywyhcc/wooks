//
//  RCDRegisterViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/3/10.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDRegisterViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDFindPswViewController.h"
#import "RCDLoginViewController.h"
#import "RCUnderlineTextField.h"
#import "UIColor+RCColor.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDIndicateTextField.h"
#import "RCDCountryListController.h"
#import "RCDCountry.h"
#import "RCDLanguageManager.h"
#import "AppDelegate.h"
#import "RCDCommonString.h"
#import "RCDLoginManager.h"
#import "SYNetworkingManager.h"
#import "WKWebViewController.h"

#define UserTextFieldTag 1000
#define NickNameFieldTag 1003

@interface RCDRegisterViewController () <UITextFieldDelegate, RCDCountryListControllerDelegate>
@property (nonatomic, strong) RCDIndicateTextField *countryTextField;
@property (nonatomic, strong) RCDIndicateTextField *phoneTextField;
@property (nonatomic, strong) UITextField *tfEmail;
@property (nonatomic, strong) UITextField *tfNickName;
@property (nonatomic, strong) UITextField *tfPassword;
@property (nonatomic, strong) UITextField *tfRePassword;
@property (nonatomic, strong) UIImageView *rongLogo;
@property (nonatomic, strong) UIView *inputBackground;
@property (nonatomic, strong) UITextField *tfMobile;
@property (nonatomic, strong) RCAnimatedImagesView *animatedImagesView;
@property (nonatomic, strong) UILabel *licenseLb;
@property (nonatomic, strong) UILabel *errorMsgLb;
@property (nonatomic, strong) UILabel *countDownLable;
@property (nonatomic, strong) UIButton *fetchVerificationCodeBt;
@property (nonatomic, strong) RCDCountry *currentRegion;

@property (nonatomic, strong) UILabel *userNameMsgLb;
@property (nonatomic, strong) RCUnderlineTextField *verificationCodeField;
@property (nonatomic, strong) UILabel *verificationCodeLb;
@property (nonatomic, strong) RCUnderlineTextField *passwordTextField;
@property (nonatomic, strong) UILabel *pswMsgLb;
@property (nonatomic, strong) RCUnderlineTextField *rePasswordTextField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *userProtocolButton;
@property (nonatomic, strong) UIView *bottomBackground;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, strong) NSString *verCode;
@property (nonatomic, strong) RCUnderlineTextField *inviteTextField;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation RCDRegisterViewController {
    NSTimer *_CountDownTimer;
    int _Seconds;
    MBProgressHUD *hud;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];//RCDDYCOLOR(0xf0f0f6, 0x000000);
    self.currentRegion = [[RCDCountry alloc] initWithDict:[DEFAULTS objectForKey:RCDCurrentCountryKey]];

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

//    [self.animatedImagesView stopAnimating];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Target action

/*获取验证码*/
- (void)getVerficationCode {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
    [hud show:YES];
    self.errorMsgLb.text = @"";
    if (self.phoneNumber.length > 0) {
        __weak typeof(self) ws = self;
        NSString *phone = [NSString stringWithFormat:@"%@", self.phoneNumber];
        
        
        [SYNetworkingManager getWithURLString:SendVerCode parameters:@{@"telphone":phone} success:^(NSDictionary *data) {
            [hud hide:YES];
            if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                [ws getVerifyCode:self.currentRegion.phoneCode phoneNumber:phone];
            }
            else {
                ws.errorMsgLb.text = RCDLocalizedString(@"phone_number_type_error");
            }
        } failure:^(NSError *error) {
            [hud hide:YES];
            NSLog(@"失败");
        }];
    }

        
//    [RCDLoginManager
//        checkPhoneNumberAvailable:self.currentRegion.phoneCode
//                      phoneNumber:phone
//                         complete:^(BOOL success, BOOL numberAvailable) {
//                             rcd_dispatch_main_async_safe(^{
//                                 if (success) {
//                                     if (!numberAvailable) {
//                                         [hud hide:YES];
//                                         ws.errorMsgLb.text =
//                                             RCDLocalizedString(@"phone_number_has_been_registered");
//                                     } else {
//                                         [ws getVerifyCode:self.currentRegion.phoneCode phoneNumber:phone];
//                                     }
//                                 } else {
//                                     [hud hide:YES];
//                                     ws.errorMsgLb.text = RCDLocalizedString(@"phone_number_type_error");
//                                 }
//                             });
//                         }];
//    } else {
//        [hud hide:YES];
//        _errorMsgLb.text = RCDLocalizedString(@"phone_number_type_error");
//    }
}

- (void)getVerifyCode:(NSString *)phoneCode phoneNumber:(NSString *)phone {
    __weak typeof(self) ws = self;
    rcd_dispatch_main_async_safe(^{
        [hud hide:YES];
        ws.fetchVerificationCodeBt.hidden = YES;
        ws.countDownLable.hidden = NO;
        [ws CountDown:60];
    });

//    [RCDLoginManager getVerificationCode:phoneCode
//        phoneNumber:phone
//        success:^(BOOL success) {
//            rcd_dispatch_main_async_safe(^{
//                [hud hide:YES];
//                if (success) {
//                    ws.fetchVerificationCodeBt.hidden = YES;
//                    ws.countDownLable.hidden = NO;
//                    [ws CountDown:60];
//                }
//            });
//        }
//        error:^(RCDLoginErrorCode errorCode, NSString *_Nonnull errorMsg) {
//            rcd_dispatch_main_async_safe(^{
//                [hud hide:YES];
//                if (errorCode == RCDLoginErrorCodeParameterError) {
//                    ws.errorMsgLb.text = RCDLocalizedString(@"phone_number_type_error");
//                } else {
//                    ws.errorMsgLb.text = errorMsg;
//                }
//            });
//        }];
}

- (void)btnDoneClicked:(id)sender {
    if (![self checkContent])
        return;
    
    if (![_passwordTextField.text isEqualToString:_rePasswordTextField.text]) {
        self.errorMsgLb.text = @"两次密码不一致";
        return;
    }
    
    RCNetworkStatus status = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];

    if (RC_NotReachable == status) {
        self.errorMsgLb.text = RCDLocalizedString(@"network_can_not_use_please_check");
    }
    __weak typeof(self) ws = self;
    NSString *userName = self.phoneTextField.textField.text;
    NSString *verificationCode = self.verificationCodeField.text;
    NSString *userPwd = self.passwordTextField.text;
//    NSString *nickName = self.rePasswordTextField.text;
//    NSString *inviteCode = self.inviteTextField.text;
    
    [ws registerUser:userName password:userPwd verifyToken:verificationCode phoneNum:userName];
    //验证验证码是否有效
//    [RCDLoginManager verifyVerificationCode:self.currentRegion.phoneCode
//        phoneNumber:userName
//        verificationCode:verificationCode
//        success:^(BOOL success, NSString *_Nonnull codeToken) {
//            rcd_dispatch_main_async_safe(^{
//                if (success) {
//                    [ws registerUser:nickName password:userPwd verifyToken:codeToken];
//                }
//            });
//        }
//        error:^(RCDLoginErrorCode errorCode) {
//            rcd_dispatch_main_async_safe(^{
//                if (errorCode == RCDLoginErrorCodeWrongPassword) {
//                    ws.errorMsgLb.text = RCDLocalizedString(@"verification_code_error");
//                } else if (errorCode == RCDLoginErrorCodeVerificationCodeExpired) {
//                    ws.errorMsgLb.text = RCDLocalizedString(@"captcha_overdue");
//                } else {
//                    ws.errorMsgLb.text = RCDLocalizedString(@"register_fail");
//                }
//            });
//        }];
}

//注册用户
- (void)registerUser:(NSString *)nickName password:(NSString *)userPwd verifyToken:(NSString *)verifyToken phoneNum:(NSString*)phoneNum {
    __weak typeof(self) ws = self;
    NSDictionary *dic = @{@"username":nickName,@"password":userPwd,@"telphone":phoneNum,@"region":self.currentRegion.phoneCode,@"tryCode":verifyToken};
    if (self.inviteTextField.text.length > 0) {
        dic = @{@"username":nickName,@"password":userPwd,@"telphone":phoneNum,@"region":self.currentRegion.phoneCode,@"tryCode":verifyToken,@"inviterId":self.inviteTextField.text};
    }
    [SYNetworkingManager postWithURLString:Register parameters:dic success:^(NSDictionary *data) {
//        ws.errorMsgLb.text = RCDLocalizedString(@"register_success");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_MSEC),
                       dispatch_get_main_queue(), ^{
            if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                [self showAlertViewWithMessage:@"注册成功"];
            }
            else{
                [self showAlertViewWithMessage:[data stringValueForKey:@"message"]];
            }
       });
    } failure:^(NSError *error) {
        ws.errorMsgLb.text = RCDLocalizedString(@"register_fail");
    }];
//    [RCDLoginManager
//        registerWithNickname:nickName
//                    password:userPwd
//            verficationToken:verifyToken
//                    complete:^(BOOL success) {
//                        rcd_dispatch_main_async_safe(^{
//                            if (success) {
//                                ws.errorMsgLb.text = RCDLocalizedString(@"register_success");
//                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_MSEC),
//                                               dispatch_get_main_queue(), ^{
//                                                   [self.navigationController popViewControllerAnimated:YES];
//                                               });
//                            } else {
//                                ws.errorMsgLb.text = RCDLocalizedString(@"register_fail");
//                            }
//                        });
//                    }];
}

- (void)showAlertViewWithMessage:(NSString *)message {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        if ([message isEqualToString:@"注册成功"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

/*找回密码*/
- (void)forgetPswEvent {
    RCDFindPswViewController *temp = [[RCDFindPswViewController alloc] init];
    [self.navigationController pushViewController:temp animated:YES];
}

/*阅读用户协议*/
- (void)userProtocolEvent {
}
/*注册*/
- (void)loginPageEvent {
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
    self.countryTextField.textField.text = country.countryName;
    self.currentRegion = country;
    self.phoneTextField.indicateInfoLabel.text = [NSString stringWithFormat:@"+%@", self.currentRegion.phoneCode];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == UserTextFieldTag) {
        BOOL enable = [self validatePhoneNumber:textField.text];
        UIColor *color = [FPStyleGuide weichatGreenColor];//[[UIColor alloc] initWithRed:23 / 255.f green:136 / 255.f blue:213 / 255.f alpha:1];
        if (!enable) {
            color = [[UIColor alloc] initWithRed:133 / 255.f green:133 / 255.f blue:133 / 255.f alpha:1];
        }
        self.fetchVerificationCodeBt.enabled = enable;
        self.fetchVerificationCodeBt.backgroundColor = color;
        if (enable) {
            self.phoneNumber = textField.text;
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/**
 *  检查输入内容
 *
 *  @return 是否合法输入
 */
- (BOOL)checkContent {
    NSString *userName = self.phoneTextField.textField.text;
    NSString *userPwd = self.passwordTextField.text;
    NSString *reUserPwd = self.rePasswordTextField.text;

    if (userName.length == 0) {

        _errorMsgLb.text = RCDLocalizedString(@"phone_number_can_not_nil");
        return NO;
    }
    if (userPwd.length > 20) {
        _errorMsgLb.text = RCDLocalizedString(@"password_can_not_more_than_20");
        return NO;
    }
    if (userPwd.length == 0) {
        _errorMsgLb.text = RCDLocalizedString(@"password_can_not_nil");
        return NO;
    }
    if (reUserPwd.length == 0) {
        _errorMsgLb.text = RCDLocalizedString(@"nickname_can_not_nil");
        return NO;
    }
    if (reUserPwd.length > 32) {
        _errorMsgLb.text = RCDLocalizedString(@"nickname_can_not_over_32");
        return NO;
    }
    NSRange _range = [reUserPwd rangeOfString:@" "];
    if (_range.location != NSNotFound) {
        _errorMsgLb.text = RCDLocalizedString(@"nickname_can_not_contain_space");
        return NO;
    }
    return YES;
}

- (NSUInteger)animatedImagesNumberOfImages:(RCAnimatedImagesView *)animatedImagesView {
    return 2;
}

- (UIImage *)animatedImagesView:(RCAnimatedImagesView *)animatedImagesView imageAtIndex:(NSUInteger)index {
//    return [UIImage imageNamed:@"login_background.png"];
    return [UIImage imageNamed:@""];
}

- (void)CountDown:(int)seconds {
    _Seconds = seconds;
    _CountDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(timeFireMethod)
                                                     userInfo:nil
                                                      repeats:YES];
}
- (void)timeFireMethod {
    _Seconds--;
    _countDownLable.text = [NSString stringWithFormat:RCDLocalizedString(@"after_x_seconds_send"), _Seconds];
    if (_Seconds == 0) {
        [_CountDownTimer invalidate];
        _countDownLable.hidden = YES;
        _fetchVerificationCodeBt.hidden = NO;
        _countDownLable.text = RCDLocalizedString(@"after_60_seconds_send");
    }
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
    RCDRegisterViewController *temp = [[RCDRegisterViewController alloc] init];
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;        //可更改为其他方式
    transition.subtype = kCATransitionFromLeft; //可更改为其他方式
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:temp animated:NO];
}

#pragma mark - noti
- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect keyboardBounds = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat space = CGRectGetMaxY(self.inputBackground.frame) - 50 - keyboardBounds.origin.y;
    if (space > 0) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.view.frame =
                                 CGRectMake(0.f, -space, self.view.frame.size.width, self.view.frame.size.height);
                         }
                         completion:nil];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.frame =
                             CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:nil];
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
}

- (void)initSubviews {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.view addSubview:self.animatedImagesView];

//    [self.animatedImagesView addSubview:[self getSwitchLanguage]];

    [self.view addSubview:self.licenseLb];

    [self.view addSubview:self.rongLogo];
    
    [self.view addSubview:self.nameLabel];

    [self.view addSubview:self.inputBackground];

    [self.view addSubview:self.errorMsgLb];

//    [self.inputBackground addSubview:self.countryTextField];

    [self.inputBackground addSubview:self.phoneTextField];

    [self.inputBackground addSubview:self.userNameMsgLb];

    [self.inputBackground addSubview:self.verificationCodeField];

    [self.inputBackground addSubview:self.verificationCodeLb];

    [self.inputBackground addSubview:self.fetchVerificationCodeBt];

    [self.inputBackground addSubview:self.countDownLable];

    [self.inputBackground addSubview:self.passwordTextField];

    [self.inputBackground addSubview:self.pswMsgLb];

    [self.inputBackground addSubview:self.rePasswordTextField];
    
    [self.inputBackground addSubview:self.inviteTextField];

    [self.inputBackground addSubview:self.loginButton];

    [self.view addSubview:self.userProtocolButton];

    [self.view addSubview:self.bottomBackground];

    [self.bottomBackground addSubview:[self getLoginButton]];

    [self.bottomBackground addSubview:[self getForgetPswButton]];
}

- (void)setLayout {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_userNameMsgLb
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.phoneTextField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-6]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_userNameMsgLb
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.phoneTextField
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-7]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_verificationCodeLb
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_verificationCodeField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_verificationCodeLb
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_verificationCodeField
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-7]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_fetchVerificationCodeBt
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_verificationCodeField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-10]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_countDownLable
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_verificationCodeField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-10]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_countDownLable
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_fetchVerificationCodeBt
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_countDownLable
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_fetchVerificationCodeBt
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_countDownLable
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_fetchVerificationCodeBt
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_pswMsgLb
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_passwordTextField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-6]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_pswMsgLb
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_passwordTextField
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-7]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_userProtocolButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:20]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_rongLogo
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];

    NSDictionary *views = NSDictionaryOfVariableBindings(_errorMsgLb, _licenseLb, _rongLogo, _inputBackground,
                                                         _userProtocolButton, _bottomBackground);

    NSArray *viewConstraints = [[[[[[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-41-[_inputBackground]-41-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]
        //      arrayByAddingObjectsFromArray:
        //          [NSLayoutConstraint
        //              constraintsWithVisualFormat:@"H:|-14-[_rongLogo]-70-|"
        //                                  options:0
        //                                  metrics:nil
        //                                    views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:|-60-[_rongLogo(100)]-80-[_errorMsgLb(=="
                                                                      @"12)]-1-[_inputBackground(==350)]-"
                                                                      @"(==0)-[_bottomBackground(==50)]"
                                                              options:0
                                                              metrics:nil
                                                                views:views]]

        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_rongLogo(100)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]]

        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_userProtocolButton(==20)]-30-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_bottomBackground]-0-|"
        options:0
        metrics:nil
          views:views]]
                                 
//        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_userProtocolButton]-10-|"
//                                                                              options:0
//                                                                              metrics:nil
//                                                                                views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_licenseLb]-10-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_errorMsgLb]-10-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]];

    [self.view addConstraints:viewConstraints];
    
    NSLayoutConstraint *bottomBackConstraint = [NSLayoutConstraint constraintWithItem:_bottomBackground
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.view
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                  multiplier:1.f
                                                                                    constant:0];
    [self.view addConstraint:bottomBackConstraint];

    NSLayoutConstraint *userProtocolLabelConstraint = [NSLayoutConstraint constraintWithItem:_userProtocolButton
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.view
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                  multiplier:1.f
                                                                                    constant:0];
    [self.view addConstraint:userProtocolLabelConstraint];
    NSDictionary *inputViews = NSDictionaryOfVariableBindings(
        _userNameMsgLb, _pswMsgLb, _phoneTextField, _passwordTextField, _loginButton,
        _rePasswordTextField,_inviteTextField, _verificationCodeField, _verificationCodeLb, _fetchVerificationCodeBt);

    NSArray *inputViewConstraints = [[[[[[[[
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_phoneTextField]|" options:0 metrics:nil views:inputViews]
                                            
        arrayByAddingObjectsFromArray:
            [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_verificationCodeField][_fetchVerificationCodeBt]|"
                                                    options:0
                                                    metrics:nil
                                                      views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:[_fetchVerificationCodeBt(100)]|"
                                                              options:0
                                                              metrics:nil
                                                                views:inputViews]]

        //                                      arrayByAddingObjectsFromArray:
        //                                      [NSLayoutConstraint
        //                                       constraintsWithVisualFormat:@"H:[_verificationCodeField]-[_countDownLable]|"
        //                                       options:0
        //                                       metrics:nil
        //                                       views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_passwordTextField]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_rePasswordTextField]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_inviteTextField]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:inputViews]]
                                       
                                       
        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|["
                                                                                      @"_phoneTextField(50)]-["
                                                                                      @"_verificationCodeField(50)]-["
                                                                                      @"_passwordTextField(50)]-["
                                                                                      @"_rePasswordTextField(50)]-["
                                       
                                                                        @"_inviteTextField(50)]-["
                                                                                      @"_loginButton(50)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]]

        arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:[_fetchVerificationCodeBt(35)]"
                                                              options:0
                                                              metrics:nil
                                                                views:inputViews]]

        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_loginButton]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:inputViews]];

    [_inputBackground addConstraints:inputViewConstraints];
}

- (BOOL)validatePhoneNumber:(NSString *)phoneNumber {
    NSString *regex = @"^\\d{3,15}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isPhoneNumber = [pred evaluateWithObject:phoneNumber];
    return isPhoneNumber;
}

#pragma mark - Getters and setters
- (RCDIndicateTextField *)countryTextField {
    if (!_countryTextField) {
        _countryTextField = [[RCDIndicateTextField alloc] init];
        _countryTextField.indicateInfoLabel.text = RCDLocalizedString(@"country");
        _countryTextField.textField.text = self.currentRegion.countryName;
        _countryTextField.textField.userInteractionEnabled = NO;
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
        _phoneTextField.textField.tag = UserTextFieldTag;
        _phoneTextField.indicateInfoLabel.text = [NSString stringWithFormat:@"+%@", self.currentRegion.phoneCode];
        UIColor *color = [FPStyleGuide lightGrayTextColor];
        _phoneTextField.textField.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:@"请输入手机号码"
                                            attributes:@{NSForegroundColorAttributeName : color}];
        _phoneTextField.userInteractionEnabled = YES;
        _phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _phoneTextField.textField.adjustsFontSizeToFitWidth = YES;
        _phoneTextField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
        [_phoneTextField.textField addTarget:self
                                      action:@selector(textFieldDidChange:)
                            forControlEvents:UIControlEventEditingChanged];
        if (_phoneTextField.textField.text.length > 0) {
            [_phoneTextField.textField setFont:[UIFont fontWithName:@"Heiti SC" size:25.0]];
        }
    }
    return _phoneTextField;
}

- (RCAnimatedImagesView *)animatedImagesView {
    if (!_animatedImagesView) {
        _animatedImagesView = [[RCAnimatedImagesView alloc]
            initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _animatedImagesView.delegate = self;
    }
    return _animatedImagesView;
}

- (UIButton *)getSwitchLanguage {
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

- (UILabel *)licenseLb {
    if (!_licenseLb) {
        _licenseLb = [[UILabel alloc] initWithFrame:CGRectZero];
        //  _licenseLb.text = @"仅供演示融云 SDK 功能使用";
        _licenseLb.font = [UIFont fontWithName:@"Heiti SC" size:12.0];
        _licenseLb.translatesAutoresizingMaskIntoConstraints = NO;
        _licenseLb.textColor = [[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5];
    }
    return _licenseLb;
}

- (UIImageView *)rongLogo {
    if (!_rongLogo) {
        UIImage *rongLogoImage = [UIImage imageNamed:@"login_logo"];
        _rongLogo = [[UIImageView alloc] initWithImage:rongLogoImage];
        _rongLogo.contentMode = UIViewContentModeScaleAspectFit;
        _rongLogo.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _rongLogo;
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

- (UILabel *)userNameMsgLb {
    if (!_userNameMsgLb) {
        UILabel *userNameMsgLb = [[UILabel alloc] initWithFrame:CGRectZero];
        userNameMsgLb.text = RCDLocalizedString(@"mobile_number");

        userNameMsgLb.font = [UIFont fontWithName:@"Heiti SC" size:10.0];
        userNameMsgLb.translatesAutoresizingMaskIntoConstraints = NO;
        userNameMsgLb.textColor = [[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5];
        _userNameMsgLb = userNameMsgLb;
    }
    return _userNameMsgLb;
}

- (RCUnderlineTextField *)verificationCodeField {
    if (!_verificationCodeField) {
        RCUnderlineTextField *verificationCodeField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];

        verificationCodeField.backgroundColor = [UIColor clearColor];
        UIColor *color = [FPStyleGuide lightGrayTextColor];
        verificationCodeField.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:RCDLocalizedString(@"code")
                                            attributes:@{NSForegroundColorAttributeName : color}];
        verificationCodeField.textColor = [UIColor blackColor];
        self.view.translatesAutoresizingMaskIntoConstraints = YES;
        verificationCodeField.translatesAutoresizingMaskIntoConstraints = NO;
        verificationCodeField.adjustsFontSizeToFitWidth = YES;
        verificationCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
        verificationCodeField.keyboardType = UIKeyboardTypeNumberPad;
        if (verificationCodeField.text.length > 0) {
            [verificationCodeField setFont:[UIFont fontWithName:@"Heiti SC" size:25.0]];
        }

        [verificationCodeField addTarget:self
                                  action:@selector(textFieldDidChange:)
                        forControlEvents:UIControlEventEditingChanged];
        verificationCodeField.delegate = self;
        _verificationCodeField = verificationCodeField;
    }
    return _verificationCodeField;
}

- (UILabel *)verificationCodeLb {
    if (!_verificationCodeLb) {
        UILabel *verificationCodeLb = [[UILabel alloc] initWithFrame:CGRectZero];
        verificationCodeLb.text = RCDLocalizedString(@"verification_code");
        verificationCodeLb.hidden = YES;

        verificationCodeLb.font = [UIFont fontWithName:@"Heiti SC" size:10.0];
        verificationCodeLb.translatesAutoresizingMaskIntoConstraints = NO;
        verificationCodeLb.textColor = [UIColor whiteColor];
        _verificationCodeLb = verificationCodeLb;
    }
    return _verificationCodeLb;
}

- (UIButton *)fetchVerificationCodeBt {
    if (!_fetchVerificationCodeBt) {
        _fetchVerificationCodeBt = [[UIButton alloc] init];
        [_fetchVerificationCodeBt
            setBackgroundColor:[[UIColor alloc] initWithRed:133 / 255.f green:133 / 255.f blue:133 / 255.f alpha:1]];
        [_fetchVerificationCodeBt setTitle:RCDLocalizedString(@"send_verification_code") forState:UIControlStateNormal];
        [_fetchVerificationCodeBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_fetchVerificationCodeBt addTarget:self
                                     action:@selector(getVerficationCode)
                           forControlEvents:UIControlEventTouchUpInside];
        _fetchVerificationCodeBt.translatesAutoresizingMaskIntoConstraints = NO;
        [_fetchVerificationCodeBt.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:13.0]];
        _fetchVerificationCodeBt.enabled = NO;
        _fetchVerificationCodeBt.layer.masksToBounds = YES;
        _fetchVerificationCodeBt.layer.cornerRadius = 6.f;
    }
    return _fetchVerificationCodeBt;
}

- (UILabel *)countDownLable {
    if (!_countDownLable) {
        _countDownLable = [[UILabel alloc] init];
        _countDownLable.textColor = [UIColor whiteColor];
        [_countDownLable
            setBackgroundColor:[[UIColor alloc] initWithRed:133 / 255.f green:133 / 255.f blue:133 / 255.f alpha:1]];
        _countDownLable.textAlignment = UITextAlignmentCenter;
        [_countDownLable setFont:[UIFont fontWithName:@"Heiti SC" size:13.0]];
        _countDownLable.text = RCDLocalizedString(@"after_60_seconds_send");
        _countDownLable.translatesAutoresizingMaskIntoConstraints = NO;
        _countDownLable.hidden = YES;
        _countDownLable.layer.masksToBounds = YES;
        _countDownLable.layer.cornerRadius = 6.f;
    }
    return _countDownLable;
}

- (RCUnderlineTextField *)passwordTextField {
    if (!_passwordTextField) {
        RCUnderlineTextField *passwordTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];
        passwordTextField.textColor = [UIColor blackColor];
        passwordTextField.returnKeyType = UIReturnKeyDone;
        passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        passwordTextField.secureTextEntry = YES;
        passwordTextField.delegate = self;
        UIColor *color = [FPStyleGuide lightGrayTextColor];
        passwordTextField.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:RCDLocalizedString(@"password")
                                            attributes:@{NSForegroundColorAttributeName : color}];
        passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordTextField = passwordTextField;
    }
    return _passwordTextField;
}

- (UILabel *)pswMsgLb {
    if (!_pswMsgLb) {
        UILabel *pswMsgLb = [[UILabel alloc] initWithFrame:CGRectZero];
        pswMsgLb.text = RCDLocalizedString(@"char_section_case_sensitive_from6_t16");
        pswMsgLb.font = [UIFont fontWithName:@"Heiti SC" size:10.0];
        pswMsgLb.translatesAutoresizingMaskIntoConstraints = NO;
        pswMsgLb.textColor = [[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5];
        _pswMsgLb = pswMsgLb;
    }
    return _pswMsgLb;
}

- (RCUnderlineTextField *)rePasswordTextField {
    if (!_rePasswordTextField) {
        RCUnderlineTextField *rePasswordTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];
        rePasswordTextField.delegate = self;
        rePasswordTextField.textColor = [UIColor blackColor];
        rePasswordTextField.returnKeyType = UIReturnKeyDone;
        rePasswordTextField.secureTextEntry = YES;
        // passwordTextField.delegate = self;
        rePasswordTextField.adjustsFontSizeToFitWidth = YES;
        rePasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        UIColor *color = [FPStyleGuide lightGrayTextColor];//RCDLocalizedString(@"nickname")
        rePasswordTextField.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:@"确认密码"
                                            attributes:@{NSForegroundColorAttributeName : color}];
        rePasswordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        [rePasswordTextField addTarget:self
                                action:@selector(textFieldDidChange:)
                      forControlEvents:UIControlEventEditingChanged];

        if (rePasswordTextField.text.length > 0) {
            [rePasswordTextField setFont:[UIFont fontWithName:@"Heiti SC" size:25.0]];
        }
        _rePasswordTextField = rePasswordTextField;
    }
    return _rePasswordTextField;
}

- (RCUnderlineTextField *)inviteTextField {
    if (!_inviteTextField) {
        RCUnderlineTextField *inviteTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];
        inviteTextField.delegate = self;
        inviteTextField.textColor = [UIColor blackColor];
        inviteTextField.returnKeyType = UIReturnKeyDone;
//        rePasswordTextField.secureTextEntry = YES;
        // passwordTextField.delegate = self;
        inviteTextField.adjustsFontSizeToFitWidth = YES;
        inviteTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        UIColor *color = [FPStyleGuide lightGrayTextColor];//RCDLocalizedString(@"nickname")
        inviteTextField.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:@"邀请码(选填)"
                                            attributes:@{NSForegroundColorAttributeName : color}];
        inviteTextField.translatesAutoresizingMaskIntoConstraints = NO;
        [inviteTextField addTarget:self
                                action:@selector(textFieldDidChange:)
                      forControlEvents:UIControlEventEditingChanged];

        if (inviteTextField.text.length > 0) {
            [inviteTextField setFont:[UIFont fontWithName:@"Heiti SC" size:20.0]];
        }
        _inviteTextField = inviteTextField;
    }
    return _inviteTextField;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginButton addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
        [loginButton setTitle:RCDLocalizedString(@"register") forState:UIControlStateNormal];
        loginButton.backgroundColor = [FPStyleGuide weichatGreenColor];//[UIColor colorWithRed:28 / 255.0 green:119 / 255.0 blue:211 / 255.0 alpha:0.95];
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loginButton.layer.cornerRadius = 3;
        loginButton.titleLabel.font = [UIFont systemFontOfSize:23];
        loginButton.translatesAutoresizingMaskIntoConstraints = NO;
        _loginButton = loginButton;
    }
    return _loginButton;
}

- (UIButton *)userProtocolButton {
    if (!_userProtocolButton) {
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
    }
    return _userProtocolButton;
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

- (UIView *)bottomBackground {
    if (!_bottomBackground) {
        UIView *bottomBackground = [[UIView alloc] initWithFrame:CGRectZero];
        bottomBackground.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomBackground = bottomBackground;
    }
    return _bottomBackground;
}

- (UIButton *)getLoginButton {
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 30, 0, 120, 20)];
    [loginButton setTitle:RCDLocalizedString(@"Login") forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor blackColor]
                      forState:UIControlStateNormal];
    loginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

    [loginButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [loginButton addTarget:self action:@selector(loginPageEvent) forControlEvents:UIControlEventTouchUpInside];
    return loginButton;
}

- (UIButton *)getForgetPswButton {
    UIButton *forgetPswButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 120 + 30, 0, 120, 20)];
    [forgetPswButton setTitle:RCDLocalizedString(@"forgot_password") forState:UIControlStateNormal];
    [forgetPswButton setTitleColor:[UIColor blackColor]
                          forState:UIControlStateNormal];
    forgetPswButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    forgetPswButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [forgetPswButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [forgetPswButton addTarget:self action:@selector(forgetPswEvent) forControlEvents:UIControlEventTouchUpInside];
    return forgetPswButton;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 190, SCREEN_WIDTH, 20)];
        _nameLabel.text = @"WOOSTALK";
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.userInteractionEnabled = NO;
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont boldSystemFontOfSize:20];
        
    }
    return _nameLabel;
}
@end
