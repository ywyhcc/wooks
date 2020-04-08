//
//  RCDAboutRongCloudTableViewController.m
//  RCloudMessage
//
//  Created by litao on 15/4/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDAboutRongCloudTableViewController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDLogoTableViewCell.h"
#import "RCDUIBarButtonItem.h"
#import "RCDVersionCell.h"
#import "UIColor+RCColor.h"
#import "RCDDebugTableViewController.h"
#import "RCDCommonString.h"
#import <WebKit/WebKit.h>
#import "WkWebViewController.h"

@interface RCDAboutRongCloudTableViewController ()
@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, strong) NSDate *firstClickDate;
@property (nonatomic, assign) NSUInteger clickTimes;
@end

@implementation RCDAboutRongCloudTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.firstClickDate = nil;
        self.clickTimes = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

    NSLog(@"%@",infoDictionary);

    // app名称

    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];

    // app版本

    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"------%@------%@",app_Name,app_Version);
    [self initUI];
}

#pragma mark - action
- (void)downloadNewVersionIfNeed {
    BOOL isNeedUpdate = [[DEFAULTS objectForKey:RCDNeedUpdateKey] boolValue];
    if (isNeedUpdate) {
        NSString *finalURL = [DEFAULTS objectForKey:RCDApplistURLKey];
        NSURL *applistURL = [NSURL URLWithString:finalURL];
        [[UIApplication sharedApplication] openURL:applistURL];
    }
}
- (void)openUrlFor:(NSInteger)index {
    NSString *urlString = self.urls[index];
    if (!urlString.length) {
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
//    if (url) {
//        [[UIApplication sharedApplication] openURL:url];
//    }
    WKWebViewController *webVC = [[WKWebViewController alloc] init];
    webVC.url = urlString;
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (0 == indexPath.row) {
        static NSString *logoCellWithIdentifier = @"RCDLogoTableViewCell";
        RCDLogoTableViewCell *logoCell = [self.tableView dequeueReusableCellWithIdentifier:logoCellWithIdentifier];
        if (logoCell == nil) {
            logoCell = [[RCDLogoTableViewCell alloc] init];
        }
        logoCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return logoCell;
    }
    if (3 == indexPath.row) {
        static NSString *versionCellWithIdentifier = @"RCDVersionCell";
        RCDVersionCell *versionCell = [self.tableView dequeueReusableCellWithIdentifier:versionCellWithIdentifier];
        if (versionCell == nil) {
            versionCell = [[RCDVersionCell alloc] init];
        }
        [versionCell setCellStyle:DefaultStyle_RightLabel_WithoutRightArrow];
        versionCell.leftLabel.text = RCDLocalizedString(@"SealTalk_version");
//        NSString *SealTalkVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SealTalk Version"];
        versionCell.rightLabel.text = @"1.0";
        BOOL isNeedUpdate = [[DEFAULTS objectForKey:RCDNeedUpdateKey] boolValue];
        if (isNeedUpdate) {
            [versionCell addNewImageView];
        }
        versionCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return versionCell;
    }

    static NSString *reusableCellWithIdentifier = @"RCDBaseSettingTableViewCell";
    RCDBaseSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];

    if (cell == nil) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    if (1 == indexPath.row) {
//        [cell setCellStyle:DefaultStyle];
//        cell.leftLabel.text = RCDLocalizedString(@"update_log");
//    } else if (1 == indexPath.row) {
        [cell setCellStyle:DefaultStyle];
        cell.leftLabel.text = RCDLocalizedString(@"function_introduce");
    } else if (2 == indexPath.row) {
        [cell setCellStyle:DefaultStyle];
        cell.leftLabel.text = RCDLocalizedString(@"offical_website");
    } else if (4 == indexPath.row) {
        [cell setCellStyle:DefaultStyle_RightLabel_WithoutRightArrow];
        cell.leftLabel.text = @"联系我们";//RCDLocalizedString(@"SDK_version");
//        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        cell.rightLabel.text = @"postmaster@whatstalk.cn";
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.f;
    if (0 == indexPath.row) {
        height = 141.f;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row < 4) {
        [self openUrlFor:indexPath.row];
    } else if (indexPath.row == 4) {
        [self downloadNewVersionIfNeed];
    } else if (indexPath.row == 5) {
        if (self.clickTimes == 0) {
            self.firstClickDate = [[NSDate alloc] init];
            self.clickTimes = 1;
        } else if ([self.firstClickDate timeIntervalSinceNow] > -3) {
            self.clickTimes++;
            if (self.clickTimes >= 5) {
                [self gotoDebugModel];
            }
        } else {
            self.clickTimes = 0;
            self.firstClickDate = nil;
        }
    }
}

- (void)gotoDebugModel {
    RCDDebugTableViewController *debugVC = [RCDDebugTableViewController new];
    [self.navigationController pushViewController:debugVC animated:YES];
}

- (void)setPoweredView {
    CGRect screenBounds = self.view.frame;
    UILabel *footerLabel = [[UILabel alloc] init];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.frame = CGRectMake(
        screenBounds.size.width / 2 - 100,
        screenBounds.size.height - 30 - 21 - self.navigationController.navigationBar.frame.size.height, 200, 21);
    footerLabel.text = @"Powered by woostalk";
    [footerLabel setFont:[UIFont systemFontOfSize:12.f]];
    [footerLabel setTextColor:[UIColor colorWithHexString:@"999999" alpha:1.0]];
    [self.view addSubview:footerLabel];
}

- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addNewImageView:(RCDBaseSettingTableViewCell *)cell {
    UIImageView *newImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new"]];
    newImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:newImageView];
    UILabel *leftLabel = cell.leftLabel;
    NSDictionary *views = NSDictionaryOfVariableBindings(leftLabel, newImageView);
    [cell.contentView
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[leftLabel]-10-[newImageView(50)]"
                                                               options:0
                                                               metrics:nil
                                                                 views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[newImageView(23)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:newImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
}

- (void)initUI {
    [self setPoweredView];
    self.navigationItem.title = RCDLocalizedString(@"about_sealtalk");

    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:@""//RCDLocalizedString(@"me")
                                                                             target:self
                                                                             action:@selector(clickBackBtn:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

#pragma mark - getter
- (NSArray *)urls {
    if (!_urls) {
        _urls = @[
            @"http://47.99.177.136:8081/Woostalk/index_wap.html",
            @"http://47.99.177.136:8081/Woostalk/index_wap.html",
            @"http://47.99.177.136:8081/Woostalk/index_wap.html",
            @"http://47.99.177.136:8081/Woostalk/index_wap.html"
        ];
    }
    return _urls;
}
@end
