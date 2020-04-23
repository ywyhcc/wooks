//
//  MomentViewController.m
//  MomentKit
//
//  Created by LEA on 2017/12/12.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "MomentViewController.h"
#import "WKWebViewController.h"
#import "MMLocationViewController.h"
#import "MMUserDetailViewController.h"
#import "MMCommentInputView.h"
#import "MomentCell.h"
#import "MomentUtil.h"
#import "MMRunLoopWorkDistribution.h"
#import "MMFPSLabel.h"
#import "PostFiendViewController.h"
#include <CoreServices/CoreServices.h>
#import "XFCameraController.h"
#import "SendMomentsViewController.h"
#import "IJSImagePickerController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "RCDCommonString.h"
#import "QiniuQuery.h"
#import "DetailMomentViewController.h"
#import "RCDPersonDetailViewController.h"
#import "MeDetailViewController.h"
#import "RCDUserInfoManager.h"
#import "RCDQRCodeManager.h"
#import "RCDForwardManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "RCDQRInfoHandle.h"
#import "RCDForwardSelectedViewController.h"
#import "MMImagePreviewView.h"

@interface MomentViewController ()<UITableViewDelegate,UITableViewDataSource,UUActionSheetDelegate,MomentCellDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray * momentList;  // 朋友圈动态列表
@property (nonatomic, strong) MMTableView * tableView; // 表格
@property (nonatomic, strong) UIView * tableHeaderView; // 表头
@property (nonatomic, strong) MMImageView * coverImageView; // 封面
@property (nonatomic, strong) MMImageView * avatarImageView; // 当前用户头像
@property (nonatomic, strong) MMCommentInputView * commentInputView; // 评论输入框
@property (nonatomic, strong) MomentCell * operateCell; // 当前操作朋友圈动态
@property (nonatomic, strong) Comment * operateComment; // 当前操作评论
@property (nonatomic, strong) MUser * loginUser; // 当前用户
@property (nonatomic, strong) NSIndexPath * selectedIndexPath; // 当前评论indexPath
@property (nonatomic, assign) CGFloat keyboardHeight; // 键盘高度
@property (nonatomic, strong) UILabel *commentLabel;  //个性签名
@property (nonatomic) NSInteger pageNumber;

@property(nonatomic, assign) BOOL bo; //!< <#注释#>

@property(nonatomic, assign) BOOL picOrBack;

@property (strong, nonatomic) UIActionSheet *actionSheet;

@property (nonatomic, strong) NSArray<RCDFriendInfo *> *friendList;

@property (nonatomic, strong) MMScrollView *currentScrollImageView;

@end

@implementation MomentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pageNumber = 1;
    self.title = @"";
    self.view.backgroundColor = [UIColor whiteColor];
    self.momentList = [[NSMutableArray alloc] init];

    [self getFriendList];
    [self getData];
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    [self setStatusBarBackgroundColor:RCDDYCOLOR(0xf0f0f6, 0x000000)];
    self.view.backgroundColor = [UIColor whiteColor];

    
    [self updateHeadData];
}

- (void)getFriendList{
    [RCDUserInfoManager getFriendListFromServer:^(NSArray<RCDFriendInfo *> *friendList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (friendList) {
                self.friendList = friendList;
            }
        });
    }];
}


- (void)setStatusBarBackgroundColor:(UIColor *)color {
    if ([UIDevice currentDevice].systemVersion.floatValue <= 10.0) {
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
            statusBar.backgroundColor = color;
        }
    }
}

- (void)updateHeadData{
    NSString *portraitUrl = [DEFAULTS stringForKey:RCDUserPortraitUriKey];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:portraitUrl] placeholderImage:[UIImage imageNamed:@"moment_head"]];
    
    self.commentLabel.text = [DEFAULTS objectForKey:UserSingleSign];
}

#pragma mark - 模拟数据

