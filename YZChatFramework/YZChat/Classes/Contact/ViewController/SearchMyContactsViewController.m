//
//  SearchMyContactsViewController.m
//  YChat
//
//  Created by magic on 2020/10/26.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "SearchMyContactsViewController.h"
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
#import "TCommonContactCellData.h"
#import "TCommonContactCell.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "YChatNetworkEngine.h"


@interface SearchMyContactsViewController () <SearchBarDelegate,UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)SearchBarView  * searchBarView;
@property (nonatomic, strong)NSMutableArray * searchList;
@property (nonatomic, strong)NSMutableArray * dataArray;
@property (nonatomic, strong)UITableView    * tableView;

@end

@implementation SearchMyContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.hidesBackButton = YES;
    
    UIView* titleView = [[UIView alloc]initWithFrame:self.searchBarView.frame];
    [titleView addSubview:self.searchBarView];
    self.navigationItem.titleView = titleView;
    self.view.backgroundColor =  [UIColor colorWithHex:KCommonBackgroundColor];
    
    self.searchList = [[NSMutableArray alloc]init];
    self.dataArray = [[NSMutableArray alloc]init];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    [self fetchMyContacts];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource =  self;
        _tableView.tableFooterView =  [UIView new];
        [_tableView registerClass:[TCommonContactCell class] forCellReuseIdentifier:@"cell"];
        _tableView.separatorColor = [UIColor colorWithHex:KCommonSepareteLineColor];
        _tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    }
    return _tableView;
}


- (SearchBarView *)searchBarView {
    if (!_searchBarView) {
        _searchBarView = [[SearchBarView alloc]initWithFrame:CGRectMake(0, 0,KScreenWidth-10,44)];
        _searchBarView.placeholder = @"昵称/备注";
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
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([self.searchList count] > 0) {
        TCommonContactCellData *data = self.searchList[indexPath.row];
        data.cselector = @selector(onSelectFriend:);
        [cell fillWithData:data];
    }
    return cell;
}

- (void)onSelectFriend:(TCommonContactCell *)cell {
    TCommonContactCellData *data = cell.contactData;

    id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
    if ([vc isKindOfClass:[UIViewController class]]) {
        vc.friendProfile = data.friendProfile;
        vc.isShowConversationAtTop = YES;
        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfo *info = [self.searchList objectAtIndex:indexPath.row];
    FriendRequestViewController *frc = [[FriendRequestViewController alloc] init];
    frc.user = info;
    [self.navigationController pushViewController:frc animated:YES];
}

- (void)textDidChange:(NSString *)searchText {
     [self.searchList removeAllObjects];
     dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
     dispatch_async(globalQueue, ^{
     if (searchText != nil && searchText.length > 0) {
         //遍历需要搜索的所有内容，其中self.dataArray为存放总数据的数组
         for (TCommonContactCellData *model in self.dataArray) {
               NSString *tempStr = model.title;
               if ([tempStr rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0 ) {
                 [self.searchList addObject:model];
               }
           }
         
         if ([self.searchList count] == 0) {
             [self fetchMyContactsBySearchText:searchText];
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

- (void)fetchMyContacts {
    [[V2TIMManager sharedInstance] getFriendList:^(NSArray<V2TIMFriendInfo *> *infoList) {
        for (V2TIMFriendInfo *friend in infoList) {
            TCommonContactCellData *data = [[TCommonContactCellData alloc] initWithFriend:friend];
            [self.dataArray addObject:data];
        }
    } fail:nil];
}

- (void)fetchMyContactsBySearchText:(NSString *)searchText {
    [YChatNetworkEngine requestFriendsInfoByMobile:searchText completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"] intValue] == 200) {
                for (NSDictionary* dic in result[@"data"]) {
                    NSArray* dataArray = dic[@"SnsProfileItem"];
                    TCommonContactCellData* friendInfo = [[TCommonContactCellData alloc]init];
                    friendInfo.identifier = dic[@"To_Account"];
                    V2TIMFriendInfo* info = [[V2TIMFriendInfo alloc]init];
                    info.userID = dic[@"To_Account"];
                    for (NSDictionary* d in dataArray) {
                        if ([d[@"Tag"] isEqualToString:@"Tag_Profile_IM_Nick"]) {
                            friendInfo.title = d[@"Value"];
                            info.userFullInfo.nickName = d[@"Value"];
                        }
                        if ([d[@"Tag"] isEqualToString:@"Tag_Profile_IM_Image"]) {
                            friendInfo.avatarUrl = [NSURL URLWithString:d[@"Value"]];
                            info.userFullInfo.faceURL = d[@"Value"];
                        }
                        if ([d[@"Tag"] isEqualToString:@"Tag_SNS_IM_Remark"]) {
                            info.friendRemark = d[@"Value"];
                        }
                    }
                    friendInfo.friendProfile = info;
                    [self.searchList addObject:friendInfo];
                }
                [self.tableView reloadData];
            }
        }
    }];
}

@end
