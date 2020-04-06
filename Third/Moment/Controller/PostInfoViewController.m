//
//  PostInfoViewController.m
//  SealTalk
//
//  Created by hanchongchong on 2020/4/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "PostInfoViewController.h"

@interface PostInfoViewController ()

@end

@implementation PostInfoViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
//    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
