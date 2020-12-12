//
//  SearchFriendViewController.m
//  YChat
//
//  Created by magic on 2020/9/19.
//  Copyright © 2020 Apple. All rights reserved.
//
/**
 *  本文件实现了查找好友的视图控制器，使用户能够根据用户ID查找指定用户
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import "SearchFriendViewController.h"
#import "UIView+MMLayout.h"
#import <ImSDKForiOS/TIMFriendshipManager.h>
#import "FriendRequestViewController.h"
#import "THeader.h"
#import "YChatNetworkEngine.h"
#import "UserInfo.h"
#import "UIColor+ColorExtension.h"
#import "TCommonContactCell.h"
#import <Masonry/Masonry.h>
#import "FriendProfileViewController.h"
#import "SearchFriendsTableViewCell.h"

@interface SearchFriendViewController() <UISearchControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView        * tableView;
@property (nonatomic, strong) NSMutableArray     * dataArray;
@property (nonatomic, strong) UISearchController * searchController;
@property (nonatomic, strong) NSMutableArray     * searchList;

@end

@implementation SearchFriendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"添加好友";
    self.dataArray = [[NSMutableArray alloc]init];
    self.searchList = [[NSMutableArray alloc]init];
    [self.view addSubview:self.tableView];
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.definesPresentationContext = YES;//不设置会导致一些位置错乱，无动画等问题

    // 创建搜索框
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = YES;
    self.searchController.searchBar.placeholder = @"昵称/备注/群昵称";
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleProminent;
//    [self.view addSubview:self.searchContfroller.searchBar];
    self.searchController.searchBar.backgroundColor = [UIColor whiteColor];
    
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.frame = CGRectMake(0, 0, Screen_Width, 44);
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    //解决：退出时搜索框依然存在的问题
    self.definesPresentationContext = YES;
}


-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[SearchFriendsTableViewCell class] forCellReuseIdentifier:@"SearchFriendsTableViewCell"];
    }
    return _tableView;
}

-(void)requestFriendsInfo:(NSString*)keyword {
    self.searchList = @[].mutableCopy;
    [YChatNetworkEngine requestUserListWithParam:keyword completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            for (NSDictionary *dic in result[@"data"]) {
                UserInfo* model = [UserInfo yy_modelWithDictionary:dic];
                [self.searchList addObject:model];
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"%s",__func__);
    // 获取搜索框里地字符串
    NSString *searchString = searchController.searchBar.text;
    if ([searchString length] > 0) {
        [self requestFriendsInfo:searchString];
    }
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    NSLog(@"%s",__func__);
}
- (void)didPresentSearchController:(UISearchController *)searchController{
    NSLog(@"%s",__func__);
}
- (void)willDismissSearchController:(UISearchController *)searchController{
    NSLog(@"%s",__func__);
}
- (void)didDismissSearchController:(UISearchController *)searchController{
    NSLog(@"%s",__func__);
}

// Called after the search controller's search bar has agreed to begin editing or when 'active' is set to YES. If you choose not to present the controller yourself or do not implement this method, a default presentation is performed on your behalf.
- (void)presentSearchController:(UISearchController *)searchController {
    NSLog(@"%s",__func__);
}


#pragma mark UISearchBarDelegate

// return NO to not become first responder
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"%s",__func__);
    return YES;
}

// called when text starts editing
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"%s",__func__);
    NSLog(@"searchBar.text = %@",searchBar.text);
    [self.tableView reloadData];
}

// return NO to not resign first responder
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    NSLog(@"%s",__func__);
    return YES;
}

// called when text ends editing
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    NSLog(@"%s",__func__);
    NSLog(@"searchBar.text = %@",searchBar.text);
}

// called before text changes
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"%s",__func__);
    NSLog(@"searchBar.text = %@",searchBar.text);
    return YES;
}

// called when text changes (including clear)
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"%s",__func__);
    NSLog(@"searchBar.text = %@",searchBar.text);
}

// called when keyboard search button pressed 键盘搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"%s",__func__);
    NSLog(@"searchBar.text = %@",searchBar.text);
    if (!self.searchController.active) {
        [self.tableView reloadData];
    }
    [self.searchController.searchBar resignFirstResponder];
}

// called when bookmark button pressed
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"%s",__func__);
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"%s",__func__);
    [self.searchList removeAllObjects];
    [self.tableView reloadData];
}

// called when search results button pressed
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"%s",__func__);
}

// selecte ScopeButton
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    NSLog(@"%s",__func__);
    NSLog(@"selectedScope = %ld",selectedScope);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchFriendsTableViewCell" forIndexPath:indexPath];
    if (self.searchController.active) {
        if ([self.searchList count] > 0) {
            UserInfo *info = [self.searchList objectAtIndex:indexPath.row];
            [cell fillWithData:info];
        }
    }
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfo *info = [self.searchList objectAtIndex:indexPath.row];
    TCommonContactCellData *data = [[TCommonContactCellData alloc]init];
    V2TIMFriendInfo* friendInfo = [[V2TIMFriendInfo alloc]init];
    friendInfo.userID = info.userId;
    data.friendProfile = friendInfo;
    data.title = info.nickName;
    data.avatarUrl = [NSURL URLWithString:info.userIcon];
    
    FriendProfileViewController* friendVc = [[FriendProfileViewController alloc]init];
    friendVc.friendProfile  = data.friendProfile;
    [self.navigationController pushViewController:friendVc animated:true];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}




@end
