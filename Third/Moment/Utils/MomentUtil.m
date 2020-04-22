//
//  MomentUtil.m
//  MomentKit
//
//  Created by LEA on 2019/2/1.
//  Copyright © 2019 LEA. All rights reserved.
//

#import "MomentUtil.h"
#import "JKDBHelper.h"
#import "Message.h"
#import "RCDCommonString.h"

@implementation MomentUtil

#pragma mark - 获取
// 获取动态集合
+ (NSArray *)getMomentListDic:(NSDictionary *)dic
{
//    NSString * sql = nil;
//    if (momentId == 0) {
//        sql = [NSString stringWithFormat:@"ORDER BY pk DESC limit %d",pageNum];
//    } else {
//        sql = [NSString stringWithFormat:@"WHERE pk < %d ORDER BY pk DESC limit %d",momentId,pageNum];
//    }
    NSArray *tempList = dic[@"allMoments"][@"records"];
    
    NSMutableArray * momentList = [[NSMutableArray alloc] init];
//    NSArray * tempList = [Moment findByCriteria:sql];
//    NSInteger count = [tempList count];
    for (NSInteger i = 0; i < tempList.count; i ++)
    {
        Moment * moment = [[Moment alloc] init];
        moment.time = 1555382410;
        moment.singleWidth = 500;
        moment.singleHeight = 302;
//        moment.isLike = 0;
        moment.text = tempList[i][@"momentAbout"];
        moment.discussIdStr = tempList[i][@"id"];
        moment.userIds = tempList[i][@"momentCreateUser"][@"userAccountId"];
        // 处理评论 ↓↓
        NSArray * idList = tempList[i][@"discuss"];///评论个数
        NSInteger count = [idList count];
        NSMutableArray * list = [NSMutableArray array];
        for (NSInteger i = 0; i < count; i ++)
        {
            NSString *typeStr = idList[i][@"type"];
            NSInteger pk = i + 1;
            Comment * comment = [[Comment alloc] init];//获取评论的内容
            comment.pk = pk;
            comment.text = [NSString stringWithFormat:@"%@", [idList[i] stringValueForKey:@"content"] ];//, idList[i][@"discussId"]
            comment.commentDiscussIdStr = [idList[i] stringValueForKey:@"discussId"];
            comment.fromId = 4;
            comment.toId = typeStr.intValue;
            comment.fromUserAccountIdStr = [idList[i] stringValueForKey:@"fromUserAccountId"];
            
            MUser * user1 = nil;
            NSString *accoutIdStr = [idList[i] stringValueForKey:@"fromUserAccountId"];
            if (comment.fromId != 0) {
                user1 = [[MUser alloc] init];//[MUser findFirstByCriteria:[NSString stringWithFormat:@"WHERE PK = %ld",(long)comment.fromId]];
                user1.pk = 5;
                user1.type = [accoutIdStr isEqualToString:[ProfileUtil getUserAccountID]] ? 1 : 0;//1是自己 0是他人
                user1.name = [idList[i] stringValueForKey:@"userNickName"];
                user1.account = accoutIdStr;
                user1.portrait = nil;
                user1.region = nil;
            } else {
                user1 = nil;
            }
            
            comment.fromUser = user1;
            
            MUser * user2 = nil;
            
            if (comment.toId == 2) {
                NSString *accoutIdStr = [idList[i] stringValueForKey:@"toUserAccountId"];
                user2 = [[MUser alloc] init];//[MUser findFirstByCriteria:[NSString stringWithFormat:@"WHERE PK = %ld",(long)comment.toId]];
                user2.pk = 6;
                user2.type = [accoutIdStr isEqualToString:[ProfileUtil getUserAccountID]] ? 1 : 0;
                user2.name = [idList[i] stringValueForKey:@"replyedUserNickName"];
                user2.account = accoutIdStr;
                user2.portrait = nil;
                user2.region = nil;
            } else {
                user2 = nil;
            }
            comment.toUser = user2;
            if (comment) {
               [list addObject:comment];
            }
        }
        moment.commentList = list;
        // 处理赞  ↓↓
        idList = [tempList[i] arrayValueForKey:@"likeUsers"];
        NSString *momentIdStr = [tempList[i] stringValueForKey:@"id"];
        count = [idList count];
        list = [NSMutableArray array];
        for (NSInteger i = 0; i < count; i ++)
        {
            NSString *accoutIdStr = [idList[i] stringValueForKey:@"createUser"];
            NSInteger pk = i+1;
            MUser * user = [[MUser alloc] init];
            user.pk = pk;
            user.type = [accoutIdStr isEqualToString:[ProfileUtil getUserAccountID]] ? 1 : 0;//1是自己 0是他人
            user.name = [idList[i] stringValueForKey:@"nickName"];
            user.account = [idList[i] stringValueForKey:@"createUser"];
            user.portrait = [idList[i] stringValueForKey:@"avaterUrl"];
            if (!moment.isLike) {
                moment.isLike = [accoutIdStr isEqualToString:[ProfileUtil getUserAccountID]] ? 1 : 0;
            }
            user.momentIdStr = momentIdStr;
            user.region = @"";
            if (user) {
                [list addObject:user];
            }
        }
        moment.likeList = list;
        // 处理图片 ↓↓
        idList = [tempList[i] arrayValueForKey:@"momentFiles"];
        count = [idList count];
        list = [NSMutableArray array];
        for (NSInteger i = 0; i < count; i ++)
        {
            NSInteger pk = i+1;
            MPicture * pic = [[MPicture alloc] init];//[MPicture findFirstByCriteria:[NSString stringWithFormat:@"WHERE PK = %ld",(long)pk]];
            pic.thumbnail = [idList[i] stringValueForKey:@"fileUrl"];
            NSString *fileTypeStr = [idList[i] stringValueForKey:@"fileType"];
            if (fileTypeStr.intValue == 2) {
                pic.thumbnailVideo = [idList[i] stringValueForKey:@"fileUrl"];
                pic.thumbnailAvert = [idList[i] stringValueForKey:@"fileThumbnailUrl"];
            }
            //这里做一个处理
            if (pic) {
                if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
                    [list addObject:pic];
                }
            }
        }
        moment.pictureList = list;
        
        // 发布者
        
        NSString *accoutIdStr = tempList[i][@"momentCreateUser"][@"createUser"];
        
        MUser * user = [[MUser alloc] init];
        user.pk = i+1;
        user.type = [accoutIdStr isEqualToString:[ProfileUtil getUserAccountID]] ? 1 : 0;//1是自己 0是他人
        user.name = tempList[i][@"momentCreateUser"][@"nickName"];
        user.account = tempList[i][@"momentCreateUser"][@"createUser"];
        user.portrait = tempList[i][@"momentCreateUser"][@"avaterUrl"];
        user.region = nil;
        moment.user = user;
        // 位置
        MLocation * location = [MLocation findByPK:1];
        location.pk = i+1;
        location.position = tempList[i][@"location"];
        moment.location = location;
        NSString *timeCreatTimeStr = tempList[i][@"createDate"];
        moment.time = timeCreatTimeStr.longLongValue/1000;
        // == 加入集合
        [momentList addObject:moment];
    }
    return momentList;
}

