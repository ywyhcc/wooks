//
//  MMImageListView.m
//  MomentKit
//
//  Created by LEA on 2017/12/14.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "MMImageListView.h"
#import "MMImagePreviewView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "RCDQRInfoHandle.h"
#import "RCDQRCodeManager.h"
#import "RCDForwardSelectedViewController.h"
#import "RCDForwardManager.h"
#import "UIImage+RCImage.h"

#pragma mark - ------------------ 小图List显示视图 ------------------

@interface MMImageListView ()

// 图片视图数组
@property (nonatomic, strong) NSMutableArray * imageViewsArray;
// 预览视图
@property (nonatomic, strong) MMImagePreviewView * previewView;

@property (nonatomic,strong)AVPlayer *player;//播放器对象
@property (nonatomic,strong)AVPlayerItem *currentPlayerItem;
@property (nonatomic,strong)AVPlayerLayer *avLayer;

@end

@implementation MMImageListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // 小图(九宫格)
        _imageViewsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 9; i++) {
            MMImageView * imageView = [[MMImageView alloc] initWithFrame:CGRectZero];
            imageView.tag = 1000 + i;
            imageView.backgroundColor = k_background_color;
            [imageView setClickHandler:^(MMImageView *imageView){
                [self singleTapSmallViewCallback:imageView];
                if (self.singleTapHandler) {
                    self.singleTapHandler(imageView);
                }
            }];
            [_imageViewsArray addObject:imageView];
            [self addSubview:imageView];
        }
        // 预览视图
        _previewView = [[MMImagePreviewView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _previewView.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)btnLong:(UILongPressGestureRecognizer*)tap{
    if ([tap.view isKindOfClass:[MMImageView class]]) {
        
    }
}

#pragma mark - Setter
// 图片位置绘制
- (void)setMoment:(Moment *)moment
{
    _moment = moment;
    for (MMImageView * imageView in _imageViewsArray) {
        imageView.hidden = YES;
    }
    // 图片区
    NSInteger count = [moment.pictureList count];
    if (count == 0) {
        self.size = CGSizeZero;
        return;
    }
    // 更新视图数据
    _previewView.pageNum = count;
    _previewView.scrollView.contentSize = CGSizeMake(_previewView.width*count, _previewView.height);
    // 添加图片
    MMImageView * imageView = nil;
    for (NSInteger i = 0; i < count; i++)
    {
        NSInteger rowNum = i / 3;
        NSInteger colNum = i % 3;
        if(count == 4) {
            rowNum = i / 2;
            colNum = i % 2;
        }
        CGFloat imageX = colNum * (kImageWidth + kImagePadding);
        CGFloat imageY = rowNum * (kImageWidth + kImagePadding);
        CGRect frame = CGRectMake(imageX, imageY, kImageWidth, kImageWidth);
        
        MPicture * picture = [_moment.pictureList objectAtIndex:i];
        // 单张图片需计算实际显示size
        if (count == 1) {
            CGSize singleSize = [Utility getMomentImageSize:CGSizeMake(moment.singleWidth, moment.singleHeight)];
            frame = CGRectMake(0, 0, singleSize.width, singleSize.height);
            
            if ([picture.isHorPic isEqualToString:@"2"]) {
                frame = CGRectMake(0, 0, SCREEN_WIDTH / 3, 200);
            }
            
//            if (picture.thumbnail.length > 0) {
//                CGSize newSize = [UIImage GetImageSizeWithURL:picture.thumbnail];
//                if (newSize.height > newSize.width) {
//                    frame = CGRectMake(0, 0, SCREEN_WIDTH / 3, 200);
//                }
//            }
//            else if (picture.thumbnailAvert.length > 0){
//                CGSize newSize = [UIImage GetImageSizeWithURL:picture.thumbnailAvert];
//                if (newSize.height > newSize.width) {
//                    frame = CGRectMake(0, 0, SCREEN_WIDTH / 3, 200);
//                }
//            }
            
        }
        imageView = [self viewWithTag:1000 + i];
        imageView.hidden = NO;
        imageView.frame = frame;
        
       if (picture.thumbnailVideo.length) {
           [imageView setCenterImageHidden:NO];
       }
       else {
           [imageView setCenterImageHidden:YES];
       }
    }
    self.width = kTextWidth;
    self.height = imageView.bottom;
}

// 图片渲染
- (void)loadPicture
{
    // 图片区
    NSInteger count = [_moment.pictureList count];
    MMImageView * imageView = nil;
    for (NSInteger i = 0; i < count; i++)
    {
        imageView = [self viewWithTag:1000 + i];
        // 赋值>图片渲染
        MPicture * picture = [_moment.pictureList objectAtIndex:i];
        if (picture.thumbnailVideo.length) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:picture.thumbnailAvert]
            placeholderImage:nil];
        } else {
            [imageView sd_setImageWithURL:[NSURL URLWithString:picture.thumbnail]
                         placeholderImage:nil];
            imageView.picURL = picture.thumbnail;
        }
    }
}

