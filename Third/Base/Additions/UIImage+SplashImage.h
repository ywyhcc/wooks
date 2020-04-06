//
//  UIImage+SplashImage.h
//  FirstP2P
//
//  Created by James Zhao on 5/14/15.
//  Copyright (c) 2015 9888. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Category on `UIImage` to access the splash image.
 **/
@interface UIImage (SplashImage)

/**
 * Return the name of the splash image for a given orientation.
 * @param orientation The interface orientation.
 * @return The name of the splash image.
 **/
+ (NSString *)splashImageNameForOrientation:(UIInterfaceOrientation)orientation;

/**
 * Returns the splash image for a given orientation.
 * @param orientation The interface orientation.
 * @return The splash image.
 **/
+ (UIImage*)splashImageForOrientation:(UIInterfaceOrientation)orientation;

@end
