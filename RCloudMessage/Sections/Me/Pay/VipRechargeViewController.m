//
//  VipRechargeViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/30.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "VipRechargeViewController.h"
#import "VipRechargeView.h"
#import "RCDUtilities.h"
#import "VipRechargeModel.h"
#import "PaymentManager.h"

@interface VipRechargeViewController ()

@property (nonatomic, strong)NSArray *dataArray;

@property (nonatomic, strong)NSMutableArray *btnArray;

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong)UIButton *weichatBtn;

@property (nonatomic, strong)UIButton *zhifuBtn;

@end

@implementation VipRechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.title = @"会员中心";
    
    self.btnArray = [NSMutableArray arrayWithCapacity:0];
    
    self.view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, RCDScreenHeight - 64 - RCDExtraTopHeight - RCDExtraBottomHeight)];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scrollView];
    
    [self requestRechargeCardInfo];
    
    
//    self.weichatBtn = [self createBtnCell:@"生成微信二维码" imageName:@"add_wechat"];
//    self.weichatBtn.frame = CGRectMake(0, 20, SCREEN_WIDTH, 50);
////    viewBottom = self.weichatBtn.bottom;
//    [self.weichatBtn addTarget:self action:@selector(weixinBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.scrollView addSubview:self.weichatBtn];
//
//    self.zhifuBtn = [self createBtnCell:@"生成支付宝二维码" imageName:@"mixin_ic_alipay"];
//    self.zhifuBtn.frame = CGRectMake(0, self.weichatBtn.bottom, SCREEN_WIDTH, 50);
//    [self.zhifuBtn addTarget:self action:@selector(zhifubaoBtnClicked) forControlEvents:UIControlEventTouchUpInside];
////    viewBottom = self.zhifuBtn.bottom;
//    [self.scrollView addSubview:self.zhifuBtn];
    
//    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, viewBottom);
}

- (UIButton*)createBtnCell:(NSString *)title imageName:(NSString*)imageName{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    
    UIImageView *leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 30, 30)];
    leftImage.image = [UIImage imageNamed:imageName];
    leftImage.backgroundColor = [UIColor whiteColor];
    [button addSubview:leftImage];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftImage.right + 10, 0, SCREEN_WIDTH, 50)];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:13];
    [button addSubview:titleLabel];
    
    UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 25, 15, 8, 20)];
    arrowImage.image = [UIImage imageNamed:@"forward_arrow"];
    [button addSubview:arrowImage];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, SCREEN_WIDTH, 0.5)];
    line.backgroundColor = [UIColor colorWithHex:0xcbcccb];
    [button addSubview:line];
    
    return button;
}

- (void)btnClickedDown:(UIButton*)sender{
    for (VipRechargeView *item in self.btnArray) {
        item.backgroundColor = [UIColor whiteColor];
    }
    sender.backgroundColor = [UIColor colorWithHex:0xcbcccb];
    VipRechargeModel *model = self.dataArray[sender.tag];
    [[PaymentManager shareManager] requestProducts];
}

- (void)weixinBtnClicked{
    
}


- (void)zhifubaoBtnClicked{
    
}

- (void)requestRechargeCardInfo{
    [SYNetworkingManager getWithURLString:RechargeInfo parameters:@{} success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSArray *list = [data arrayValueForKey:@"payMentSpecifications"];
            NSMutableArray *dataMuArr = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *dic in list) {
                VipRechargeModel *model = [[VipRechargeModel alloc] init];
                model.vipID = [dic stringValueForKey:@"id"];
                model.day = [dic stringValueForKey:@"discountPrice"];
                model.money = [dic stringValueForKey:@"price"];
                model.moneyEveryday = [dic stringValueForKey:@"type"];
                [dataMuArr addObject:model];
            }
            self.dataArray = dataMuArr;
            [self updateView];
            
        }
    } failure:^(NSError *error) {
    }];
}

- (void)updateView{
    CGFloat viewBottom = 0;
    CGFloat rechargeWidth = (SCREEN_WIDTH - 50) / 3;
    CGFloat rechargeHeight = 150;
    for (int i = 0; i < self.dataArray.count; i ++) {
        int lie = i % 3;
        int hang = i / 3;
        VipRechargeView *rechargeView = [[VipRechargeView alloc] initWithFrame:CGRectMake(15 + lie * (rechargeWidth + 10),20 + hang * (rechargeHeight + 10), rechargeWidth, rechargeHeight) andModel:self.dataArray[i]];
        [rechargeView addTarget:self action:@selector(btnClickedDown:) forControlEvents:UIControlEventTouchUpInside];
        rechargeView.tag = i;
        [self.scrollView addSubview:rechargeView];
        [self.btnArray addObject:rechargeView];
        viewBottom = rechargeView.bottom;
    }
    
    self.weichatBtn.top = viewBottom + 20;
    self.zhifuBtn.top = self.weichatBtn.bottom;
    viewBottom = self.zhifuBtn.bottom;
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, viewBottom + 20);
}


@end
