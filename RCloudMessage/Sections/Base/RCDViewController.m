//
//  RCDViewController.m
//  SealTalk
//
//  Created by 张改红 on 2019/10/28.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDViewController.h"
#import "RCDUIBarButtonItem.h"

@implementation RCDViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    
    RCDUIBarButtonItem *leftButton =
        [[RCDUIBarButtonItem alloc] initWithLeftBarButton:@""
                                                   target:self
                                                   action:@selector(leftBarButtonItemPressed)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
}

- (void)leftBarButtonItemPressed {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
