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
#import "MomentNowLocationViewController.h"
#import "CanSeeMomentViewController.h"
#import "QiniuQuery.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIView+MBProgressHUD.h"
#import "UIColor+RCColor.h"

#define kSingleLineHeight 80
#define kMaxLines  6

@interface SendMomentsViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HDragItemListView *itemList;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSString *locationStr;
@property (nonatomic, strong) NSString *membersStr;

@property (nonatomic, assign) CGFloat lastTextViewHeight;

@property (nonatomic, strong) RCDUIBarButtonItem *rightBtn;
@property (nonatomic, strong) RCDUIBarButtonItem *leftBtn;

@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, strong) NSMutableArray *fileArray;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIImageView *videoPic;
@property (nonatomic ,strong) dispatch_queue_t queue;

@end

@implementation SendMomentsViewController

- (instancetype)init {
    if (self = [super init]) {
        _queue = dispatch_get_main_queue();
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView{
    [super loadView];
    
    self.fileArray = [NSMutableArray arrayWithCapacity:0];
    self.params = [NSMutableDictionary dictionaryWithCapacity:0];
    [self.params setObject:[ProfileUtil getUserAccountID] forKey:@"optUserAccountId"];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNavigationButton];
    
    switch (self.type) {
        case pic:{
            [self initPicHeadview];
        }
            break;
        case text:{
            [self initTextHeadview];
        }
            break;
        case video:{
            [self initVideoHeadView];
        }
                break;
            
        default:
            break;
    }

}

- (void)initPicHeadview{
    
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
    

    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, SCREEN_HEIGHT - IJSGStatusBarAndNavigationBarHeight - 10) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_tableView];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, itemList.frame.size.height)];

    [headerView addSubview:itemList];
    
    self.locationStr = @"";

    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width, kSingleLineHeight)];
    _textView.font = [UIFont systemFontOfSize:16];
//    _textView.text = @"   你的想法";
    [headerView addSubview:_textView];

    itemList.y = _textView.height + 64;
    headerView.height = itemList.height + itemList.y;

    _tableView.tableHeaderView = headerView;
    _tableView.tableFooterView = [UIView new];

    [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];

    
    [self initData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChange:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)initTextHeadview{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, SCREEN_HEIGHT - IJSGStatusBarAndNavigationBarHeight - 10) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_tableView];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    
    self.locationStr = @"";

    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width, 130)];
    _textView.font = [UIFont systemFontOfSize:16];
//    _textView.text = @"   你的想法";
    [headerView addSubview:_textView];

    _tableView.tableHeaderView = headerView;
    _tableView.tableFooterView = [UIView new];

    [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
}

- (void)initVideoHeadView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, SCREEN_HEIGHT - IJSGStatusBarAndNavigationBarHeight - 10) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_tableView];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    
    self.locationStr = @"";

    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width, 50)];
    _textView.font = [UIFont systemFontOfSize:16];
