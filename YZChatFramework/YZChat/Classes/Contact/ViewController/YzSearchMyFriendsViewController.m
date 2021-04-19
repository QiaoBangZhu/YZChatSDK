//
//  YzSearchMyFriendsViewController.m
//  YZChat
//
//  Created by 安笑 on 2021/4/19.
//

#import "YzSearchMyFriendsViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>

#import "YzCommonImport.h"
#import "YZFriendListTableViewCell.h"

// navigation
#import "FriendRequestViewController.h"

@interface YzSearchMyFriendsViewController ()

@property (nonatomic, strong) NSArray <YUserInfo *>*dataArray;
@property (nonatomic, strong) NSArray <YUserInfo *>*searchList;
@property (nonatomic, copy) NSString *keywords;

@end

@implementation YzSearchMyFriendsViewController

#pragma mark - 初始化

- (void)didInitialize {
    [super didInitialize];

    self.dataArray = [[NSArray alloc] init];
    self.searchList = [[NSArray alloc] init];
    [self fetchFriends];
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController setNavigationBarHidden: YES animated: YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];

    [self.searchController setActive: YES animated: YES];
}

#pragma mark - 用户交互

- (void)subscribe {
    [super subscribe];

    [[[RACObserve(self, keywords) distinctUntilChanged] throttle: 0.25]
     subscribeNext:^(NSString  *_Nullable keywords) {
        [self changedKeywords: keywords];
    }];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) return 0;
    return self.searchList.count > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YZFriendListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kReuseIdentifier_FriendListTableViewCell forIndexPath: indexPath];

    YUserInfo *info = [self.searchList objectAtIndex:indexPath.row];
    [cell fillWithData:info];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendRequestViewController *viewController = [[FriendRequestViewController alloc] init];
    viewController.user = [self.searchList objectAtIndex: indexPath.row];
    [self.navigationController pushViewController: viewController animated:YES];
}


#pragma mark - CIGAMSearchControllerDelegate

- (void)searchController:(CIGAMSearchController *)searchController
updateResultsForSearchString:(NSString *)searchString {
    self.keywords = searchString;
}

- (void)didPresentSearchController:(CIGAMSearchController *)searchController {
    [searchController.searchBar becomeFirstResponder];
}

- (void)willDismissSearchController:(CIGAMSearchController *)searchController {
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - 页面布局

- (void)initSubviews {
    [super initSubviews];

    self.shouldShowSearchBar = YES;
}

- (void)initSearchController {
    [super initSearchController];

    [self.searchController.tableView registerClass: [YZFriendListTableViewCell class] forCellReuseIdentifier: kReuseIdentifier_FriendListTableViewCell];
    self.searchController.launchView = [[UIView alloc] init];
    self.searchController.launchView.backgroundColor = [UIColor colorWithHex: KCommonBackgroundColor];
}

- (void)setupSubviews {
    [super setupSubviews];

    self.view.backgroundColor = UIColorWhite;
}

#pragma mark - 数据

- (void)fetchFriends {
    @weakify(self)
    [YChatNetworkEngine requestUserListWithParam: @"" completion:^(NSDictionary *result, NSError *error) {
        @strongify(self)
        if (error) {
            [CIGAMTips showError: error.localizedDescription];
            [self showEmptyViewWithText: error.localizedDescription];
        } else {
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in result[@"data"]) {
                YUserInfo* model = [YUserInfo yy_modelWithDictionary: dic];
                [temp addObject: model];
            }
            self.dataArray = [temp copy];
        }
    }];
}

- (void)changedKeywords:(NSString *)keywords {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        if (keywords.length > 0) {
            for (YUserInfo *model in self.dataArray) {
                  if ([model.nickName rangeOfString: keywords options: NSCaseInsensitiveSearch].length >0 ||
                      [model.mobile rangeOfString: keywords options: NSCaseInsensitiveSearch].length >0) {
                    [temp addObject: model];
                  }
              }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.searchList = [temp copy];
        });
    });
}

- (void)setSearchList:(NSArray <YUserInfo *>*)searchList {
    _searchList = searchList;
    if (self.searchController.active) {
        [self.searchController.tableView reloadData];
    }
}

@end
