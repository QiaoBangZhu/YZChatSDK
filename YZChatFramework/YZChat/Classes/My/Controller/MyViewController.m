//
//  MyViewController.m
//  YChat
//
//  Created by magic on 2020/9/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "MyViewController.h"
#import "THeader.h"
#import "TUIKit.h"
#import "UIColor+TUIDarkMode.h"
#import "SettingViewController.h"
#import "ProfileViewController.h"
#import "YChatSettingStore.h"
#import "UserInfo.h"
#import "ProfileCardCell.h"
#import "CommonTextImageTableViewCell.h"
#import "UIColor+ColorExtension.h"
#import "MyQRCodeViewController.h"
#import "WebViewController.h"
#import "QRScanViewController.h"
#import "CommonConstant.h"
#import "NSBundle+YZBundle.h"

@interface MyViewController () <ProfileCardDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) ProfileCardCellData *profileCellData;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleName = @"我";
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    [self.tableView registerClass:[ProfileCardCell class] forCellReuseIdentifier:@"personalCell"];
    [self.tableView registerClass:[CommonTextImageTableViewCell class] forCellReuseIdentifier:@"textCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self setupData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     
//    if (@available(iOS 11.0, *)) {
//        [self.navigationController.navigationBar setPrefersLargeTitles:true];
//        NSDictionary* dic =  @{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:21 weight:UIFontWeightMedium]};
//        self.navigationController.navigationBar.largeTitleTextAttributes =  dic;
//
//    } else {
//        // Fallback on earlier versions
//    }
    
    [self setupData];
}


/**
 *初始化视图显示数据
 */
- (void)setupData
{

    _data = [NSMutableArray array];

    UserInfo* user = [[YChatSettingStore sharedInstance]getUserInfo];
    
    ProfileCardCellData *personal = [[ProfileCardCellData alloc] init];
    personal.name = user.nickName;
    personal.signature = user.userSignature;
    personal.gender = user.gender;
    personal.avatarImage = YZChatResource(@"my_defaultAvatarImage");
    personal.avatarUrl = [NSURL URLWithString:user.userIcon];
    personal.company = user.position;
    personal.cselector = @selector(didSelectCommon);
    personal.showAccessory = NO;
    self.profileCellData = personal;
    [_data addObject:@[personal]];
    
    CommonTextCellData *moible = [CommonTextCellData new];
    moible.key = @"手机号";
    moible.thumbnail = YZChatResource(@"icon_mobile");
    moible.value = [user.mobile length] == 0 ? @"待完善" : user.mobile;
    moible.showAccessory = NO;
    moible.showTopLine = NO;
    
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
    qrcode.cselector = @selector(didSelectMyQrcode);
    [_data addObject:@[moible,email,qrcode]];

    
//    CommonTextCellData *departmant = [CommonTextCellData new];
//    departmant.key = @"部门";
//    departmant.thumbnail = [UIImage imageNamed:@"icon_department"];
//    departmant.value = [user.departName length] == 0 ? @"待完善" : user.departName;
//    departmant.showAccessory = NO;
//    departmant.showTopLine = NO;
//
//    CommonTextCellData *position = [CommonTextCellData new];
//    position.key = @"职位";
//    position.value = [user.position length] == 0 ? @"待完善" : user.position;
//    position.thumbnail = [UIImage imageNamed:@"icon_position"];
//    position.showAccessory = NO;
//    position.showTopLine = YES;
//
//    CommonTextCellData *jobNum = [CommonTextCellData new];
//    jobNum.key = @"工号";
//    jobNum.value = [user.departMentId length] == 0 ? @"待完善": user.departMentId;
//    jobNum.thumbnail = [UIImage imageNamed:@"icon_job_number"];
//    jobNum.showAccessory = NO;
//    jobNum.showTopLine = YES;
    
    //@[departmant,position,jobNum,email]
    
    CommonTextCellData *scan = [CommonTextCellData new];
    scan.key = @"扫一扫";
    scan.thumbnail = YZChatResource(@"icon_scan");
    scan.showAccessory = YES;
    scan.showTopLine = NO;
    scan.cselector = @selector(didSelectScan);
    [_data addObject:@[scan]];
    
    CommonTextCellData *userAgreement = [CommonTextCellData new];
    userAgreement.key = @"用户协议";
    userAgreement.thumbnail = YZChatResource(@"icon_userAgreement");
    userAgreement.showAccessory = YES;
    userAgreement.showTopLine = NO;
    userAgreement.cselector = @selector(didSelectUserAgreement);
    
    CommonTextCellData *privacyAgreement = [CommonTextCellData new];
    privacyAgreement.key = @"隐私协议";
    privacyAgreement.thumbnail = YZChatResource(@"icon_privacy");
    privacyAgreement.showAccessory = YES;
    privacyAgreement.showTopLine = YES;
    privacyAgreement.cselector = @selector(didSelectPrivacyAgreement);
    
    [_data addObject:@[userAgreement,privacyAgreement]];
    
    CommonTextCellData *setting = [CommonTextCellData new];
    setting.key = @"设置";
    setting.showAccessory = YES;
    setting.thumbnail = YZChatResource(@"icon_setting");
    setting.cselector = @selector(didSelectSetting);

    [_data addObject:@[setting]];

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
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = _data[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section) {
        return  205;
    }
    return 48* (Screen_Width/375);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[ProfileCardCellData class]]){
        ProfileCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personalCell" forIndexPath:indexPath];
        cell.delegate = self;
        
        [cell fillWithData:(ProfileCardCellData *)data];
        return cell;
    }else if([data isKindOfClass:[CommonTextCellData class]]) {
        CommonTextImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        [cell fillWithData:(CommonTextCellData *)data];
        return cell;
    }
    
    return nil;
}

- (void)didSelectCommon {
    ProfileViewController* profileVc = [[ProfileViewController alloc]init];
    [self.navigationController pushViewController:profileVc animated:true];
}

- (void)didSelectMyQrcode {
    MyQRCodeViewController* qrcodeVc = [[MyQRCodeViewController alloc]init];
    [self.navigationController pushViewController:qrcodeVc animated:YES];
}

- (void)didSelectScan {
    QRScanViewController* qrcodeVc = [[QRScanViewController alloc]init];
    [self.navigationController pushViewController:qrcodeVc animated:YES];
}

- (void)didSelectUserAgreement {
    WebViewController* webVc = [[WebViewController alloc]init];
    webVc.url = [NSURL URLWithString:userAgreementUrl];
    webVc.title = @"用户协议";
    [self.navigationController pushViewController:webVc animated:true];
}

- (void)didSelectPrivacyAgreement {
    WebViewController* webVc = [[WebViewController alloc]init];
    webVc.url = [NSURL URLWithString:privacyPolicyUrl];
    webVc.title = @"用户协议";
    [self.navigationController pushViewController:webVc animated:true];
}

- (void)didSelectSetting {
    SettingViewController* settingVc = [[SettingViewController alloc]init];
    [self.navigationController pushViewController:settingVc animated:true];
}

- (void)didTapOnAvatar:(ProfileCardCell *)cell {
    
    
}

- (void)didTapOnQrcode:(ProfileCardCell *)cell {
    MyQRCodeViewController* qrcodeVc = [[MyQRCodeViewController alloc]init];
    [self.navigationController pushViewController:qrcodeVc animated:YES];
}



@end
