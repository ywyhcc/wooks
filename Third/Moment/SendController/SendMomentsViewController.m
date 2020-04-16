//
//  ViewController.m
//  HDragImageDemo
//
//  Created by 黄江龙 on 2018/9/5.
//  Copyright © 2018年 huangjianglong. All rights reserved.
//

#import "SendMomentsViewController.h"
#import "HDragItemListView.h"
#import "UIView+Ex.h"
#import "RCDUIBarButtonItem.h"
#import "RCDUtilities.h"
#import "IJSImagePickerController.h"
#import "IJSExtension.h"

#define kSingleLineHeight 80
#define kMaxLines  6

@interface SendMomentsViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HDragItemListView *itemList;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, assign) CGFloat lastTextViewHeight;

@property (nonatomic, strong) RCDUIBarButtonItem *rightBtn;
@property (nonatomic, strong) RCDUIBarButtonItem *leftBtn;

@end

@implementation SendMomentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNavigationButton];
    
    HDragItem *item = [[HDragItem alloc] init];
    item.backgroundColor = [UIColor clearColor];
    item.image = [UIImage imageNamed:@"add_image"];
    item.isAdd = YES;
    
    // 创建标签列表
    HDragItemListView *itemList = [[HDragItemListView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    self.itemList = itemList;
    itemList.backgroundColor = [UIColor clearColor];
    // 高度可以设置为0，会自动跟随标题计算
    // 设置排序时，缩放比例
    itemList.scaleItemInSort = 1.3;
    // 需要排序
    itemList.isSort = YES;
    itemList.isFitItemListH = YES;

    [itemList addItem:item];

    __weak typeof(self) weakSelf = self;

    [itemList setClickItemBlock:^(HDragItem *item) {
        if (item.isAdd) {
            NSLog(@"添加");
            [weakSelf showUIImagePickerController];
        }
    }];
    
    /**
     * 移除tag 高度变化，得重设
     */
    itemList.deleteItemBlock = ^(HDragItem *item) {
        HDragItem *lastItem = [weakSelf.itemList.itemArray lastObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!lastItem.isAdd) {
                HDragItem *item = [[HDragItem alloc] init];
                item.backgroundColor = [UIColor clearColor];
                item.image = [UIImage imageNamed:@"add_image"];
                item.isAdd = YES;
                [weakSelf.itemList addItem:item];
            }
            [weakSelf updateHeaderViewHeight];
        });
    };
    
    [self.view addSubview:itemList];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, SCREEN_HEIGHT - IJSGStatusBarAndNavigationBarHeight - 10) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_tableView];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, itemList.frame.size.height)];

    [headerView addSubview:itemList];
    
//    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)]

    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width, kSingleLineHeight)];
    _textView.font = [UIFont systemFontOfSize:16];
    _textView.text = @"   你的想法";
    [headerView addSubview:_textView];

    itemList.y = _textView.height + 64;
    headerView.height = itemList.height + itemList.y;

    _tableView.tableHeaderView = headerView;
    _tableView.tableFooterView = [UIView new];

    [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];

    
    [self initData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChange:) name:UITextViewTextDidChangeNotification object:nil];

}

- (void)initData{
    if (self.imageArray.count == 0) {
        return;
    }
    for (UIImage *img in self.imageArray) {
        HDragItem *item = [[HDragItem alloc] init];
        item.image = img;
        item.backgroundColor = [UIColor purpleColor];
        [self.itemList addItem:item];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateHeaderViewHeight];
    });
    
}

- (void)setNavigationButton {
    self.leftBtn = [[RCDUIBarButtonItem alloc]
    initWithbuttonTitle:@"取消"
             titleColor:[RCDUtilities generateDynamicColor:[FPStyleGuide lightGrayTextColor]
                                                 darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
            buttonFrame:CGRectMake(0, 0, 50, 30)
                 target:self
                 action:@selector(cancelBtnClicked)];
    
    [self.leftBtn buttonIsCanClick:YES
                           buttonColor:[RCDUtilities generateDynamicColor:[UIColor blackColor]
                                                                darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                         barButtonItem:self.leftBtn];
       self.navigationItem.leftBarButtonItems = [self.leftBtn setTranslation:self.leftBtn translation:11];
    

    self.rightBtn = [[RCDUIBarButtonItem alloc]
        initWithbuttonTitle:@"发布"
                 titleColor:[RCDUtilities generateDynamicColor:[FPStyleGuide lightGrayTextColor]
                                                     darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                buttonFrame:CGRectMake(0, 0, 50, 30)
                     target:self
                     action:@selector(sendBtnClicked)];
    [self.rightBtn buttonIsCanClick:YES
                        buttonColor:[RCDUtilities generateDynamicColor:[FPStyleGuide lightGrayTextColor]
                                                             darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                      barButtonItem:self.rightBtn];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

- (void)cancelBtnClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendBtnClicked{
    
}

//更新头部高度
- (void)updateHeaderViewHeight{
    self.itemList.y = _textView.height + 20;
    self.tableView.tableHeaderView.height = self.itemList.itemListH + self.itemList.y;
    [self.tableView beginUpdates]; //加上这对代码，改header的时候，会有动画，不然比较僵硬
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
    [self.tableView endUpdates];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"所在位置";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"谁可以看";
    }
    return cell;
}


#pragma mark - textView
- (void)textViewChange:(NSNotificationCenter *)notifi{
    CGSize size = [_textView sizeThatFits:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)];
    CGFloat height = size.height;
    BOOL scrollEnabled = NO;
    if (height > kSingleLineHeight * kMaxLines) {
        height = kSingleLineHeight * kMaxLines;
        scrollEnabled = YES;
    }
    _textView.scrollEnabled = scrollEnabled;
    _textView.height = height;
    
    if (_lastTextViewHeight != height && _lastTextViewHeight > 0) { //换行
        [self updateHeaderViewHeight];
    }
    
    _lastTextViewHeight = height;
}

#pragma mark - UIImagePickerController
- (void)showUIImagePickerController{
    IJSImagePickerController *imageVc = [[IJSImagePickerController alloc] initWithMaxImagesCount:9 - self.itemList.itemArray.count columnNumber:4];
        //可选  可以通过代理的回调去获取数据
        [imageVc loadTheSelectedData:^(NSArray<UIImage *> *photos, NSArray<NSURL *> *avPlayers, NSArray<PHAsset *> *assets, NSArray<NSDictionary *> *infos, IJSPExportSourceType sourceType, NSError *error) {
            
            for (UIImage *img in photos) {
                HDragItem *item = [[HDragItem alloc] init];
                item.image = img;
                item.backgroundColor = [UIColor purpleColor];
                [self.itemList addItem:item];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateHeaderViewHeight];
            });
        }];
    imageVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imageVc animated:YES completion:nil];
}


@end