+ (NSArray*)getOtherMomentListDic:(NSDictionary *)dic{
    NSArray *tempList = dic[@"myMomentLog"][@"records"];
        
    NSMutableArray * momentList = [[NSMutableArray alloc] init];
//    NSArray * tempList = [Moment findByCriteria:sql];
//    NSInteger count = [tempList count];
    for (NSInteger i = 0; i < tempList.count; i ++)
    {
        Moment * moment = [[Moment alloc] init];
        moment.time = 1555382410;
        moment.singleWidth = 500;
        moment.singleHeight = 302;
//        moment.isLike = 0;
        moment.text = tempList[i][@"momentAbout"];
        moment.discussIdStr = tempList[i][@"id"];
        moment.userIds = tempList[i][@"momentCreateUser"][@"userAccountId"];
        // 处理评论 ↓↓
        NSArray * idList = tempList[i][@"discuss"];///评论个数
        NSInteger count = [idList count];
        NSMutableArray * list = [NSMutableArray array];
        for (NSInteger i = 0; i < count; i ++)
        {
            NSString *typeStr = idList[i][@"type"];
            NSInteger pk = i + 1;
            Comment * comment = [[Comment alloc] init];//获取评论的内容
            comment.pk = pk;
            comment.text = [NSString stringWithFormat:@"%@", idList[i][@"content"]];//, idList[i][@"discussId"]
            comment.commentDiscussIdStr = idList[i][@"discussId"];
            comment.fromId = 4;
            comment.toId = typeStr.intValue;
            comment.fromUserAccountIdStr = idList[i][@"fromUserAccountId"];
            
            MUser * user1 = nil;
            NSString *accoutIdStr = idList[i][@"fromUserAccountId"];
            if (comment.fromId != 0) {
                user1 = [[MUser alloc] init];//[MUser findFirstByCriteria:[NSString stringWithFormat:@"WHERE PK = %ld",(long)comment.fromId]];
                user1.pk = 5;
                user1.type = [accoutIdStr isEqualToString:[ProfileUtil getUserAccountID]] ? 1 : 0;//1是自己 0是他人
                user1.name = idList[i][@"userNickName"];
                user1.account = accoutIdStr;
                user1.portrait = nil;
                user1.region = nil;
            } else {
                user1 = nil;
            }
            
            comment.fromUser = user1;
            
            MUser * user2 = nil;
            
            if (comment.toId == 2) {
                NSString *accoutIdStr = idList[i][@"toUserAccountId"];
                user2 = [[MUser alloc] init];//[MUser findFirstByCriteria:[NSString stringWithFormat:@"WHERE PK = %ld",(long)comment.toId]];
                user2.pk = 6;
                user2.type = [accoutIdStr isEqualToString:[ProfileUtil getUserAccountID]] ? 1 : 0;
                user2.name = idList[i][@"replyedUserNickName"];
                user2.account = accoutIdStr;
                user2.portrait = nil;
                user2.region = nil;
            } else {
                user2 = nil;
            }
            comment.toUser = user2;
            if (comment) {
               [list addObject:comment];
            }
        }
        moment.commentList = list;
        // 处理赞  ↓↓
        idList = tempList[i][@"likeUsers"];
        NSString *momentIdStr = tempList[i][@"id"];
        count = [idList count];
        list = [NSMutableArray array];
        for (NSInteger i = 0; i < count; i ++)
        {
            NSString *accoutIdStr = idList[i][@"createUser"];
            NSInteger pk = i+1;
            MUser * user = [[MUser alloc] init];
            user.pk = pk;
            user.type = [accoutIdStr isEqualToString:[ProfileUtil getUserAccountID]] ? 1 : 0;//1是自己 0是他人
            user.name = idList[i][@"nickName"];
            user.account = idList[i][@"createUser"];
            user.portrait = idList[i][@"avaterUrl"];
            if (!moment.isLike) {
                moment.isLike = [accoutIdStr isEqualToString:[ProfileUtil getUserAccountID]] ? 1 : 0;
            }
            user.momentIdStr = momentIdStr;
            user.region = @"";
            if (user) {
                [list addObject:user];
            }
        }
        moment.likeList = list;
        // 处理图片 ↓↓
        idList = tempList[i][@"momentFiles"];
        count = [idList count];
        list = [NSMutableArray array];
        for (NSInteger i = 0; i < count; i ++)
        {
            NSInteger pk = i+1;
            MPicture * pic = [[MPicture alloc] init];//[MPicture findFirstByCriteria:[NSString stringWithFormat:@"WHERE PK = %ld",(long)pk]];
            pic.thumbnail = idList[i][@"fileUrl"];
            NSString *fileTypeStr = idList[i][@"fileType"];
            if (fileTypeStr.intValue == 2) {
                pic.thumbnailVideo = idList[i][@"fileUrl"];
                pic.thumbnailAvert = idList[i][@"fileThumbnailUrl"];
            }
            
            if (pic) {
                [list addObject:pic];
            }
        }
        moment.pictureList = list;
        
        // 发布者
        
        NSString *accoutIdStr = tempList[i][@"momentCreateUser"][@"createUser"];
        
        MUser * user = [[MUser alloc] init];
        user.pk = i+1;
        user.type = [accoutIdStr isEqualToString:[ProfileUtil getUserAccountID]] ? 1 : 0;//1是自己 0是他人
        user.name = tempList[i][@"momentCreateUser"][@"nickName"];
        user.account = tempList[i][@"momentCreateUser"][@"createUser"];
        user.portrait = tempList[i][@"momentCreateUser"][@"avaterUrl"];
        user.region = nil;
        moment.user = user;
        // 位置
        MLocation * location = [MLocation findByPK:1];
        location.pk = i+1;
        location.position = tempList[i][@"location"];
        moment.location = location;
        NSString *timeCreatTimeStr = tempList[i][@"createDate"];
        moment.time = timeCreatTimeStr.longLongValue/1000;
        // == 加入集合
        [momentList addObject:moment];
    }
    return momentList;
}

