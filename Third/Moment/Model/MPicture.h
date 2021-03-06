//
//  MPicture.h
//  MomentKit
//
//  Created by LEA on 2019/2/28.
//  Copyright © 2019 LEA. All rights reserved.
//
//  图片Model
//

#import <UIKit/UIKit.h>

@interface MPicture : JKDBModel

// 图片路径
@property (nonatomic, copy) NSString * thumbnail;

// 视频路径
@property (nonatomic, copy) NSString * thumbnailVideo;

// 视频缩略图路径
@property (nonatomic, copy) NSString * thumbnailAvert;

@end

