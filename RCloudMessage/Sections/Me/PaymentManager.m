//
//  PaymentManager.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/5/17.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "PaymentManager.h"
#import <StoreKit/StoreKit.h>
#import "UIViewController+HUD.h"
#import "UIView+MBProgressHUD.h"
#import "MBProgressHUD.h"
#import "UIColor+RCColor.h"

@interface PaymentManager()<SKPaymentTransactionObserver, SKProductsRequestDelegate>
// 所有商品
@property (nonatomic, strong)NSArray *products;
@property (nonatomic, strong)SKProductsRequest *request;
@property (nonatomic, strong)MBProgressHUD *hud;
@property (nonatomic, strong)NSString *productID;
@property (nonatomic, strong)UIView *bgView;

@property (nonatomic, strong)UIView *loadBgView;

@property (nonatomic, strong) UIImageView *imgLoadingView;

@property (nonatomic, strong) CABasicAnimation *picAnimation;

@end

static PaymentManager *manager = nil;

@implementation PaymentManager


+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:manager];
    });
    return manager;
}


- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [_request cancel];
}

// 请求可卖的商品
- (void)requestProducts:(NSString*)productID inView:(UIView*)bgView
{
    
    NSArray *arr = [[SKPaymentQueue defaultQueue] transactions];
    for (SKPaymentTransaction *transAction in arr) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transAction];
    }
    
    self.bgView = bgView;
    [self createAnimationView];
    [self startAnimation];
//    [self.hud showHUDMessage:@"正在生成订单"];
//    [self showHudInView:bgView hint:@"正在生成订单"];
    self.productID = @"";
    if (![SKPaymentQueue canMakePayments]) {
//        [self.hud hideAnimated:YES];
        // 您的手机没有打开程序内付费购买
        return;
    }
    self.productID = productID;
    // 1.请求所有的商品ID
//    NSString *productFilePath = [[NSBundle mainBundle] pathForResource:@"iapdemo.plist" ofType:nil];
//    NSArray *products = [NSArray arrayWithContentsOfFile:productFilePath];
    
    // 2.获取所有的productid
     NSArray *productIds = @[@"vip_1month"];//[products valueForKeyPath:@"productId"];
    
    // 3.获取productid的set(集合中)
    NSSet *set = [NSSet setWithArray:productIds];
    
    // 4.向苹果发送请求,请求可卖商品
    _request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    _request.delegate = self;
    [_request start];
}
 
/**
 *  当请求到可卖商品的结果会执行该方法
 *
 *  @param response response中存储了可卖商品的结果
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    // 用来保存价格
    NSMutableArray *tempIDArray = [NSMutableArray arrayWithCapacity:0];
    
    
    NSMutableDictionary *priceDic = @{}.mutableCopy;
     for (SKProduct *product in response.products) {
 
        // 货币单位
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        // 带有货币单位的价格
        NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
            [priceDic setObject:formattedPrice forKey:product.productIdentifier];
     
         NSLog(@"价格:%@", product.price);
         NSLog(@"标题:%@", product.localizedTitle);
         NSLog(@"秒速:%@", product.localizedDescription);
         NSLog(@"productid:%@", product.productIdentifier);
         
         [tempIDArray addObject:product.productIdentifier];
         if ([product.productIdentifier isEqualToString:self.productID]) {
             [self buyProduct:product];
         }
     }
    if (![tempIDArray containsObject:self.productID]) {
        [self stopAnimation];
    }
    // 保存价格列表
    [[NSUserDefaults standardUserDefaults] setObject:priceDic forKey:@"priceDic"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 1.存储所有的数据
    self.products = response.products;
    self.products = [self.products sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(SKProduct *obj1, SKProduct *obj2) {
        return [obj1.price compare:obj2.price];
    }];
}
 
#pragma mark - 购买商品
- (void)buyProduct:(SKProduct *)product
{
    // 1.创建票据
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    NSLog(@"productIdentifier----%@", payment.productIdentifier);
    
    // 2.将票据加入到交易队列中
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}
 
#pragma mark - 实现观察者回调的方法
/**
 *  当交易队列中的交易状态发生改变的时候会执行该方法
 *
 *  @param transactions 数组中存放了所有的交易
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    /*
     SKPaymentTransactionStatePurchasing, 正在购买
     SKPaymentTransactionStatePurchased, 购买完成(销毁交易)
     SKPaymentTransactionStateFailed, 购买失败(销毁交易)
     SKPaymentTransactionStateRestored, 恢复购买(销毁交易)
     SKPaymentTransactionStateDeferred 最终状态未确定
     */
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"用户正在购买");
                break;
                
            case SKPaymentTransactionStatePurchased:
                NSLog(@"productIdentifier----->%@", transaction.payment.productIdentifier);
                [self buySuccessWithPaymentQueue:queue Transaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"购买失败");
                [queue finishTransaction:transaction];
                [self stopAnimation];
                break;
                
            case SKPaymentTransactionStateRestored:
                NSLog(@"恢复购买");
                //TODO:向服务器请求补货，服务器补货完成后，客户端再完成交易单子
                [queue finishTransaction:transaction];
                [self stopAnimation];
                break;
                
            case SKPaymentTransactionStateDeferred:
                NSLog(@"最终状态未确定");
                [queue finishTransaction:transaction];
                [self stopAnimation];
                break;
                
            default:
                [queue finishTransaction:transaction];
                [self stopAnimation];
                break;
        }
    }
}
 
