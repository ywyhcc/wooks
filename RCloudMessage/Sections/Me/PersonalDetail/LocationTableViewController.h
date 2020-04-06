//
//  LocationTableViewController.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDTableViewController.h"

typedef enum {
    provence,
    city,
    xian,
} locationType;


@interface LocationTableViewController : RCDTableViewController

@property (nonatomic, strong)NSString *locationID;

@property (nonatomic, assign)locationType type;

@property (nonatomic, strong)NSDictionary *recordDic;

@end