//    _textView.text = @"   你的想法";
    [headerView addSubview:_textView];
    
    self.videoPic = [[UIImageView alloc] initWithFrame:CGRectMake(20, _textView.bottom + 10, 45, 80)];
    if (self.videoImage != nil) {
        self.videoPic.image = self.videoImage;
    }
    else {
        self.videoPic.image = [self getVideoPreViewImage:self.videoPath];
    }
    self.videoPic.backgroundColor = [UIColor redColor];
    [headerView addSubview:self.videoPic];

    _tableView.tableHeaderView = headerView;
    _tableView.tableFooterView = [UIView new];

    [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
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
                 titleColor:[RCDUtilities generateDynamicColor:[UIColor whiteColor]
                                                     darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
                buttonFrame:CGRectMake(0, 0, 50, 30)
                     target:self
                     action:@selector(sendBtnClicked)];
    self.rightBtn.button.backgroundColor = [FPStyleGuide weichatGreenColor];
    self.rightBtn.button.layer.cornerRadius = 7;
    self.rightBtn.button.clipsToBounds = YES;
    [self.rightBtn buttonIsCanClick:YES
                        buttonColor:[UIColor whiteColor]
                      barButtonItem:self.rightBtn];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

- (void)cancelBtnClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendBtnClicked{
    [self.textView resignFirstResponder];
    [self.hud show:YES];
    [self.params setObject:self.textView.text forKey:@"momentAbout"];
    if (self.locationStr.length > 0) {
        [self.params setObject:self.locationStr forKey:@"location"];
    }
    __weak SendMomentsViewController *weakSelf = self;
    switch (self.type) {
        case text:{
            [SYNetworkingManager postWithURLString:CreatFrindInfo parameters:self.params success:^(NSDictionary *data) {
                [self.hud hideAnimated:YES];
                if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                    if (weakSelf.sendCallBack) {
                        weakSelf.sendCallBack(YES);
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            } failure:^(NSError *error) {
                [self.hud hideAnimated:YES];
            }];
        }
            break;
        case pic:{
            [self backItemListImages:^(NSArray *imageArr) {
                [SYNetworkingManager postWithURLString:CreatFrindInfo parameters:self.params success:^(NSDictionary *data) {
                    [self.hud hideAnimated:YES];
                    if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                        if (weakSelf.sendCallBack) {
                            weakSelf.sendCallBack(YES);
                        }
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                } failure:^(NSError *error) {
                    [self.hud hideAnimated:YES];
                }];
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.hud hideAnimated:YES];
            });
        }
            break;
        case video:{
            
            NSData *data = [NSData dataWithContentsOfURL:self.videoPath];
            QiniuQuery *query = [[QiniuQuery alloc] init];
            [query uploadVideo:data success:^(NSString *urlStr, NSString *key) {
                
                NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithCapacity:0];
                [muDic setObject:urlStr forKey:@"fileUrl"];
                [muDic setObject:@"2" forKey:@"fileType"];//图片
                [muDic setObject:@"mp4" forKey:@"fileExtension"];
                [muDic setObject:key forKey:@"fileKey"];
                [self.params setObject:@[muDic] forKey:@"momentFiles"];
                [SYNetworkingManager postWithURLString:CreatFrindInfo parameters:self.params success:^(NSDictionary *data) {
                    [self.hud hideAnimated:YES];
                    if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                        if (weakSelf.sendCallBack) {
                            weakSelf.sendCallBack(YES);
                        }
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                } failure:^(NSError *error) {
                    [self.hud hideAnimated:YES];
                }];
            } faild:^(NSError *error) {
            }];
        }
            break;
        default:
            break;
    }
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"所在位置";
        if (self.locationStr.length > 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"所在位置:%@",self.locationStr];
        }
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"谁可以看";
        if (self.membersStr.length > 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"谁可以看:%@",self.membersStr];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak SendMomentsViewController *weakSelf = self;
    if (indexPath.row == 0) {
        
        MomentNowLocationViewController *nextVC = [[MomentNowLocationViewController alloc] init];
        nextVC.locationBack = ^(NSString *location){
            weakSelf.locationStr = location;
            [weakSelf.tableView reloadData];
        };
        [self.navigationController pushViewController:nextVC animated:YES];
    } else if (indexPath.row == 1) {
        CanSeeMomentViewController *nextVC = [[CanSeeMomentViewController alloc] init];
        nextVC.canSeeCallBack = ^(NSArray *membersID, BOOL isSomeCanSee, NSArray *labelsID, NSString *names) {
            if (membersID.count > 0) {
                [weakSelf.params setObject:membersID forKey:@"momentCanLookUserAccountIds"];
            }
            if (isSomeCanSee) {
                [weakSelf.params setObject:@"2" forKey:@"momentAuthority"];
            }
            if (labelsID.count > 0) {
                [weakSelf.params setObject:membersID forKey:@"momentCanLookLabelIds"];
            }
            if (names.length > 0) {
                weakSelf.membersStr = names;
                [weakSelf.tableView reloadData];
            }
        };
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}

- (void)backItemListImages:(void (^)(NSArray *imageArr))back{
    [self.fileArray removeAllObjects];
    __weak SendMomentsViewController *weakSelf = self;
    [self.hud showAnimated:YES];
    HDragItem *lastItem = [weakSelf.itemList.itemArray lastObject];
    BOOL lastIsAdd = lastItem.isAdd;
    for (HDragItem *item in self.itemList.itemArray) {
        if (item.isAdd) {continue;}
        dispatch_barrier_async(_queue, ^{
            QiniuQuery *query = [[QiniuQuery alloc] init];
            [query uploadWithImage:UIImagePNGRepresentation(item.image) success:^(NSString *urlStr, NSString *kye) {
                NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithCapacity:0];
                [muDic setObject:urlStr forKey:@"fileUrl"];
                [muDic setObject:@"1" forKey:@"fileType"];//图片
                [muDic setObject:@"png" forKey:@"fileExtension"];
                [muDic setObject:kye forKey:@"fileKey"];
                [weakSelf.fileArray addObject:muDic];
                NSUInteger itemCount = weakSelf.itemList.itemArray.count;
                if (lastIsAdd) {
                    itemCount = weakSelf.itemList.itemArray.count - 1;
                }
                if (weakSelf.fileArray.count == itemCount) {
                    [weakSelf.params setObject:weakSelf.fileArray forKey:@"momentFiles"];
                    [weakSelf.hud hideAnimated:YES];
                    back(weakSelf.fileArray);
                }
                else {
                    [weakSelf.params setObject:@[] forKey:@"momentFiles"];
                }
            } faild:^(NSError *error) {
            }];
        });
    }
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
    
    HDragItem *lastItem = [self.itemList.itemArray lastObject];
    BOOL lastIsAdd = lastItem.isAdd;
    NSUInteger itemCount = lastIsAdd ? self.itemList.itemArray.count - 1 : self.itemList.itemArray.count;
    if (9 - itemCount <= 0) {
        return;
    }
    IJSImagePickerController *imageVc = [[IJSImagePickerController alloc] initWithMaxImagesCount:9 - itemCount columnNumber:4];
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

// 获取视频第一帧
- (UIImage*) getVideoPreViewImage:(NSURL *)path
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
    }
    return _hud;
}

@end
