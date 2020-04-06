//
//  NSUserDefaults+Category.h
//  Momonts
//
//  Created by zhangzhendong on 2020/3/14.
//  Copyright © 2020 zhangzhendong. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSUserDefaults (Category)

- (void)saveUserInfo:(NSDictionary*)dic;

- (NSDictionary *)getUserInfoFromMemory;


@end
