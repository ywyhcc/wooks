//
//  RCDFrienfRemarksViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/8/11.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDFriendInfo.h"
#import "RCDViewController.h"
#import "RCDFriendDescription.h"

@interface RCDFriendRemarksViewController : RCDViewController

@property (nonatomic, copy) void (^setRemarksSuccess)();
@property (nonatomic, copy) NSString *friendId;
@property (nonatomic, strong) RCDFriendDescription *friendDescription;

@end
