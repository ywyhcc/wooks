//
//  ProfileUtil.h
//  Momonts
//
//  Created by zhangzhendong on 2020/3/14.
//  Copyright © 2020 zhangzhendong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MProfile.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileUtil : NSObject

+ (NSString*)getUserAccountID;

+ (NSString*)getUserinfoID;

+ (void)saveUserInfo:(NSDictionary*)dic;

+ (NSDictionary*)getUserInfo;

+ (MProfile*)getUserProfile;

+ (NSString*)getToken;

+ (void)deleteUserInfo;

@end

NS_ASSUME_NONNULL_END
