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
                user1 = [MUser findFirstByCriteria:[NSString stringWithFormat:@"WHERE PK = %ld",(long)comment.fromId]];
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
                user2 = [MUser findFirstByCriteria:[NSString stringWithFormat:@"WHERE PK = %ld",(long)comment.toId]];
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
            MPicture * pic = [MPicture findFirstByCriteria:[NSString stringWithFormat:@"WHERE PK = %ld",(long)pk]];
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
            user1 = [MUser findFirstByCriteria:[NSString stringWithFormat:@"WHERE PK = %ld",(long)comment.fromId]];
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
            user2 = [MUser findFirstByCriteria:[NSString stringWithFormat:@"WHERE PK = %ld",(long)comment.toId]];
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
        MPicture * pic = [MPicture findFirstByCriteria:[NSString stringWithFormat:@"WHERE PK = %ld",(long)pk]];
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

// 用于生成测试数据
+ (void)createData
{
    // 名字
    NSArray * names = @[@"刘瑾",
//                        @"陈哲轩",
//                        @"安鑫",
//                        @"欧阳沁",
//                        @"韩艺",
//                        @"宋铭",
//                        @"童璐",
                        @"赵星桐"];
    // 头像网络图片
    NSArray * images = @[@"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=239815455,722413567&fm=26&gp=0.jpg",
//                         @"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=3541265676,1400518403&fm=26&gp=0.jpg",
//                         @"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=4048148084,3143739835&fm=26&gp=0.jpg",
//                         @"https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=1332016725,373543071&fm=26&gp=0.jpg",
//                         @"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=2602067745,3002996441&fm=26&gp=0.jpg",
//                         @"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1475395453,2108906778&fm=26&gp=0.jpg",
//                         @"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=607325505,1723717136&fm=26&gp=0.jpg",
//                         @"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=303738546,3651368779&fm=26&gp=0.jpg",
//                         @"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3720222383,755636251&fm=26&gp=0.jpg",
                         @"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3089533896,892066834&fm=26&gp=0.jpg"];
    // 内容
    NSArray * contents = @[@"鹟是一种身体小，嘴稍扁平，基部有许多刚毛，脚短小的益鸟。",
//                           @"画家把她描绘成一个临江而立的忧伤女子。🔥🔥",
//                           @"不要以为这是👉白浅上神👈，这只是一只可爱的文须雀。",
//                           @"这种鸟上体棕黄色，翅黑色具白色翅斑，外侧尾羽白色。",
//                           @"这是一只胖胖的剪嘴鸥，作者以黑白红三种分明的颜色描绘她，其实很符合剪嘴鸥的形象。",
//                           @"这是网上很火的一个孤影夕阳红的故事，一只白鹭立与夕阳下的湖泊，红色的夕阳把一切都染上了一层绯红。",
//                           @"“不要脸”画家呼葱觅蒜再出新作，以飞鸟为材画出仙侠新境界。",
//                           @"蜀绣又名“川绣”，是在丝绸或其他织物上采用蚕丝线绣出花纹图案的中国传统工艺",
//                           @"昨夜雨疏风骤，浓睡不消残酒。试问卷帘人，却道海棠依旧。知否，知否？应是绿肥红瘦。",
                           @"安利我喜欢的插画师：晓艺大佬。"];
    
    // 用户 ↓↓
    NSInteger max = [names count];
    Comment * formerComment = nil; // 前一个
    for (NSInteger i = 0; i < 1000; i ++)
    {
        // 用户
        MUser * user = [[MUser alloc] init];
        user.type = 0;
        user.name = @"zzd";
        user.portrait = [images objectAtIndex:0];
        user.account = @"wxid12345678";
        user.region = @"浙江 杭州";
        [user save];
        // 消息
        Message * message = [[Message alloc] init];
        message.time = 1555382410;
        message.userName = [names objectAtIndex:0];
        message.userPortrait = [images objectAtIndex:0];
        message.content = [contents objectAtIndex:0];
        [message save];
        // 评论
        Comment * comment = [[Comment alloc] init];
        comment.pk = i;
        comment.text = [contents objectAtIndex:1];
        if (i == 0) {
            comment.fromId = arc4random() % 10 + 1;
            comment.toId = 0;
        } else {
            NSInteger fromId = arc4random() % 10 + 1;
            if (fromId == formerComment.fromId) {
                comment.fromId = fromId;
                comment.toId = 0;
            } else {
                comment.fromId = fromId;
                comment.toId = formerComment.fromId;
            }
        }
        [comment save];
        formerComment = comment;
        // 图片
        MPicture * picture = [[MPicture alloc] init];
        picture.thumbnail = [images objectAtIndex:0];
        [picture save];
    }
    
    // 当前用户
    MUser * user = [[MUser alloc] init];
    user.type = 1;
    user.name = [DEFAULTS objectForKey:RCDUserNickNameKey];
    user.account = [ProfileUtil getUserAccountID];//@"wxid12345678";
    user.region = @"浙江 杭州";
    [user saveOrUpdateByColumnName:@"type" AndColumnValue:@"1"];
    
    // 位置
    MLocation * location = [[MLocation alloc] init];
    location.position = @"杭州 · 雷峰塔景区";
    location.landmark = @"雷峰塔景区";
    location.address = @"杭州市西湖区南山路15号";
    location.latitude = 30.231250;
    location.longitude = 120.148550;
    [location save];
    
    // 动态  ↓↓
    for (int i = 0; i < 1; i ++)
    {
        // 动态
        Moment * moment = [[Moment alloc] init];
        moment.userId = arc4random() % 10 + 1;
        moment.likeIds = [MomentUtil getIdsByMaxPK:arc4random() % 10 + 1];
        moment.commentIds = [MomentUtil getIdsByMaxPK:arc4random() % 5 + 1];
        moment.pictureIds = [MomentUtil getIdsByMaxPK:arc4random() % 9 + 1];
        moment.time = 1555382410;
        moment.singleWidth = 500;
        moment.singleHeight = 302;
//        moment.isLike = 0;
        if (i == 0) {
            moment.text = @"“不要脸”画家呼葱觅蒜再出新作，以飞鸟为材画出仙侠新境界。详见链接：https://baijiahao.baidu.com/s?id=1611814670460612719&wfr=spider&for=pc";
        } else if (i % 3 == 0) {
            moment.text = @"蜀绣又名“川绣”，是在丝绸或其他织物上采用蚕丝线绣出花纹图案的中国传统工艺，主要指以四川成都为中心的川西平原一带的刺绣。蜀绣最早见于西汉的记载，当时的工艺已相当成熟，同时传承了图案配色鲜艳、常用红绿颜色的特点。蜀绣又名“川绣”，是在丝绸或其他织物上采用蚕丝线绣出花纹图案的中国传统工艺，主要指以四川成都为中心的川西平原一带的刺绣。蜀绣最早见于西汉的记载，当时的工艺已相当成熟，同时传承了图案配色鲜艳、常用红绿颜色的特点。";
        } else if (i % 5 == 0) {
            moment.text = @"昨夜雨疏风骤，浓睡不消残酒。试问卷帘人，却道海棠依旧。知否，知否？应是绿肥红瘦。";
        } else if (i % 7 == 0) {
            moment.text = @"安利我喜欢的插画师：晓艺大佬。详见链接：https://www.duitang.com/album/?id=86312973 ";
        } else if (i % 8 == 0) {
            moment.text = @"我好饿啊，我想吃：🍔🥛🌰🍑🍟🍎🍞🍣🍟🍞🍊🍓🍉，她们让我叫外卖，☎️：18367980021。让我不要打扰她们happy，有事就发邮件：chellyLau@126.com";
        } else {
            moment.text = @"美冠鹦鹉又被称为粉红凤头鹦鹉，因为它的头冠特别美丽又有粉红色的羽毛，被誉为爱情鸟的鹦鹉，赋予粉红色的生命，也是暖暖的少女色，恋爱感爆棚。";
        }
        [moment save];
    }
}

@end