- (void)getData {
    
    NSDictionary *dic = @{@"userAccountId":[ProfileUtil getUserAccountID], @"pageNumber":@"1", @"pageSize":@"20"};
    
    [SYNetworkingManager getWithURLString:GetMomentData parameters:dic success:^(NSDictionary *data) {
        NSLog(@"%@", data);
        [self handleData:data];
        if (![[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            [self.tableView.mj_header endRefreshing];
        }
        
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)getMoreData{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"加载中";
    NSDictionary *dic = @{@"userAccountId":[ProfileUtil getUserAccountID], @"pageNumber":[NSString stringWithFormat:@"%ld",(long)self.pageNumber], @"pageSize":@"20"};
    
    [SYNetworkingManager getWithURLString:GetMomentData parameters:dic success:^(NSDictionary *data) {
        [hud hideAnimated:YES];
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if ([[MomentUtil getMomentListDic:data] count]) {
                self.pageNumber ++;
                [self.tableView.mj_footer endRefreshing];
                [self.momentList addObjectsFromArray:[MomentUtil getMomentListDic:data]];
                [self.tableView reloadData];
            } else {
                [self.tableView.mj_footer endRefreshing];
            }
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)handleData:(NSDictionary *)dic {
    NSString *errCodeStr = dic[@"errorCode"];
    if (!errCodeStr.intValue) {
        self.pageNumber = 2;
        [self configData:dic];
        [self.tableView.mj_header endRefreshing];
    }
}

- (void)configData:(NSDictionary *)dic
{
//    self.loginUser.pk = 1;
//    self.loginUser.type = 1;
//    self.loginUser.name = @"张振动";
//    self.loginUser.account = @"wx123456";
//    self.loginUser.portrait = @"";
//    self.loginUser.region = @"山东 青岛";
    self.loginUser = [MUser findFirstByCriteria:@"WHERE type = 1"];
    if (self.loginUser == nil) {
        self.loginUser = [[MUser alloc] init];
        self.loginUser.account = [ProfileUtil getUserAccountID];
        self.loginUser.name = [DEFAULTS objectForKey:RCDUserNickNameKey];
        self.loginUser.pk = 5;
        self.loginUser.type = 1;
        self.loginUser.portrait = [DEFAULTS objectForKey:RCDUserPortraitUriKey];
        
    }
    
    [self.momentList removeAllObjects];
    [self.momentList addObjectsFromArray:[MomentUtil getMomentListDic:dic]];
    [self.tableView reloadData];
    NSLog(@"%@", self.momentList);
}

#pragma mark - UI
- (void)configUI
{
    // 封面
    MMImageView * imageView = [[MMImageView alloc] initWithFrame:CGRectMake(0, 0, k_screen_width, 250)];
//    imageView.image = [UIImage imageNamed:@"moment_cover"];
    [imageView sd_setImageWithURL:[NSURL URLWithString:[DEFAULTS objectForKey:MomentBackImg]] placeholderImage:[UIImage imageNamed:@"moment_cover"]];
    self.coverImageView = imageView;
    
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCoverImage)];
    [self.coverImageView addGestureRecognizer:singleTap];
    // 用户头像
    NSString *portraitUrl = [DEFAULTS stringForKey:RCDUserPortraitUriKey];
    imageView = [[MMImageView alloc] initWithFrame:CGRectMake(k_screen_width-85, self.coverImageView.bottom-60, 75, 75)];
    imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    imageView.layer.borderWidth = 2;
    [imageView sd_setImageWithURL:[NSURL URLWithString:portraitUrl] placeholderImage:[UIImage imageNamed:@"moment_head"]];
    self.avatarImageView = imageView;
    
    UITapGestureRecognizer *porTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headGestureTap)];
    [self.avatarImageView addGestureRecognizer:porTap];
    
    //个性签名
    self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.avatarImageView.bottom, SCREEN_WIDTH - 20, 30)];
    self.commentLabel.numberOfLines = 0;
    self.commentLabel.text = [DEFAULTS objectForKey:UserSingleSign];
    self.commentLabel.font = [UIFont systemFontOfSize:13];
    self.commentLabel.textAlignment = NSTextAlignmentRight;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(k_screen_width - 50, 20, 40, 30);
    [btn setImage:[UIImage imageNamed:@"moment_camera"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(addMoment) forControlEvents:UIControlEventTouchUpInside];
    
    //button长按事件
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnLong:)];
    longPress.minimumPressDuration = 0.5; //定义按的时间
    [btn addGestureRecognizer:longPress];
    
    // 表头
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, k_screen_width, 290)];
    view.userInteractionEnabled = YES;
    [view addSubview:self.coverImageView];
    [view addSubview:self.avatarImageView];
    [view addSubview:self.commentLabel];
    [view addSubview:btn];
    self.tableHeaderView = view;
    // 表格
    MMTableView * tableView = [[MMTableView alloc] initWithFrame:CGRectMake(0, k_status_height, k_screen_width, k_screen_height-k_bar_height - k_status_height)];
    if ([UIDevice currentDevice].systemVersion.floatValue < 10.0) {
        tableView.frame = CGRectMake(0, 0, k_screen_width, k_screen_height-k_bar_height);
    }
    tableView.separatorInset = UIEdgeInsetsZero;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableHeaderView = self.tableHeaderView;
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    // 上拉加载更多
    MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self getMoreData];
