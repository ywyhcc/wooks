//
//  LabelEditNameViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "LabelEditNameViewController.h"
#import "RCDUserInfoManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDChatViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDUIBarButtonItem.h"
#import "UIColor+RCColor.h"
#import "RCDCommonString.h"

@interface LabelEditNameViewController ()

@property (nonatomic, strong) UITextField *userNameTextField;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) NSDictionary *subViews;
@property (nonatomic, strong) RCDUIBarButtonItem *rightBtn;
@property (nonatomic, strong) RCDUIBarButtonItem *leftBtn;
@property (nonatomic, strong) NSString *originNickName;

@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation LabelEditNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
    self.userNameTextField.text = self.nameStr;
    self.originNickName = self.nameStr;
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
                 buttonColor:[RCDUtilities generateDynamicColor:[FPStyleGuide lightGrayTextColor]
                                                      darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
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
    self.navigationItem.title = @"标签名字";
}

- (void)setNavigationButton {
    self.leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                              target:self
                                                              action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = self.leftBtn;

    self.rightBtn = [[RCDUIBarButtonItem alloc]
        initWithbuttonTitle:@"确定"
                 titleColor:[RCDUtilities generateDynamicColor:[UIColor blackColor]
                                                     darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                buttonFrame:CGRectMake(0, 0, 50, 30)
                     target:self
                     action:@selector(saveBtnClicked)];
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[RCDUtilities generateDynamicColor:[FPStyleGuide lightGrayTextColor]
                                                             darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                      barButtonItem:self.rightBtn];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

- (void)saveBtnClicked{
    if (self.callBack) {
        self.callBack(self.userNameTextField.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
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
        hud.labelText = @"修改中...";
        _hud = hud;
    }
    return _hud;
}
@end
