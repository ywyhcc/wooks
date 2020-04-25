//
//  MomentListViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/20.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "MomentListViewController.h"
#import "MMTableView.h"
#import "MomentMsgTableViewCell.h"
#import "SingleMomentViewController.h"
#import "MomentMsgModel.h"
#import "RCDUIBarButtonItem.h"
#import "RCDUtilities.h"


@interface MomentListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)MMTableView *tableView;

@property (nonatomic, strong)NSMutableArray *momentList;

@property (nonatomic)NSInteger pageNumber;

@property (nonatomic, strong)RCDUIBarButtonItem *rightBtn;

@end

@implementation MomentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.title = @"互动消息";
    self.pageNumber = 1;
    self.momentList = [NSMutableArray arrayWithCapacity:0];
    self.view.backgroundColor = [UIColor whiteColor];
    [self makeTableView];
    
    [self getData];
    
    [self setNaviItem];
}

- (void)setNaviItem {
    
    self.rightBtn = [[RCDUIBarButtonItem alloc]
        initWithbuttonTitle:@"清空"
                 titleColor:[RCDUtilities generateDynamicColor:[UIColor whiteColor]
                                                     darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                buttonFrame:CGRectMake(0, 0, 50, 30)
                     target:self
                     action:@selector(clearMsgClicked)];
    self.rightBtn.button.backgroundColor = [FPStyleGuide weichatGreenColor];
    self.rightBtn.button.layer.cornerRadius = 7;
    self.rightBtn.button.clipsToBounds = YES;
    [self.rightBtn buttonIsCanClick:YES
                        buttonColor:[UIColor whiteColor]
                      barButtonItem:self.rightBtn];
    self.rightBtn.button.titleLabel.font = [UIFont systemFontOfSize:15];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

- (void)clearMsgClicked{
//    ClearMomentMsg
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"清空中";
    NSDictionary *params = @{};
    [SYNetworkingManager deleteWithURLString:ClearMomentMsg parameters:params success:^(NSDictionary *data) {
        [hud hideAnimated:YES];
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSError *error) {
        [hud hideAnimated:YES];
    }];
}

- (void)makeTableView{
    self.tableView = [[MMTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, k_screen_height-k_bar_height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    // 上拉加载更多
    MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData];
    }];
    [footer setTitle:@"已加载全部" forState:MJRefreshStateNoMoreData];
    footer.stateLabel.font = [UIFont systemFontOfSize:14];
    self.tableView.mj_footer = footer;
}

- (void)getData{
    NSDictionary *params = @{@"pageNumber":[NSString stringWithFormat:@"%ld",(long)self.pageNumber]};
    [SYNetworkingManager getWithURLString:GetMomentMsg parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            self.pageNumber = 2;
            NSArray *tempList = [[data dictionaryValueForKey:@"momentOpts"] arrayValueForKey:@"records"];
            for (NSDictionary *dic in tempList) {
                MomentMsgModel *model = [[MomentMsgModel alloc] initWithDictionary:dic];
                [self.momentList addObject:model];
                [self.tableView reloadData];
            }
        }
    } failure:^(NSError *error) {
    }];
}

- (void)loadMoreData{
    NSDictionary *params = @{@"pageNumber":[NSString stringWithFormat:@"%ld",(long)self.pageNumber]};
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"加载中";
    [SYNetworkingManager getWithURLString:GetMomentMsg parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            [hud hideAnimated:YES];
            self.pageNumber ++;
            NSArray *tempList = [[data dictionaryValueForKey:@"momentOpts"] arrayValueForKey:@"records"];
            if ([tempList count]) {
                [self.tableView.mj_footer endRefreshing];
                for (NSDictionary *dic in tempList) {
                    MomentMsgModel *model = [[MomentMsgModel alloc] initWithDictionary:dic];
                    [self.momentList addObject:model];
                    [self.tableView reloadData];
                }
            } else {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } failure:^(NSError *error) {
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
    MomentMsgTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[MomentMsgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.tag = indexPath.row;
    [cell updateCellWithModel:self.momentList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SingleMomentViewController *momentVC = [[SingleMomentViewController alloc] init];
    MomentMsgModel *moment = self.momentList[indexPath.row];
    momentVC.momentID = moment.momentId;
    [self.navigationController pushViewController:momentVC animated:YES];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MomentMsgTableViewCell cellHeight];
}


@end
