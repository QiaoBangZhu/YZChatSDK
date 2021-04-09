//
//  YZSearchViewController.m
//  YChat
//
//  Created by magic on 2020/10/6.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZSearchViewController.h"
#import <Masonry/Masonry.h>
#import "YChatViewController.h"
#import "TCommonContactCell.h"
#import "YZFriendProfileViewController.h"

@interface YZSearchViewController ()<UITableViewDelegate, UITableViewDataSource>
//满足搜索条件的数组
@property (strong, nonatomic) NSMutableArray *searchList;
@property (strong, nonatomic) UITableView    *tableView;
@end

@implementation YZSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.searchList = [NSMutableArray new];
    self.dataListArry = [NSMutableArray new];
    
    //不加的话，table会下移
    self.automaticallyAdjustsScrollViewInsets = NO;
    //不加的话，UISearchBar返回后会上移
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[TCommonContactCell class] forCellReuseIdentifier:@"TCommonContactCell"];
    }
    return _tableView;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        tabBarController.tabBar.hidden = YES;
        tabBarController.edgesForExtendedLayout = UIRectEdgeBottom;
    }
}

#pragma mark - tableView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TCommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCommonContactCell" forIndexPath:indexPath];
    TCommonContactCellData *data = [self.searchList objectAtIndex:indexPath.row];
    data.cselector = @selector(onSelectFriend:);
    [cell fillWithData:data];
    return cell;
}

- (void)onSelectFriend:(TCommonContactCell *)cell {
    TCommonContactCellData *data = cell.contactData;
    YZFriendProfileViewController* friendVc = [[YZFriendProfileViewController alloc]init];
    friendVc.friendProfile  = data.friendProfile;
    [self.navigationController pushViewController:friendVc animated:true];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([userModel.userID length] > 0) {
//        FriendProfileViewController *friendProfileVc = [[FriendProfileViewController alloc]init];
//        V2TIMFriendInfo* friendProfile = [[V2TIMFriendInfo alloc]init];
//        friendProfile.userID = userModel.userID;
//        friendProfileVc.friendProfile = friendProfile;
//        [self.navigationController pushViewController:friendProfileVc animated:YES];
//    }else{
//        GroupInfoController *groupInfo = [[GroupInfoController alloc] init];
//        groupInfo.groupId = userModel.groupID;
//        [self.navigationController pushViewController:groupInfo animated:YES];
//    }
}

#pragma mark - UISearchResultsUpdating
//每输入一个字符都会执行一次
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSLog(@"搜索关键字：%@",searchController.searchBar.text);
    searchController.searchResultsController.view.hidden = NO;

    //谓词搜索
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title CONTAINS[c] %@", searchController.searchBar.text];
    if (self.searchList!= nil) {
        [self.searchList removeAllObjects];
    }
    NSArray* predicateArr = [_dataListArry filteredArrayUsingPredicate:predicate];
    
    //过滤数据
    self.searchList = [NSMutableArray arrayWithArray:predicateArr];
    //刷新表格
    
    [self.tableView reloadData];
}

@end