//        Moment * moment = [self.momentList lastObject];
//        NSArray * tempList = [MomentUtil getMomentListDic:nil];
//        if ([tempList count]) {
//            [self.momentList addObjectsFromArray:tempList];
//            [self.tableView reloadData];
//            [tableView.mj_footer endRefreshing];
//        } else {
//            [self.tableView.mj_footer endRefreshingWithNoMoreData];
//        }
    }];
    
    [footer setTitle:@"已加载全部" forState:MJRefreshStateNoMoreData];
    footer.stateLabel.font = [UIFont systemFontOfSize:14];
    self.tableView.mj_footer = footer;
    
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getData];
    }];
//    header.lastUpdatedTimeText = ^NSString * _Nonnull(NSDate * _Nullable lastUpdatedTime) {
//
//    };
    [header setTitle:@"加载中" forState:MJRefreshStateRefreshing];
    header.stateLabel.font = [UIFont systemFontOfSize:14];
    self.tableView.mj_header = header;
}

- (void)headGestureTap{
    MeDetailViewController *personDetailVC = [[MeDetailViewController alloc] init];
    [self.navigationController pushViewController:personDetailVC animated:YES];
//    DetailMomentViewController *nextVC = [[DetailMomentViewController alloc] init];
//    nextVC.userAccoutID = [ProfileUtil getUserAccountID];
//    [self.navigationController pushViewController:nextVC animated:YES];
}

-(void)btnLong:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // do something
        SendMomentsViewController *nextVC = [[SendMomentsViewController alloc] init];
        UINavigationController* cityListNav = [[UINavigationController alloc]initWithRootViewController:nextVC];
        nextVC.type = text;
        nextVC.title = @"发布动态";
        cityListNav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:cityListNav animated:YES completion:nil];
//        PostFiendViewController *post = [[PostFiendViewController alloc] init];
//        post.textOrPic = YES;
//        [self.navigationController pushViewController:post animated:YES];
    }else {
    }
}

- (void)changeCoverImage {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
        }else{
            self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消"destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
        }
    
        self.picOrBack = YES;
        
        self.actionSheet.tag = 10000;
        [self.actionSheet showInView:self.view];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
    
    }];
    
    // 文件显示的图片
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
     // 获取文件类型:
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
         // 用户选的文件为图片类型(kUTTypeImage)
    }else if([mediaType isEqualToString:(NSString*)kUTTypeMovie]){
        // 用户选的文件为视频类型(kUTTypeMovie)
        // 获取视频对应的URL
        NSURL *url = info[UIImagePickerControllerMediaURL];
        // 上传视频时用到data
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        SendMomentsViewController *nextVC = [[SendMomentsViewController alloc] init];
        UINavigationController* cityListNav = [[UINavigationController alloc]initWithRootViewController:nextVC];
        nextVC.title = @"发布动态";
        nextVC.type = video;
        nextVC.videoPath = url;
        cityListNav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:cityListNav animated:YES completion:nil];
    }
    
    if (self.picOrBack) {
        __weak MomentViewController *weakSelf = self;
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        QiniuQuery *query = [[QiniuQuery alloc] init];
        [query uploadWithImage:UIImagePNGRepresentation(image) success:^(NSString *urlStr, NSString *key) {
            
            NSDictionary *params = @{@"momentCover":urlStr,@"userInfoId":[ProfileUtil getUserProfile].userInfoID};
            [SYNetworkingManager requestPUTWithURLStr:UpdateMyInfo paramDic:params success:^(NSDictionary *data) {
                if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                    [DEFAULTS setObject:urlStr forKey:MomentBackImg];
                    [DEFAULTS synchronize];
                    [weakSelf updateCoverImage:urlStr];
                }
                else {
                    
                }
            } failure:^(NSError *error) {
                
            }];
            
            
        } faild:^(NSError *error) {}];
    }
}

- (void)updateCoverImage:(NSString*)imageStr{
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@"moment_cover"]];
}


#pragma mark - 发布动态
- (void)addMoment
{
    NSLog(@"新增");
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄", @"从相册选择",@"视频(不大于60s)", nil];
    }else{
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消"destructiveButtonTitle:nil otherButtonTitles:@"从相册选择",@"视频(不大于60s)", nil];
    }
    self.picOrBack = NO;
    self.actionSheet.tag = 10005;
    [self.actionSheet showInView:self.view];
    
