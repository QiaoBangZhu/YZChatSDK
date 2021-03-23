//
//  YZAboutViewController.m
//  YChat
//
//  Created by magic on 2020/10/21.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZAboutViewController.h"
#import <Masonry/Masonry.h>
#import "UIColor+ColorExtension.h"
#import "YCommonTextCell.h"
#import "YZWebViewController.h"
#import "CommonConstant.h"
#import "NSBundle+YZBundle.h"

@interface YZAboutViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)UIImageView * logoImageView;
@property (nonatomic, strong)UILabel     * versionLabel;
@property (nonatomic, strong)UITableView * tableView;
@property (nonatomic, strong)NSMutableArray *data;

@end

@implementation YZAboutViewController

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
    userAgreement.key = @"  用户服务协议";
    userAgreement.cselector = @selector(showUserAgreement);
    userAgreement.showAccessory = YES;
        
    YCommonTextCellData *privacy = [YCommonTextCellData new];
    privacy.key = @"  隐私政策";
    privacy.showAccessory = YES;
    privacy.cselector = @selector(showPrivacy);
    [_data addObject:@[userAgreement,privacy]];
    
    [self.tableView reloadData];
}

- (void)showUserAgreement {
    YZWebViewController* webVc = [[YZWebViewController alloc]init];
    webVc.url = [NSURL URLWithString:userAgreementUrl];
    webVc.title = @"用户服务协议";
    [self.navigationController pushViewController:webVc animated:true];
}

- (void)showPrivacy {
    YZWebViewController* webVc = [[YZWebViewController alloc]init];
    webVc.url = [NSURL URLWithString:privacyPolicyUrl];
    webVc.title = @"隐私政策";
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
        make.bottom.equalTo(@0);
        make.left.equalTo(@16);
        make.right.equalTo(@-16);
        make.top.equalTo(_versionLabel.mas_bottom).offset(36);
    }];
    
    UIView *shadowView = [[UIView alloc] init];
    shadowView.frame = CGRectMake(16,319,343,106);
    shadowView.layer.backgroundColor = [UIColor colorWithRed:251/255.0 green:252/255.0 blue:255/255.0 alpha:1.0].CGColor;
    shadowView.layer.shadowColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.88].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(-3,-3);
    shadowView.layer.shadowOpacity = 1;
    shadowView.layer.shadowRadius = 6;
    shadowView.frame = self.tableView.frame;
}

- (UILabel *)versionLabel {
    if (!_versionLabel) {
        _versionLabel = [[UILabel alloc]init];
        _versionLabel.font = [UIFont systemFontOfSize:16];
        _versionLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
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
        _tableView.backgroundColor = [UIColor colorWithHex:0xFBFCFF];
        _tableView.layer.cornerRadius = 8;
        _tableView.scrollEnabled = NO;
        _tableView.tableFooterView = [UIView new];

        _tableView.layer.shadowColor = [[UIColor colorWithHex:0xAEAEC0] CGColor];
        _tableView.layer.shadowOffset = CGSizeMake(3,3);
        _tableView.layer.shadowOpacity = 1;
        _tableView.layer.shadowRadius = 5;
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
    return 0;
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.changeColorWhenTouched = NO;

        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 24, 0, 24)];
         }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsMake(0, 24, 0, 24)];
        }
        
        [cell fillWithData:(YCommonTextCellData *)data];
        return cell;
    }
    
    return nil;
}



@end
