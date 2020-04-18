//
//  CanSeeTableViewCell.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LabelModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CanSeeTableViewCell : UITableViewCell

- (void)updateCellData:(LabelModel*)model selected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
