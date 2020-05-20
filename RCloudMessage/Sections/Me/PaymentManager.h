//
//  PaymentManager.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/5/17.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PaymentManager : NSObject

+ (instancetype)shareManager;

- (void)requestProducts;

@end

NS_ASSUME_NONNULL_END
