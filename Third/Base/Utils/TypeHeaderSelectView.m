//
//  TypeHeaderSelectView.m
//  FirstP2P
//
//  Created by zhangzhendong on 2018/8/22.
//  Copyright © 2018年 9888. All rights reserved.
//

#import "TypeHeaderSelectView.h"
#import "NSString+Util.h"

@interface TypeHeaderSelectView()

@property (nonatomic, strong) UIView *indicator;
@property (nonatomic, strong) NSArray *typeArr;

@end

@implementation TypeHeaderSelectView

- (UIButton *)buttonWithFrame:(CGRect)frame text:(NSString *)text tag:(NSInteger)tag{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    NSDictionary *attrsDictionary1 = @{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:17],NSForegroundColorAttributeName:[FPStyleGuide lightGrayTextColor],
                                       NSParagraphStyleAttributeName:paragraphStyle};
    NSDictionary *attrsDictionary2 = @{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:20],NSForegroundColorAttributeName:[UIColor blackColor],NSParagraphStyleAttributeName:paragraphStyle};
    [attributedString1 addAttributes:attrsDictionary1 range:NSMakeRange(0, text.length)];
    [attributedString2 addAttributes:attrsDictionary2 range:NSMakeRange(0, text.length)];
    
    [btn setAttributedTitle:attributedString1 forState:UIControlStateNormal];
    [btn setAttributedTitle:attributedString2 forState:UIControlStateSelected];
    
    [btn addTarget:self action:@selector(onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = tag;
    return btn;
}

- (id)initWithFrame:(CGRect)frame typeNames:(NSArray<NSString *> *)typeArray{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.typeArr = typeArray;
        CGFloat typeWidth = 0;
        for (NSString *typeStr in typeArray) {
            CGSize size = [typeStr suggestedSizeWithFont:[UIFont systemFontOfSize:17]];
            typeWidth += size.width;
        }
        CGFloat whiteAverage = 30;
        if (frame.size.width > (typeWidth + whiteAverage * typeArray.count)) {
            whiteAverage = (frame.size.width - typeWidth) / typeArray.count;
        }
        CGFloat contentWidth = (frame.size.width < (typeWidth + whiteAverage * self.typeArr.count)) ? (typeWidth + whiteAverage * self.typeArr.count) : frame.size.width;
        self.contentSize = CGSizeMake(contentWidth, frame.size.height);
        self.backgroundColor = [UIColor whiteColor];
        self.btnArray = [NSMutableArray array];
        CGFloat left = 0;
        for (int i = 0; i < typeArray.count; i ++) {
            CGSize size = [typeArray[i] suggestedSizeWithFont:[UIFont systemFontOfSize:17]];
            UIButton *btn = [self buttonWithFrame:CGRectMake(left, 0, size.width + whiteAverage, self.frame.size.height) text:typeArray[i] tag:i];
            left += btn.width;
            [self.btnArray addObject:btn];
            [self addSubview:btn];
        }
        self.indicator = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.height - 2, 26, 1)];
        self.indicator.backgroundColor = [UIColor colorWithHex:0x06c360];
        [self addSubview:self.indicator];
        [self onBtnClicked:[self.btnArray firstObject]];
    }
    
    return self;
}

- (void)selectIndex:(NSInteger)index{
    if (index < 0 || index >= self.btnArray.count) return;
    
    [self onBtnClicked:self.btnArray[index]];
}

- (void)updateIndicatorWidth:(CGFloat)indicatorWidth{
    CGRect lastFrame = self.indicator.frame;
    self.indicator.frame = CGRectMake((lastFrame.origin.x + lastFrame.size.width - indicatorWidth) / 2, lastFrame.origin.y, indicatorWidth, lastFrame.size.height);
}

- (void)updateSelectedColor:(UIColor *)selectedColor{
    for (UIButton *btn in self.btnArray) {
        [btn setTitleColor:selectedColor forState:UIControlStateSelected];
    }
    self.indicator.backgroundColor = selectedColor;
}

- (void)onBtnClicked:(UIButton *)sender{
    CGFloat viewWidth = self.contentSize.width;
    if (viewWidth > SCREEN_WIDTH) {
        CGFloat offetx = 0;
        if (sender.center.x <= SCREEN_WIDTH / 2) {
            offetx = 0;
        }else{
            offetx = sender.center.x - SCREEN_WIDTH / 2;
            if (viewWidth - sender.center.x < SCREEN_WIDTH / 2) {
                offetx = viewWidth - SCREEN_WIDTH;
            }
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.contentOffset = CGPointMake(offetx, 0);
        }];
    }
    
    if (self.selectCallback) {
        self.selectCallback(self.typeArr[sender.tag]);
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    for (UIButton *btn in self.btnArray) {
        btn.selected = NO;
    }
    sender.selected = YES;
    self.indicator.center = CGPointMake(sender.center.x, self.indicator.center.y);
    [UIView commitAnimations];
    
//    for (UIButton *tempBtn in self.btnArray) {
//        [tempBtn setTitleColor:[FPStyleGuide redColor] forState:UIControlStateNormal];
//    }
//    [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

@end
