//
//  MeHeadTableViewCell.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/7.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "MeHeadTableViewCell.h"
#import "RCDCommonString.h"

@interface MeHeadTableViewCell()

@property (nonatomic, strong)UIImageView *headImg;
@property (nonatomic, strong)UILabel *nameLabel;

@property (nonatomic, strong)UILabel *idLabel;

@property (nonatomic, strong)UIImageView *arrowView;

@property (nonatomic, strong)UIButton *headBtn;

@end

@implementation MeHeadTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}


- (void)createUI{
    self.headImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 25, 70, 70)];
    self.headImg.userInteractionEnabled = YES;
    NSString *portraitUrl = [DEFAULTS stringForKey:RCDUserPortraitUriKey];
    self.headImg.layer.cornerRadius = 5;
    self.headImg.clipsToBounds = YES;
    [self.headImg sd_setImageWithURL:[NSURL URLWithString:portraitUrl]];
    [self addSubview:self.headImg];
    
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImg.right + 20, self.headImg.top + 5, SCREEN_WIDTH, self.headImg.height / 3)];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:20];
    self.nameLabel.text = [DEFAULTS stringForKey:RCDUserNickNameKey];
    self.nameLabel.textColor = [UIColor blackColor];
    [self addSubview:self.nameLabel];
    
    self.idLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.left, self.nameLabel.bottom + 10, SCREEN_WIDTH - self.nameLabel.left, self.headImg.height / 3)];
    self.idLabel.textAlignment = NSTextAlignmentLeft;
    self.idLabel.font = [UIFont systemFontOfSize:15];
    self.idLabel.text = [NSString stringWithFormat:@"Woostalk号：%@",[DEFAULTS stringForKey:WoosTalkID]];
    self.idLabel.textColor = [FPStyleGuide lightGrayTextColor];
    [self addSubview:self.idLabel];
    
    self.arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 18, self.headImg.centerY, 8, 13)];
    self.arrowView.image = [UIImage imageNamed:@"right_arrow"];
    self.arrowView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.arrowView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClicked)];
    [self.headImg addGestureRecognizer:tap];
    
//    self.headImg
}

- (void)tapClicked{
    
    self.headBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.headBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.headBtn.backgroundColor = [UIColor clearColor];
    [self.headBtn addTarget:self action:@selector(removeHeadView) forControlEvents:UIControlEventTouchUpInside];
    [[UIApplication sharedApplication].keyWindow addSubview:self.headBtn];
    
    //CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    UIImageView *headImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 0, 0)];
    headImage.backgroundColor = [UIColor blackColor];
    [headImage sd_setImageWithURL:[NSURL URLWithString:[DEFAULTS stringForKey:RCDUserPortraitUriKey]]];
    headImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.headBtn addSubview:headImage];
    
    [UIView animateWithDuration:0.3 animations:^{
        headImage.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
    
}

- (void)removeHeadView{
    [self.headBtn removeFromSuperview];
}




@end
