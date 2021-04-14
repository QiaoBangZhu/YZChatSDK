/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMLogManagerViewController.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/1/24.
//

#import "CIGAMLogManagerViewController.h"
#import "CIGAMCore.h"
#import "CIGAMLog.h"
#import "CIGAMStaticTableViewCellData.h"
#import "CIGAMStaticTableViewCellDataSource.h"
#import "UITableView+CIGAMStaticCell.h"
#import "CIGAMTableView.h"
#import "CIGAMPopupMenuView.h"
#import "UITableView+CIGAM.h"
#import "CIGAMTableViewCell.h"
#import "CIGAMSearchController.h"
#import "UIBarItem+CIGAM.h"
#import "UIViewController+CIGAM.h"

@interface CIGAMLogManagerViewController ()

@property(nonatomic, copy) NSDictionary<NSString *, NSNumber *> *allNames;
@property(nonatomic, copy) NSArray<NSString *> *sortedLogNames;
@property(nonatomic, copy) NSArray<NSString *> *sectionIndexTitles;
@end

@implementation CIGAMLogManagerViewController

- (void)didInitializeWithStyle:(UITableViewStyle)style {
    [super didInitializeWithStyle:style];
    self.rowCountWhenShowSearchBar = 10;
}

- (void)initTableView {
    [super initTableView];
    [self setupDataSource];
}

- (void)initSearchController {
    [super initSearchController];
    self.searchController.cigam_preferredStatusBarStyleBlock = ^UIStatusBarStyle{
        return CIGAMStatusBarStyleDarkContent;
    };
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkEmptyView];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    if (self.allNames.count) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(handleMenuItemEvent)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)setupDataSource {
    self.allNames = [CIGAMLogger sharedInstance].logNameManager.allNames;
    
    NSArray<NSString *> *logNames = self.allNames.allKeys;
    
    self.sortedLogNames = [logNames sortedArrayUsingComparator:^NSComparisonResult(NSString *logName1, NSString *logName2) {
        logName1 = [self formatLogNameForSorting:logName1];
        logName2 = [self formatLogNameForSorting:logName2];
        return [logName1 caseInsensitiveCompare:logName2];
    }];
    self.sectionIndexTitles = ({
        NSMutableArray<NSString *> *titles = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < self.sortedLogNames.count; i++) {
            NSString *logName = self.sortedLogNames[i];
            NSString *sectionIndexTitle = [[self formatLogNameForSorting:logName] substringToIndex:1];
            if (![titles containsObject:sectionIndexTitle]) {
                [titles addObject:sectionIndexTitle];
            }
        }
        [titles copy];
    });
    
    NSMutableArray<NSArray<CIGAMStaticTableViewCellData *> *> *cellDataSections = [[NSMutableArray alloc] init];
    NSMutableArray<CIGAMStaticTableViewCellData *> *currentSection = nil;
    for (NSInteger i = 0; i < self.sortedLogNames.count; i++) {
        NSString *logName = self.sortedLogNames[i];
        NSString *formatedLogName = [self formatLogNameForSorting:logName];
        NSString *sectionIndexTitle = [formatedLogName substringToIndex:1];
        NSUInteger section = [self.sectionIndexTitles indexOfObject:sectionIndexTitle];
        if (section != NSNotFound) {
            if (cellDataSections.count <= section) {
                // 说明这个 section 还没被创建过
                currentSection = [[NSMutableArray alloc] init];
                [cellDataSections addObject:currentSection];
            }
            [currentSection addObject:({
                CIGAMStaticTableViewCellData *d = [[CIGAMStaticTableViewCellData alloc] init];
                d.text = logName;
                d.accessoryType = CIGAMStaticTableViewCellAccessoryTypeSwitch;
                d.accessoryValueObject = self.allNames[logName];
                d.accessoryTarget = self;
                d.accessoryAction = @selector(handleSwitchEvent:);
                d;
            })];
        }
    }
    
    // 超过一定数量则出搜索框，先设置好搜索框的显隐，以便其他东西可以依赖搜索框的显隐状态来做判断
    NSInteger rowCount = logNames.count;
    self.shouldShowSearchBar = rowCount >= self.rowCountWhenShowSearchBar;
    
    CIGAMStaticTableViewCellDataSource *dataSource = [[CIGAMStaticTableViewCellDataSource alloc] initWithCellDataSections:cellDataSections];
    self.tableView.cigam_staticCellDataSource = dataSource;
}

- (void)reloadData {
    [self setupDataSource];
    [self checkEmptyView];
    [self.tableView reloadData];
}

- (void)checkEmptyView {
    if (self.allNames.count <= 0) {
        [self showEmptyViewWithText:@"暂无 CIGAMLog 产生" detailText:nil buttonTitle:nil buttonAction:NULL];
    } else {
        [self hideEmptyView];
    }
    [self setupNavigationItems];
}

- (NSArray<NSString *> *)sortedLogNameArray {
    NSArray<NSString *> *logNames = self.allNames.allKeys;
    NSArray<NSString *> *sortedArray = [logNames sortedArrayUsingComparator:^NSComparisonResult(NSString *logName1, NSString *logName2) {
        
        return NSOrderedAscending;
    }];
    return sortedArray;
}

- (NSString *)formatLogNameForSorting:(NSString *)logName {
    if (self.formatLogNameForSortingBlock) {
        return self.formatLogNameForSortingBlock(logName);
    }
    return logName;
}

