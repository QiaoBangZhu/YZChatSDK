//
//  YzSelectGroupMemberViewController.m
//  YZChat
//
//  Created by 安笑 on 2021/5/12.
//

#import "YzSelectGroupMemberViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>
#import <MMLayout/UIView+MMLayout.h>

#import "THelper.h"
#import "TUIGroupMemberCell.h"
#import "TCommonContactSelectCell.h"

#import "YzCommonImport.h"

static NSString *kReuseIdentifier_ContactSelectCell = @"ReuseIdentifier_ContactSelectCell";

@interface YzSelectGroupMemberViewController () {
    NSString *_groupId;
    V2TIMGroupMemberFilter _filter;
    BOOL _multipleSelection;
}

@property (nonatomic, strong) NSArray <TCommonContactSelectCellData *>*members;
@property (nonatomic, strong) NSArray <TCommonContactSelectCellData *>*searchList;
@property (nonatomic, strong) NSMutableSet *selectedSet;
@property (nonatomic, copy) NSString *keywords;

@end

@implementation YzSelectGroupMemberViewController

#pragma mark - 初始化

- (instancetype)initWithGroupId:(NSString *)groupId
                         filter:(V2TIMGroupMemberFilter)filter
              multipleSelection:(BOOL)multipleSelection {
    _groupId = groupId;
    _filter = filter;
    _multipleSelection = multipleSelection;
    if (multipleSelection) {
        _selectedSet = [[NSMutableSet alloc] init];
    }

    return [super initWithStyle: UITableViewStylePlain];
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    [self showEmptyViewWithLoading];
    [self fetchGroupMemberList];
}

#pragma mark - 用户交互

- (void)subscribe {
    [super subscribe];

    @weakify(self)
    [[[RACObserve(self, keywords) distinctUntilChanged] throttle: 0.25]
     subscribeNext:^(NSString  *_Nullable keywords) {
        @strongify(self)
        [self searchKeywords: keywords];
    }];
}

- (void)clickDone {
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (TCommonContactSelectCellData *data in self.members) {
        if ([self.selectedSet containsObject: data.identifier]) {
            [temp addObject: data.identifier];
        }
    }
    if (self.selectCompleted) {
        self.selectCompleted(temp.copy);
    }
}

- (void)didSelectContactCell:(TCommonContactSelectCell *)cell {
    TCommonContactSelectCellData *data = cell.selectData;
    if (!_multipleSelection) {
        if (self.selectCompleted) {
            self.selectCompleted(@[data.identifier]);
        }
        return;
    }

    data.selected = !data.isSelected;
    [cell fillWithData:data];
    if (data.isSelected) {
        [self.selectedSet addObject: data.identifier];
    } else {
        [self.selectedSet removeObject: data.identifier];
    }
    [self updateDoneBarButtonItem];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) return self.members.count > 0 ? 1 : 0;
    return self.searchList.count > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) return self.members.count;
    return self.searchList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCommonContactSelectCell *cell = [tableView dequeueReusableCellWithIdentifier: kReuseIdentifier_ContactSelectCell];
    if (!cell) {
        cell = [[TCommonContactSelectCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: kReuseIdentifier_ContactSelectCell];
        if (!_multipleSelection) {
            [cell.selectButton setHidden: YES];
            cell.avatarView.mm_left(12);
            cell.titleLabel.mm_left(cell.avatarView.mm_maxX + 12);
        }
    }

    TCommonContactSelectCellData *data;
    if (tableView == self.tableView) {
        data = self.members[indexPath.row];
    } else {
        data = self.searchList[indexPath.row];
    }

    if (data.enabled) {
        data.responder = self;
        data.cselector = @selector(didSelectContactCell:);
    } else {
        data.cselector = nil;
        data.responder = nil;
    }
    [cell fillWithData: data];

    return cell;
}

#pragma mark - CIGAMSearchControllerDelegate

- (void)searchController:(CIGAMSearchController *)searchController updateResultsForSearchString:(NSString *)searchString {
    self.keywords = searchString;
}

- (void)willPresentSearchController:(CIGAMSearchController *)searchController {
    self.searchList = @[];
    [searchController.tableView reloadData];
}

- (void)willDismissSearchController:(CIGAMSearchController *)searchController {
    [self.tableView reloadData];
}

#pragma mark - 页面布局

- (void)setupNavigationItems {
    [super setupNavigationItems];
    if (_multipleSelection) {
        [self updateDoneBarButtonItem];
    }
}

- (void)updateDoneBarButtonItem {
    NSString *title = [NSString stringWithFormat: @"完成 (%ld)", self.selectedSet.count];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem cigam_itemWithTitle: title target: self action: @selector(clickDone)];
    self.navigationItem.rightBarButtonItem.enabled = self.selectedSet.count > 0;
}

- (void)initSubviews {
    [super initSubviews];

    self.shouldShowSearchBar = YES;
}

- (void)initSearchController {
    [super initSearchController];

    self.searchController.launchView = [[UIView alloc] init];
    self.searchController.launchView.backgroundColor = [UIColor colorWithHex: KCommonBackgroundColor];
    self.searchBar.placeholder = @"请输入昵称";
}

- (void)initTableView {
    [super initTableView];

    [self.tableView setSeparatorInset: UIEdgeInsetsZero];
}

#pragma mark - 数据

- (void)fetchGroupMemberList {
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupMemberList: _groupId filter: _filter nextSeq: 0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        @strongify(self)
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (V2TIMGroupMemberFullInfo *member in memberList) {
            if (self.availableFilter && !self.availableFilter(member.userID)) continue;
            TCommonContactSelectCellData *data = [[TCommonContactSelectCellData alloc] init];
            data.identifier = member.userID;
            data.avatarUrl = [NSURL URLWithString: member.faceURL];
            if (member.nameCard.length > 0) {
                data.title = member.nameCard;
            } else if (member.friendRemark.length > 0) {
                data.title = member.friendRemark;
            } else if (member.nickName.length > 0) {
                data.title = member.nickName;
            } else {
                data.title = member.userID;
            }
            if (self.disableFilter) {
                data.enabled = !self.disableFilter(member.userID);
            }
            [temp addObject: data];
        }
        [self hideEmptyView];
        if (!temp.count) {
            [self showEmptyViewWithText: self.emptyTip ?: @"暂无数据"];
        }
        self.members = [temp copy];
        [self.tableView reloadData];
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        [self hideEmptyView];
        if ([msg isEqualToString: @"members is invalid"]) {
            [self showEmptyViewWithText: self.emptyTip ?: @"暂无数据"];
        } else {
            [THelper makeToastError: code msg: msg];
        }
    }];
}

- (void)searchKeywords:(NSString *)keywords {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        if (keywords.length > 0) {
            for (TCommonContactSelectCellData *data in self.members) {
                if ([data.title rangeOfString: keywords options: NSCaseInsensitiveSearch].length > 0 ) {
                    [temp addObject: data];
                }
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.searchList = [temp copy];
        });
    });
}


- (void)setSearchList:(NSArray<TCommonContactSelectCellData *> *)searchList {
    _searchList = searchList;
    if (self.searchController.active) {
        [self.searchController.tableView reloadData];
    }
}

@end