+ (Moment*)getSingleMomentWithDic:(NSDictionary*)dic{
    Moment * moment = [[Moment alloc] init];
    moment.time = 1555382410;
    moment.singleWidth = 500;
    moment.singleHeight = 302;
//        moment.isLike = 0;
    moment.text = dic[@"momentAbout"];
    moment.discussIdStr = dic[@"momentDetail"][@"id"];
    moment.userIds = dic[@"momentCreateUser"][@"userAccountId"];
    // 处理评论 ↓↓
    NSArray * idList = dic[@"discuss"];///评论个数
    NSInteger count = [idList count];
    NSMutableArray * list = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i ++)
    {
        NSString *typeStr = idList[i][@"type"];
        NSInteger pk = i + 1;
        Comment * comment = [[Comment alloc] init];//获取评论的内容
        comment.pk = pk;
        comment.text = [NSString stringWithFormat:@"%@", idList[i][@"content"]];//, idList[i][@"discussId"]
        comment.commentDiscussIdStr = idList[i][@"discussId"];
        comment.fromId = 4;
        comment.toId = typeStr.intValue;
        comment.fromUserAccountIdStr = idList[i][@"fromUserAccountId"];
        
        MUser * user1 = nil;
        NSString *accoutIdStr = idList[i][@"fromUserAccountId"];
        if (comment.fromId != 0) {
            user1 = [[MUser alloc] init];//[MUser findFirstByCriteria:[NSString stringWithFormat:@"WHERE PK = %ld",(long)comment.fromId]];
            user1.pk = 5;
            user1.type = [accoutIdStr isEqualToString:[ProfileUtil getUserAccountID]] ? 1 : 0;//1是自己 0是他人
            user1.name = idList[i][@"userNickName"];
            user1.account = accoutIdStr;
            user1.portrait = nil;
            user1.region = nil;
        } else {
            user1 = nil;
        }
        
        comment.fromUser = user1;
        
        MUser * user2 = nil;
        
        if (comment.toId == 2) {
            NSString *accoutIdStr = idList[i][@"toUserAccountId"];
            user2 = [[MUser alloc] init];//[MUser findFirstByCriteria:[NSString stringWithFormat:@"WHERE PK = %ld",(long)comment.toId]];
            user2.pk = 6;
            user2.type = [accoutIdStr isEqualToString:[ProfileUtil getUserAccountID]] ? 1 : 0;
            user2.name = idList[i][@"replyedUserNickName"];
            user2.account = accoutIdStr;
            user2.portrait = nil;
            user2.region = nil;
        } else {
            user2 = nil;
        }
        comment.toUser = user2;
        if (comment) {
           [list addObject:comment];
        }
    }
    moment.commentList = list;
    // 处理赞  ↓↓
    idList = dic[@"likeUsers"];
    NSString *momentIdStr = dic[@"id"];
    count = [idList count];
    list = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i ++)
    {
        NSString *accoutIdStr = idList[i][@"createUser"];
        NSInteger pk = i+1;
        MUser * user = [[MUser alloc] init];
        user.pk = pk;
        user.type = [accoutIdStr isEqualToString:[ProfileUtil getUserAccountID]] ? 1 : 0;//1是自己 0是他人
        user.name = idList[i][@"nickName"];
        user.account = idList[i][@"createUser"];
        user.portrait = idList[i][@"avaterUrl"];
        if (!moment.isLike) {
            moment.isLike = [accoutIdStr isEqualToString:[ProfileUtil getUserAccountID]] ? 1 : 0;
        }
        user.momentIdStr = momentIdStr;
        user.region = @"";
        if (user) {
            [list addObject:user];
        }
    }
    moment.likeList = list;
    // 处理图片 ↓↓
    idList = dic[@"momentFiles"];
    count = [idList count];
    list = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i ++)
    {
        NSInteger pk = i+1;
        MPicture * pic = [[MPicture alloc] init];//[MPicture findFirstByCriteria:[NSString stringWithFormat:@"WHERE PK = %ld",(long)pk]];
        pic.thumbnail = idList[i][@"fileUrl"];
        NSString *fileTypeStr = idList[i][@"fileType"];
        if (fileTypeStr.intValue == 2) {
            pic.thumbnailVideo = idList[i][@"fileUrl"];
            pic.thumbnailAvert = idList[i][@"fileThumbnailUrl"];
        }
        
        if (pic) {
            [list addObject:pic];
        }
    }
    moment.pictureList = list;
    
    // 发布者
    
    NSString *accoutIdStr = dic[@"momentCreateUser"][@"createUser"];
    
    MUser * user = [[MUser alloc] init];
    user.pk = 1;
    user.type = [accoutIdStr isEqualToString:[ProfileUtil getUserAccountID]] ? 1 : 0;//1是自己 0是他人
    user.name = dic[@"momentCreateUser"][@"nickName"];
    user.account = dic[@"momentCreateUser"][@"createUser"];
    user.portrait = dic[@"momentCreateUser"][@"avaterUrl"];
    user.region = nil;
    moment.user = user;
    // 位置
    MLocation * location = [MLocation findByPK:1];
    location.pk = 1;
    location.position = dic[@"momentDetail"][@"location"];
    moment.location = location;
    NSString *timeCreatTimeStr = dic[@"momentDetail"][@"createDate"];
    moment.time = timeCreatTimeStr.longLongValue/1000;
    return moment;
}

