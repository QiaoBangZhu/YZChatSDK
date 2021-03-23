//
//  YZTransferGrpOwnerViewController.m
//  YChat
//
//  Created by magic on 2020/10/10.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZTransferGrpOwnerViewController.h"
#import <QMUIKit/QMUIKit.h>
#import "YChatNetworkEngine.h"
#import "YZTransferGrpOwnerCell.h"
#import <ImSDKForiOS/ImSDK.h>
#import "UIColor+ColorExtension.h"
#import "YZSearchBarView.h"
#import <Masonry/Masonry.h>

@interface YZTransferGrpOwnerViewController ()<SearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)NSMutableArray* searchList;
@property (nonatomic, strong)YZSearchBarView * searchBarView;
@property (nonatomic, assign)BOOL isSearching;
@property (nonatomic, strong)UITableView   * tableView;
@end

@implementation YZTransferGrpOwnerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"转让群主";
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.searchBarView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.top.equalTo(self.searchBarView.mas_bottom);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isSearching = NO;
}

//- (instancetype)initWithStyle:(UITableViewStyle)style {
//    if (self = [super initWithStyle:style]) {
//        self.shouldShowSearchBar = YES;
//        self.searchList = [[NSMutableArray alloc]init];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([self isViewLoaded]) {
//                self.searchBar.placeholder = @"请输入昵称";
//                [self.tableView reloadData];
//            }
//        });
//    }
//    return self;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _isSearching == false ? self.dataArray.count : self.searchList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    TransferGrpOwnerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[TransferGrpOwnerCell alloc] initForTableView:tableView withStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (_isSearching) {
        TGroupMemberCellData*info = [self.searchList objectAtIndex:indexPath.row];
        [cell fillWithData:info];
    }else {
        TGroupMemberCellData*info = [self.dataArray objectAtIndex:indexPath.row];
        [cell fillWithData:info];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TGroupMemberCellData *info = _isSearching == true ? self.searchList[indexPath.row] : self.dataArray[indexPath.row];
    [[V2TIMManager sharedInstance] transferGroupOwner:self.groupInfo.groupID member:info.identifier succ:^{
        [QMUITips showWithText:@"转让成功"];
        self.finished = true;
        [self.navigationController popViewControllerAnimated:true];
    } fail:^(int code, NSString *desc) {
        [QMUITips showError:desc];
    }];
}

//- (void)searchController:(QMUISearchController *)searchController updateResultsForSearchString:(NSString *)searchString {
//
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[c] %@", searchController.searchBar.text];
//    if (self.searchList!= nil) {
//        [self.searchList removeAllObjects];
//    }
//    NSArray* predicateArr = [self.dataArray filteredArrayUsingPredicate:predicate];
//    //过滤数据
//    self.searchList = [NSMutableArray arrayWithArray:predicateArr];
//    [searchController.tableView reloadData];
//}

- (YZSearchBarView *)searchBarView {
    if (!_searchBarView) {
        _searchBarView  = [[YZSearchBarView alloc]initWithFrame:CGRectMake(0,0, KScreenWidth, 44)];
        _searchBarView.placeholder = @"请输入昵称";
        _searchBarView.isShowCancle = NO;
        _searchBarView.isCanEdit =  YES;
        _searchBarView.delegate = self;
    }
    return _searchBarView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView =  [UIView new];
        _tableView.separatorColor = [UIColor colorWithHex:KCommonSepareteLineColor];
        _tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        _tableView.delegate = self;
        _tableView.dataSource =  self;
    }
    return _tableView;
}

- (void)textDidChange:(NSString *)searchText {
    _isSearching = YES;
    if (searchText == nil || searchText.length == 0) {
        [self.searchList removeAllObjects];
        _isSearching = NO;
        [self.tableView reloadData];
        return;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[c] %@", searchText];
    if (self.searchList!= nil) {
        [self.searchList removeAllObjects];
    }
    NSArray* predicateArr = [self.dataArray filteredArrayUsingPredicate:predicate];
    //过滤数据
    self.searchList = [NSMutableArray arrayWithArray:predicateArr];
    [self.tableView reloadData];
}

@end

