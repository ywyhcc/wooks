//
//  BaseViewController.m
//  FirstP2P
//
//  Created by LCL on 4/17/13.
//  Copyright (c) 2013 FirstP2P. All rights reserved.
//

#import "BaseViewController.h"

#import "AppDelegate.h"
//#import "Common.h"
//#import "WebViewController.h"
//#import "ClientConfig.h"
//#import "UIBaseNavigationController.h"
//#import "FeedbackDrawController.h"

@interface BaseViewController ()

//@property (nonatomic, strong) MBProgressHUD *loadingView;
//@property (nonatomic, strong) P2PLoadingView410 *loadingView410;
//@property(copy, nonatomic) NSString *titleStringForUmeng;

@end

@implementation BaseViewController

#pragma mark -
#pragma mark life circle

- (void)commonSetup
{
    //self.automaticallyAdjustsScrollViewInsets = NO;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;
#endif
    self.enableInteractivePopGestureRecognizer = YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self commonSetup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonSetup];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.enableInteractivePopGestureRecognizer = YES;
    }
    return self;
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:self.needHideNavigationBar animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	
}

- (void)loadView
{
    [super loadView];
    
    self.navigationController.navigationBar.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
//    self.navigationController.navigationBar.tintColor = [FPStyleGuide appTitleColor];
//    self.navigationController.navigationBar.barTintColor = [FPStyleGuide appThemeColor];
    self.navigationController.navigationBar.translucent = NO;
    //防止自定义的返回按钮导致系统滑动返回失效
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self.navigationController;
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setShadowImage:)]) {
        self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"navigation_shadow.png"];
    }
    
//    self.view.backgroundColor = [FPStyleGuide commonBackgroundColor];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
+ (id)viewControllerWithStoryBoardName:(NSString *)storyBoardName identifier:(NSString *)identifier
{
    if (storyBoardName.length > 0 && identifier.length > 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:[NSBundle mainBundle]];
        id viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
        return viewController;
    }
    
    return nil;
}

#pragma mark -
#pragma mark custom navigationBar
- (void)setNavigationTitle:(NSString *)title
{
    if (self.titleLabel) {
		self.titleLabel.text = title;
    }else{
        [self setNavigationTitle:title titleColor:[FPStyleGuide appTitleColor]];
    }
}

- (CGFloat)navigationTitleWidth{
	return SCREEN_WIDTH - 140;
}

- (void)setNavigationTitle:(NSString *)title titleColor:(UIColor *)titleColor
{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [self navigationTitleWidth], NAVIGATIONBAR_HEIGHT)];
    self.titleLabel.textColor = titleColor;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.shadowOffset = CGSizeMake(0, 0);
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = title;
    self.navigationItem.titleView = self.titleLabel;
    self.navigationItem.title = @"";
}

- (void)setLeftBarItem:(UIBarButtonItem *)item
{
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItem = item;
    self.navigationItem.hidesBackButton = YES;
}

- (void)setLeftBarItemText:(NSString *)text target:(id)target action:(SEL)action
{
    self.navigationItem.leftBarButtonItems = nil;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:text
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:target
                                                                    action:action];
    self.navigationItem.leftBarButtonItem = leftItem;
        
    self.navigationItem.hidesBackButton = YES;
}

- (void)setLeftBarItemImage:(UIImage *)image target:(id)target action:(SEL)action
{
    self.navigationItem.leftBarButtonItems = nil;
    UIButton *btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btnLeft setImage:image forState:UIControlStateNormal];
    [btnLeft addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [btnLeft setContentEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    self.navigationItem.hidesBackButton = YES;
}

- (void)setRightBarItem:(UIBarButtonItem *)item
{
    self.navigationItem.rightBarButtonItem = item;
}

- (void)setRightBarItemText:(NSString *)text target:(id)target action:(SEL)action
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:text
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:target
                                                                     action:action];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)setRightBarItemImage:(UIImage *)image target:(id)target action:(SEL)action
{
    UIButton *btnRight = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btnRight setImage:image forState:UIControlStateNormal];
    [btnRight addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btnRight setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, -20)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
}

- (void)enableLeftItem:(BOOL)enable
{
    self.navigationItem.leftBarButtonItem.enabled = enable;
}

- (void)enableRightItem:(BOOL)enable
{
    self.navigationItem.rightBarButtonItem.enabled = enable;
}

