//
//  LabelEditNameViewController.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

@interface LabelEditNameViewController : RCDViewController

@property(nonatomic, strong)NSString *nameStr;

@property (nonatomic, copy) void (^callBack)(NSString *name);

@end
