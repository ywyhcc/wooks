//
//  UIImage+Additions.h
//  FirstP2P
//
//  Created by fengquan on 4/16/15.
//  Copyright (c) 2015 9888. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage(Additions)

- (UIImage *)scaleImageToSize:(CGSize)size;

- (UIImage *)fixOrientation;

- (UIImage *)squaredImage;

+ (UIImage *)scaleAndRotateImage:(UIImage *)image maxResolution:(NSInteger)maxResolution;
@end
