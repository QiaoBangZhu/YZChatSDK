//
//  ContactSelectViewController.m
//  YChat
//
//  Created by magic on 2020/10/2.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YContactSelectViewController.h"
#import "TCommonContactSelectCell.h"
#import "TContactSelectViewModel.h"
#import "ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TUIContactListPicker.h"
#import "UIImage+TUIKIT.h"
#import "THeader.h"
#import "Toast/Toast.h"
#import "THelper.h"
#import "UIColor+TUIDarkMode.h"
#import "UIColor+ColorExtension.h"
#import "CommonConstant.h"
#import <Masonry/Masonry.h>
#import "YZSearchBarView.h"
#import <ImSDKForiOS/ImSDK.h>

#import "TCommonContactCellData.h"

static NSString *kReuseIdentifier = @"ContactSelectCell";

@interface YContactSelectViewController ()<UITableViewDelegate,UITableViewDataSource,SearchBarDelegate>
@property UITableView *tableView;
@property UIView *emptyView;
@property TUIContactListPicker *pickerView;
@property NSMutableArray *selectArray;
@property (nonatomic, strong) UIButton *confirmBtn;
@property(nonatomic,strong) YZSearchBarView  *searchBar;
@property(nonatomic,strong) NSMutableArray *searchList;
@property(nonatomic, strong)NSMutableArray *dataArray;
@end

@implementation YContactSelectViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)initData
{
    self.maxSelectCount = INT_MAX;
    self.selectArray = @[].mutableCopy;
    self.searchList = @[].mutableCopy;
    self.dataArray = @[].mutableCopy;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 30)];
    [rightButton setTitleColor:[UIColor colorWithHex:kCommonBlueTextColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(finishTask) forControlEvents:UIControlEventTouchUpInside];
    _confirmBtn = rightButton;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    
    [self.view addSubview:self.searchBar];

    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.top.equalTo(self.searchBar.mas_bottom);
    }];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [_tableView setSectionIndexColor:[UIColor colorWithHex:KCommonlittleLightGrayColor]];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    //cell无数据时，不显示间隔线
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:v];
    _tableView.separatorInset = UIEdgeInsetsZero;
    [_tableView registerClass:[TCommonContactSelectCell class] forCellReuseIdentifier:kReuseIdentifier];

    _emptyView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_emptyView];
    _emptyView.mm_fill();
    _emptyView.hidden = YES;

    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_emptyView addSubview:tipsLabel];
    tipsLabel.text = @"联系人列表空，请先添加好友";
    tipsLabel.mm_sizeToFit().mm_center();


//    _pickerView = [[TUIContactListPicker alloc] initWithFrame:CGRectZero];
//    [self.view addSubview:_pickerView];
//    [_pickerView.accessoryBtn addTarget:self action:@selector(finishTask) forControlEvents:UIControlEventTouchUpInside];

    [self setupBinds];

    if (self.sourceIds) {
        [self.viewModel setSourceIds:self.sourceIds];
    } else {
        [self.viewModel loadContacts];
    }
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
}

- (void)setupBinds
{
    @weakify(self)
    [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(NSNumber *finished) {
        @strongify(self)
        if ([finished boolValue]) {
            if (self.isFromFriendProfile) {
                for (NSString* groupname in self.viewModel.groupList) {
                    for (TCommonContactSelectCellData *data in self.viewModel.dataDict[groupname]) {
                        if ([data.identifier isEqualToString: self.friendProfileCellData.identifier]) {
                            data.selected = YES;
                            if (![self.selectArray containsObject:data]) {
                                [self.selectArray addObject:data];
                                [self.confirmBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",self.selectArray.count] forState:UIControlStateNormal];
                                break;
                            }
                        }
                    }
                }
            }

            [self.tableView reloadData];
        }
    }];
    [RACObserve(self.viewModel, groupList) subscribeNext:^(NSArray *group) {
        @strongify(self)
        self.emptyView.hidden = (group.count > 0);
    }];
    
    [RACObserve(self.viewModel, searchDataArray) subscribeNext:^(NSArray *searchDataArray) {
        @strongify(self)
        if ([searchDataArray count] > 0) {
            [self.dataArray addObjectsFromArray:searchDataArray];
        }
    }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    _pickerView.mm_width(self.view.mm_w).mm_height(60+_pickerView.mm_safeAreaBottomGap).mm_bottom(0);
    _tableView.mm_width(self.view.mm_w).mm_flexToBottom(self.view.mm_b);
}

- (YZSearchBarView *)searchBar {
    if (!_searchBar) {
        _searchBar = [[YZSearchBarView alloc]initWithFrame:CGRectMake(0,0, KScreenWidth,44)];
        _searchBar.backgroundColor = [UIColor whiteColor];
        _searchBar.placeholder = @"请输入昵称/备注";
        _searchBar.isShowCancle = NO;
        _searchBar.isCanEdit = YES;
        _searchBar.delegate = self;
    }
    return _searchBar;
}


- (TContactSelectViewModel *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [TContactSelectViewModel new];
    }
    return _viewModel;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return [self.searchList count] > 0 ? [self.searchList count] : self.viewModel.groupList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.searchList count] > 0) {
        return 1;
    }
    NSString *group = self.viewModel.groupList[section];
    NSArray *list = self.viewModel.dataDict[group];
    return list.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
