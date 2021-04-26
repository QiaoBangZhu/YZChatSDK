//
//  MyViewController.m
//  YChat
//
//  Created by magic on 2020/9/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZMyViewController.h"
#import "UIColor+TUIDarkMode.h"
#import "YZSettingViewController.h"
#import "YZProfileViewController.h"
#import "YChatSettingStore.h"
#import "YZProfileCardCell.h"
#import "YZCommonTextImageTableViewCell.h"
#import "UIColor+ColorExtension.h"
#import "YZMyQRCodeViewController.h"
#import "YZWebViewController.h"
#import "QRScanViewController.h"
#import "UIImage+YChatExtension.h"
#import <Masonry/Masonry.h>
#import "CIGAMKit.h"
#import "NSBundle+YZBundle.h"
#import "YUserInfo.h"
#import "THeader.h"
#import "TUIKit.h"


@interface YZMyViewController () <ProfileCardDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) ProfileCardCellData *profileCellData;
@property (nonatomic, strong) UITableView * tableView;
@end

@implementation YZMyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.right.equalTo(@-16);
        make.top.equalTo(@0);
        make.bottom.equalTo(@-24);
    }];
}

- (UIImage *)navigationBarBackgroundImage {
    return  [UIImage cigam_imageWithColor: UIColorClear];
}

- (UIImage *)navigationBarShadowImage {
    return [UIImage cigam_imageWithColor: UIColorClear size:CGSizeMake(4, PixelOne) cornerRadius:0];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(16, 0, KScreenWidth-32, KScreenHeight-safeAreaTopHeight) style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        [_tableView registerClass:[YZProfileCardCell class] forCellReuseIdentifier:@"personalCell"];
        [_tableView registerClass:[YZCommonTextImageTableViewCell class] forCellReuseIdentifier:@"textCell"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = false;
        _tableView.alwaysBounceHorizontal = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.layer.cornerRadius = 8;
        _tableView.layer.masksToBounds = YES;
    }
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self configureNav];
    [self setupData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage imageWithColor:[UIColor clearColor]];
}


/**
 *初始化视图显示数据
 */
