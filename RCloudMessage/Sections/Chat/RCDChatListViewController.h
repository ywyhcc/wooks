//
//  RongCloud
//
//  Created by Liv on 14/10/31.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import <UIKit/UIKit.h>

@interface RCDChatListViewController : RCConversationListViewController

@property (nonatomic)BOOL comeToMsgList;

- (void)updateBadgeValueForTabBarItem;

@end