//    PostFiendViewController *post = [[PostFiendViewController alloc]init];
//    [self.navigationController pushViewController:post animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    MUser * user = [[MUser alloc] init];
    user.type = 1;
    user.name = [DEFAULTS objectForKey:RCDUserNickNameKey];;
    user.account = [ProfileUtil getUserAccountID];
    user.portrait = [DEFAULTS objectForKey:RCDUserPortraitUriKey];
//    user.region = @"浙江 杭州";
    [user save];
}

#pragma mark - 评论相关
- (void)addComment:(NSString *)commentText
{
    NSDictionary *dic;
    Moment * moment = self.operateCell.moment;
    if (!self.operateComment) {
        dic = @{@"momentId":moment.discussIdStr, @"fromUserAccountId":[ProfileUtil getUserAccountID], @"momentOwnerUser":moment.userIds, @"optCode":@"1", @"content":commentText};
    } else {
//        NSArray *arr = [self.operateComment.text componentsSeparatedByString:@"."];
        dic = @{@"momentId":moment.discussIdStr, @"fromUserAccountId":[ProfileUtil getUserAccountID], @"momentOwnerUser":moment.userIds, @"optCode":@"2", @"content":commentText, @"toUserAccountId":self.operateComment.fromUserAccountIdStr, @"discussId":self.operateComment.commentDiscussIdStr};
    }
    [SYNetworkingManager postWithURLString:DiscussOrReply parameters:dic success:^(NSDictionary *data) {
        // 新增评论
        Comment * comment = [[Comment alloc] init];
        comment.text = commentText;
        comment.fromUser = self.loginUser;
        comment.fromId = self.loginUser.pk;
        if (self.operateComment) { // 回复评论
            comment.toUser = self.operateComment.fromUser;
            comment.toId = self.operateComment.fromUser.pk;
        }
        // 更新评论列表

        NSMutableArray * commentList = [[NSMutableArray alloc] initWithArray:moment.commentList];
        [commentList addObject:comment];
        moment.commentList = commentList;
        NSMutableString * ids = [[NSMutableString alloc] initWithString:moment.commentIds.length ? moment.commentIds : @""];
        if ([ids length]) {
            [ids appendFormat:@",%d",comment.pk];
        } else {
            [ids appendFormat:@"%d",comment.pk];
        }
        moment.commentIds = ids;
        // 刷新
        self.operateCell.moment = moment;
        [UIView performWithoutAnimation:^{
            [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
        }];
    } failure:^(NSError *error) {

    }];
}

// 滚动table
- (void)scrollForComment
{
    if (self.keyboardHeight > 0) {
        CGRect rect = [AppDelegate sharedInstance].convertRect;
        // 转换成window坐标
        rect = [self.tableView convertRect:rect toView:nil];
        CGFloat delta = self.commentInputView.ctTop - rect.origin.y - rect.size.height;
        CGFloat offsetY = self.tableView.contentOffset.y - delta;
        [self.tableView setContentOffset:CGPointMake(0, offsetY) animated:YES];
    } else {
        if(self.selectedIndexPath.section == self.momentList.count - 1){
            [UIView performWithoutAnimation:^{
                [self.tableView scrollToBottomAnimated:NO];
            }];
        }
    }
}

#pragma mark - MomentCellDelegate
- (void)didOperateMoment:(MomentCell *)cell operateType:(MMOperateType)operateType;
{
    switch (operateType)
    {
        case MMOperateTypeProfile: // 用户详情
        {
//            MMUserDetailViewController * controller = [[MMUserDetailViewController alloc] init];
//            controller.user = cell.moment.user;
//            [self.navigationController pushViewController:controller animated:YES];
            if ([cell.moment.userIds isEqualToString:[ProfileUtil getUserAccountID]]) {
                MeDetailViewController *nextVC = [[MeDetailViewController alloc] init];
                [self.navigationController pushViewController:nextVC animated:YES];
            }
            else {
                RCDPersonDetailViewController *detailViewController = [[RCDPersonDetailViewController alloc] init];
                detailViewController.userId = cell.moment.userIds;
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
            
            break;
        }
        case MMOperateTypeDelete: // 删除
        {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"确定删除吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // 取消
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                // db移除
                NSDictionary *dic = @{@"momentId":cell.moment.discussIdStr};

                [SYNetworkingManager deleteWithURLString:DelFriendInfo parameters:dic success:^(NSDictionary *data) {
                    [cell.moment deleteObject];
                    // 移除UI
                    [self.momentList removeObject:cell.moment];
                    [self.tableView reloadData];
                } failure:^(NSError *error) {
                    
                }];
                               
            }]];
            [self presentViewController:alert animated:YES completion:nil];
            break;
        }
        case MMOperateTypeLocation: // 位置
        {
            MMLocationViewController * controller = [[MMLocationViewController alloc] init];
            controller.location = cell.moment.location;
            [self.navigationController pushViewController:controller animated:YES];
        }
        case MMOperateTypeLike: // 点赞
        {
 
            Moment * moment = cell.moment;
            
            NSDictionary *dic = @{@"optUserAccountId":[ProfileUtil getUserAccountID], @"optCode":moment.isLike ? @"-1" : @"1", @"momentId":moment.discussIdStr};
            
            [SYNetworkingManager requestPUTWithURLStr:LikeOrDisLike paramDic:dic success:^(NSDictionary *data) {
                NSMutableArray * likeList = [NSMutableArray arrayWithArray:moment.likeList];
                NSMutableArray * idList = [NSMutableArray arrayWithArray:[moment.likeIds componentsSeparatedByString:@","]];
                if (moment.isLike) { // 取消点赞
                    moment.isLike = 0;
                    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"type = 1"];
                    NSArray * result = [likeList filteredArrayUsingPredicate:predicate];
                    if ([result count]) {
                        for (MUser * removeUser in result) {
                            if ([removeUser.account isEqualToString:[ProfileUtil getUserAccountID]]) {
                                [likeList removeObject:removeUser];
                                [idList removeObject:[NSString stringWithFormat:@"%d",removeUser.pk]];
                            }
                        }
                        
                    }
                } else { // 点赞
                    moment.isLike = 1;
                    [likeList addObject:self.loginUser];
                    [idList addObject:[NSString stringWithFormat:@"%d",self.loginUser.pk]];
                }
                moment.likeList = likeList;
                moment.likeIds = [MomentUtil getIdsByIdList:idList];
                // 刷新
                [self.momentList replaceObjectAtIndex:cell.tag withObject:moment];
                NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
                if (indexPath) {
                    [UIView performWithoutAnimation:^{
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                              withRowAnimation:UITableViewRowAnimationNone];
                    }];
                }
            } failure:^(NSError *error) {
    
            }];
            break;
        }
        case MMOperateTypeComment: // 添加评论
        {
            self.operateCell = cell;
            self.operateComment = nil;
            
            self.selectedIndexPath = [self.tableView indexPathForCell:cell];
            CGRect rect = [self.tableView rectForRowAtIndexPath:self.selectedIndexPath];
            [AppDelegate sharedInstance].convertRect = rect;
            self.commentInputView.comment = nil;
            [self.commentInputView show];
            break;
        }
        case MMOperateTypeFull: // 全文/收起
        {
            NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
            if (indexPath) {
                [UIView performWithoutAnimation:^{
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                          withRowAnimation:UITableViewRowAnimationNone];
                }];
            }
            break;
        }
        default:
            break;
    }
}

