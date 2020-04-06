//
//  VipRechargeModel.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/30.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VipRechargeModel : NSObject

@property (nonatomic, strong) NSString *vipID;

@property (nonatomic, strong) NSString *day;

@property (nonatomic, strong) NSString *money;

@property (nonatomic, strong) NSString *moneyEveryday;

@end

NS_ASSUME_NONNULL_END
