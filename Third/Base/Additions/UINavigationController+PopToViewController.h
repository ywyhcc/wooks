//
//  UINavigationController+PopToViewController.h
//  FirstP2P
//
//  Created by James Zhao on 9/18/16.
//  Copyright © 2016 9888. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (PopToViewController)

- (NSArray <UIViewController *> *)viewControllersInBackStackOfClass:(Class)cls;
- (UIViewController *)firstViewControllerInBackStackOfClass:(Class)cls;
- (UIViewController *)popToFirstViewControllerOfClass:(Class)cls animated:(BOOL)animated;
- (BOOL)pushFromFirstViewControllerOfClass:(Class)cls viewControllers:(NSArray *)viewControllers animated:(BOOL)animated;
- (void)pushViewControllersFromRoot:(NSArray *)viewControllersToPush animated:(BOOL)animated;

@end
