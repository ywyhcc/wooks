//
//  UINavigationController+PopToViewController.m
//  FirstP2P
//
//  Created by James Zhao on 9/18/16.
//  Copyright © 2016 9888. All rights reserved.
//

#import "UINavigationController+PopToViewController.h"

@implementation UINavigationController (PopToViewController)

- (NSArray <UIViewController *> *)viewControllersInBackStackOfClass:(Class)cls
{
    NSMutableArray   *matches = [@[] mutableCopy];
    UIViewController *viewController = nil;

    for (int i = 0; i < self.viewControllers.count; i++) {
        viewController = self.viewControllers[i];

        if ([viewController isKindOfClass:cls]) {
            [matches addObject:viewController];
        }
    }

    return matches.count > 0 ? matches : nil;
}

- (UIViewController *)firstViewControllerInBackStackOfClass:(Class)cls
{
    NSArray *matches = [self viewControllersInBackStackOfClass:cls];

    return [matches firstObject];
}

- (UIViewController *)popToFirstViewControllerOfClass:(Class)cls animated:(BOOL)animated
{
    UIViewController *viewController = [self firstViewControllerInBackStackOfClass:cls];
    if (viewController) {
        [self popToViewController:viewController animated:animated];
        return viewController;
    } else {
        return nil;
    }
}
- (BOOL)pushFromFirstViewControllerOfClass:(Class)cls viewControllers:(NSArray *)viewControllersToPush animated:(BOOL)animated
{
    UIViewController *firstMatchedViewController = [self firstViewControllerInBackStackOfClass:cls];
    if (firstMatchedViewController) {
        NSInteger index = [self.viewControllers indexOfObject:firstMatchedViewController];
        NSMutableArray *viewControllers = [@[] mutableCopy];
        [viewControllers addObjectsFromArray:[self.viewControllers subarrayWithRange:NSMakeRange(0, index + 1)]];
        [viewControllers addObjectsFromArray:viewControllersToPush];
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:viewControllers];
        [self setViewControllers:[orderedSet array] animated:animated];
        return YES;
    }
    return NO;
}

- (void)pushViewControllersFromRoot:(NSArray *)viewControllersToPush animated:(BOOL)animated
{
    UIViewController *rootViewController = self.viewControllers.firstObject;
    NSMutableArray *viewControllers = [@[] mutableCopy];
    if (rootViewController) {
        [viewControllers addObject:rootViewController];
    }
    [viewControllers addObjectsFromArray:viewControllersToPush];

    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:viewControllers];
    [self setViewControllers:[orderedSet array] animated:animated];
}

@end
