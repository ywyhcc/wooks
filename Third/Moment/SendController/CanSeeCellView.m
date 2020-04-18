//
//  CanSeeCellView.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "CanSeeCellView.h"

@interface CanSeeCellView()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UIImageView *arrowImage;

@end

@implementation CanSeeCellView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, (frame.size.height - 16) / 2, 16, 16)];
        self.arrowImage.image = [UIImage imageNamed:@"can_see_arrow"];
        self.arrowImage.hidden = YES;
        [self addSubview:self.arrowImage];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, frame.size.width, 20)];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:self.titleLabel];
        
        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, self.titleLabel.bottom, frame.size.width, 15)];
        self.detailLabel.textColor = [FPStyleGuide lightGrayTextColor];
        self.detailLabel.textAlignment = NSTextAlignmentLeft;
        self.detailLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.detailLabel];
        
    }
    return self;
}

- (void)updateTitle:(NSString*)title andDetail:(NSString*)detail{
    self.titleLabel.text = title;
    self.detailLabel.text = detail;
}

- (void)updateSelect:(BOOL)selected{
    if (selected) {
        self.arrowImage.hidden = NO;
    }
    else {
        self.arrowImage.hidden = YES;
    }
}

@end
