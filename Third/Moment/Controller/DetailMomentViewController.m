//
//  DetailMomentViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/19.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "DetailMomentViewController.h"
#import "MMImageListView.h"
#import "MomentUtil.h"
#import "DetailMomentTableViewCell.h"
#import "UIView+MBProgressHUD.h"
#import "SingleMomentViewController.h"
#import "RCDUIBarButtonItem.h"

@interface DetailMomentViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray * momentList;  // 朋友圈动态列表

@property (nonatomic, strong)MMTableView *tableView;

@property (nonatomic, strong) UIView * tableHeaderView; // 表头
@property (nonatomic, strong) MMImageView * coverImageView; // 封面
@property (nonatomic, strong) MMImageView * avatarImageView; // 当前用户头像

@property (nonatomic, strong) UILabel *commentLabel;  //个性签名

@property (nonatomic)NSInteger pageNumber;

@end

@implementation DetailMomentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"蜜友圈";
    self.pageNumber = 1;
    self.momentList = [NSMutableArray arrayWithCapacity:0];
    
    [self configUI];
    
    [self setNaviItem];
    
    [self getMomentsInfo];
    
    [self updateHeadData];
}

- (void)setNaviItem {
    if ([self.userAccoutID isEqualToString:[ProfileUtil getUserAccountID]]) {
        RCDUIBarButtonItem *rightBtn = [[RCDUIBarButtonItem alloc] initContainImage:[UIImage imageNamed:@"config"]
                                                                     imageViewFrame:CGRectMake(8.5, 8.5, 17, 17)
                                                                        buttonTitle:nil
                                                                         titleColor:nil
                                                                         titleFrame:CGRectZero
                                                                        buttonFrame:CGRectMake(0, 0, 40, 40)
                                                                             target:self
                                                                             action:@selector(messageBtnClicked)];
        self.tabBarController.navigationItem.rightBarButtonItems = @[ rightBtn ];
    }
}

- (void)messageBtnClicked{
    
}

- (void)getMomentsInfo{
    if (self.userAccoutID.length == 0) {
        return;
    }
    NSDictionary *params = @{@"userAccountId":self.userAccoutID,@"pageNumber":@"1"};
    
    [SYNetworkingManager getWithURLString:GetOtherMoments parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            self.pageNumber = 2;
            [self.momentList addObjectsFromArray:[MomentUtil getOtherMomentListDic:data]];
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
    }];
}

- (void)updateHeadData{
    if (self.userAccoutID.length == 0) {
        return;
    }
    __weak DetailMomentViewController *weakSelf = self;
    NSDictionary *params = @{@"fromUserAccountId":[ProfileUtil getUserAccountID],@"toUserAccountId":self.userAccoutID};
        
    [SYNetworkingManager postWithURLString:GetInfo parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            
            NSString *portraitUri = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"avaterUrl"];
            [weakSelf.avatarImageView sd_setImageWithURL:[NSURL URLWithString:portraitUri] placeholderImage:[UIImage imageNamed:@"moment_head"]];
            
            
            NSString *comments = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"comments"];
            self.commentLabel.text = comments;
            
            NSString *momentCover = [[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"momentCover"];
            [weakSelf.coverImageView sd_setImageWithURL:[NSURL URLWithString:momentCover] placeholderImage:[UIImage imageNamed:@"moment_cover"]];
            
            
        }
    } failure:^(NSError *error) {
    }];
}

- (void)configUI
{
    // 封面
    MMImageView * imageView = [[MMImageView alloc] initWithFrame:CGRectMake(0, 0, k_screen_width, 250)];
//    imageView.image = [UIImage imageNamed:@"moment_cover"];
    [imageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"moment_cover"]];
    self.coverImageView = imageView;
    
    // 用户头像
    NSString *portraitUrl = @"";
    imageView = [[MMImageView alloc] initWithFrame:CGRectMake(k_screen_width-85, self.coverImageView.bottom-60, 75, 75)];
    imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    imageView.layer.borderWidth = 2;
    [imageView sd_setImageWithURL:[NSURL URLWithString:portraitUrl] placeholderImage:[UIImage imageNamed:@"moment_head"]];
    self.avatarImageView = imageView;
    
    //个性签名
    self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.avatarImageView.bottom, SCREEN_WIDTH - 20, 30)];
    self.commentLabel.numberOfLines = 0;
    self.commentLabel.text = @"";
    self.commentLabel.font = [UIFont systemFontOfSize:13];
    self.commentLabel.textAlignment = NSTextAlignmentRight;
    
    // 表头
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, k_screen_width, 290)];
    view.userInteractionEnabled = YES;
    [view addSubview:self.coverImageView];
    [view addSubview:self.avatarImageView];
    [view addSubview:self.commentLabel];
    self.tableHeaderView = view;
    
    // 表格
    MMTableView * tableView = [[MMTableView alloc] initWithFrame:CGRectMake(0, 0, k_screen_width, k_screen_height-k_bar_height)];
    tableView.separatorInset = UIEdgeInsetsZero;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableHeaderView = self.tableHeaderView;
    tableView.tableFooterView = [UIView new];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    // 上拉加载更多
    MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData];
    }];
    [footer setTitle:@"已加载全部" forState:MJRefreshStateNoMoreData];
    footer.stateLabel.font = [UIFont systemFontOfSize:14];
    self.tableView.mj_footer = footer;
}

- (void)loadMoreData{
    if (self.userAccoutID.length == 0) {
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak DetailMomentViewController *weakSelf = self;
    NSDictionary *params = @{@"userAccountId":self.userAccoutID,@"pageNumber":[NSString stringWithFormat:@"%ld",(long)self.pageNumber]};
    
    [SYNetworkingManager getWithURLString:GetOtherMoments parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            [hud hideAnimated:YES];
            self.pageNumber ++;
            NSArray * tempList = [MomentUtil getOtherMomentListDic:data];
            if ([tempList count]) {
                [self.momentList addObjectsFromArray:tempList];
                [self.tableView reloadData];
                [weakSelf.tableView.mj_footer endRefreshing];
            } else {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        else {
            [hud hideAnimated:YES];
        }
    } failure:^(NSError *error) {
        [hud hideAnimated:YES];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.momentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"DetailMomentTableViewCell";
    DetailMomentTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[DetailMomentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.tag = indexPath.row;
    [cell setMomentData:self.momentList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SingleMomentViewController *momentVC = [[SingleMomentViewController alloc] init];
    Moment *moment = self.momentList[indexPath.row];
    momentVC.momentID = moment.discussIdStr;
    [self.navigationController pushViewController:momentVC animated:YES];
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DetailMomentTableViewCell cellHeight];
}


@end
