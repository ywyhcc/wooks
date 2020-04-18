//
//  CanSeePersonTableViewCell.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "CanSeePersonTableViewCell.h"

@interface CanSeePersonTableViewCell()

@property (nonatomic, strong) UIImageView *iPhoto;
@property (nonatomic, strong) UILabel *labelName;

@end

@implementation CanSeePersonTableViewCell

+ (CGFloat)cellHeight{
    return 50;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {

        [self updateUI];
    }

    return self;
}

#pragma mark - private
//
- (void)updateUI {
    UIImage *image = [UIImage imageNamed:@"contact"];
    self.iPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 30, 30)];
    self.iPhoto.image = image;
    self.iPhoto.backgroundColor = [UIColor clearColor];
    [self addSubview:self.iPhoto];

    self.labelName = [[UILabel alloc] initWithFrame:CGRectMake(self.iPhoto.right + 10, 0, 200, [CanSeePersonTableViewCell cellHeight])];
    self.labelName.backgroundColor = [UIColor clearColor];
    [self addSubview:self.labelName];
}

- (void)rcCellDefault {
    self.labelName.text = nil;
    self.iPhoto.image = nil;
}

#pragma mark - custom
//
- (void)setUserInfo:(RCDFriendInfo *)info {
    [self rcCellDefault];

    [self.iPhoto sd_setImageWithURL:[NSURL URLWithString:info.portraitUri]
                   placeholderImage:[UIImage imageNamed:@"contact"]];
    self.labelName.text = info.name;

}

//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//    self.iPhoto.center = CGPointMake(15 + self.iPhoto.frame.size.width / 2, self.frame.size.height / 2);
//    self.labelName.center = CGPointMake(self.iPhoto.frame.origin.x + self.iPhoto.frame.size.width + 10 +
//                                            self.labelName.frame.size.width / 2,
//                                        self.frame.size.height / 2);
//}


@end
