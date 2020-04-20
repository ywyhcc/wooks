//
//  MomentMsgModel.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/20.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "MomentMsgModel.h"

@implementation MomentMsgModel


- (id)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        
        self.createDate = [dic stringValueForKey:@"createDate"];
        self.discussContent = [dic stringValueForKey:@"discussContent"];
        self.momentFileUrl = [dic stringValueForKey:@"momentFileUrl"];
        self.momentId = [dic stringValueForKey:@"momentId"];
        self.optUserAvartUrl = [dic stringValueForKey:@"optUserAvartUrl"];
        self.optUserRemark = [dic stringValueForKey:@"optUserRemark"];
        self.replyContent = [dic stringValueForKey:@"replyContent"];
        self.replyedRemark = [dic stringValueForKey:@"replyedRemark"];
        self.type = [dic stringValueForKey:@"type"];
        
    }
    return self;
}

@end
