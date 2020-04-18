//
//  QiniuQuery.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/24.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^QiniuSuccessBlock)(NSString *urlStr, NSString *key);
typedef void (^QiniuFailureBlock)(NSError *error);


typedef enum {
    images,
    videos,
} uploadType;

@interface QiniuQuery : NSObject

@property (nonatomic, copy) QiniuSuccessBlock successBlock;
@property (nonatomic, copy) QiniuFailureBlock failureBlock;

- (void)uploadWithImage:(NSData*)image success:(QiniuSuccessBlock)success faild:(QiniuFailureBlock)fail;

- (void)uploadVideo:(NSData*)videoData success:(QiniuSuccessBlock)success faild:(QiniuFailureBlock)fail;

@end
