//
//  VipCardViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/5/21.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "VipCardViewController.h"
#import "RCDCommonString.h"
#import "UIColor+RCColor.h"
#import "VipRechargeViewController.h"

@interface VipCardViewController ()

@property (nonatomic, strong)UILabel *vipLabel;

@property (nonatomic, strong)UILabel *vipDateLabel;

@end

@implementation VipCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"会员中心";
    
    [self createUI];
    
    [self getVipInfo];
}

- (void)getVipInfo{
    NSDictionary *params = @{@"userAccountId":[ProfileUtil getUserAccountID]};
    
    [SYNetworkingManager getWithURLString:GetVipInfo parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSString *status = [data stringValueForKey:@"status"];
            NSString *vipDate = [data stringValueForKey:@"memberExpirationDate"];
            [self updateCardDate:vipDate isVip:status];
        }
    } failure:^(NSError *error) {
    }];
}

- (void)createUI{
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, (SCREEN_WIDTH - 30) / 3 * 2 + 10)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteView];
    
    UIImageView *vipBgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, SCREEN_WIDTH - 30, (SCREEN_WIDTH - 30) / 3 * 2)];
    vipBgView.userInteractionEnabled = YES;
    vipBgView.image = [UIImage imageNamed:@"vip_bg_img"];
    [whiteView addSubview:vipBgView];
    
    UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(40, 35, 40, 40)];
    [headImg sd_setImageWithURL:[NSURL URLWithString:[DEFAULTS stringForKey:RCDUserPortraitUriKey]]];
    [vipBgView addSubview:headImg];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImg.right + 5, headImg.top, SCREEN_WIDTH, 20)];
    nameLabel.textColor = [UIColor colorWithHex:0x6e452c];
    nameLabel.text = [DEFAULTS stringForKey:RCDUserNickNameKey];
    nameLabel.font = [UIFont systemFontOfSize:14];
    [vipBgView addSubview:nameLabel];
    
    self.vipLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImg.right + 5, nameLabel.bottom + 5, SCREEN_WIDTH, 15)];
    self.vipLabel.font = [UIFont systemFontOfSize:14];
    self.vipLabel.textColor = [UIColor colorWithHex:0x6e452c];
    [vipBgView addSubview:self.vipLabel];
    
    self.vipDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImg.left, headImg.bottom + 25, SCREEN_WIDTH, 20)];
    self.vipDateLabel.textColor = [UIColor colorWithHex:0x6e452c];
    self.vipDateLabel.font = [UIFont systemFontOfSize:16];
    self.vipDateLabel.textAlignment = NSTextAlignmentLeft;
    [vipBgView addSubview:self.vipDateLabel];
    
    UIButton *rechargeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rechargeBtn.frame = CGRectMake((vipBgView.width - 60) / 2, self.vipDateLabel.bottom + 25, 60, 35);
    [rechargeBtn setTitle:@"续费" forState:UIControlStateNormal];
    [rechargeBtn setTintColor:[UIColor whiteColor]];
    rechargeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    rechargeBtn.backgroundColor = [FPStyleGuide weichatGreenColor];
    [rechargeBtn addTarget:self action:@selector(onRechargeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    rechargeBtn.layer.cornerRadius = 5;
    rechargeBtn.clipsToBounds = YES;
    [vipBgView addSubview:rechargeBtn];
}

- (void)updateCardDate:(NSString*)dateStr isVip:(NSString*)vipStatus{
    if ([vipStatus isEqualToString:@"1"]) {
        self.vipLabel.text = @"您已成为会员";
        self.vipDateLabel.text = [NSString stringWithFormat:@"会员有效期：%@",[NSString convertStrToTime:dateStr]];
    }
    else if ([vipStatus isEqualToString:@"0"]){
        self.vipLabel.text = @"您还未成为会员";
        self.vipDateLabel.text = @"续费充值可成为会员";
    }
}

- (void)onRechargeBtnClicked{
    VipRechargeViewController *rechargeVC = [[VipRechargeViewController alloc] init];
    [self.navigationController pushViewController:rechargeVC animated:YES];
}


@end
