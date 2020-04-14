//
//  MMUserDetailViewController.h
//  MomentKit
//
//  Created by LEA on 2019/4/15.
//  Copyright © 2019 LEA. All rights reserved.
//
//  用户详细资料
//

#import <UIKit/UIKit.h>
#import "MUser.h"
#import "RCDViewController.h"

@interface MMUserDetailViewController : RCDViewController

@property (nonatomic, strong) MUser * user;

@end

@interface MMUserDetailCell : UITableViewCell

@property (nonatomic, strong) MUser * user;

@end

