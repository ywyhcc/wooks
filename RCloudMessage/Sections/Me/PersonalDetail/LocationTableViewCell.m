//
//  LocationTableViewCell.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "LocationTableViewCell.h"

@implementation LocationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createLabel];
    }
    return self;
}

- (void)createLabel{
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH, 44)];
    self.nameLabel.font = [UIFont systemFontOfSize:17.0];
    self.nameLabel.textColor = [UIColor blackColor];
    [self addSubview:self.nameLabel];
}

- (void)updateLabel:(NSString*)name{
    self.nameLabel.text = name;
}

@end