- (void)setBackBarItemTarget:(id)target action:(SEL)action
{
    if (target && action) {
        // 定制的返回，主要用于点击返回打开菜单栏，或者返回前需要做额外的动作
        UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [btnBack setImage:[UIImage imageNamed:@"left_back_btn"] forState:UIControlStateNormal];
        [btnBack addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btnBack];
        NSMutableArray *items = [@[]mutableCopy];
        UIBarButtonItem *placeHolder = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        placeHolder.width = -8;
        [items addObject:placeHolder];
        
        [items addObject:backBarButtonItem];
		self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.leftBarButtonItems = items;
        self.navigationItem.hidesBackButton = YES;
    }
    else {
		self.navigationItem.leftBarButtonItems = nil;
        
        UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [btnBack setImage:[UIImage imageNamed:@"left_back_btn"] forState:UIControlStateNormal];
        [btnBack setContentEdgeInsets:UIEdgeInsetsMake(0, -16, 0, 0)];
        [btnBack addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
        self.navigationItem.hidesBackButton = YES;
    }
}

- (void)goBack:(id)sender
{
    if (self.navigationController.topViewController == self) {
        if (self.navigationController.viewControllers.count>1) {
            [self.navigationController popViewControllerAnimated:YES];
        } else if (self.navigationController.presentingViewController) {
            [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}


#pragma mark -
#pragma mark loadingView
- (void)showLoadingView:(NSString *)message
{
//    if (self.loadingView410) {
//        [self.loadingView410 removeFromSuperview];
//        self.loadingView410 = nil;
//    }
//    self.loadingView410 = [[P2PLoadingView410 alloc] initWithView:[AppDelegate sharedWindow]];
//
//    if (message != nil) {
//        [self.loadingView410 setMessage:message];
//    }
//
//    if(![self.loadingView410 isDescendantOfView:[AppDelegate sharedWindow]]) {
//        [[AppDelegate sharedWindow] addSubview:self.loadingView410];
//    }
//    [self.loadingView410 show];
}

- (void)showLoadingViewInView:(NSString *)message frame:(CGRect)lframe{
//    if (self.loadingView410) {
//        [self.loadingView410 removeFromSuperview];
//        self.loadingView410 = nil;
//    }
//    self.loadingView410 = [[P2PLoadingView410 alloc] initWithFrame:lframe];
//
//    if ([CommonUtil isEmptyString:message]){
//        message = LOADING_TEXT_DEFAULT;
//    }
//
//    if (message != nil) {
//        [self.loadingView410 setMessage:message];
//    }
//
//    if(![self.loadingView410 isDescendantOfView:self.view]) {
//        [self.view addSubview:self.loadingView410];
//    }
//
//    [self.loadingView410 show];
}
/*
- (void)showLoadingViewInView:(NSString *)message
{
    [self showLoadingViewInView:message frame:self.view.bounds];
}

- (void)showAlertHudView:(NSString *)message
{
    [self showAlertHudView:message inView:[AppDelegate sharedWindow]];
}

- (void)showAlertHudView:(NSString *)message dismissAfter:(float)delay
{
    [self showAlertHudView:message inView:[AppDelegate sharedWindow]];
    [self hideAlertHudView:delay];
}

- (void)showAlertHudView:(NSString *)message inView:(UIView *)view
{
    if (self.loadingView) {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
    self.loadingView = [[P2PLoadingView alloc] initWithView:view];
	self.loadingView.minSize = CGSizeMake(90, 0);
    self.loadingView.removeFromSuperViewOnHide = YES;
    
    if (message != nil) {
        self.loadingView.detailsLabelText = message;
//        self.loadingView.detailsLabel.text = message;
    }
    self.loadingView.mode = MBProgressHUDModeText;
    
    if(![self.loadingView isDescendantOfView:view]) {
        [view addSubview:self.loadingView];
    }
    [self.loadingView show:YES];
//    [self.loadingView showAnimated:YES];
}

- (void)showAlertHudView:(NSString *)message inView:(UIView *)view dismissAfter:(float)delay
{
    [self showAlertHudView:message inView:view];
    [self hideAlertHudView:delay];
}

- (void)hideLoadingView
{
    if (self.loadingView) {
        [self.loadingView hide:NO];
    }
    if (self.loadingView410) {
        [self.loadingView410 hide];
    }
}

- (void)setHudCompletionBlock:(MBProgressHUDCompletionBlock)block
{
    if ([self.loadingView superview]) {
        self.loadingView.completionBlock = block;
    }
}

- (void)hideAlertHudView:(float)after
{
    [self.loadingView hide:NO afterDelay:after];
//    [self.loadingView hideAnimated:NO afterDelay:after];
}

//实现UIGestureRecognizerDelegate 方法，解决ios5系统 UIButton和Tap事件监听冲突问题
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]){
        return NO;
    }
    return YES;
}
*/

@end
