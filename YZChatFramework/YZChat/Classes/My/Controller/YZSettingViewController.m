//
//  YZSettingViewController.m
//  YChat
//
//  Created by magic on 2020/9/20.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZSettingViewController.h"
#import "THeader.h"
#import "YCommonTextCell.h"
#import "TUIProfileCardCell.h"
#import "YUIButtonTableViewCell.h"
#import <ImSDKForiOS/ImSDK.h>
#import "YZChangePasswordViewController.h"
#import "YChatSettingStore.h"
#import <SDWebImage/SDWebImage.h>
#import <SDWebImageManager.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "UIColor+ColorExtension.h"
#import "YZAboutViewController.h"
#import "YZBaseManager.h"
#import <Masonry/Masonry.h>
#import "UIImage+Foundation.h"

@interface YZSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation YZSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.right.equalTo(@-16);
        make.top.equalTo(@24);
        make.bottom.equalTo(@0);
    }];
    [self setupData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[YCommonTextCell class] forCellReuseIdentifier:@"textCell"];
        [_tableView registerClass:[YUIButtonTableViewCell class] forCellReuseIdentifier:@"buttonCell"];
        _tableView.separatorColor = [UIColor colorWithHex:KCommonSeparatorLineColor];
        _tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.layer.cornerRadius = 8;
        _tableView.layer.shadowColor = [[UIColor colorWithHex:0xAEAEC0] CGColor];
        _tableView.layer.shadowOffset = CGSizeMake(3,3);
        _tableView.layer.shadowOpacity = 1;
        _tableView.layer.shadowRadius = 5;
    }
    return _tableView;
}

/**
 *初始化视图显示数据
 */
- (void)setupData
{
    _data = [NSMutableArray array];

    YCommonTextCellData *modifyPassword = [YCommonTextCellData new];
    modifyPassword.key = @"修改密码";
    modifyPassword.cselector = @selector(changePwd);
    modifyPassword.showTopCorner = YES;
    modifyPassword.showAccessory = YES;
    
//    YCommonTextCellData *checkVersion = [YCommonTextCellData new];
//    checkVersion.key = @"检查更新";
//    checkVersion.showAccessory = YES;
    
    YCommonTextCellData *clearDisk = [YCommonTextCellData new];
    clearDisk.key = @"清除缓存";
    clearDisk.value = [self getCacheSize];
    clearDisk.cselector = @selector(clearCache);
    clearDisk.showAccessory = YES;
    
    YCommonTextCellData *aboutUs = [YCommonTextCellData new];
    aboutUs.key = @"关于我们";
    aboutUs.showAccessory = YES;
    aboutUs.showBottomCorner = YES;
    aboutUs.cselector = @selector(aboutUsAction);
    [_data addObject:@[modifyPassword,clearDisk,aboutUs]];
    
    YUIButtonCellData *button =  [[YUIButtonCellData alloc] init];
    button.title = @"退出登录";
    button.style = YButtonRedText;
    button.cbuttonSelector = @selector(logout:);
    [_data addObject:@[button]];

    [self.tableView reloadData];
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
        return 1;
    }
    return 22;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = _data[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = _data[indexPath.section];
    TCommonCellData *data = array[indexPath.row];
    return [data heightOfWidth:Screen_Width];
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
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 24, 0, 24)];
         }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsMake(0, 24, 0, 24)];
        }
        cell.valueLabel.textColor = [UIColor colorWithHex:kCommonBlueTextColor];
        [cell fillWithData:(YCommonTextCellData *)data];
        
        return cell;
    }else if([data isKindOfClass:[YUIButtonCellData class]]){
        YUIButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TButtonCell_ReuseId];
        
        if(!cell){
            cell = [[YUIButtonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TButtonCell_ReuseId];
        }
        [cell fillWithData:(YUIButtonCellData *)data];
        return cell;
    }
    
    return nil;
}

-(void)logout:(YUIButtonTableViewCell *)cell {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定退出吗" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[V2TIMManager sharedInstance]logout:nil fail:nil];
        [self didLogoutInSettingController:self];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didLogoutInSettingController:(YZSettingViewController *)controller
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"YzWorkzonePayReturn" object:nil];
    [[YChatSettingStore sharedInstance] logout];

    Class cls = NSClassFromString(@"YZLoginViewController");
    if (cls) {
        UINavigationController *navi = [[NSClassFromString(@"MAGICNavigationViewController") alloc] init] ?: [[UINavigationController alloc] init];
        navi.viewControllers = @[[[cls alloc] init]];
        [UIApplication sharedApplication].keyWindow.rootViewController = navi;
    }
}

- (void)changePwd {
    YZChangePasswordViewController* changePwdVc = [[YZChangePasswordViewController alloc]init];
    [self.navigationController pushViewController:changePwdVc animated:true];
}

- (void)aboutUsAction {
    YZAboutViewController* aboutVc = [[YZAboutViewController alloc]init];
    [self.navigationController pushViewController:aboutVc animated:true];
}

-(NSString* )getCacheSize{
    //得到缓存路径
    NSString * path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSFileManager * manager = [NSFileManager defaultManager];
    CGFloat size = 0;
    //首先判断是否存在缓存文件
    if ([manager fileExistsAtPath:path]) {
        NSArray * childFile = [manager subpathsAtPath:path];
        for (NSString * fileName in childFile) {
            //缓存文件绝对路径
            NSString * absolutPath = [path stringByAppendingPathComponent:fileName];
            size = size + [manager attributesOfItemAtPath:absolutPath error:nil].fileSize;
        }
        //计算sdwebimage的缓存和系统缓存总和
        size = size + [SDImageCache sharedImageCache].totalDiskSize;
    }
    size = size/1024/1024;
    NSString* cacheStr = [NSString stringWithFormat:@"%.2fM",size];
    return  cacheStr;
}

//清除缓存
- (void)clearAnyLocalCache{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,YES);
    NSString *path = [paths lastObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childrenFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childrenFiles) {
            // 拼接路径
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            // 将文件删除
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    //SDWebImage的清除功能
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)clearCache {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:@"是否清理缓存" preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self clearAnyLocalCache];
        [self setupData];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}


@end
