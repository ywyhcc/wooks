//
//  FuctionIntroduceViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/28.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "FuctionIntroduceViewController.h"

@interface FuctionIntroduceViewController ()

@end

@implementation FuctionIntroduceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"功能介绍";
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - k_top_height)];
    textView.font = [UIFont systemFontOfSize:15];
    textView.text = @"1.阅后即焚：可根据内容自动调整阅读时间，不留存任何信息，保护用户隐私。\n2.强提醒：不会再错过任何重要消息。\n3.已读未读提醒：只要他/她看到了，你就会知道。\n4.可传输大文件：传输的文件大小没有限制。\n5.具有多种聊天方式：文字、图片、小视频、语音通话、视频通话。\n6.加密传输：聊天内容进行了加密传输，不用担心网络窃听。\n7.群聊人数无上限：可支持千人视频会议。\n8.群组管理功能更加强大：截屏通知、一键复制新群、进群审核、全员禁言、群主认证，群成员保护。\n9.数据无痕：不存储用户聊天数据，不会对用户的聊天内容进行大数据存储和分析，不存在利用户数据进行商业营销的可能。";
    textView.editable = NO;
    textView.selectable = NO;
    [self.view addSubview:textView];
    
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
