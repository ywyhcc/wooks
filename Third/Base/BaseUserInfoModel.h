//
//  BaseUserInfoModel.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseUserInfoModel : NSObject

- (id)initWithDictionary:(NSDictionary *)dic;

@property (nonatomic, strong) NSString *avaterUrl;

@property (nonatomic, strong) NSString *comments;

@property (nonatomic, strong) NSString *gender;

@property (nonatomic, strong) NSString *nickName;

@property (nonatomic, strong) NSString *telphone;

@property (nonatomic, strong) NSString *userAccountId;

@property (nonatomic, strong) NSString *woostalkId;

//@property (nonatomic, strong) NSString *avaterUrl;
//@property (nonatomic, strong) NSString *avaterUrl;
//@property (nonatomic, strong) NSString *avaterUrl;
//@property (nonatomic, strong) NSString *avaterUrl;

@end

NS_ASSUME_NONNULL_END
