//
//  DetailMomentTableViewCell.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/19.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "DetailMomentTableViewCell.h"
#import "NSString+Util.h"
#import "Moment.h"

@interface DetailMomentTableViewCell()

@property (nonatomic, strong)UILabel *dateLabel;

@property (nonatomic, strong)UIView *imgBgView;

@property (nonatomic, strong)UILabel *detailLabel;

@property (nonatomic, strong)UILabel *countLabel;

@end

@implementation DetailMomentTableViewCell

+ (CGFloat)cellHeight{
    return 100;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}


- (void)createUI{
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 80, 40)];
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.dateLabel.font = [UIFont boldSystemFontOfSize:13];
    [self addSubview:self.dateLabel];
    
    self.imgBgView = [[UIView alloc] initWithFrame:CGRectMake(self.dateLabel.right , self.dateLabel.top, [DetailMomentTableViewCell cellHeight] - 20, [DetailMomentTableViewCell cellHeight] - 20)];
    self.imgBgView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.imgBgView];
    
    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.imgBgView.right + 5, self.imgBgView.top,SCREEN_WIDTH - self.imgBgView.right - 30 , self.imgBgView.height - 10)];
    self.detailLabel.textAlignment = NSTextAlignmentLeft;
    self.detailLabel.numberOfLines = 3;
    self.detailLabel.font = [UIFont systemFontOfSize:15];
    self.detailLabel.textColor = [UIColor blackColor];
    [self addSubview:self.detailLabel];
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.detailLabel.left, self.detailLabel.bottom, self.detailLabel.width, 8)];
    self.countLabel.textColor = [FPStyleGuide lightGrayTextColor];
    self.countLabel.font = [UIFont systemFontOfSize:13];
    self.countLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.countLabel];
    
}

- (void)setMomentData:(Moment*)moment{
    NSString *timeChuo = [NSString stringWithFormat:@"%ld",moment.time];
    NSArray *timeArr = [[NSString convertStrToTime:timeChuo] componentsSeparatedByString:@"-"];
    NSString *riStr = timeArr[2];
    
    NSString *dateStr = [NSString stringWithFormat:@"%@%@月",timeArr[2],timeArr[1]];
    NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:dateStr];
    [noteStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25] range:NSMakeRange(0, riStr.length)];
    self.dateLabel.attributedText = noteStr;
    
    self.detailLabel.text = moment.text;
    if (moment.pictureList.count > 1) {
        self.countLabel.text = [NSString stringWithFormat:@"共%lu张",(unsigned long)moment.pictureList.count];
    }
    else{
        self.countLabel.text = @"";
    }
    if (moment.pictureList.count == 0) {
        self.detailLabel.left = self.imgBgView.left;
        self.detailLabel.width = SCREEN_WIDTH - self.imgBgView.left - 30;
    }
    else {
        self.detailLabel.left = self.imgBgView.right + 5;
        self.detailLabel.width = SCREEN_WIDTH - self.imgBgView.right - 30;
    }
    [self updateImageBgView:moment.pictureList];

}

- (void)updateImageBgView:(NSArray*)fileArr{
    for (UIView * view in self.imgBgView.subviews) {
        [view removeFromSuperview];
    }
//    MPicture
    if (fileArr.count == 1) {
        MPicture *picture = fileArr[0];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.imgBgView.bounds];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        if (picture.thumbnailVideo.length > 0) {
            UIImageView *videoImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.imgBgView.height - 20, 20, 20)];
            videoImg.image = [UIImage imageNamed:@"video_start"];
            [imgView addSubview:videoImg];
            
            [imgView sd_setImageWithURL:[NSURL URLWithString:picture.thumbnailAvert]];
        }
        else {
            [imgView sd_setImageWithURL:[NSURL URLWithString:picture.thumbnail]];
        }
        [self.imgBgView addSubview:imgView];
    }
    else{
        NSUInteger count = fileArr.count;
        if (count > 4) {
            count = 4;
        }
        
        for (int i = 0; i < count; i ++) {
            int leftNum = i % 2;
            int heightNum = i / 2;
            
            MPicture *picture = fileArr[i];
            UIImageView *blockImg = [[UIImageView alloc] initWithFrame:CGRectMake(leftNum * self.imgBgView.height / 2, heightNum * self.imgBgView.height / 2, self.imgBgView.height / 2 - 1, self.imgBgView.height / 2 - 1)];
            blockImg.contentMode = UIViewContentModeScaleAspectFit;
            [blockImg sd_setImageWithURL:[NSURL URLWithString:picture.thumbnail]];
            [self.imgBgView addSubview:blockImg];
        }
    }
}



@end
