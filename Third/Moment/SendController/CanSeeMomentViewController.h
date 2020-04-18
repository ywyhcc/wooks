//
//  CanSeeMomentViewController.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

@interface CanSeeMomentViewController : RCDViewController

@property (nonatomic, copy) void (^canSeeCallBack)(NSArray *membersID,BOOL isSomeCanSee,NSArray *labelsID);

@end


