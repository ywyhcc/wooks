//
//  DetailMomentTableViewCell.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/19.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailMomentTableViewCell : UITableViewCell

+ (CGFloat)cellHeight;

- (void)setMomentData:(Moment*)moment;

@end

NS_ASSUME_NONNULL_END
