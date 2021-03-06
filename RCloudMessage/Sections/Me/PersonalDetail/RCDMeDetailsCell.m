//
//  RCDMeDetailsCell.m
//  RCloudMessage
//
//  Created by Jue on 16/9/9.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDMeDetailsCell.h"
#import "RCDCommonDefine.h"
#import "RCDUtilities.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDCommonString.h"

@interface RCDMeDetailsCell()

@property (nonatomic, strong)UILabel *talkLabel;

@end

@implementation RCDMeDetailsCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init {
    self = [super init];
    if (self) {
        NSString *portraitUrl = [DEFAULTS stringForKey:RCDUserPortraitUriKey];
        self = [[RCDMeDetailsCell alloc] initWithLeftImageStr:portraitUrl
                                                leftImageSize:CGSizeMake(65, 65)
                                                 rightImaeStr:nil
                                               rightImageSize:CGSizeZero];
        self.leftImageCornerRadius = 5.f;
        self.leftLabel.text = [DEFAULTS stringForKey:RCDUserNickNameKey];
        self.leftLabel.textColor = RCDDYCOLOR(0x000000, 0xa8a8a8);
        
    }
    return self;
}


- (void)addDetailLabel{
    if ([DEFAULTS stringForKey:WoosTalkID].length > 0) {
        self.talkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.leftLabel.left, 50, self.leftLabel.width, 20)];
        self.talkLabel.font = [UIFont systemFontOfSize:12];
        self.talkLabel.text = [NSString stringWithFormat:@"woostalk号:%@",[DEFAULTS stringForKey:WoosTalkID]];
        [self addSubview:self.talkLabel];
    }
}

@end
