//
//  CanSeeCellView.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CanSeeCellView : UIView

- (void)updateTitle:(NSString*)title andDetail:(NSString*)detail;

- (void)updateSelect:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
