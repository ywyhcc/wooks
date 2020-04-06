//
//  FBYHomeService.m
//  Momonts
//
//  Created by zhangzhendong on 2020/3/14.
//  Copyright © 2020 zhangzhendong. All rights reserved.
//

#import "FBYHomeService.h"
#import <AFNetworking.h>
#import "RequestHeader.h"


@interface FBYHomeService ()



@end

@implementation FBYHomeService

- (void)searchMessage:(NSString *)pageNum andWithDic:(NSDictionary *)Alldic andUrl:(NSString *)url andSuccess:(void (^)(NSDictionary *))success andFailure:(void (^)(int))failure{
    
    //1.创建ADHTTPSESSIONMANGER对象
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //2.设置该对象返回类型
//    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    if ([pageNum isEqualToString:[NSString stringWithFormat:@"get"]]) {
        
        NSString *urlstr= [NSString stringWithFormat:@"%@%@",BaseURL,url];
        
        NSLog(@"%@",urlstr);
        //调出请求头
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        //将token封装入请求头
        
        NSUserDefaults *tokenid = [NSUserDefaults standardUserDefaults];
        NSString *token = [tokenid objectForKey:@"tokenid"];
        NSLog(@"%@",token);
        
//        NSDictionary *headers = [RequestHeader getHederDic];
        
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
        
        [manager GET:urlstr parameters:Alldic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *dic = responseObject;
            success(dic);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
        
    }else {
            NSString *urlstr= [NSString stringWithFormat:@"%@%@",BaseURL,url];
            NSLog(@"%@",urlstr);
//            [manager.requestSerializer setValue:@"1" forHTTPHeaderField:@"x-signature"];
//            [manager.requestSerializer setValue:@"2" forHTTPHeaderField:@"x-timestamp"];
//            manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 30;
//            manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager POST:urlstr parameters:Alldic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
              NSDictionary *dic = responseObject;
        
              success(dic);
        
          }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(404);
          }];
    }
}

- (void)getRequestWithDic:(NSDictionary *)Alldic andUrl:(NSString *)url andSuccess:(void (^)(NSDictionary * _Nonnull))success andFailure:(void (^)(int))failure{
    [self searchMessage:@"get" andWithDic:Alldic andUrl:url andSuccess:success andFailure:failure];
}

- (void)postRequestWithAction:(NSString *)action andWithDic:(NSDictionary *)Alldic andUrl:(NSString *)url andSuccess:(void (^)(NSDictionary * _Nonnull))success andFailure:(void (^)(int))failure{
    [self searchMessage:@"post" andWithDic:Alldic andUrl:url andSuccess:success andFailure:failure];
}

@end
