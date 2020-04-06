//
//  LocationTableViewCell.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationTableViewCell : UITableViewCell

@property (nonatomic, strong)UILabel *nameLabel;

- (void)updateLabel:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
