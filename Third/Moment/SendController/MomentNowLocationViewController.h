//
//  MomentNowLocationViewController.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MomentNowLocationViewController : RCDViewController

@property (nonatomic, copy) void (^locationBack)( NSString *name);

@property (nonatomic, strong) NSString *userID;

@property (nonatomic, strong) NSString *groupID;

@end

NS_ASSUME_NONNULL_END
