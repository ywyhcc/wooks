//
//  PostFiendViewController.m
//  mytest
//
//  Created by 易云时代 on 2017/7/20.
//  Copyright © 2017年 笑伟. All rights reserved.
//

#import "PostFiendViewController.h"
#import "PrivacyViewController.h"

static NSString *cell_id = @"cell_id";

@interface PostFiendViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UIView               *_editv;
    UIButton             *_addPic;
    NSMutableArray       *_imageArray;
    NSArray *arr;
    
    UITextView *_textView;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) NSArray *titleArr;

@end

@implementation PostFiendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleArr = @[@{@"title":@"所在位置", @"image":@"", @"detailTitle":@""},
                      @{@"title":@"提醒谁看", @"image":@"", @"detailTitle":@""},
                      @{@"title":@"谁可以看", @"image":@"", @"detailTitle":@"公开"},];
    
    UIButton *cancelButton =[[UIButton alloc]initWithFrame:CGRectMake(20, k_status_height, 50, 30)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
//    cancelButton.titleLabel.textColor = [UIColor blackColor];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"发表文字";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
    titleLabel.frame = CGRectMake(70, k_status_height, k_screen_width-140, 30);
    [self.view addSubview:titleLabel];
    if (!self.textOrPic) {
        titleLabel.hidden = YES;
    }
    
    self.button =[[UIButton alloc]initWithFrame:CGRectMake(k_screen_width-70, k_status_height, 50, 30)];
    [self.button setTitle:@"发表" forState:UIControlStateNormal];
    self.button.backgroundColor = [UIColor greenColor];
    [self.button addTarget:self action:@selector(pushSec) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(16, 0, k_screen_width-32, 100)];
    _textView.delegate = self;
//    [self.view addSubview:_textView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(16, k_status_height+30, k_screen_width-32, k_screen_height-k_status_height-30) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.1)];
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView registerClass: [UITableViewCell class] forCellReuseIdentifier:cell_id];
    [self.view addSubview:self.tableView];
    
    [self.tableView.tableHeaderView addSubview:_textView];
    
}
-(void)pushSec{
    NSDictionary *dic = @{@"optUserAccountId":[ProfileUtil getUserAccountID],
                          @"momentAbout":_textView.text,
                          @"location":@"山东 德州",
                          @"momentCanLookUserAccountIds":@"",
                          @"momentAuthority":@"1",
                          @"momentCanLookLabelIds":@""
    };
    [SYNetworkingManager postWithURLString:CreatFrindInfo parameters:dic success:^(NSDictionary *data) {
        NSLog(@"%@", data);
    } failure:^(NSError *error) {
        
    }];
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
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text=self.titleArr[indexPath.row][@"title"];
    cell.detailTextLabel.text=self.titleArr[indexPath.row][@"detailTitle"];

    cell.detailTextLabel.tag = 100 + indexPath.row;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 2) {
        PrivacyViewController *privacyVC = [[PrivacyViewController alloc] init];
        privacyVC.sdkBackDic = ^(NSArray *backArr) {
            [self changeDetailLabel:backArr];
        };
        [self.navigationController pushViewController:privacyVC animated:YES];
    }
}

- (void)changeDetailLabel:(NSArray *)arr {
    UILabel *detailLabel = [self.view viewWithTag:102];
    detailLabel.text = arr[0];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 100.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    
    return view;
}


@end
