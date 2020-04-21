//
//  MomentUtil.h
//  MomentKit
//
//  Created by LEA on 2019/2/1.
//  Copyright © 2019 LEA. All rights reserved.
//
//  Moment、Comment、MUser(赞)、MPicture之间的关联均以Model存储的PK为关联。
//  正常应该是由JSON数据转化，这么做主要为了测试方便。
//

#import <Foundation/Foundation.h>
#import "Comment.h"
#import "Moment.h"
#import "Message.h"
#import "MPicture.h"
#import "MLocation.h"
#import "MUser.h"

@interface MomentUtil : NSObject

@property (nonatomic, strong) Message * message;

// 获取动态集合
+ (NSArray *)getMomentListDic:(NSDictionary *)dic;

//获取他人动态集合
+ (NSArray *)getOtherMomentListDic:(NSDictionary *)dic;
// 获取字符数组
+ (NSString *)getLikeString:(Moment *)moment;
//获取单个朋友圈详情
+ (Moment*)getSingleMomentWithDic:(NSDictionary*)dic;

// id集合
+ (NSArray *)getIdListByIds:(NSString *)ids;
// ids
+ (NSString *)getIdsByIdList:(NSArray *)idList;


@end