// 选择评论
- (void)didOperateMoment:(MomentCell *)cell selectComment:(Comment *)comment
{
    self.operateCell = cell;
    self.operateComment = comment;
    
    if (comment.fromUser.type == 1) { // 删除自己的评论
        UUActionSheet * sheet = [[UUActionSheet alloc] initWithTitle:@"删除我的评论" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil];
        sheet.tag = MMDelCommentTag;
        [sheet showInView:self.view.window];
    } else { // 回复评论
        self.selectedIndexPath = [self.tableView indexPathForCell:cell];
        self.commentInputView.comment = comment;
        [self.commentInputView show];
    }
}

// 点击高亮文字
- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText
{
    switch (link.linkType)
    {
        case MLLinkTypeURL: // 链接
        {
            WKWebViewController * controller = [[WKWebViewController alloc] init];
            controller.url = linkText;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case MLLinkTypePhoneNumber: // 电话
        {
            UUActionSheet * sheet = [[UUActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@可能是一个电话号码，你可以",link.linkValue] delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"呼叫" otherButtonTitles:@"复制号码",nil];
            sheet.tag = MMHandlePhoneTag;
            [sheet showInView:self.view.window];
            break;
        }
        case MLLinkTypeEmail: // 邮箱
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@",linkText]]];
            break;
        }
        case MLLinkTypeOther: // 用户
        {
//            int pk = [link.linkValue intValue];
//            MUser * user = [MUser findByPK:pk];
            
            if ([[DEFAULTS objectForKey:RCDUserNickNameKey] isEqualToString:linkText]) {
                MeDetailViewController *nextVC = [[MeDetailViewController alloc] init];
                [self.navigationController pushViewController:nextVC animated:YES];
            }
            else{
                if (self.friendList.count == 0) {
                    [self getFriendList];
                    return;
                }
                NSString *userID = nil;
                if (self.friendList.count > 0) {
                    for (RCDFriendInfo *friendInfo in self.friendList) {
                        if ([friendInfo.displayName isEqualToString:linkText] || [friendInfo.name isEqualToString:linkText]) {
                            userID = friendInfo.userId;
                            break;
                        }
                    }
                }
                if (userID != nil) {
                    RCDPersonDetailViewController *nextVC = [[RCDPersonDetailViewController alloc] init];
                    nextVC.userId = userID;
                    [self.navigationController pushViewController:nextVC animated:YES];
                }
            }
//            MMUserDetailViewController * controller = [[MMUserDetailViewController alloc] init];
//            controller.user = user;
//            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UUActionSheetDelegate
- (void)actionSheet:(UUActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == MMHandlePhoneTag) { // 电话
        NSString * title = actionSheet.title;
        NSString * subString = [title substringWithRange:NSMakeRange(0, [title length] - 13)];
        if (buttonIndex == 0) { // 拨打电话
            UIWebView * webView = [[UIWebView alloc] init];
            NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",subString]];
            [webView loadRequest:[NSURLRequest requestWithURL:url]];
            [self.view addSubview:webView];
        } else if (buttonIndex == 1) { // 复制
            [[UIPasteboard generalPasteboard] setPersistent:YES];
            [[UIPasteboard generalPasteboard] setValue:subString forPasteboardType:[UIPasteboardTypeListString objectAtIndex:0]];
        } else { // 取消
            
        }
    } else if (actionSheet.tag == MMDelCommentTag) { // 删除自己的评论
        if (buttonIndex == 0)
        {
            // 移除Moment的评论
            Moment * moment = self.operateCell.moment;
//            NSArray *arr = [self.operateComment.text componentsSeparatedByString:@"."];
//            NSDictionary *dic = @{@"discussId":arr[1]};
            NSDictionary *dic = @{@"discussId":self.operateComment.commentDiscussIdStr};
            [SYNetworkingManager deleteWithURLString:DeleteDisucuss parameters:dic success:^(NSDictionary *data) {
//                NSLog(@"12312%@", data);
                // 移除Moment的评论
                NSMutableArray * tempList = [NSMutableArray arrayWithArray:moment.commentList];
                [tempList removeObject:self.operateComment];
                NSMutableArray * idList = [NSMutableArray arrayWithArray:[MomentUtil getIdListByIds:moment.commentIds]];
                [idList removeObject:[NSString stringWithFormat:@"%d",self.operateComment.pk]];
                moment.commentIds = [MomentUtil getIdsByIdList:idList];
                moment.commentList = tempList;
                // 数据库更新

                [self.operateComment deleteObject];
                // 刷新
                [self.momentList replaceObjectAtIndex:self.operateCell.tag withObject:moment];
                NSIndexPath * indexPath = [self.tableView indexPathForCell:self.operateCell];
                if (indexPath) {
                    [UIView performWithoutAnimation:^{
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                              withRowAnimation:UITableViewRowAnimationNone];
                    }];
                }
            } failure:^(NSError *error) {
                
            }];
        } else { // 取消
            
        }
    } else if (actionSheet.tag == 10000) {
    
        NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    //来源:相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    //来源:相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 2:
                    return;
            }
        } else {
            if (buttonIndex == 2) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    } else if (actionSheet.tag == 10005) {
    
        __weak MomentViewController *weakSelf = self;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:{
                    //来源:相机
                    XFCameraController *cameraController = [XFCameraController defaultCameraController];
                    
                    __weak XFCameraController *weakCameraController = cameraController;
                    
                    cameraController.takePhotosCompletionBlock = ^(UIImage *image, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakCameraController dismissViewControllerAnimated:YES completion:nil];
                            
                            SendMomentsViewController *nextVC = [[SendMomentsViewController alloc] init];
                            UINavigationController* cityListNav = [[UINavigationController alloc]initWithRootViewController:nextVC];
                            nextVC.type = pic;
                            nextVC.imageArray = @[image];
                            nextVC.title = @"发布动态";
                            cityListNav.modalPresentationStyle = UIModalPresentationFullScreen;
                            [weakSelf.navigationController presentViewController:cityListNav animated:YES completion:nil];
                        });
                        
                    };
                    
                    cameraController.shootCompletionBlock = ^(NSURL *videoUrl, CGFloat videoTimeLength, UIImage *thumbnailImage, NSError *error) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakCameraController dismissViewControllerAnimated:YES completion:nil];
                            
                            SendMomentsViewController *nextVC = [[SendMomentsViewController alloc] init];
                            UINavigationController* cityListNav = [[UINavigationController alloc]initWithRootViewController:nextVC];
                            nextVC.type = video;
                            nextVC.videoPath = videoUrl;
                            nextVC.videoImage = thumbnailImage;
                            nextVC.title = @"发布动态";
                            cityListNav.modalPresentationStyle = UIModalPresentationFullScreen;
                            [self.navigationController presentViewController:cityListNav animated:YES completion:nil];
                        });
                    };
                    cameraController.modalPresentationStyle = UIModalPresentationFullScreen;
                    
                    [self presentViewController:cameraController animated:YES completion:nil];
                }
                    break;
                case 1:
                    //来源:相册
                {
                    IJSImagePickerController *imageVc = [[IJSImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4];
                        //可选  可以通过代理的回调去获取数据
                        [imageVc loadTheSelectedData:^(NSArray<UIImage *> *photos, NSArray<NSURL *> *avPlayers, NSArray<PHAsset *> *assets, NSArray<NSDictionary *> *infos, IJSPExportSourceType sourceType, NSError *error) {
                            SendMomentsViewController *nextVC = [[SendMomentsViewController alloc] init];
                            UINavigationController* cityListNav = [[UINavigationController alloc]initWithRootViewController:nextVC];
                            nextVC.type = pic;
                            nextVC.imageArray = photos;
                            nextVC.title = @"发布动态";
                            cityListNav.modalPresentationStyle = UIModalPresentationFullScreen;
                            [self.navigationController presentViewController:cityListNav animated:YES completion:nil];
                            
                            NSLog(@"%@",photos);
                            NSLog(@"%@",avPlayers);
                        }];
                    imageVc.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:imageVc animated:YES completion:nil];
                }
                    break;
                case 2:{
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
                    imagePicker.delegate = self;
                    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                    imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
                    imagePicker.allowsEditing = YES;
                    imagePicker.videoMaximumDuration = 60;
                    [self presentViewController:imagePicker animated:YES completion:nil];
                }
            }
        } else {
            if (buttonIndex == 1) {
                
            } else {
                IJSImagePickerController *imageVc = [[IJSImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4];
                    //可选  可以通过代理的回调去获取数据
                    [imageVc loadTheSelectedData:^(NSArray<UIImage *> *photos, NSArray<NSURL *> *avPlayers, NSArray<PHAsset *> *assets, NSArray<NSDictionary *> *infos, IJSPExportSourceType sourceType, NSError *error) {
                        SendMomentsViewController *nextVC = [[SendMomentsViewController alloc] init];
                        UINavigationController* cityListNav = [[UINavigationController alloc]initWithRootViewController:nextVC];
                        nextVC.imageArray = photos;
                        nextVC.type = pic;
                        nextVC.title = @"发布动态";
                        cityListNav.modalPresentationStyle = UIModalPresentationFullScreen;
                        [self.navigationController presentViewController:cityListNav animated:YES completion:nil];
                        
                        NSLog(@"%@",photos);
                        NSLog(@"%@",avPlayers);
                    }];
                imageVc.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:imageVc animated:YES completion:nil];
            }
        }
            // 跳转到相机或相册页面
