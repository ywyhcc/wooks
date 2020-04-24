//
//  ActiveInviteCodeViewController.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/24.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDViewController.h"


@interface ActiveInviteCodeViewController : RCDViewController

@property (nonatomic, copy) void (^sendCallBack)();

@end