#pragma mark - 小图单击
- (void)singleTapSmallViewCallback:(MMImageView *)imageView
{
    NSInteger count = [_moment.pictureList count];
    if (count == 1) {
        MPicture * picture1 = [_moment.pictureList objectAtIndex:0];
        if (picture1.thumbnailVideo.length) {
            if (self.player) {
                self.player = nil;
            }
            [_previewView.pageControl removeFromSuperview];
            [self videoPlay:picture1.thumbnailVideo];
            return;
        }
    }
    
    UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    // 解除隐藏
    [window addSubview:_previewView];
    [window bringSubviewToFront:_previewView];
    // 清空
    [_previewView.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 添加子视图
    NSInteger index = imageView.tag - 1000;
    
    CGRect convertRect;
    if (count == 1) {
        [_previewView.pageControl removeFromSuperview];
    }
    
    for (NSInteger i = 0; i < count; i ++)
    {
        // 转换Frame
        MMImageView *pImageView = (MMImageView *)[self viewWithTag:1000+i];
        convertRect = [[pImageView superview] convertRect:pImageView.frame toView:window];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnLong:)];
        longPress.minimumPressDuration = 0.5; //定义按的时间
        [pImageView addGestureRecognizer:longPress];
        
        // 添加
        MMScrollView *scrollView = [[MMScrollView alloc] initWithFrame:CGRectMake(i*_previewView.width, 0, _previewView.width, _previewView.height)];
        scrollView.tag = 100+i;
        scrollView.maximumZoomScale = 2.0;
        scrollView.image = pImageView.image;
        scrollView.imageURL = pImageView.picURL;
        scrollView.contentRect = convertRect;
        // 单击
        [scrollView setTapBigView:^(MMScrollView *scrollView){
            [self singleTapBigViewCallback:scrollView];
        }];
        // 长按
        [scrollView setLongPressBigView:^(MMScrollView *scrollView){
            [self longPresssBigViewCallback:scrollView];
        }];
        [_previewView.scrollView addSubview:scrollView];
        if (i == index) {
            [UIView animateWithDuration:0.3 animations:^{
                _previewView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
                _previewView.pageControl.hidden = NO;
                [scrollView updateOriginRect];
            }];
        } else {
            [scrollView updateOriginRect];
        }
    }
    // 更新offset
    CGPoint offset = _previewView.scrollView.contentOffset;
    offset.x = index * k_screen_width;
    _previewView.scrollView.contentOffset = offset;
}

