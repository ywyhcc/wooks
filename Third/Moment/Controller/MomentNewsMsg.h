//
//  MomentNewsMsg.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/24.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MomentNewsMsg : NSObject

@property (nonatomic)BOOL shouldShowMessage;

+ (MomentNewsMsg *)shareInstance;

@end

NS_ASSUME_NONNULL_END
