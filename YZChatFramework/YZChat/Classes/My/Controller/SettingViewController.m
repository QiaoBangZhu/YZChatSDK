//
//  SettingViewController.m
//  YChat
//
//  Created by magic on 2020/9/20.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "SettingViewController.h"
#import "THeader.h"
#import "YCommonTextCell.h"
#import "TUIProfileCardCell.h"
#import "YUIButtonTableViewCell.h"
//#import <ImSDK/ImSDK.h>
#import <ImSDKForiOS/ImSDK.h>
#import "ChangePasswordViewController.h"
#import "YChatSettingStore.h"
#import "LoginViewController.h"
#import <SDWebImage/SDWebImage.h>
#import <SDWebImageManager.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "UIColor+ColorExtension.h"
#import "AboutViewController.h"
#import "YZBaseManager.h"

@interface SettingViewController ()
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    [self setupTableView];
    [self setupData];
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
   [self.tableView registerClass:[YUIButtonTableViewCell class] forCellReuseIdentifier:@"buttonCell"];
   self.tableView.separatorColor = [UIColor colorWithHex:KCommonSepareteLineColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    aboutUs.cselector = @selector(aboutUsAction);
    [_data addObject:@[modifyPassword]];
    [_data addObject:@[clearDisk,aboutUs]];
    
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
    return 10;
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
            [cell setSeparatorInset:UIEdgeInsetsZero];
         }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
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

- (void)didLogoutInSettingController:(SettingViewController *)controller
{
    [[YChatSettingStore sharedInstance] logout];
    [UIApplication sharedApplication].keyWindow.rootViewController = [[YZBaseManager shareInstance]getMainController];
}

- (void)changePwd {
    ChangePasswordViewController* changePwdVc = [[ChangePasswordViewController alloc]init];
    [self.navigationController pushViewController:changePwdVc animated:true];
}

- (void)aboutUsAction {
    AboutViewController* aboutVc = [[AboutViewController alloc]init];
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