- (void)buySuccessWithPaymentQueue:(SKPaymentQueue *)queue Transaction:(SKPaymentTransaction *)transaction {
    NSLog(@"这就算是购买成功了");
    [self stopAnimation];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSDictionary *params = @{@"user_id":@"user_id",
//                             // 获取商品
//                             @"goods":[self goodsWithProductIdentifier:transaction.payment.productIdentifier]};
//
//    [manager POST:@"url" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
//
//        if ([responseObject[@"code"] intValue] == 200) {
//
//            // 防止丢单, 必须在服务器确定后从交易队列删除交易
//            // 如果不从交易队列上删除交易, 下次调用addTransactionObserver:, 仍然会回调'updatedTransactions'方法, 以此处理丢单
//
//            WELog(@"购买成功");
//            [queue finishTransaction:transaction];
//        }
//
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//
//    }];
}
 
// 商品列表 也可以使用从苹果请求的数据, 具体细节自己视情况处理
// goods1 是商品的ID
- (NSString *)goodsWithProductIdentifier:(NSString *)productIdentifier {
    NSDictionary *goodsDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"priceDic"];
    return goodsDic[productIdentifier];
}
 
// 恢复购买
- (void)restore
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
 
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    // 恢复失败
    NSLog(@"恢复失败");
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.bgView animated:YES];
        _hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
    }
    return _hud;
}

- (UIImageView*)imgLoadingView{
    if (!_imgLoadingView) {
        _imgLoadingView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 80, 30, 30)];
        _imgLoadingView.image = [UIImage imageNamed:@"rainbow_ic"];
    }
    return _imgLoadingView;
}

- (UIView*)loadBgView{
    if (!_loadBgView) {
        _loadBgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _loadBgView.backgroundColor = [UIColor clearColor];
    }
    return _loadBgView;
}

- (void)createAnimationView{
    
    [self.bgView addSubview:self.loadBgView];
    [self.bgView addSubview:self.imgLoadingView];
    [self.bgView bringSubviewToFront:self.imgLoadingView];
    
    CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];

    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果

    animation.fromValue = [NSNumber numberWithFloat:0.f];

    animation.toValue =  [NSNumber numberWithFloat: M_PI *2];

    animation.duration  = 0.5;

    animation.autoreverses = NO;

    animation.fillMode =kCAFillModeForwards;

    animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    
    self.picAnimation = animation;
    
    [self.imgLoadingView.layer addAnimation:self.picAnimation forKey:nil];

}
 
- (void)startAnimation{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bgView addSubview:self.loadBgView];
        self.imgLoadingView.hidden = NO;
        [self.imgLoadingView.layer addAnimation:self.picAnimation forKey:nil];
    });
}

- (void)stopAnimation{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadBgView removeFromSuperview];
        self.imgLoadingView.hidden = YES;
        [self.imgLoadingView.layer removeAllAnimations];
    });
}

@end