#define TEXT_TAG 1
    static NSString *headerViewId = @"ContactDrawerView";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewId];
    if (!headerView)
    {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerViewId];
        UIView * bgView = [[UIView alloc]init];
        bgView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        [headerView addSubview:bgView];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        
        headerView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.tag = TEXT_TAG;
        textLabel.font = [UIFont systemFontOfSize:16];
        textLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
        [bgView addSubview:textLabel];
        textLabel.mm_fill().mm_left(12);
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    UILabel *label = [headerView viewWithTag:TEXT_TAG];
    if ([self.searchList count] == 0) {
        label.text = self.viewModel.groupList[section];
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return CGFLOAT_MIN;
//}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return  self.viewModel.groupList;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCommonContactSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier forIndexPath:indexPath];

    if ([self.searchList count] > 0) {
        TCommonContactSelectCellData* data = self.searchList[indexPath.section];
        if (data.enabled) {
            data.cselector = @selector(didSelectContactCell:);
        } else {
            data.cselector = NULL;
        }
        
//        if (self.isFromFriendProfile && (data.identifier == self.friendProfileCellData.identifier)) {
//            data.selected = YES;
//            if (![self.selectArray containsObject:data]) {
//                [self.selectArray addObject:data];
//                [self.confirmBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",self.selectArray.count] forState:UIControlStateNormal];
//            }
//        }
        [cell fillWithData:data];
        return  cell;
    }
    NSString *group = self.viewModel.groupList[indexPath.section];
    NSArray *list = self.viewModel.dataDict[group];
    TCommonContactSelectCellData *data = list[indexPath.row];
    if (data.enabled) {
        data.cselector = @selector(didSelectContactCell:);
    } else {
        data.cselector = NULL;
    }
//    if (self.isFromFriendProfile && ([data.identifier isEqualToString: self.friendProfileCellData.identifier])) {
//        data.selected = YES;
//        if (![self.selectArray containsObject:data]) {
//            [self.selectArray addObject:data];
//            [self.confirmBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",self.selectArray.count] forState:UIControlStateNormal];
//        }
//    }
    [cell fillWithData:data];
    return cell;
}

- (void)didSelectContactCell:(TCommonContactSelectCell *)cell
{
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
//    self.pickerView.selectArray = [self.selectArray copy];
    if ([self.selectArray count] > 0) {
        [self.confirmBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",self.selectArray.count] forState:UIControlStateNormal];
    }else {
        [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    }
   
}

- (void)finishTask
{
    if (self.finishBlock && [self.selectArray count] >0) {
        self.finishBlock(self.selectArray);
    }
}

- (void)textDidChange:(NSString *)searchText {
     [self.searchList removeAllObjects];
     dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
     dispatch_async(globalQueue, ^{
     if (searchText != nil && searchText.length > 0) {
         //遍历需要搜索的所有内容，其中self.dataArray为存放总数据的数组
         for (TCommonContactSelectCellData *model in self.dataArray) {
               NSString *tempStr = model.title;
               if ([tempStr rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0 ) {
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
