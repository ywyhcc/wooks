//
//  MomentNowLocationViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "MomentNowLocationViewController.h"
#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "POITableViewCell.h"
#import "MJRefresh.h"
#import "UIViewController+HUD.h"
#import "RCDUIBarButtonItem.h"
#import "IJSUConst.h"

@interface MomentNowLocationViewController ()<UISearchControllerDelegate,UISearchResultsUpdating,AMapLocationManagerDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UISearchController *searchController;
@property (nonatomic, strong) UINavigationController *searchNavigationController;
@property (nonatomic, assign)CLLocationCoordinate2D currentLocationCoordinate;
@property (nonatomic, strong)AMapLocationManager *locationManager;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic,strong)AMapSearchAPI *mapSearch;
@property (nonatomic,strong)NSArray *dataArray;
@property (nonatomic ,strong)AMapPOIAroundSearchRequest *request;
@property (nonatomic ,assign)NSInteger currentPage;
@property (nonatomic ,assign)BOOL isSelectedAddress;
@property (nonatomic ,strong)NSIndexPath *selectedIndexPath;
@property (nonatomic ,strong)NSString *city;//定位的当前城市，用于搜索功能

@property (nonatomic ,strong)UITableView *searchTableView;//用于搜索的tableView
@property (nonatomic ,strong)NSArray *tipsArray;//搜索提示的数组
@property (nonatomic ,strong)NSMutableArray *remoteArray;
@property (nonatomic ,strong)AMapPOI *currentPOI;//点击选择的当前的位置插入到数组中
@property (nonatomic ,assign)BOOL isClickPoi;
@property (nonatomic, strong)RCDUIBarButtonItem *rightBtn;
@property (nonatomic, strong)AMapPOI *selectPOI;

@end

@implementation MomentNowLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"位置信息";
    [self setUpSearchController];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.currentPage = 1;
    [self.view addSubview:self.tableView];
    [self configLocationManager];
    [self locateAction];
    self.remoteArray = @[].mutableCopy;
    self.mapSearch = [[AMapSearchAPI alloc] init];
    self.mapSearch.delegate = self;
    
    self.request = [[AMapPOIAroundSearchRequest alloc] init];
    self.request.keywords  = @"商务住宅|餐饮服务|生活服务";
    /* 按照距离排序. */
    self.request.sortrule = 0;
    self.request.offset = 50;
    self.request.requireExtension = YES;
    self.selectedIndexPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
    self.definesPresentationContext = YES;
    [self setRightNav];
}

- (void)setRightNav{
//    self.rightBtn = [[RCDUIBarButtonItem alloc]
//        initWithbuttonTitle:@"选择"
//                 titleColor:[RCDUtilities generateDynamicColor:[FPStyleGuide lightGrayTextColor]
//                                                     darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
//                buttonFrame:CGRectMake(0, 0, 50, 30)
//                     target:self
//                     action:@selector(sendMessage)];
//    [self.rightBtn buttonIsCanClick:YES
//                        buttonColor:[RCDUtilities generateDynamicColor:[FPStyleGuide lightGrayTextColor]
//                                                             darkColor:[HEXCOLOR(0xA8A8A8) colorWithAlphaComponent:0.4]]
//                      barButtonItem:self.rightBtn];
//    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

- (void)setUpSearchController{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    UISearchBar *bar = self.searchController.searchBar;
    bar.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
    bar.barStyle = UIBarStyleDefault;
    bar.translucent = YES;
    bar.barTintColor = [UIColor groupTableViewBackgroundColor];
    bar.tintColor = [UIColor colorWithRed:0 green:(190 / 255.0) blue:(12 / 255.0) alpha:1];
    UIImageView *view = [[[bar.subviews objectAtIndex:0] subviews] firstObject];
    view.layer.borderColor = [UIColor colorWithRed:((0xdddddd >> 16) & 0x000000FF)/255.0f green:((0xdddddd >> 8) & 0x000000FF)/255.0f blue:((0xdddddd) & 0x000000FF)/255.0 alpha:1].CGColor;
    view.layer.borderWidth = 0.7;
    
    bar.showsBookmarkButton = NO;
    UITextField *searchField = [bar valueForKey:@"searchField"];
    searchField.placeholder = @"搜索地点";
    if (searchField) {
        [searchField setBackgroundColor:[UIColor whiteColor]];
        searchField.layer.cornerRadius = 3.0f;
        searchField.layer.borderColor = [UIColor colorWithRed:((0xdddddd >> 16) & 0x000000FF)/255.0f green:((0xdddddd >> 8) & 0x000000FF)/255.0f blue:((0xdddddd) & 0x000000FF)/255.0 alpha:1].CGColor;
        searchField.layer.borderWidth = 0.7;
    }
    
    [self.view addSubview:bar];
}

- (UITableView *)tableView{
    if (_tableView == nil) {//WX_TABBAR_HEIGHT
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT - IJSGStatusBarAndNavigationBarHeight - IJSGTabbarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            self.currentPage ++ ;
            self.request.page = self.currentPage;
            self.request.location = [AMapGeoPoint locationWithLatitude:self.currentLocationCoordinate.latitude longitude:self.currentLocationCoordinate.longitude];
            [self.mapSearch AMapPOIAroundSearch:self.request];
        }];
    }
    return _tableView;
}

