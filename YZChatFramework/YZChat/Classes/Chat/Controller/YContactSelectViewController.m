//
//  ContactSelectViewController.m
//  YChat
//
//  Created by magic on 2020/10/2.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YContactSelectViewController.h"

#import "MMLayout/UIView+MMLayout.h"
#import <ReactiveObjC/ReactiveObjC.h>

#import "TCommonContactSelectCell.h"
#import "THelper.h"

#import "YzCommonImport.h"

static NSString *kReuseIdentifier = @"ContactSelectCell";

@interface YContactSelectViewController ()

@property (nonatomic, strong) NSMutableArray *selectArray;
@property (nonatomic, strong) NSArray <TCommonContactSelectCellData *>*searchList;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) NSString *keywords;

@end

@implementation YContactSelectViewController

- (void)didInitialize {
    [super didInitialize];

    self.viewModel = [[TContactSelectViewModel alloc] init];
    self.maxSelectCount = INT_MAX;
    self.selectArray = [[NSMutableArray alloc] init];
    self.searchList = [[NSArray alloc] init];
    self.dataArray = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupBinds];
    if (self.sourceIds) {
        [self.viewModel setSourceIds:self.sourceIds];
    } else {
        [self.viewModel loadContacts];
    }
}

#pragma mark - 用户交互

- (void)setupBinds {
    @weakify(self)
    [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(NSNumber *finished) {
        @strongify(self)
        if ( [finished boolValue]) {
            if (self.isFromFriendProfile) {
                for (NSString* group in self.viewModel.groupList) {
                    for (TCommonContactSelectCellData *data in self.viewModel.dataDict[group]) {
                        if ([data.identifier isEqualToString: self.friendProfileCellData.identifier]) {
                            data.selected = YES;
                            if (![self.selectArray containsObject:data]) {
                                [self.selectArray addObject:data];
                                break;
                            }
                        }
                    }
                }

                [self updateConfirmText];
            }

            [self.tableView reloadData];
        }
    }];

    [[RACObserve(self.viewModel, groupList) skip: 1] subscribeNext:^(NSArray *group) {
        @strongify(self)
        if (group.count > 0) {
            [self hideEmptyView];
        } else {
            [self showEmptyViewWithText: @"联系人列表空，请先添加好友"];
        }
    }];

    [RACObserve(self.viewModel, searchDataArray) subscribeNext:^(NSArray *searchDataArray) {
        @strongify(self)
        if ([searchDataArray count] > 0) {
            [self.dataArray addObjectsFromArray:searchDataArray];
        }
    }];

    [[[RACObserve(self, keywords) distinctUntilChanged] throttle: 0.25]
     subscribeNext:^(NSString  *_Nullable keywords) {
        [self searchKeywords: keywords];
    }];
}

- (void)confirmSelected {
    if (self.finishBlock && [self.selectArray count] >0) {
        self.finishBlock(self.selectArray);
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) return self.viewModel.groupList.count;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView != self.tableView) return self.searchList.count;
    NSString *group = self.viewModel.groupList[section];
    return self.viewModel.dataDict[group].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) return self.viewModel.groupList[section];
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) return 25;
    return 0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.tableView) return self.viewModel.groupList;
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCommonContactSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier forIndexPath:indexPath];

    if (tableView != self.tableView) {
        TCommonContactSelectCellData* data = self.searchList[indexPath.section];
        if (data.enabled) {
            data.responder = self;
            data.cselector = @selector(didSelectContactCell:);
        } else {
            data.cselector = nil;
            data.responder = nil;
        }

        [cell fillWithData:data];
        return  cell;
    }

    NSString *group = self.viewModel.groupList[indexPath.section];
    TCommonContactSelectCellData *data = self.viewModel.dataDict[group][indexPath.row];
    if (data.enabled) {
        data.cselector = @selector(didSelectContactCell:);
    } else {
        data.cselector = nil;
    }

    [cell fillWithData:data];
    return cell;
}

- (void)didSelectContactCell:(TCommonContactSelectCell *)cell {
    TCommonContactSelectCellData *data = cell.selectData;
    if (!data.isSelected) {
        if (self.selectArray.count + 1 > self.maxSelectCount) {
            [THelper makeToast:[NSString stringWithFormat:@"最多选择%ld个",(long)self.maxSelectCount]];
            return;
        }
    }
    if ([data.identifier isEqualToString: self.friendProfileCellData.identifier] && self.isFromFriendProfile && data.isSelected == YES) {
        return;
    }
    data.selected = !data.isSelected;
    [cell fillWithData:data];
    if (data.isSelected) {
        [self.selectArray addObject:data];
    } else {
        [self.selectArray removeObject:data];
    }

    [self updateConfirmText];
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

    self.navigationItem.rightBarButtonItem = [UIBarButtonItem cigam_itemWithTitle: @"确定" target: self action: @selector(confirmSelected)];
    [self updateConfirmText];
}

- (void)updateConfirmText {
    [self.navigationItem.rightBarButtonItem setEnabled: self.selectArray.count > 0];
    if (self.selectArray.count > 0) {
        [self.navigationItem.rightBarButtonItem setTitle: [NSString stringWithFormat:@"确定(%ld)",self.selectArray.count]];
    } else {
        [self.navigationItem.rightBarButtonItem setTitle: @"确定"];
    }
}

- (void)initSubviews {
    [super initSubviews];

    self.shouldShowSearchBar = YES;
}

- (void)initSearchController {
    [super initSearchController];

    [self.searchController.tableView registerClass: [TCommonContactSelectCell class] forCellReuseIdentifier: kReuseIdentifier];
    self.searchController.launchView = [[UIView alloc] init];
    self.searchController.launchView.backgroundColor = [UIColor colorWithHex: KCommonBackgroundColor];
    self.searchBar.placeholder = @"请输入昵称/备注";
}

- (void)initTableView {
    [super initTableView];

    [self.tableView setSectionIndexBackgroundColor: [UIColor clearColor]];
    [self.tableView setSectionIndexColor: [UIColor colorWithHex: KCommonLittleLightGrayColor]];
    [self.tableView setBackgroundColor: [UIColor colorWithHex: KCommonBackgroundColor]];
    [self.tableView setSeparatorInset: UIEdgeInsetsZero];
    [self.tableView registerClass: [TCommonContactSelectCell class] forCellReuseIdentifier: kReuseIdentifier];
}

#pragma mark - 数据

- (void)searchKeywords:(NSString *)keywords {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        if (keywords.length > 0) {
            for (TCommonContactSelectCellData *model in self.dataArray) {
                if ([model.title rangeOfString: keywords options: NSCaseInsensitiveSearch].length > 0 ) {
                    [temp addObject: model];
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