//            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//            imagePickerController.delegate = self;
//            imagePickerController.allowsEditing = YES;
//            imagePickerController.sourceType = sourceType;
//            [self presentViewController:imagePickerController animated:YES completion:^{
//
//            }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.momentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"MomentCell";
    MomentCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[MomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.tag = indexPath.row;
    cell.moment = [self.momentList objectAtIndex:indexPath.row]; // UITrackingRunLoopMode
    cell.delegate = self;
    [cell setSingleLongHandler:^(MMScrollView *imgView) {
        if (imgView.imageURL.length == 0) {
            return;
        }
        self.currentScrollImageView = imgView;
        UIAlertAction *cancelAction =
                    [UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *saveAction =
            [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Save", @"RongCloudKit", nil)
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *_Nonnull action) {
                                       [self saveImage];
                                   }];
        UIAlertAction *fowardAction =
        [UIAlertAction actionWithTitle:@"转发"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *_Nonnull action) {
            
            UIImage *image = imgView.imageView.image;
            RCImageMessage *msg = [RCImageMessage messageWithImage:image];
            msg.full = YES;
            RCMessage *message = [[RCMessage alloc] initWithType:1
                                                        targetId:[RCIM sharedRCIM].currentUserInfo.userId
                                                       direction:(MessageDirection_SEND)
                                                       messageId:-1
                                                         content:msg];
            [[RCDForwardManager sharedInstance]
                setWillForwardMessageBlock:^(RCConversationType type, NSString *_Nonnull targetId) {
                    [[RCIM sharedRCIM] sendMediaMessage:type
                        targetId:targetId
                        content:msg
                        pushContent:nil
                        pushData:nil
                        progress:^(int progress, long messageId) {

                        }
                        success:^(long messageId) {

                        }
                        error:^(RCErrorCode errorCode, long messageId) {

                        }
                        cancel:^(long messageId){

                        }];
                }];
            [RCDForwardManager sharedInstance].isForward = YES;
            [RCDForwardManager sharedInstance].isMultiSelect = NO;
            [RCDForwardManager sharedInstance].selectedMessages = @[ [RCMessageModel modelWithMessage:message] ];
            RCDForwardSelectedViewController *forwardSelectedVC = [[RCDForwardSelectedViewController alloc] init];
            UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:forwardSelectedVC];
            navi.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.navigationController presentViewController:navi animated:YES completion:nil];
                               }];
        
        NSArray *actions = @[ cancelAction, saveAction,fowardAction ];
        NSString *info = [RCDQRCodeManager decodeQRCodeImage:[UIImage imageWithData:[self getCurrentPreviewImageData:imgView.imageURL]]];
        if (info) {
            UIAlertAction *identifyQRCodeAction =
                [UIAlertAction actionWithTitle:RCDLocalizedString(@"IdentifyQRCode")
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *_Nonnull action) {
                                           [[RCDQRInfoHandle alloc] identifyQRCode:info base:self];
                                       }];
            actions = @[ cancelAction, saveAction, identifyQRCodeAction ];
        }
        [RCKitUtility showAlertController:nil
                                  message:nil
                           preferredStyle:UIAlertControllerStyleActionSheet
                                  actions:actions
                         inViewController:self];
    }];
    // 停止滚动时渲染图片
    cell.currentIndexPath = indexPath;
