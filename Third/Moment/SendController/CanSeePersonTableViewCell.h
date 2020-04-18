//
//  CanSeePersonTableViewCell.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDFriendInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface CanSeePersonTableViewCell : UITableViewCell

- (void)setUserInfo:(RCDFriendInfo *)info;

@end

NS_ASSUME_NONNULL_END
