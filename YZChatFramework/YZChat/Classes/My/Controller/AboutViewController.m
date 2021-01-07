//
//  AboutViewController.m
//  YChat
//
//  Created by magic on 2020/10/21.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "AboutViewController.h"
#import <Masonry/Masonry.h>
#import "UIColor+ColorExtension.h"
#import "YCommonTextCell.h"
#import "WebViewController.h"
#import "CommonConstant.h"
#import "NSBundle+YZBundle.h"

@interface AboutViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)UIImageView * logoImageView;
@property (nonatomic, strong)UILabel     * versionLabel;
@property (nonatomic, strong)UITableView * tableView;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"关于我们";
    self.view.backgroundColor =  [UIColor colorWithHex:KCommonBackgroundColor];
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.versionLabel];
    [self.view addSubview:self.tableView];
    [self setupTableView];
    [self makeConstraint];
    [self setupData];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    _versionLabel.text = [NSString stringWithFormat:@"当前版本v%@",app_Version];
}

- (void)setupTableView {
   self.tableView.tableFooterView = [[UIView alloc] init];
   self.tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
   if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
       [self.tableView setSeparatorInset:UIEdgeInsetsZero];
   }
   if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
      [self.tableView setLayoutMargins:UIEdgeInsetsZero];
   }
   [self.tableView registerClass:[YCommonTextCell class] forCellReuseIdentifier:@"textCell"];
   self.tableView.separatorColor = [UIColor colorWithHex:KCommonSepareteLineColor];
   self.tableView.delegate = self;
   self.tableView.dataSource = self;
}

/**
 *初始化视图显示数据
 */
- (void)setupData
{
    _data = [NSMutableArray array];

    YCommonTextCellData *userAgreement = [YCommonTextCellData new];
    userAgreement.key = @"  用户协议";
    userAgreement.cselector = @selector(showUserAgreement);
    userAgreement.showAccessory = YES;
        
    YCommonTextCellData *privacy = [YCommonTextCellData new];
    privacy.key = @"  隐私协议";
    privacy.showAccessory = YES;
    privacy.cselector = @selector(showPrivacy);
    [_data addObject:@[userAgreement,privacy]];
    
    [self.tableView reloadData];
}

- (void)showUserAgreement {
    WebViewController* webVc = [[WebViewController alloc]init];
    webVc.url = [NSURL URLWithString:userAgreementUrl];
    webVc.title = @"用户协议";
    [self.navigationController pushViewController:webVc animated:true];
}

- (void)showPrivacy {
    WebViewController* webVc = [[WebViewController alloc]init];
    webVc.url = [NSURL URLWithString:userAgreementUrl];
    webVc.title = @"隐私协议";
    [self.navigationController pushViewController:webVc animated:true];
}


- (void)makeConstraint {
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(@50);
        make.size.equalTo(@80);
    }];
    
    [self.versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_logoImageView.mas_bottom).offset(10);
        make.centerX.equalTo(@0);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.top.equalTo(_versionLabel.mas_bottom).offset(20);
    }];
    
}

- (UILabel *)versionLabel {
    if (!_versionLabel) {
        _versionLabel = [[UILabel alloc]init];
        _versionLabel.font = [UIFont systemFontOfSize:12];
        _versionLabel.textColor = [UIColor blackColor];
    }
    return _versionLabel;
}

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc]init];
        _logoImageView.image = YZChatResource(@"logo");
    }
    return _logoImageView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _data.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!section) {
        return 0;
    }
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = _data[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[YCommonTextCellData class]]) {
        YCommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
         }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        [cell fillWithData:(YCommonTextCellData *)data];
        return cell;
    }
    
    return nil;
}




@end