#pragma mark - 辅助方法
// 获取ids
+ (NSString *)getIdsByMaxPK:(NSInteger)maxPK
{
    NSMutableString * ids = [[NSMutableString alloc] init];
    for (int i = 1; i <= maxPK; i ++) {
        if (i == maxPK) {
            [ids appendString:[NSString stringWithFormat:@"%d",i]];
        } else {
            [ids appendString:[NSString stringWithFormat:@"%d,",i]];
        }
    }
    return ids;
}

// id集合
+ (NSArray *)getIdListByIds:(NSString *)ids
{
    if (ids.length == 0) {
        return nil;
    }
    return [ids componentsSeparatedByString:@","];
}

// ids
+ (NSString *)getIdsByIdList:(NSArray *)idList
{
    NSMutableString * ids = [[NSMutableString alloc] init];
    NSInteger count = [idList count];
    for (NSInteger i = 0; i < count; i ++) {
        NSString * idd = [idList objectAtIndex:i];
        if (i == count - 1) {
            [ids appendString:[NSString stringWithFormat:@"%@",idd]];
        } else {
            [ids appendString:[NSString stringWithFormat:@"%@,",idd]];
        }
    }
    return ids;
}

// 数组转字符
+ (NSString *)getLikeString:(Moment *)moment
{
    NSMutableString * likeString = [[NSMutableString alloc] init];
    NSInteger count = [moment.likeList count];
    for (NSInteger i = 0; i < count; i ++)
    {
        MUser * user = [moment.likeList objectAtIndex:i];
        if (i == 0) {
            [likeString appendString:user.name];
        } else {
            [likeString appendString:[NSString stringWithFormat:@"，%@",user.name]];
        }
    }
    return likeString;
}

#pragma mark - 初始化

@end