- (void)setupData
{

    _data = [NSMutableArray array];

    YUserInfo* user = [[YChatSettingStore sharedInstance]getUserInfo];
    
    ProfileCardCellData *personal = [[ProfileCardCellData alloc] init];
    personal.name = user.nickName;
    personal.signature = user.userSignature;
    personal.gender = user.gender;
    personal.avatarImage = YZChatResource(@"my_defaultAvatarImage");
    personal.avatarUrl = [NSURL URLWithString:user.userIcon];
    personal.company = user.position;
//    personal.cselector = @selector(didSelectCommon);
    personal.showAccessory = NO;
    self.profileCellData = personal;
    [_data addObject:@[personal]];
    
    CommonTextCellData *mobile = [CommonTextCellData new];
    mobile.key = @"手机号";
    mobile.thumbnail = YZChatResource(@"icon_mobile");
    mobile.value = [user.mobile length] == 0 ? @"待完善" : user.mobile;
    mobile.showAccessory = NO;
    mobile.showTopLine = NO;
    
    CommonTextCellData *email = [CommonTextCellData new];
    email.key = @"邮箱";
    email.value = [user.email length] == 0 ? @"待完善" : user.email;
    email.thumbnail = YZChatResource(@"icon_mail");
    email.showAccessory = NO;
    email.showTopLine = YES;
    
    CommonTextCellData *qrcode = [CommonTextCellData new];
    qrcode.key = @"我的二维码";
    qrcode.thumbnail = YZChatResource(@"icon_qRcode_big");
    qrcode.showAccessory = YES;
    qrcode.showTopLine = YES;
    qrcode.showBottomCorner = YES;
    qrcode.cselector = @selector(didSelectMyQrcode);
    [_data addObject:@[mobile,email,qrcode]];

    CommonTextCellData *scan = [CommonTextCellData new];
    scan.key = @"扫一扫";
    scan.thumbnail = YZChatResource(@"icon_scan");
    scan.showAccessory = YES;
    scan.showTopLine = NO;
    scan.showTopCorner = YES;
    scan.cselector = @selector(didSelectScan);
    
    CommonTextCellData *setting = [CommonTextCellData new];
    setting.key = @"设置";
    setting.showAccessory = YES;
    setting.showTopLine = YES;
    setting.thumbnail = YZChatResource(@"icon_setting");
    setting.cselector = @selector(didSelectSetting);
    
    CommonTextCellData *userAgreement = [CommonTextCellData new];
    userAgreement.key = @"用户服务协议";
    userAgreement.thumbnail = YZChatResource(@"icon_userAgreement");
    userAgreement.showAccessory = YES;
    userAgreement.showTopLine = YES;
    userAgreement.cselector = @selector(didSelectUserAgreement);
    
    CommonTextCellData *privacyAgreement = [CommonTextCellData new];
    privacyAgreement.key = @"隐私政策";
    privacyAgreement.thumbnail = YZChatResource(@"icon_privacy");
    privacyAgreement.showAccessory = YES;
    privacyAgreement.showTopLine = YES;
    privacyAgreement.showBottomCorner = YES;
    privacyAgreement.cselector = @selector(didSelectPrivacyAgreement);
    
    [_data addObject:@[scan, setting,userAgreement,privacyAgreement]];

    [self.tableView reloadData];
}

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
    if (!section || section == 1) {
        return 0;
    }
    return 24;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = _data[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section) {
        return  196;
    }
    return 53* (Screen_Width/375);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[ProfileCardCellData class]]){
        YZProfileCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personalCell" forIndexPath:indexPath];
        cell.delegate = self;
        
        [cell fillWithData:(ProfileCardCellData *)data];
        return cell;
    }else if([data isKindOfClass:[CommonTextCellData class]]) {
        YZCommonTextImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        [cell fillWithData:(CommonTextCellData *)data];
        return cell;
    }
    
    return nil;
}

-(void)didTapSignature {
    YZProfileViewController* profileVc = [[YZProfileViewController alloc]init];
    [self.navigationController pushViewController:profileVc animated:true];
}

- (void)didSelectCommon {
    YZProfileViewController* profileVc = [[YZProfileViewController alloc]init];
    [self.navigationController pushViewController:profileVc animated:true];
}

- (void)didSelectMyQrcode {
    YZMyQRCodeViewController* qrcodeVc = [[YZMyQRCodeViewController alloc]init];
    [self.navigationController pushViewController:qrcodeVc animated:YES];
}

- (void)didSelectScan {
    QRScanViewController* qrcodeVc = [[QRScanViewController alloc]init];
    [self.navigationController pushViewController:qrcodeVc animated:YES];
}

- (void)didSelectUserAgreement {
    YZWebViewController* webVc = [[YZWebViewController alloc]init];
    webVc.url = [NSURL URLWithString:userAgreementUrl];
    webVc.title = @"用户服务协议";
    [self.navigationController pushViewController:webVc animated:true];
}

- (void)didSelectPrivacyAgreement {
    YZWebViewController* webVc = [[YZWebViewController alloc]init];
    webVc.url = [NSURL URLWithString:privacyPolicyUrl];
    webVc.title = @"隐私政策";
    [self.navigationController pushViewController:webVc animated:true];
}

- (void)didSelectSetting {
    YZSettingViewController* settingVc = [[YZSettingViewController alloc]init];
    [self.navigationController pushViewController:settingVc animated:true];
}

- (void)didTapOnAvatar:(YZProfileCardCell *)cell {
    YZProfileViewController* profileVc = [[YZProfileViewController alloc]init];
    [self.navigationController pushViewController:profileVc animated:true];

}

- (void)didTapOnQrcode:(YZProfileCardCell *)cell {
    YZMyQRCodeViewController* qrcodeVc = [[YZMyQRCodeViewController alloc]init];
    [self.navigationController pushViewController:qrcodeVc animated:YES];
}



@end
