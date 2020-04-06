//
//  LabelTableViewCell.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "LabelTableViewCell.h"


@interface LabelTableViewCell()

@property (nonatomic, strong) UILabel * nameLabel;

@property (nonatomic, strong) UILabel *detailLabel;


@end

@implementation LabelTableViewCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self createView];
    }
    return self;
}

+(CGFloat)cellHeight{
    return CellHeight;
}

- (void)createView{
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(33, 0, SCREEN_WIDTH, CellHeight)];
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.font = [UIFont systemFontOfSize:15];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.nameLabel];
    
    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.nameLabel.bottom, SCREEN_WIDTH - 20, 20)];
    self.detailLabel.textColor = [UIColor lightGrayColor];
    self.detailLabel.font = [UIFont systemFontOfSize:13];
    self.detailLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.detailLabel];
}

- (void)updateCellModel:(LabelModel *)model{
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@(%@)",model.labelName,model.count];
//    self.detailLabel.text = @"详细内容成员";
    
}


@end
