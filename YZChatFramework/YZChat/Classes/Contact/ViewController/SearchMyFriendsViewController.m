//
//  SearchMyFriendsViewController.m
//  YChat
//
//  Created by magic on 2020/10/25.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "SearchMyFriendsViewController.h"
#import "SearchBarView.h"
#import "CommonConstant.h"
#import "UIColor+ColorExtension.h"
#import "FriendListTableViewCell.h"
#import "YChatSettingStore.h"
#import "YChatNetworkEngine.h"
#import "FriendProfileViewController.h"
//#import <ImSDK/ImSDK.h>
#import <ImSDKForiOS/ImSDK.h>
#import "UIColor+ColorExtension.h"
#import "FriendRequestViewController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import <Masonry/Masonry.h>
#import <IQKeyboardManager/IQKeyboardManager.h>

@interface SearchMyFriendsViewController ()<SearchBarDelegate,UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)SearchBarView  * searchBarView;
@property (nonatomic, strong)NSMutableArray * searchList;
@property (nonatomic, strong)NSMutableArray * dataArray;
@property (nonatomic, strong)UITableView    * tableView;

@end

@implementation SearchMyFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.hidesBackButton = YES;
    
    UIView* titleView = [[UIView alloc]initWithFrame:self.searchBarView.frame];
    [titleView addSubview:self.searchBarView];
    self.navigationItem.titleView = titleView;
    self.view.backgroundColor =  [UIColor colorWithHex:KCommonBackgroundColor];
    
    self.searchList = [[NSMutableArray alloc]init];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = NO;
    [self.view addSubview:self.tableView];
    [self requestFriendsInfo:@""];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth,KScreenHeight-safeAreaTopHeight) style:UITableViewStylePlain];
        _tableView.tableFooterView =  [UIView new];
        _tableView.separatorColor = [UIColor colorWithHex:KCommonSepareteLineColor];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource =  self;
    }
    return _tableView;
}

- (SearchBarView *)searchBarView {
    if (!_searchBarView) {
        _searchBarView = [[SearchBarView alloc]initWithFrame:CGRectMake(0, 0,KScreenWidth-10,44)];
        _searchBarView.placeholder = @"手机号/昵称";
        _searchBarView.isShowCancle = YES;
        _searchBarView.isCanEdit =  YES;
        _searchBarView.delegate = self;
        [_searchBarView becomeFirstResponder];
    }
    return _searchBarView;
}

- (void)onCancle {
    [self.navigationController popViewControllerAnimated:true];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    FriendListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[FriendListTableViewCell alloc] initForTableView:tableView withStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([self.searchList count] > 0) {
        UserInfo *info = [self.searchList objectAtIndex:indexPath.row];
        [cell fillWithData:info];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfo *info = [self.searchList objectAtIndex:indexPath.row];
    FriendRequestViewController *frc = [[FriendRequestViewController alloc] init];
    frc.user = info;
    [self.navigationController pushViewController:frc animated:YES];
}

-(void)requestFriendsInfo:(NSString*)keyword {
    self.dataArray = @[].mutableCopy;
    self.searchList = @[].mutableCopy;
    [YChatNetworkEngine requestUserListWithParam:keyword completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            for (NSDictionary *dic in result[@"data"]) {
                UserInfo* model = [UserInfo yy_modelWithDictionary:dic];
                [self.dataArray addObject:model];
            }
        }
    }];
}

- (void)textDidChange:(NSString *)searchText {
     NSLog(@"输入的关键字是---%@---%lu",searchText,(unsigned long)searchText.length);
     [self.searchList removeAllObjects];
     dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
     dispatch_async(globalQueue, ^{
     if (searchText != nil && searchText.length > 0) {
         //遍历需要搜索的所有内容，其中self.dataArray为存放总数据的数组
         for (UserInfo *model in self.dataArray) {
               NSString *nickname = model.nickName;
               NSString *mobile = model.mobile;
               if ([nickname rangeOfString:searchText options:NSCaseInsensitiveSearch].length >0 || [mobile rangeOfString:searchText options:NSCaseInsensitiveSearch].length >0) {
                 [self.searchList addObject:model];
               }
           }
      }else{
          self.searchList = [[NSMutableArray alloc]init];
      }
       //回到主线程
      dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
      });
}

@end
