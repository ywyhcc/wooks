//
//  MomentMsgModel.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/20.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MomentMsgModel : NSObject

- (id)initWithDictionary:(NSDictionary *)dic;

@property (nonatomic, strong)NSString *createDate;              // 创建时间

@property (nonatomic, strong)NSString *discussContent;          // 评论内容

@property (nonatomic, strong)NSString *momentFileUrl;           //动态文件

@property (nonatomic, strong)NSString *momentId;                //动态ID

@property (nonatomic, strong)NSString *optUserAvartUrl;         //操作人头像

@property (nonatomic, strong)NSString *optUserRemark;           //操作人备注

@property (nonatomic, strong)NSString *replyContent;            //回复内容

@property (nonatomic, strong)NSString *replyedRemark;           //回复人备注

@property (nonatomic, strong)NSString *type;                    //操作类型


@end

NS_ASSUME_NONNULL_END
