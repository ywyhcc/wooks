//
//  CanSeeTableViewCell.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "CanSeeTableViewCell.h"

@interface CanSeeTableViewCell()

@property (nonatomic, strong)UILabel *titleLabel;

@property (nonatomic, strong)UIImageView *singleImage;

@end

@implementation CanSeeTableViewCell

+ (CGFloat)cellHeight{
    return 50;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.singleImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, ([CanSeeTableViewCell cellHeight] - 16) / 2, 16, 16)];
        self.singleImage.image = [UIImage imageNamed:@"can_see_unselected"];//can_see_arrow
        [self addSubview:self.singleImage];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, ([CanSeeTableViewCell cellHeight] - 20) / 2, SCREEN_WIDTH, 20)];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:self.titleLabel];
        
    }
    return self;
}

- (void)updateCellData:(LabelModel*)model selected:(BOOL)selected{
    self.titleLabel.text = [NSString stringWithFormat:@"%@(%@)",model.labelName,model.count];
    if (selected) {
        self.singleImage.image = [UIImage imageNamed:@"can_see_arrow"];
    }
    else {
        self.singleImage.image = [UIImage imageNamed:@"can_see_unselected"];
    }
}

@end
