//
//  MomentMsgTableViewCell.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/20.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MomentMsgModel.h"

@interface MomentMsgTableViewCell : UITableViewCell

+ (CGFloat)cellHeight;

- (void)updateCellWithModel:(MomentMsgModel*)model;

@end
