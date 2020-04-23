//
//  SYNetworkingManager.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/21.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "SYNetworkingManager.h"
#import <AFNetworking.h>

static AFHTTPSessionManager *smanager;

@implementation SYNetworkingManager


+ (AFHTTPSessionManager *)sharedHTTPManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        smanager = [AFHTTPSessionManager manager];
        /**
         *  可以接受的类型
         */
        smanager.responseSerializer = [AFHTTPResponseSerializer serializer];
        smanager.requestSerializer = [AFJSONRequestSerializer serializer];
        if ([ProfileUtil getToken].length > 0) {
            [smanager.requestSerializer setValue:[ProfileUtil getToken] forHTTPHeaderField:@"token"];
        }
        /**
         *  请求队列的最大并发数
         */
        //    manager.operationQueue.maxConcurrentOperationCount = 5;
        /**
         *  请求超时的时间
         */
        smanager.requestSerializer.timeoutInterval = 5;
        
    });
    return smanager;
}




+ (void)getWithURLString:(NSString *)urlString
              parameters:(id)parameters
                 success:(SuccessBlock)successBlock
                 failure:(FailureBlock)failureBlock
{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    /**
//     *  可以接受的类型
//     */
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    if ([ProfileUtil getToken].length > 0) {
//        [manager.requestSerializer setValue:[ProfileUtil getToken] forHTTPHeaderField:@"token"];
//    }
//    /**
//     *  请求队列的最大并发数
//     */
//    //    manager.operationQueue.maxConcurrentOperationCount = 5;
//    /**
//     *  请求超时的时间
//     */
//    manager.requestSerializer.timeoutInterval = 5;
    
    AFHTTPSessionManager *manager = [SYNetworkingManager sharedHTTPManager];
    if ([ProfileUtil getToken].length > 0) {
        [manager.requestSerializer setValue:[ProfileUtil getToken] forHTTPHeaderField:@"token"];
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BaseURL,urlString];
    [manager GET:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            successBlock(dic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
            NSLog(@"网络异常 - T_T%@", error);
        }
    }];
}

+ (void)postWithURLString:(NSString *)urlString
               parameters:(id)parameters
                  success:(SuccessBlock)successBlock
                  failure:(FailureBlock)failureBlock
{
    

    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    if ([ProfileUtil getToken].length > 0) {
//        [manager.requestSerializer setValue:[ProfileUtil getToken] forHTTPHeaderField:@"token"];
//    }
//    manager.requestSerializer.timeoutInterval = 5;
    
    AFHTTPSessionManager *manager = [SYNetworkingManager sharedHTTPManager];
    if ([ProfileUtil getToken].length > 0) {
        [manager.requestSerializer setValue:[ProfileUtil getToken] forHTTPHeaderField:@"token"];
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BaseURL,urlString];
    [manager POST:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            successBlock(dic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
            NSLog(@"网络异常 - T_T%@", error);
        }
    }];
     
}

+ (void)requestPUTWithURLStr:(NSString *)urlStr paramDic:(NSDictionary *)paramDic success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock{
 
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    // 设置请求头
////    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    if ([ProfileUtil getToken].length > 0) {
//        [manager.requestSerializer setValue:[ProfileUtil getToken] forHTTPHeaderField:@"token"];
//    }
    
    AFHTTPSessionManager *manager = [SYNetworkingManager sharedHTTPManager];
    if ([ProfileUtil getToken].length > 0) {
        [manager.requestSerializer setValue:[ProfileUtil getToken] forHTTPHeaderField:@"token"];
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BaseURL,urlStr];
    [manager PUT:urlString parameters:paramDic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (successBlock) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            successBlock(dic);
        }
            
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
            NSLog(@"网络异常 - T_T%@", error);
        }
    }];
}

+ (void)deleteWithURLString:(NSString *)urlString
parameters:(id)parameters
   success:(SuccessBlock)successBlock
                    failure:(FailureBlock)failureBlock{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    if ([ProfileUtil getToken].length > 0) {
//        [manager.requestSerializer setValue:[ProfileUtil getToken] forHTTPHeaderField:@"token"];
//    }
//    manager.requestSerializer.timeoutInterval = 5;
    
    AFHTTPSessionManager *manager = [SYNetworkingManager sharedHTTPManager];
    if ([ProfileUtil getToken].length > 0) {
        [manager.requestSerializer setValue:[ProfileUtil getToken] forHTTPHeaderField:@"token"];
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BaseURL,urlString];
    
    manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
    [manager DELETE:urlStr parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (successBlock) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                successBlock(dic);
            }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
            NSLog(@"网络异常 - T_T%@", error);
        }
    }];
}

@end
