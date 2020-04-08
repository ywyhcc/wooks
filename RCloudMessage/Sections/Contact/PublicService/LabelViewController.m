//
//  LabelViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "LabelViewController.h"
#import "LabelTableViewCell.h"
#import "RCDFriendInfo.h"
#import "NewLabelViewController.h"
#import "LabelModel.h"

#define LabelTableViewCellID @"LabelTableViewCell"

@interface LabelViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong) UIButton *headerView;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation LabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNav];
    [self createHeaderView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, RCDScreenHeight - 64 - RCDExtraTopHeight - RCDExtraBottomHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestAllLabels];
}


- (void)setNav{
    self.title = @"标签页";
}

- (void)createHeaderView{
    self.headerView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, [LabelTableViewCell cellHeight]);
    [self.headerView addTarget:self action:@selector(createLabelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *imgLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (CellHeight - 20) / 2, 20, 20)];
    imgLabel.text = @"+";
    imgLabel.layer.borderColor = [FPStyleGuide weichatGreenColor].CGColor;
    imgLabel.layer.borderWidth = 1;
    imgLabel.layer.cornerRadius = 10;
    imgLabel.textAlignment = NSTextAlignmentCenter;
    imgLabel.textColor = [FPStyleGuide weichatGreenColor];
    imgLabel.clipsToBounds = YES;
    [self.headerView addSubview:imgLabel];
    
    
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgLabel.right + 10, (CellHeight - 20) / 2, SCREEN_WIDTH, 20)];
    newLabel.font = [UIFont systemFontOfSize:15];
    newLabel.text = @"新建标签";
    newLabel.textColor = [UIColor colorWithHex:0x24db5a];
    [self.headerView addSubview:newLabel];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, CellHeight - 0.3, SCREEN_WIDTH, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.headerView addSubview:line];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LabelTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:LabelTableViewCellID];
    if (cell == nil) {
        cell = [[LabelTableViewCell alloc] init];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell updateCellModel:self.dataSource[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LabelTableViewCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LabelModel *model = self.dataSource[indexPath.row];
    NewLabelViewController *nextVC = [[NewLabelViewController alloc] init];
    nextVC.titleStr = @"设置标签";
    nextVC.nameStr = model.labelName;
    nextVC.labelID = model.labelid;
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
 
// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
 
// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LabelModel *model = self.dataSource[indexPath.row];
        NSDictionary *params = @{@"labelId":model.labelid};
        [SYNetworkingManager deleteWithURLString:DeleteLabel parameters:params success:^(NSDictionary *data) {
            if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                [self requestAllLabels];
            }
        } failure:^(NSError *error) {
            
        }];
    }
}
 
// 修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}


- (void)createLabelBtnClicked{
    NewLabelViewController *nextVC = [[NewLabelViewController alloc] init];
    nextVC.titleStr = @"新建标签";
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)requestAllLabels{
    NSDictionary *params = @{@"userAccountId":[ProfileUtil getUserAccountID]};
    [SYNetworkingManager getWithURLString:GetAllLabels parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSMutableArray *labels = [NSMutableArray arrayWithCapacity:0];
            NSArray *allLabel = [data arrayValueForKey:@"labels"];
            for (NSDictionary *labelDic in allLabel) {
                NSDictionary *detailLabel = [labelDic dictionaryValueForKey:@"allLabel"];
                LabelModel *model = [[LabelModel alloc] init];
                model.count = [labelDic stringValueForKey:@"labelUserSize"];
                model.labelid = [detailLabel stringValueForKey:@"id"];
                model.labelName = [detailLabel stringValueForKey:@"labelName"];
                [labels addObject:model];
            }
            self.dataSource = labels;
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        NSLog(@"失败");
    }];
}

@end
