//
//  LocationTableViewController.m
//  SealTalk
//
//  Created by zhangzhendong on 2020/4/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "LocationTableViewController.h"
#import "LocationModel.h"
#import "LocationTableViewCell.h"
#import "RCDCommonString.h"

@interface LocationTableViewController ()

@property (nonatomic, strong)NSArray *dataArr;

@end

@implementation LocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestData];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identifier = @"locationCell";
    LocationTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[LocationTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];

    }
    
    LocationModel *model = self.dataArr[indexPath.row];
    [cell updateLabel:model.name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LocationModel *model = self.dataArr[indexPath.row];
    LocationTableViewController *nextVC = [[LocationTableViewController alloc] init];
    switch (self.type) {
        case provence:{
            nextVC.type = city;
            nextVC.locationID = model.locationID;
            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:self.recordDic];
            [muDic setObject:model.name forKey:@"1"];
            nextVC.recordDic = muDic;
            [self.navigationController pushViewController:nextVC animated:YES];
        }
            break;
        case city:{
            nextVC.type = xian;
            nextVC.locationID = model.locationID;
            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:self.recordDic];
            [muDic setObject:model.name forKey:@"2"];
            nextVC.recordDic = muDic;
            [self.navigationController pushViewController:nextVC animated:YES];
        }
            break;
        case xian:{
            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:self.recordDic];
            [muDic setObject:model.name forKey:@"3"];
            self.recordDic = muDic;
            [self updateMeLocationInfo];
        }
            break;
        default:
            break;
    }
}

- (void)requestData{
    
    switch (self.type) {
        case provence:{
            NSDictionary *params = @{@"countryId":@"1"};
            [SYNetworkingManager getWithURLString:GetProvenceInfo parameters:params success:^(NSDictionary *data) {
                if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                    NSMutableArray *modelArr = [NSMutableArray arrayWithCapacity:0];
                    for (NSDictionary *dic in [data arrayValueForKey:@"proviences"]) {
                        LocationModel *model = [[LocationModel alloc] init];
                        model.name = [dic stringValueForKey:@"proName"];
                        model.locationID = [dic stringValueForKey:@"id"];
                        [modelArr addObject:model];
                    }
                    self.dataArr = modelArr;
                    [self.tableView reloadData];
                }
            } failure:^(NSError *error) {
                
            }];
        }break;
        case city:{
            NSDictionary *params = @{@"proId":self.locationID};
            [SYNetworkingManager getWithURLString:GetCityInfo parameters:params success:^(NSDictionary *data) {
                if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                    NSMutableArray *modelArr = [NSMutableArray arrayWithCapacity:0];
                    for (NSDictionary *dic in [data arrayValueForKey:@"citys"]) {
                        LocationModel *model = [[LocationModel alloc] init];
                        model.name = [dic stringValueForKey:@"cityName"];
                        model.locationID = [dic stringValueForKey:@"id"];
                        [modelArr addObject:model];
                    }
                    self.dataArr = modelArr;
                    [self.tableView reloadData];
                }
            } failure:^(NSError *error) {
                
            }];
        }break;
        case xian:{
            NSDictionary *params = @{@"cityId":self.locationID};
            [SYNetworkingManager getWithURLString:GetXianInfo parameters:params success:^(NSDictionary *data) {
                if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
                    NSMutableArray *modelArr = [NSMutableArray arrayWithCapacity:0];
                    for (NSDictionary *dic in [data arrayValueForKey:@"districts"]) {
                        LocationModel *model = [[LocationModel alloc] init];
                        model.name = [dic stringValueForKey:@"districtName"];
                        model.locationID = [dic stringValueForKey:@"id"];
                        [modelArr addObject:model];
                    }
                    self.dataArr = modelArr;
                    [self.tableView reloadData];
                }
            } failure:^(NSError *error) {
                
            }];
        }break;
        default:
            break;
    }
}

- (void)updateMeLocationInfo{
    NSString *str = @"";
    if ([self.recordDic stringValueForKey:@"1"].length > 0) {
        str = [self.recordDic stringValueForKey:@"1"];
    }
    if ([self.recordDic stringValueForKey:@"2"].length > 0) {
        str = [NSString stringWithFormat:@"%@-%@",str,[self.recordDic stringValueForKey:@"2"]];
    }
    if ([self.recordDic stringValueForKey:@"3"].length > 0) {
        str = [NSString stringWithFormat:@"%@-%@",str,[self.recordDic stringValueForKey:@"3"]];
    }
    
    
    NSDictionary *params = @{@"userInfoId":[ProfileUtil getUserProfile].userInfoID,@"district":str};
    [SYNetworkingManager requestPUTWithURLStr:UpdateMyInfo paramDic:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            [DEFAULTS setObject:str forKey:LocationInfo];
        }
    } failure:^(NSError *error) {
        
    }];
}



@end