- (void)handleSwitchEvent:(UISwitch *)switchControl {
    UITableView *tableView = self.searchController.active ? self.searchController.tableView : self.tableView;
    NSIndexPath *indexPath = [tableView cigam_indexPathForRowAtView:switchControl];
    CIGAMStaticTableViewCellData *cellData = [tableView.cigam_staticCellDataSource cellDataAtIndexPath:indexPath];
    cellData.accessoryValueObject = @(switchControl.on);
    [[CIGAMLogger sharedInstance].logNameManager setEnabled:switchControl.on forLogName:cellData.text];
}

- (void)handleMenuItemEvent {
    CIGAMPopupMenuView *menuView = [[CIGAMPopupMenuView alloc] init];
    menuView.automaticallyHidesWhenUserTap = YES;
    menuView.preferLayoutDirection = CIGAMPopupContainerViewLayoutDirectionBelow;
    menuView.maximumWidth = 124;
    menuView.safetyMarginsOfSuperview = UIEdgeInsetsSetRight(menuView.safetyMarginsOfSuperview, 6);
    menuView.items = @[
                       [CIGAMPopupMenuButtonItem itemWithImage:nil title:@"开启全部" handler:^(CIGAMPopupMenuButtonItem *aItem) {
                           for (NSString *logName in self.allNames) {
                               [[CIGAMLogger sharedInstance].logNameManager setEnabled:YES forLogName:logName];
                           }
                           [self reloadData];
                           [aItem.menuView hideWithAnimated:YES];
                       }],
                       [CIGAMPopupMenuButtonItem itemWithImage:nil title:@"禁用全部" handler:^(CIGAMPopupMenuButtonItem *aItem) {
                           for (NSString *logName in self.allNames) {
                               [[CIGAMLogger sharedInstance].logNameManager setEnabled:NO forLogName:logName];
                           }
                           [self reloadData];
                           [aItem.menuView hideWithAnimated:YES];
                       }],
                       [CIGAMPopupMenuButtonItem itemWithImage:nil title:@"清空全部" handler:^(CIGAMPopupMenuButtonItem *aItem) {
                           [[CIGAMLogger sharedInstance].logNameManager removeAllNames];
                           [self reloadData];
                           [aItem.menuView hideWithAnimated:YES];
                       }]];
    menuView.sourceBarItem = self.navigationItem.rightBarButtonItem;
    [menuView showWithAnimated:YES];
}

#pragma mark - <CIGAMTableViewDataSource, CIGAMTableViewDelegate>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CIGAMTableViewCell *cell = [tableView.cigam_staticCellDataSource cellForRowAtIndexPath:indexPath];
    CIGAMStaticTableViewCellData *cellData = [tableView.cigam_staticCellDataSource cellDataAtIndexPath:indexPath];
    NSString *logName = cellData.text;
    
    NSAttributedString *string = nil;
    if (self.formatCellTextBlock) {
        string = self.formatCellTextBlock(logName);
    } else {
        NSString *formatedLogName = [self formatLogNameForSorting:logName];
        NSRange range = [logName rangeOfString:formatedLogName];
        NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:logName attributes:@{NSFontAttributeName: UIFontMake(16), NSForegroundColorAttributeName: UIColorGray}];
        [mutableString setAttributes:@{NSForegroundColorAttributeName: UIColorBlack} range:range];
        string = [mutableString copy];
    }
    cell.textLabel.attributedText = string;
    
    if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
        BOOL enabled = self.allNames[logName].boolValue;
        UISwitch *switchControl = (UISwitch *)cell.accessoryView;
        switchControl.on = enabled;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return tableView == self.tableView ? self.sectionIndexTitles[section] : nil;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return tableView == self.tableView && self.shouldShowSearchBar ? self.sectionIndexTitles : nil;
}

#pragma mark - <CIGAMSearchControllerDelegate>

- (void)searchController:(CIGAMSearchController *)searchController updateResultsForSearchString:(NSString *)searchString {
    NSArray<NSArray<CIGAMStaticTableViewCellData *> *> *dataSource = self.tableView.cigam_staticCellDataSource.cellDataSections;
    NSMutableArray<CIGAMStaticTableViewCellData *> *resultDataSource = [[NSMutableArray alloc] init];// 搜索结果就不需要分 section 了
    for (NSInteger section = 0; section < dataSource.count; section ++) {
        for (NSInteger row = 0; row < dataSource[section].count; row ++) {
            CIGAMStaticTableViewCellData *cellData = dataSource[section][row];
            NSString *text = cellData.text;
            if ([text.lowercaseString containsString:searchString.lowercaseString]) {
                [resultDataSource addObject:cellData];
            }
        }
    }
    searchController.tableView.cigam_staticCellDataSource = [[CIGAMStaticTableViewCellDataSource alloc] initWithCellDataSections:@[resultDataSource.copy]];
    
    if (resultDataSource.count > 0) {
        [searchController hideEmptyView];
    } else {
        [searchController showEmptyViewWithText:@"无结果" detailText:nil buttonTitle:nil buttonAction:NULL];
    }
}

- (void)willDismissSearchController:(CIGAMSearchController *)searchController {
    // 在搜索状态里可能修改了 switch 的值，则退出时强制刷新一下默认状态的列表
    [self reloadData];
}

@end
