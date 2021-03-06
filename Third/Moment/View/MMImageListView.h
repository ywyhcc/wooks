//
//  MMImageListView.h
//  MomentKit
//
//  Created by LEA on 2017/12/14.
//  Copyright © 2017年 LEA. All rights reserved.
//
//  朋友圈动态 > 小图区视图
//

#import <UIKit/UIKit.h>
#import "Moment.h"

@class MMScrollView;
@class MMImageView;
@interface MMImageListView : UIView

// 动态
@property (nonatomic, strong) Moment * moment;
// 点击小图
@property (nonatomic, copy) void (^singleTapHandler)(MMImageView *imageView);

//长按小图
@property (nonatomic, copy) void (^singleLongHandler)(MMScrollView *imageView);
// 图片渲染
- (void)loadPicture;

@end

//### 单个小图显示视图
@interface MMImageView : UIImageView
//我加的图片路径
@property (nonatomic, strong)NSString *picURL;

@property (nonatomic, strong)UIImageView *centerImage;

// 点击小图
@property (nonatomic, copy) void (^clickHandler)(MMImageView *imageView);

- (void)setCenterImageHidden:(BOOL)isHidden;

@end

