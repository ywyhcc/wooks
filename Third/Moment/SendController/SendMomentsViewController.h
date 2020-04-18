//
//  ViewController.h
//  HDragImageDemo
//
//  Created by 黄江龙 on 2018/9/5.
//  Copyright © 2018年 huangjianglong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    text,
    pic,
    video,
} momentType;

@interface SendMomentsViewController : UIViewController

@property (nonatomic, strong) NSArray *imageArray;

@property (nonatomic, assign) momentType type;

@property (nonatomic, strong) NSURL *videoPath;

@property (nonatomic, strong) UIImage *videoImage;

@end

