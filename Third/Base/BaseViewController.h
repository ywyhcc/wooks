//
//  BaseViewController.h
//  FirstP2P
//
//  Created by LCL on 13-12-5.
//  Copyright (c) 2013年 FirstP2P. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *StockTransactionStoryBoardName = @"StockTransaction";

@interface BaseViewController : UIViewController<UIGestureRecognizerDelegate>

@property(copy, nonatomic) NSString *titleString;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic) BOOL enableInteractivePopGestureRecognizer;

+ (id)viewControllerWithStoryBoardName:(NSString *)storyBoardName identifier:(NSString *)identifier;

- (void)setNavigationTitle:(NSString *)title;

- (void)setNavigationTitle:(NSString *)title titleColor:(UIColor *)titleColor;

- (void)setLeftBarItem:(UIBarButtonItem *)item;

- (void)setLeftBarItemText:(NSString *)text target:(id)target action:(SEL)action;

// 注意：不要用此函数做返回按钮，返回用setBackBarItemTarget:action:
- (void)setLeftBarItemImage:(UIImage *)image target:(id)target action:(SEL)action;

- (void)setRightBarItem:(UIBarButtonItem *)item;

- (void)setRightBarItemText:(NSString *)text target:(id)target action:(SEL)action;

- (void)setRightBarItemImage:(UIImage *)image target:(id)target action:(SEL)action;

- (void)enableLeftItem:(BOOL)enable;

- (void)enableRightItem:(BOOL)enable;

- (void)setBackBarItemTarget:(id)target action:(SEL)action;

- (void)goBack:(id)sender;

#pragma mark -
#pragma mark HelpCenter
- (NSString *)helpCenterShortURL;

- (void)showHelpCenterButton;

- (void)showHelpCenterWebView;

#pragma mark -
//在window上显示LoadingView
- (void)showLoadingView:(NSString *)message;

//在view上显示LoadingView
- (void)showLoadingViewInView:(NSString *)message frame:(CGRect)lframe;
- (void)showLoadingViewInView:(NSString *)message;

//在window上显示Alert
- (void)showAlertHudView:(NSString *)message;

//在window上显示Alert，延迟自动消失
- (void)showAlertHudView:(NSString *)message dismissAfter:(float)delay;

//在view上显示Alert
- (void)showAlertHudView:(NSString *)message inView:(UIView *)view;

//在view上显示Alert，延迟自动消失
- (void)showAlertHudView:(NSString *)message inView:(UIView *)view dismissAfter:(float)delay;

//隐藏并移除LoadingView
- (void)hideLoadingView;

//- (void)setHudCompletionBlock:(MBProgressHUDCompletionBlock)block;

#pragma mark - UmengPageTrack
- (NSString *)getUmengPageKey;

- (BOOL)needHideNavigationBar;

@end
