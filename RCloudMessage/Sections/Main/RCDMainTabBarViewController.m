//
//  RCDMainTabBarViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/7/30.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDMainTabBarViewController.h"
#import "RCDChatListViewController.h"
#import "RCDContactViewController.h"
#import "RCDMeTableViewController.h"
#import "RCDSquareTableViewController.h"
#import "MomentViewController.h"
#import "UITabBar+badge.h"
#import "RCDUtilities.h"
@interface RCDMainTabBarViewController ()

@property NSUInteger previousIndex;

@end

@implementation RCDMainTabBarViewController

+ (RCDMainTabBarViewController *)sharedInstance {
    static RCDMainTabBarViewController *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setControllers];
    [self setTabBarItems];
    self.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeSelectedIndex:)
                                                 name:@"ChangeTabBarIndex"
                                               object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self setTabBarItems];
}

- (void)setControllers {
    RCDChatListViewController *chatVC = [[RCDChatListViewController alloc] init];
    NSDictionary *dictHome = [NSDictionary dictionaryWithObject:[FPStyleGuide weichatGreenColor] forKey:NSForegroundColorAttributeName];
    NSDictionary *dicNormal = [NSDictionary dictionaryWithObject:[FPStyleGuide lightGrayTextColor] forKey:NSForegroundColorAttributeName];
    [chatVC.tabBarItem setTitleTextAttributes:dicNormal forState:UIControlStateNormal];
    [chatVC.tabBarItem setTitleTextAttributes:dictHome forState:UIControlStateSelected];
    
    RCDContactViewController *contactVC = [[RCDContactViewController alloc] init];
    [contactVC.tabBarItem setTitleTextAttributes:dicNormal forState:UIControlStateNormal];
    [contactVC.tabBarItem setTitleTextAttributes:dictHome forState:UIControlStateSelected];
    
    MomentViewController *discoveryVC = [[MomentViewController alloc] init];
    [discoveryVC.tabBarItem setTitleTextAttributes:dicNormal forState:UIControlStateNormal];
    [discoveryVC.tabBarItem setTitleTextAttributes:dictHome forState:UIControlStateSelected];
    
    RCDMeTableViewController *meVC = [[RCDMeTableViewController alloc] init];
    [meVC.tabBarItem setTitleTextAttributes:dicNormal forState:UIControlStateNormal];
    [meVC.tabBarItem setTitleTextAttributes:dictHome forState:UIControlStateSelected];
    self.viewControllers = @[ chatVC, contactVC, discoveryVC, meVC ];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewControllers
        enumerateObjectsUsingBlock:^(__kindof UIViewController *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([obj isKindOfClass:[RCDChatListViewController class]]) {
                RCDChatListViewController *chatListVC = (RCDChatListViewController *)obj;
                [chatListVC updateBadgeValueForTabBarItem];
            }
        }];
}

- (void)setTabBarItems {
    
    [self.viewControllers
        enumerateObjectsUsingBlock:^(__kindof UIViewController *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([obj isKindOfClass:[RCDChatListViewController class]]) {
                obj.tabBarItem.title = RCDLocalizedString(@"conversation");
                obj.tabBarItem.image =
                    [[UIImage imageNamed:@"mixin_ic_tab_chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                obj.tabBarItem.selectedImage =
                    [[UIImage imageNamed:@"mixin_ic_tab_chat_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            } else if ([obj isKindOfClass:[RCDContactViewController class]]) {
                obj.tabBarItem.title = RCDLocalizedString(@"contacts");
                obj.tabBarItem.image =
                    [[UIImage imageNamed:@"mixin_ic_tab_contacts"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                obj.tabBarItem.selectedImage = [[UIImage imageNamed:@"mixin_ic_tab_contacts_hover"]
                    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            } else if ([obj isKindOfClass:[MomentViewController class]]) {
                obj.tabBarItem.title = RCDLocalizedString(@"discover");
                obj.tabBarItem.image =
                    [[UIImage imageNamed:@"mixin_ic_tab_found"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                obj.tabBarItem.selectedImage =
                    [[UIImage imageNamed:@"mixin_ic_tab_found_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            } else if ([obj isKindOfClass:[RCDMeTableViewController class]]) {
                obj.tabBarItem.title = RCDLocalizedString(@"me");
                obj.tabBarItem.image =
                    [[UIImage imageNamed:@"mixin_ic_tab_me"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                obj.tabBarItem.selectedImage =
                    [[UIImage imageNamed:@"mixin_ic_tab_me_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            } else {
                NSLog(@"Unknown TabBarController");
            }
            [obj.tabBarController.tabBar bringBadgeToFrontOnItemIndex:(int)idx];
        }];
}

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController {
    
    self.tabBar.tintColor = [FPStyleGuide lightGrayTextColor];
    
    NSUInteger index = tabBarController.selectedIndex;
    [RCDMainTabBarViewController sharedInstance].selectedTabBarIndex = index;
    switch (index) {
    case 0: {
        if (self.previousIndex == index) {
            //判断如果有未读数存在，发出定位到未读数会话的通知
            if ([[RCIMClient sharedRCIMClient] getTotalUnreadCount] > 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoNextConversation" object:nil];
            }
            self.previousIndex = index;
        }
        self.previousIndex = index;
    } break;

    case 1:
        self.previousIndex = index;
        break;

    case 2:
        self.previousIndex = index;
        break;

    case 3:
        self.previousIndex = index;
        break;

    default:
        break;
    }
}

- (void)changeSelectedIndex:(NSNotification *)notify {
    NSInteger index = [notify.object integerValue];
    self.selectedIndex = index;
}
@end