- (UITableView *)searchTableView{
    if (_searchTableView == nil) {
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavMustAdd + 64, SCREEN_WIDTH, SCREEN_HEIGHT - NavMustAdd - 64) style:UITableViewStylePlain];
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.tableFooterView = [UIView new];
    }
    return _searchTableView;
}

// 定位SDK
- (void)configLocationManager {
    self.locationManager = [[AMapLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //单次定位超时时间
    [self.locationManager setLocationTimeout:6];
    [self.locationManager setReGeocodeTimeout:3];
}

- (void)locateAction {
    [self showHudInView:self.view hint:@"正在定位..."];
    //带逆地理的单次定位
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error) {
            [self showHint:@"定位错误" yOffset:-180];
            NSLog(@"locError:{%ld - %@};",(long)error.code,error.localizedDescription);
            if (error.code == AMapLocationErrorLocateFailed) {
                return ;
            }
        }
        //定位信息
        NSLog(@"location:%@", location);
        if (regeocode)
        {
            [self hideHud];
            self.isClickPoi = NO;
            self.currentLocationCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            self.city = regeocode.city;
            self.request.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            [self.mapSearch AMapPOIAroundSearch:self.request];
        }
    }];
    
}


#pragma mark -AMapSearchDelegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    
    NSMutableArray *remoteArray = response.pois.mutableCopy;
    self.remoteArray = remoteArray;
    if (self.isClickPoi) {
        [remoteArray insertObject:self.currentPOI atIndex:0];
    }
    if (self.currentPage == 1) {
        self.dataArray = remoteArray;
    }else{
        NSMutableArray * moreArray = self.dataArray.mutableCopy;
        [moreArray addObjectsFromArray:remoteArray];
        self.dataArray = moreArray.copy;
    }
    
    if (response.pois.count< 50) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self.tableView.mj_footer endRefreshing];
    }
    if (self.dataArray.count > 0) {
        self.selectPOI = self.dataArray[0];
    }
    
    [self.tableView reloadData];
    self.isClickPoi = NO;
    
}

- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response{
    
    self.tipsArray = response.tips;
    [self.searchTableView reloadData];
    
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return self.dataArray.count;
    }else{
        return self.tipsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"POITableViewCell";
    POITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil] firstObject];
    }
    if (tableView == self.tableView) {
        AMapPOI *POIModel = self.dataArray[indexPath.row];
        cell.nameLabel.text = POIModel.name;
        cell.addressLable.text = POIModel.address;
        if (indexPath.row==self.selectedIndexPath.row){
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
    }else{
        AMapTip *tipModel = self.tipsArray[indexPath.row];
        cell.nameLabel.text = tipModel.name;
        cell.addressLable.text = tipModel.address;
        
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableView == tableView) {
        self.selectedIndexPath=indexPath;
        [tableView reloadData];
        AMapPOI *POIModel = self.dataArray[indexPath.row];
//        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(POIModel.location.latitude, POIModel.location.longitude);
        self.isSelectedAddress = YES;
        self.selectPOI = POIModel;
        if (self.locationBack) {
            self.locationBack(POIModel.name);
        }
    }else{
        self.searchController.active = NO;
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        AMapTip *tipModel = self.tipsArray[indexPath.row];
//        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(tipModel.location.latitude, tipModel.location.longitude);
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
                
        AMapPOI *POIModel = [AMapPOI new];
        POIModel.address = [NSString stringWithFormat:@"%@%@",tipModel.district,tipModel.address];
        POIModel.location = tipModel.location;
        POIModel.name = tipModel.name;
        self.currentPOI = POIModel;
        self.isClickPoi = YES;
//        [self.tableView reloadData];
        if (self.locationBack) {
            self.locationBack(POIModel.name);
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.searchTableView) {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
}




#pragma mark - UISearchControllerDelegate && UISearchResultsUpdating

//谓词搜索过滤
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.searchBar.text.length == 0) {
        return;
    }
    [self.view addSubview:self.searchTableView];
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.keywords = searchController.searchBar.text;
    tips.city = self.city;
    [self.mapSearch AMapInputTipsSearch:tips];
    
}


#pragma mark - UISearchControllerDelegate代理
- (void)willPresentSearchController:(UISearchController *)searchController{
//    self.searchController.searchBar.frame = CGRectMake(0, 64, self.searchController.searchBar.frame.size.width, 44.0);
//    self.mapView.frame = CGRectMake(0, 44 + Nav_topH, SCREEN_WIDTH, 400);
    
//    self.tableView.frame = CGRectMake(0, 364, SCREEN_WIDTH, SCREEN_HEIGHT - 364);
//    NSLog(@"ss---%@",NSStringFromCGRect(self.tableView.frame));
    
}

- (void)didDismissSearchController:(UISearchController *)searchController{
    self.searchController.searchBar.frame = CGRectMake(0, 0, self.searchController.searchBar.frame.size.width, 44.0);
//    self.tableView.frame = CGRectMake(0, 408, SCREEN_WIDTH, SCREEN_HEIGHT - 408);
    [self.searchTableView removeFromSuperview];
}



- (void)localButtonAction{
    [self locateAction];
}
@end
