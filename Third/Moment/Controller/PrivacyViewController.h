//
//  PrivacyViewController.h
//  SealTalk
//
//  Created by hanchongchong on 2020/4/6.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivacyViewController : UIViewController

@property (copy, nonatomic)void (^sdkBackDic)(NSArray *backArr); //!< h成功回调

@end

