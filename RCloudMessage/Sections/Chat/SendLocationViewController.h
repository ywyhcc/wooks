//
//  SendLocationViewController.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/11.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDViewController.h"



@interface SendLocationViewController : UIViewController

@property (nonatomic, copy) void (^locationBack)(UIImage *img,CLLocationCoordinate2D location, NSString *name);

@property (nonatomic, strong) NSString *userID;

@property (nonatomic, strong) NSString *groupID;

@end


