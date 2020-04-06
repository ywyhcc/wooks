//
//  PrivacyViewController.m
//  SealTalk
//
//  Created by hanchongchong on 2020/4/6.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "PrivacyViewController.h"

static NSString *cell_id = @"cell_id";

@interface PrivacyViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UIView               *_editv;
    UIButton             *_addPic;
    NSMutableArray       *_imageArray;
    NSArray *arr;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) NSArray *titleArr;
@property(nonatomic, strong) NSMutableArray * privaStrArr; //!<

@end

@implementation PrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleArr = @[@{@"title":@"公开", @"detailLabel":@"所有朋友可见", @"detailTitle":@""},
                      @{@"title":@"私密", @"detailLabel":@"仅自己可见", @"detailTitle":@""},
                      @{@"title":@"部分可见", @"detailLabel":@"选中的朋友可见", @"detailTitle":@"公开"},
                      @{@"title":@"不给谁看", @"detailLabel":@"选中的朋友不可见", @"detailTitle":@"公开"}
    ];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *cancelButton =[[UIButton alloc]initWithFrame:CGRectMake(20, k_status_height, 50, 30)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
//    cancelButton.titleLabel.textColor = [UIColor blackColor];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"谁可以看";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
    titleLabel.frame = CGRectMake(70, k_status_height, k_screen_width-140, 30);
    [self.view addSubview:titleLabel];
   
    
    self.button =[[UIButton alloc]initWithFrame:CGRectMake(k_screen_width-70, k_status_height, 50, 30)];
    [self.button setTitle:@"发表" forState:UIControlStateNormal];
    self.button.backgroundColor = [UIColor greenColor];
    [self.button addTarget:self action:@selector(pushSec) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(16, k_status_height+50, k_screen_width-32, k_screen_height-k_status_height-30) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.1)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.1)];
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView registerClass: [UITableViewCell class] forCellReuseIdentifier:cell_id];
    [self.view addSubview:self.tableView];
}
-(void)pushSec{
    if (!self.privaStrArr.count) {
        self.privaStrArr = [NSMutableArray array];
        [self.privaStrArr addObject:@"公开"];
    }
    if (self.sdkBackDic) {
        self.sdkBackDic(self.privaStrArr);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButton {
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArr.count;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1
                                      reuseIdentifier:cell_id];
    }
    UILabel *titleLabe = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 100, 20)];
    titleLabe.textColor = [UIColor blackColor];
    [titleLabe setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    titleLabe.text = self.titleArr[indexPath.row][@"title"];
    UILabel *detailTitleLabe = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 100, 20)];
    detailTitleLabe.textColor = [UIColor lightGrayColor];
    detailTitleLabe.font = [UIFont systemFontOfSize:15];
    detailTitleLabe.text = self.titleArr[indexPath.row][@"title"];
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.detailTextLabel.tag = 100 + indexPath.row;
    [cell addSubview:titleLabe];
    [cell addSubview:detailTitleLabe];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.privaStrArr = [NSMutableArray array];
    if (indexPath.row <= 1) {
        [self.privaStrArr addObject:self.titleArr[indexPath.row][@"title"]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    
    return view;
}


@end
