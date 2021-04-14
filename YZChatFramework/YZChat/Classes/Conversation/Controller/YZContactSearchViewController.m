//
//  YZContactSearchViewController.m
//  YChat
//
//  Created by magic on 2020/10/9.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZContactSearchViewController.h"
#import "YZFriendListTableViewCell.h"
#import "YChatSettingStore.h"
#import "YChatNetworkEngine.h"
#import "YZFriendProfileViewController.h"
#import <ImSDKForiOS/ImSDK.h>
#import "UIColor+ColorExtension.h"
#import "FriendRequestViewController.h"

@interface YZContactSearchViewController ()
@property (strong, nonatomic) NSMutableArray *searchList;

@end

@implementation YZContactSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"添加好友";
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        self.shouldShowSearchBar = YES;
        self.searchList = [[NSMutableArray alloc]init];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self isViewLoaded]) {
                self.searchController.active = YES;
                [self.tableView reloadData];
            }
        });
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    YZFriendListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[YZFriendListTableViewCell alloc] initForTableView:tableView withStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([self.searchList count] > 0) {
        YUserInfo *info = [self.searchList objectAtIndex:indexPath.row];
        [cell fillWithData:info];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YUserInfo *info = [self.searchList objectAtIndex:indexPath.row];
    FriendRequestViewController *frc = [[FriendRequestViewController alloc] init];
    frc.user = info;
    [self.navigationController pushViewController:frc animated:YES];
}

- (void)searchController:(CIGAMSearchController *)searchController updateResultsForSearchString:(NSString *)searchString {
    [self.searchList removeAllObjects];
    [YChatNetworkEngine requestUserListWithParam:searchString completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            for (NSDictionary *dic in result[@"data"]) {
                YUserInfo* model = [YUserInfo yy_modelWithDictionary:dic];
                [self.searchList addObject:model];
            }
            [searchController.tableView reloadData];
        }
    }];
}

-(void)requestFriendsInfo:(NSString*)keyword {
    self.searchList = @[].mutableCopy;
    [YChatNetworkEngine requestUserListWithParam:keyword completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            for (NSDictionary *dic in result[@"data"]) {
                YUserInfo* model = [YUserInfo yy_modelWithDictionary:dic];
                [self.searchList addObject:model];
            }
            [self.tableView reloadData];
        }
    }];
}



@end
