//
//  ProfileUtil.m
//  Momonts
//
//  Created by zhangzhendong on 2020/3/14.
//  Copyright © 2020 zhangzhendong. All rights reserved.
//

#import "ProfileUtil.h"
#import "NSUserDefaults+Category.h"

@implementation ProfileUtil


+ (NSString*)getUserAccountID{
    MProfile *profile = [[MProfile alloc] initWithDictionary:[self getUserInfo]];
    return profile.userAccountId;
    
}

+ (NSString*)getUserinfoID{
    MProfile *profile = [[MProfile alloc] initWithDictionary:[self getUserInfo]];
    return profile.userInfoID;
}

+ (void)deleteUserInfo{
    [ProfileUtil saveUserInfo:@{}];
}

+ (NSString*)getToken{
    MProfile *profile = [[MProfile alloc] initWithDictionary:[self getUserInfo]];
    return profile.token;
}

+(void)saveUserInfo:(NSDictionary *)dic{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] == 0) {
        return;
    }
    
    NSString *documentsDirectory = paths[0];
    NSString *filePath = @"";
    NSString *tempPath = documentsDirectory;
    if (![documentsDirectory hasSuffix:@"/"]) {
        tempPath = [NSString stringWithFormat:@"%@/",documentsDirectory];
    }
    filePath = [NSString stringWithFormat:@"%@Profile-Set400",tempPath];
    [NSKeyedArchiver archiveRootObject:dic toFile:filePath];
    
}


+ (NSDictionary*)getUserInfo{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] == 0) {
        return @{};
    }
    
    NSString *documentsDirectory = paths[0];
    NSString *filePath = @"";
    NSString *tempPath = documentsDirectory;
    if (![documentsDirectory hasSuffix:@"/"]) {
        tempPath = [NSString stringWithFormat:@"%@/",documentsDirectory];
    }
    filePath = [NSString stringWithFormat:@"%@Profile-Set400",tempPath];
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:filePath]];
    NSDictionary *rawDic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return rawDic;
}

+ (MProfile*)getUserProfile{
    MProfile *profile = [[MProfile alloc] initWithDictionary:[self getUserInfo]];
    return profile;
}

@end
