//
//  MomentMsgTableViewCell.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/20.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "MomentMsgTableViewCell.h"
#import <WebKit/WebKit.h>

@interface MomentMsgTableViewCell()

@property (nonatomic, strong)UIImageView *headImg;

@property (nonatomic, strong)UIImageView *rightImgView;

@property (nonatomic, strong)UILabel *nameLabel;

@property (nonatomic, strong)UIImageView *zanImg;

@property (nonatomic, strong)UILabel *timeLabel;

@property (nonatomic, strong)UILabel *discussLabel;

@end

@implementation MomentMsgTableViewCell

+ (CGFloat)cellHeight{
    return 85.00;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}


- (void)createUI{
    
    self.headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, ([MomentMsgTableViewCell cellHeight] - 55) / 2, 55, 55)];
    self.headImg.contentMode = UIViewContentModeScaleAspectFit;
    self.headImg.layer.cornerRadius = 5;
    self.headImg.clipsToBounds = YES;
    [self addSubview:self.headImg];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImg.right + 5, 10, SCREEN_WIDTH / 2, 15)];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.nameLabel.font = [UIFont systemFontOfSize:13];
    self.nameLabel.textColor = [UIColor colorWithHex:0x6a687c];
    [self addSubview:self.nameLabel];
    
    self.zanImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.headImg.right + 10, self.nameLabel.bottom + 5, 15, 15)];
    self.zanImg.image = [UIImage imageNamed:@"mixin_img_zan"];
    self.zanImg.hidden = YES;
    [self addSubview:self.zanImg];
    
    self.discussLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImg.right + 5, self.nameLabel.bottom, SCREEN_WIDTH - self.headImg.right - 75, 30)];
    self.discussLabel.font = [UIFont systemFontOfSize:13];
    self.discussLabel.textAlignment = NSTextAlignmentLeft;
    self.discussLabel.textColor = [UIColor blackColor];
    [self addSubview:self.discussLabel];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImg.right + 5, self.discussLabel.bottom, SCREEN_WIDTH, 20)];
    self.timeLabel.textAlignment = NSTextAlignmentLeft;
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    self.timeLabel.textColor = [FPStyleGuide lightGrayTextColor];
    [self addSubview:self.timeLabel];
//
    self.rightImgView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 65,([MomentMsgTableViewCell cellHeight] - 55) / 2, 55, 55)];
    self.rightImgView.contentMode = UIViewContentModeScaleAspectFit;
    self.rightImgView.layer.cornerRadius = 5;
    self.rightImgView.clipsToBounds = YES;
    [self addSubview:self.rightImgView];
}

- (void)updateCellWithModel:(MomentMsgModel*)model{
    
    self.nameLabel.text = model.optUserRemark;
    [self.headImg sd_setImageWithURL:[NSURL URLWithString:model.optUserAvartUrl]];
    
    NSString *timeStr = [NSString stringWithFormat:@"%lld",model.createDate.longLongValue/1000];
    self.timeLabel.text = [NSString converDetailStrToTime:timeStr];
    if (model.momentFileUrl.length > 0) {
        [self.rightImgView sd_setImageWithURL:[NSURL URLWithString:model.momentFileUrl]];
    }
    //点赞
    if ([model.type isEqualToString:@"1"]) {
        self.zanImg.hidden = NO;
        self.discussLabel.hidden = YES;
    }//评论
    else if ([model.type isEqualToString:@"2"]){
        self.zanImg.hidden = YES;
        self.discussLabel.hidden = NO;
        self.discussLabel.text = model.discussContent;
    }//回复
    else if ([model.type isEqualToString:@"3"]){
        self.zanImg.hidden = YES;
        self.discussLabel.hidden = NO;
        self.discussLabel.text = model.replyContent;
    }
}

@end
