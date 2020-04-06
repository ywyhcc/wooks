//
//  FBYHomeService.h
//  Momonts
//
//  Created by zhangzhendong on 2020/3/14.
//  Copyright © 2020 zhangzhendong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBYRequestName.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    get,
    post,
} requestType;

@interface FBYHomeService : NSObject


//pageNum和action标记参数，可以区分接口类型等
//Alldic为网络请求报文
//url接口地址
//success获取接口成功返回参数
//failure网络请求失败错误信息
- (void)searchMessage:(NSString *)pageNum andWithDic:(NSDictionary *)Alldic andUrl:(NSString *)url andSuccess:(void(^)(NSDictionary *dic))success andFailure:(void(^)(int fail))failure;


- (void)getRequestWithDic:(NSDictionary *)Alldic andUrl:(NSString *)url andSuccess:(void(^)(NSDictionary *dic))success andFailure:(void(^)(int fail))failure;

- (void)postRequestWithDic:(NSDictionary *)Alldic andUrl:(NSString *)url andSuccess:(void(^)(NSDictionary *dic))success andFailure:(void(^)(int fail))failure;

@end

NS_ASSUME_NONNULL_END
