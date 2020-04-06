//
//  UIImage+SplashImage.m
//  FirstP2P
//
//  Created by James Zhao on 5/14/15.
//  Copyright (c) 2015 9888. All rights reserved.
//

#import "UIImage+SplashImage.h"

@implementation UIImage (SplashImage)

+ (NSString *)splashImageNameForOrientation:(UIInterfaceOrientation)orientation
{
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    
    NSString *viewOrientation = @"Portrait";
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        viewSize = CGSizeMake(viewSize.height, viewSize.width);
        viewOrientation = @"Landscape";
    }
    
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    
    for (NSDictionary *dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
            return dict[@"UILaunchImageName"];
    }
    return nil;
}

+ (UIImage*)splashImageForOrientation:(UIInterfaceOrientation)orientation
{
    NSString *imageName = [self splashImageNameForOrientation:orientation];
    UIImage *image = [UIImage imageNamed:imageName];
    return image;
}

@end
