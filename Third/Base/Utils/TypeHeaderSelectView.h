//
//  TypeHeaderSelectView.h
//  FirstP2P
//
//  Created by zhangzhendong on 2018/8/22.
//  Copyright © 2018年 9888. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TypeHeaderSelectView : UIScrollView

@property (nonatomic, strong) void (^selectCallback)(NSString *str);

@property (nonatomic, strong) NSMutableArray *btnArray;

- (id)initWithFrame:(CGRect)frame typeNames:(NSArray<NSString *> *)typeArray;

- (void)updateIndicatorWidth:(CGFloat)indicatorWidth;
- (void)updateSelectedColor:(UIColor *)selectedColor;

- (void)selectIndex:(NSInteger)index;

@end
