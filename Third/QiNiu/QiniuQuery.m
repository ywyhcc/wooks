//
//  QiniuQuery.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/24.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "QiniuQuery.h"
#import <QiniuSDK.h>

@implementation QiniuQuery

- (void)uploadManagerFiles:(NSData*)image andToken:(NSString*)token success:(QiniuSuccessBlock)success faild:(QiniuFailureBlock)fail{
    
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil
    progressHandler:^(NSString *key, float percent) {
    NSLog(@"上传进度 %.2f", percent);}
    params:nil
    checkCrc:NO
    cancellationSignal:nil];
    
    
    NSString *name = [QiniuQuery qnImageFilePatName];
    [upManager putData:image key:name token:token
    complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (success) {
            NSString *picURL = [NSString stringWithFormat:@"%@%@",QiniuCloudBaseURL,key];
            success(picURL);
        }
    NSLog(@"%@", info);
    NSLog(@"%@", resp);
    } option:uploadOption];
}

- (void)uploadWithImage:(NSData*)image success:(QiniuSuccessBlock)success faild:(QiniuFailureBlock)fail{
    
    [SYNetworkingManager getWithURLString:GetQiniu parameters:nil success:^(NSDictionary *data) {
        if ([data boolValueForKey:@"success"]) {
            NSString *token = [data stringValueForKey:@"easyUploadToken"];
            [self uploadManagerFiles:image andToken:token success:success faild:fail];
        }
    } failure:^(NSError *error) {
        NSLog(@"获取七牛失败");
    }];
}

- (void)uploadVideo:(NSString*)fileURL{
    
}

+ (NSString *)qnImageFilePatName{
   NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
   [formatter setDateFormat:@"yyyyMMdd"];
   NSString *nowe = [formatter stringFromDate:[NSDate date]];
    char datax[12];//十六位防重字符
   for (int x=0;x<12;datax[x++] = (char)('A' + (arc4random_uniform(26))));
   NSString *number = [[NSString alloc] initWithBytes:datax length:12 encoding:NSUTF8StringEncoding];
   //当前时间
   NSInteger interval = (NSInteger)[[NSDate date]timeIntervalSince1970];

   NSString *name = [NSString stringWithFormat:@"Picture/%@/%ld%@.jpg",nowe,interval,number];
   NSLog(@"name__%@",name);
   return name;}


//照片获取本地路径转换
- (NSString *)getImagePath:(UIImage *)Image {
    NSString *filePath = nil;
    NSData *data = nil;
    if (UIImagePNGRepresentation(Image) == nil) {
        data = UIImageJPEGRepresentation(Image, 1.0);
    } else {
        data = UIImagePNGRepresentation(Image);
    }
    
    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //把刚刚图片转换的data对象拷贝至沙盒中
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *ImagePath = [[NSString alloc] initWithFormat:@"/theFirstImage.png"];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:ImagePath] contents:data attributes:nil];
    
    //得到选择后沙盒中图片的完整路径
    filePath = [[NSString alloc] initWithFormat:@"%@%@", DocumentsPath, ImagePath];
    return filePath;
}


@end