//    [[MMRunLoopWorkDistribution sharedInstance] addTask:^BOOL{ // kCFRunLoopDefaultMode
//        if (![cell.currentIndexPath isEqual:indexPath]) {
//            return NO;
//        }
        [cell loadPicture];
//        return YES;
//    } withKey:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 使用缓存行高，避免计算多次
    Moment * moment = [self.momentList objectAtIndex:indexPath.row];
    return moment.rowHeight;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    MM_PostNotification(@"ResetMenuView", nil);
}

#pragma mark - lazy load
- (MMCommentInputView *)commentInputView
{
    if (!_commentInputView) {
        _commentInputView = [[MMCommentInputView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        WS(wSelf);
        [_commentInputView setMMCompleteInputTextBlock:^(NSString *commentText) { // 完成文本输入
            [wSelf addComment:commentText];
        }];
        [_commentInputView setMMContainerWillChangeFrameBlock:^(CGFloat keyboardHeight) { // 输入框监听
            wSelf.keyboardHeight = keyboardHeight;
            [wSelf scrollForComment];
        }];
    }
    return _commentInputView;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//
- (void)saveImage {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        [self showAlertController:NSLocalizedStringFromTable(@"AccessRightTitle", @"RongCloudKit", nil)
                          message:NSLocalizedStringFromTable(@"photoAccessRight", @"RongCloudKit", nil)
                      cancelTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)];
        return;
    }
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary
        writeImageDataToSavedPhotosAlbum:[self getCurrentPreviewImageData:self.currentScrollImageView.imageURL]
                                metadata:nil
                         completionBlock:^(NSURL *assetURL, NSError *error) {
                             if (error != NULL) {
                                 [self showAlertController:nil
                                                   message:NSLocalizedStringFromTable(@"SavePhotoFailed",
                                                                                      @"RongCloudKit", nil)
                                               cancelTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)];
                             } else {
                                 [self showAlertController:nil
                                                   message:NSLocalizedStringFromTable(@"SavePhotoSuccess",
                                                                                      @"RongCloudKit", nil)
                                               cancelTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)];
                             }
                         }];
}
- (NSData *)getCurrentPreviewImageData:(NSString*)path {
    NSData *imageData;
    imageData = [RCKitUtility getImageDataForURLString:path];
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
    
    return data;
}
//NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
- (void)showAlertController:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController
            addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}


@end
