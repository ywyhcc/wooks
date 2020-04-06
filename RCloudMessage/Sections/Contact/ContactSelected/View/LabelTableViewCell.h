//
//  LabelTableViewCell.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LabelModel.h"

#define CellHeight 60

@interface LabelTableViewCell : UITableViewCell

+ (CGFloat)cellHeight;

- (void)updateCellModel:(LabelModel*)model;

@end
