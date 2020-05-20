//
//  VipRechargeView.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/30.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "VipRechargeView.h"
#import "VipRechargeModel.h"

@interface VipRechargeView()

@property (nonatomic, strong)UILabel *dayLabel;

@property (nonatomic, strong)UILabel *moneyLabel;

@property (nonatomic, strong)UILabel *moneyEverydayLabel;

@end

@implementation VipRechargeView

- (instancetype)initWithFrame:(CGRect)frame andModel:(VipRechargeModel*)model
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        [self createModelView:model];
    }
    return self;
}

- (void)createModelView:(VipRechargeModel*)model{
    self.dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height / 3)];
    self.dayLabel.textAlignment = NSTextAlignmentCenter;
    self.dayLabel.text = model.day;//[NSString stringWithFormat:@"%@",model.day];
    self.dayLabel.font = [UIFont systemFontOfSize:12];
    self.dayLabel.textColor = [UIColor colorWithHex:0x24db5a];
    [self addSubview:self.dayLabel];
    
    self.moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height / 3, self.width, self.height / 3)];
    self.moneyLabel.textAlignment = NSTextAlignmentCenter;
    self.moneyLabel.font = [UIFont systemFontOfSize:25];
    self.moneyLabel.text = model.money;
    self.moneyLabel.textColor = [UIColor colorWithHex:0x24db5a];
    [self addSubview:self.moneyLabel];
    
    self.moneyEverydayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height / 3 * 2, self.width, self.height / 3)];
    self.moneyEverydayLabel.textAlignment = NSTextAlignmentCenter;
    self.moneyEverydayLabel.text = model.moneyEveryday;//[NSString stringWithFormat:@"%@",model.moneyEveryday];
    self.moneyEverydayLabel.font = [UIFont systemFontOfSize:12];
    self.moneyEverydayLabel.textColor = [UIColor colorWithHex:0x24db5a];
    [self addSubview:self.moneyEverydayLabel];
}

@end
