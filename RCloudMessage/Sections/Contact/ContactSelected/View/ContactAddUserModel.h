//
//  ContactAddUserModel.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserInfoModel.h"
#import <Foundation/Foundation.h>
#include <stdbool.h>

NS_ASSUME_NONNULL_BEGIN
#define BOOL bool

@interface ContactAddUserModel : BaseUserInfoModel

@property (nonatomic, strong)NSString *status;

@end

NS_ASSUME_NONNULL_END