- (void)videoPlay:(NSString *)videoUrl {
    
    UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    // 解除隐藏
    [window addSubview:_previewView];
    [window bringSubviewToFront:_previewView];
   //第二步:获取播放地址URL
   //网络视频路径
   NSString *webVideoPath = videoUrl;
   NSURL *webVideoUrl = [NSURL URLWithString:webVideoPath];
   //第三步:创建播放器(四种方法)
   //如果使用URL创建的方式会默认为AVPlayer创建一个AVPlayerItem
   //self.player = [AVPlayer playerWithURL:localVideoUrl];
   //self.player = [[AVPlayer alloc] initWithURL:localVideoUrl];
   //self.player = [AVPlayer playerWithPlayerItem:playerItem];
   AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:webVideoUrl];
   self.currentPlayerItem = playerItem;
   AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    
   //第四步:创建显示视频的AVPlayerLayer,设置视频显示属性，并添加视频图层
   //contentView是一个普通View,用于放置视频视图
   /*
     AVLayerVideoGravityResizeAspectFill等比例铺满，宽或高有可能出屏幕
     AVLayerVideoGravityResizeAspect 等比例  默认
     AVLayerVideoGravityResize 完全适应宽高
   */
   self.avLayer = [AVPlayerLayer playerLayerWithPlayer:player];
   self.avLayer.videoGravity = AVLayerVideoGravityResizeAspect;
   self.avLayer.frame = _previewView.bounds;
   [_previewView.layer addSublayer:self.avLayer];
    
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCallback1:)];
    [_previewView addGestureRecognizer:singleTap];
    
    [player play];

    self.player = player;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:@"AVPlayerItemDidPlayToEndTimeNotification" object:self.player.currentItem];
    
   //第六步：执行play方法，开始播放
   //本地视频可以直接播放
   //网络视频需要监测AVPlayerItem的status属性为AVPlayerStatusReadyToPlay时方法才会生效
    [UIView animateWithDuration:0.3 animations:^{
        _previewView.backgroundColor = [UIColor blackColor];
        [self.player play];
    }];
   
}

- (void)dealloc {
    [self.player pause];
    [self.avLayer removeFromSuperlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

// 视频循环播放

- (void)moviePlayDidEnd:(NSNotification*)notification{

    AVPlayerItem*item = [notification object];

    [item seekToTime:kCMTimeZero];

    [self.player play];

}


#pragma mark - 大图单击||长按
- (void)singleTapBigViewCallback:(MMScrollView *)scrollView
{
    [UIView animateWithDuration:0.3 animations:^{
        _previewView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        _previewView.pageControl.hidden = YES;
        scrollView.contentRect = scrollView.contentRect;
        scrollView.zoomScale = 1.0;
    } completion:^(BOOL finished) {
        [_previewView removeFromSuperview];
    }];
}


- (void)singleTapGestureCallback1:(UIGestureRecognizer *)gesture
{
    [self.player pause];
    [self.avLayer removeFromSuperlayer];
    [UIView animateWithDuration:0.3 animations:^{
        _previewView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        _previewView.pageControl.hidden = YES;
    } completion:^(BOOL finished) {
        [_previewView removeFromSuperview];
    }];
}

- (void)longPresssBigViewCallback:(MMScrollView *)scrollView
{
    if (self.singleLongHandler) {
        self.singleLongHandler(scrollView);
    }
}

@end

#pragma mark - ------------------ 单个小图显示视图 ------------------
@implementation MMImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor lightGrayColor];
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds  = YES;
        self.userInteractionEnabled = YES;
        
        self.centerImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.centerImage.image = [UIImage imageNamed:@"album_video"];
        self.centerImage.center = self.center;
        self.centerImage.hidden = YES;
        [self addSubview:self.centerImage];
        
        UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCallback:)];
        [self addGestureRecognizer:singleTap];
    }
    return self;
}

- (void)singleTapGestureCallback:(UIGestureRecognizer *)gesture
{
    if (self.clickHandler) {
        self.clickHandler(self);
    }
}

- (void)setCenterImageHidden:(BOOL)isHidden{
    self.centerImage.center = self.center;
    if (isHidden) {
        self.centerImage.hidden = YES;
    }
    else {
        self.centerImage.hidden = NO;
    }
}

@end
