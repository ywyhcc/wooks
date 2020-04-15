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

@property(nonatomic, assign) BOOL bo; //!< <#注释#>

@property(nonatomic, assign) BOOL picOrBack;

@property (strong, nonatomic) UIActionSheet *actionSheet;

@end

@implementation MomentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"";
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self getData];//获取朋友圈数据
//    [self configData];
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    [self getData];
}

#pragma mark - 模拟数据

- (void)getData {
    
    NSDictionary *dic = @{@"userAccountId":[ProfileUtil getUserAccountID], @"pageNumber":@"1", @"pageSize":@"20"};
    
    [SYNetworkingManager getWithURLString:GetMomentData parameters:dic success:^(NSDictionary *data) {
        NSLog(@"%@", data);
        [self handleData:data];
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)handleData:(NSDictionary *)dic {
    NSString *errCodeStr = dic[@"errorCode"];
    if (!errCodeStr.intValue) {
        [self configData:dic];
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
    self.momentList = [[NSMutableArray alloc] init];
    
    
    
    [self.momentList addObjectsFromArray:[MomentUtil getMomentList:0 pageNum:dic]];
    [self.tableView reloadData];
    NSLog(@"%@", self.momentList);
}

#pragma mark - UI
- (void)configUI
{
    // 封面
    MMImageView * imageView = [[MMImageView alloc] initWithFrame:CGRectMake(0, 0, k_screen_width, 270)];
    imageView.image = [UIImage imageNamed:@"moment_cover"];
    self.coverImageView = imageView;
    
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCoverImage)];
    [self.coverImageView addGestureRecognizer:singleTap];
    // 用户头像
    imageView = [[MMImageView alloc] initWithFrame:CGRectMake(k_screen_width-85, self.coverImageView.bottom-40, 75, 75)];
    imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    imageView.layer.borderWidth = 2;
    imageView.image = [UIImage imageNamed:@"moment_head"];
    self.avatarImageView = imageView;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(k_screen_width - 50, 20, 40, 30);
    [btn setImage:[UIImage imageNamed:@"moment_camera"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(addMoment) forControlEvents:UIControlEventTouchUpInside];
    
    //button长按事件
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnLong:)];
    longPress.minimumPressDuration = 0.5; //定义按的时间
    [btn addGestureRecognizer:longPress];
    
    // 表头
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, k_screen_width, 270)];
    view.userInteractionEnabled = YES;
    [view addSubview:self.coverImageView];
    [view addSubview:self.avatarImageView];
    [view addSubview:btn];
    self.tableHeaderView = view;
    // 表格
    MMTableView * tableView = [[MMTableView alloc] initWithFrame:CGRectMake(0, 0, k_screen_width, k_screen_height-k_bar_height)];
    tableView.separatorInset = UIEdgeInsetsZero;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableHeaderView = self.tableHeaderView;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    // 上拉加载更多
    MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        Moment * moment = [self.momentList lastObject];
        NSArray * tempList = [MomentUtil getMomentList:moment.pk pageNum:nil];
        if ([tempList count]) {
            [self.momentList addObjectsFromArray:tempList];
            [self.tableView reloadData];
            [tableView.mj_footer endRefreshing];
        } else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }];
    [footer setTitle:@"已加载全部" forState:MJRefreshStateNoMoreData];
    footer.stateLabel.font = [UIFont systemFontOfSize:14];
    self.tableView.mj_footer = footer;
}

-(void)btnLong:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // do something
        PostFiendViewController *post = [[PostFiendViewController alloc] init];
        post.textOrPic = YES;
        [self.navigationController pushViewController:post animated:YES];
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
    
    if (self.picOrBack) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.coverImageView.image = image;
    } else {
        PostFiendViewController *post = [[PostFiendViewController alloc] init];
        
        [self.navigationController pushViewController:post animated:YES];
    }
}


#pragma mark - 发布动态
- (void)addMoment
{
    NSLog(@"新增");
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄", @"从相册选择", nil];
    }else{
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消"destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
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
    user.name = @"123213";
    user.account = @"wxid12345678";
    user.region = @"浙江 杭州";
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
        NSArray *arr = [self.operateComment.text componentsSeparatedByString:@"."];
        dic = @{@"momentId":moment.discussIdStr, @"fromUserAccountId":[ProfileUtil getUserAccountID], @"momentOwnerUser":moment.userIds, @"optCode":@"2", @"content":commentText, @"toUserAccountId":self.operateComment.fromUserAccountIdStr, @"discussId":arr[1]};
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
            MMUserDetailViewController * controller = [[MMUserDetailViewController alloc] init];
            controller.user = cell.moment.user;
            [self.navigationController pushViewController:controller animated:YES];
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
            int pk = [link.linkValue intValue];
            MUser * user = [MUser findByPK:pk];
            
            MMUserDetailViewController * controller = [[MMUserDetailViewController alloc] init];
            controller.user = user;
            [self.navigationController pushViewController:controller animated:YES];
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
            NSArray *arr = [self.operateComment.text componentsSeparatedByString:@"."];
            NSDictionary *dic = @{@"discussId":arr[1]};
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
        if (sourceType == UIImagePickerControllerSourceTypeCamera) {
            XFCameraController *cameraController = [XFCameraController defaultCameraController];
            
            __weak XFCameraController *weakCameraController = cameraController;
            
            cameraController.takePhotosCompletionBlock = ^(UIImage *image, NSError *error) {
                NSLog(@"takePhotosCompletionBlock");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakCameraController dismissViewControllerAnimated:YES completion:nil];
                });
            };
            
            cameraController.shootCompletionBlock = ^(NSURL *videoUrl, CGFloat videoTimeLength, UIImage *thumbnailImage, NSError *error) {
                NSLog(@"shootCompletionBlock");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakCameraController dismissViewControllerAnimated:YES completion:nil];
                });
            };
            cameraController.modalPresentationStyle = UIModalPresentationFullScreen;
            
            [self presentViewController:cameraController animated:YES completion:nil];
        }
        else {
            // 跳转到相机或相册页面
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = sourceType;
            [self presentViewController:imagePickerController animated:YES completion:^{
                
            }];
        }
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
    MM_PostNotification(@"ResetMenuView", nil);
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

@end
