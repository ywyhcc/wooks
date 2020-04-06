//
//  QiniuQuery.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/24.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^QiniuSuccessBlock)(NSString *urlStr);
typedef void (^QiniuFailureBlock)(NSError *error);


@interface QiniuQuery : NSObject

@property (nonatomic, copy) QiniuSuccessBlock successBlock;
@property (nonatomic, copy) QiniuFailureBlock failureBlock;

- (void)uploadWithImage:(NSData*)image success:(QiniuSuccessBlock)success faild:(QiniuFailureBlock)fail;

@end
