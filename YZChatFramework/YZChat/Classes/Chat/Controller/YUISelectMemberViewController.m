//
//  YUISelectMemberViewController.m
//  YChat
//
//  Created by magic on 2020/10/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YUISelectMemberViewController.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"
#import "YUISelectMemberCell.h"
#import "TUIMemberPanelCell.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUICallUtils.h"
#import "TUIMemberPanelCell.h"
#import "UIColor+ColorExtension.h"
#import "YZSearchBarView.h"
#import "NSString+TUICommon.h"
#import <Masonry/Masonry.h>

#define kUserBorder 44.0
#define kUserSpacing 2
#define kUserPanelLeftSpacing 15

@interface YUISelectMemberViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,SearchBarDelegate>
@property(nonatomic,strong) UIButton *cancelBtn;
@property(nonatomic,strong) UIButton *doneBtn;
@property(nonatomic,strong) UICollectionView *userPanel;
@property(nonatomic,strong) UITableView *selectTable;
@property(nonatomic,strong) NSMutableArray <UserModel *>*selectedUsers;

@property(nonatomic,assign) CGFloat topStartPosition;
@property(nonatomic,assign) CGFloat userPanelWidth;
@property(nonatomic,assign) CGFloat userPanelHeight;
@property(nonatomic,assign) CGFloat realSpacing;
@property(nonatomic,assign) NSInteger userPanelColumnCount;
@property(nonatomic,assign) NSInteger userPanelRowCount;

@property(nonatomic,strong) NSMutableArray *memberList;
@property(nonatomic,strong) YZSearchBarView  *searchBar;
@property(nonatomic,strong) NSMutableArray *searchList;

@property NSDictionary<NSString *, NSArray<UserModel *> *> *dataDict;
@property NSArray *groupList;

@property NSDictionary<NSString *, NSArray<UserModel *> *> *searchDataDict;
@property NSArray *searchGroupList;

@end

@implementation YUISelectMemberViewController{
    UICollectionView *_userPanel;
    UITableView *_selectTable;
    UIButton *_cancelBtn;
    UIButton *_doneBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择提醒的人";
    self.title = self.name? : @"发起呼叫";
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    [self.view addSubview:self.searchBar];
    self.searchList = [[NSMutableArray alloc]init];
    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.cancelBtn];
//    self.navigationItem.leftBarButtonItem = item;
    

    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:self.doneBtn];
    self.navigationItem.rightBarButtonItem = doneItem;
    
//    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    spaceItem.width = -15;
    self.navigationItem.rightBarButtonItems =  @[doneItem];
    
    
    CGFloat topPadding = 44.f;
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        topPadding = window.safeAreaInsets.top;
    }
    
    topPadding = MAX(0, topPadding);
    CGFloat navBarHeight = self.navigationController.navigationBar.bounds.size.height;
    self.topStartPosition = 44;//topPadding + (navBarHeight > 0 ? navBarHeight : 44);
    self.memberList = [NSMutableArray array];
    self.selectedUsers = [NSMutableArray array];
    [self getMembers];
}

#pragma mark UI
/// 取消按钮
- (UIButton *)cancelBtn {
    if (!_cancelBtn.superview) {
         _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor colorWithHex:kCommonBlueTextColor] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

/// 完成按钮
- (UIButton *)doneBtn {
    if (!_doneBtn.superview) {
        _doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_doneBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_doneBtn setAlpha:0.5];
        [_doneBtn setTitleColor:[UIColor colorWithHex:kCommonBlueTextColor] forState:UIControlStateNormal];
        [_doneBtn addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}

- (YZSearchBarView *)searchBar {
    if (!_searchBar) {
        _searchBar = [[YZSearchBarView alloc]initWithFrame:CGRectMake(0,0, KScreenWidth,44)];
        _searchBar.backgroundColor = [UIColor whiteColor];
        _searchBar.placeholder = @"请输入昵称";
        _searchBar.isShowCancle = NO;
        _searchBar.isCanEdit = YES;
        _searchBar.delegate = self;
    }
    return _searchBar;
}

///已选用户面板
- (UICollectionView *)userPanel {
    if (!_userPanel.superview) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _userPanel = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _userPanel.backgroundColor = [UIColor clearColor];
        [_userPanel registerClass:[TUIMemberPanelCell class] forCellWithReuseIdentifier:@"TUIMemberPanelCell"];
        if (@available(iOS 10.0, *)) {
            _userPanel.prefetchingEnabled = YES;
        } else {
            // Fallback on earlier versions
        }
        _userPanel.showsVerticalScrollIndicator = NO;
        _userPanel.showsHorizontalScrollIndicator = NO;
        _userPanel.contentMode = UIViewContentModeScaleAspectFit;
        _userPanel.scrollEnabled = NO;
        _userPanel.delegate = self;
        _userPanel.dataSource = self;
        [self.view addSubview:_userPanel];
    }
    return _userPanel;
}

///选择用户列表
- (UITableView *)selectTable {
    if (!_selectTable.superview) {
        _selectTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _selectTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_selectTable registerClass:[YUISelectMemberCell class] forCellReuseIdentifier:@"YUISelectMemberCell"];
        _selectTable.delegate = self;
        _selectTable.dataSource = self;
        _selectTable.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        _selectTable.separatorColor = [UIColor colorWithHex:KCommonSepareteLineColor];
        [_selectTable setSectionIndexBackgroundColor:[UIColor clearColor]];
        [_selectTable setSectionIndexColor:[UIColor colorWithHex:KCommonlittleLightGrayColor]];
        [self.view addSubview:_selectTable];
        _selectTable.mm_width(self.view.mm_w).mm_top(self.topStartPosition + 0).mm_flexToBottom(0);
    }
    return _selectTable;
}

///更新 UI
- (void)updateUserPanel {
    self.userPanel.mm_height(self.userPanelHeight).mm_left(kUserPanelLeftSpacing).mm_flexToRight(0).mm_top(self.topStartPosition);
    self.selectTable.mm_width(self.view.mm_w).mm_top(self.userPanel.mm_maxY).mm_flexToBottom(0);
    @weakify(self)
    [self.userPanel performBatchUpdates:^{
        @strongify(self)
        [self.userPanel reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
    [self.selectTable reloadData];
    self.doneBtn.alpha = (self.selectedUsers.count == 0 ?  0.5 : 1);
}

#pragma mark action

- (void)onNext {
    if (self.selectedUsers.count == 0) {
        return;
    }
    NSMutableArray *users = [NSMutableArray array];
    for (UserModel *model in self.selectedUsers) {
        [users addObject:[model copy]];
    }
    if (self.selectedFinished) {
        [self.navigationController popViewControllerAnimated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.selectedFinished(users);
        });
    }
}

/// 取消
-(void)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.searchDataDict count] > 0) {
        return  [self.searchGroupList count];
    }
    return [self.groupList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.searchGroupList count] >0) {
        NSString *group = self.searchGroupList[section];
        NSArray *list = self.searchDataDict[group];
        return list.count;
    }
    NSString *group = self.groupList[section];
    NSArray *list = self.dataDict[group];
    return list.count;
    
//    return [self.searchList count] > 0 ? [self.searchList count]:self.memberList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"YUISelectMemberCell";
    YUISelectMemberCell *cell = (YUISelectMemberCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[YUISelectMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    UserModel* model = [[UserModel alloc]init];
    if ([self.searchGroupList count] > 0) {
        NSString *group = self.searchGroupList[indexPath.section];
        NSArray *list = self.searchDataDict[group];
        model = list[indexPath.row];
        BOOL isSelect = [self isUserSelected:model];
        [cell fillWithData:model isSelect:isSelect];
        return cell;
    }
    if (indexPath.section < [self.groupList count]) {
        NSString *group = self.groupList[indexPath.section];
        NSArray *list = self.dataDict[group];
        model = list[indexPath.row];
        BOOL isSelect = [self isUserSelected:model];
        [cell fillWithData:model isSelect:isSelect];
    }
//    if ([self.searchList count] > 0) {
//        UserModel *model = self.searchList[indexPath.row];
//        BOOL isSelect = [self isUserSelected:model];
//        [cell fillWithData:model isSelect:isSelect];
//        return cell;
//    }
//    if (indexPath.row < self.memberList.count) {
//        UserModel *model = self.memberList[indexPath.row];
//        BOOL isSelect = [self isUserSelected:model];
//        [cell fillWithData:model isSelect:isSelect];
//    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
#define TEXT_TAG 1
    static NSString *headerViewId = @"ContactDrawerView";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewId];
    if (!headerView)
    {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerViewId];
        headerView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        
        UIView* leftView = [[UIView alloc]init];
        [headerView addSubview:leftView];
        leftView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.tag = TEXT_TAG;
        textLabel.font = [UIFont systemFontOfSize:14];
        textLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
        [headerView addSubview:textLabel];
        textLabel.mm_fill().mm_left(26);
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    UILabel *label = [headerView viewWithTag:TEXT_TAG];
    label.text = self.groupList[section];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!section) {
        return 0;
    }
    return 33;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *array = [NSMutableArray arrayWithObject:@""];
    [array addObjectsFromArray:self.groupList];
    return array;
}

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
//    footer.textLabel.textColor = [UIColor d_systemGrayColor];
//    footer.textLabel.font = [UIFont systemFontOfSize:14];
//}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"群成员";
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 54;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isSelected = NO;
    UserModel *userSelected = [[UserModel alloc] init];
    if ([self.searchGroupList count] > 0) {
        NSString *group = self.searchGroupList[indexPath.section];
        NSArray *list = self.searchDataDict[group];
        if (indexPath.row < list.count) {
            UserModel *user = list[indexPath.row];
            isSelected = [self isUserSelected:user];
            userSelected = [user copy];
        }
    }else {
        if ([self.groupList count] > 0) {
            NSString *group = self.groupList[indexPath.section];
            NSArray *list = self.dataDict[group];
            if (indexPath.row < list.count) {
                UserModel *user = list[indexPath.row];
                isSelected = [self isUserSelected:user];
                userSelected = [user copy];
            }
        }
    }
    
    if (userSelected.userId.length == 0) {
        return;
    }
    
    if ([userSelected.userId isEqualToString:kImSDK_MesssageAtALL]) {
        // 清空选择
        [self.selectedUsers removeAllObjects];
        [self.selectedUsers addObject:userSelected];
        // 完成选择
        [self onNext];
        return;
    }
    
    if (isSelected) {
        for (UserModel *user in self.selectedUsers) {
            if ([user.userId isEqualToString:userSelected.userId]) {
                [self.selectedUsers removeObject:user];
                break;
            }
        }
    } else {
        [self.selectedUsers addObject:userSelected];
    }
//    [self updateUserPanel];
    [self.selectTable reloadData];
    self.doneBtn.alpha = (self.selectedUsers.count == 0 ?  0.5 : 1);
}


#pragma mark UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedUsers.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"TUIMemberPanelCell";
    TUIMemberPanelCell *cell = (TUIMemberPanelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.selectedUsers.count) {
        [cell fillWithData:self.selectedUsers[indexPath.row]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kUserBorder, kUserBorder);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (indexPath.row < self.selectedUsers.count) {
        // to do
    }
}

#pragma mark data
- (NSInteger)userPanelColumnCount {
    if (self.selectedUsers.count == 0) {
        return 0;
    }
    CGFloat totalWidth = self.view.mm_w - kUserPanelLeftSpacing;
    int columnCount = (int)(totalWidth / (kUserBorder + kUserSpacing));
    return columnCount;
}

- (CGFloat)realSpacing {
    CGFloat totalWidth = self.view.mm_w - kUserPanelLeftSpacing;
    if (self.userPanelColumnCount == 0 || self.userPanelColumnCount == 1) {
        return 0;
    }
    return (totalWidth - (CGFloat)self.userPanelColumnCount * kUserBorder) / ((CGFloat)self.userPanelColumnCount - 1);
}

- (NSInteger)userPanelRowCount {
    NSInteger userCount = self.selectedUsers.count;
    NSInteger columnCount = MAX(self.userPanelColumnCount, 1);
    NSInteger rowCount = userCount / columnCount;
    if (userCount % columnCount != 0) {
        rowCount += 1;
    }
    return rowCount;
}

- (CGFloat)userPanelWidth {
    return (CGFloat)self.userPanelColumnCount * kUserBorder + ((CGFloat)self.userPanelColumnCount - 1) * self.realSpacing;
}

- (CGFloat)userPanelHeight {
    return (CGFloat)self.userPanelRowCount * kUserBorder + ((CGFloat)self.userPanelRowCount - 1) * self.realSpacing;
}

- (void)getMembers {
    @weakify(self)
    [self getMembersWithOptionalStyle];
    [[V2TIMManager sharedInstance] getGroupMemberList:self.groupId filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        @strongify(self)
        NSMutableDictionary *dataDict = @{}.mutableCopy;
        NSMutableArray *groupList = @[].mutableCopy;
        NSMutableArray *nonameList = @[].mutableCopy;
        if ([self.memberList count] > 0) {
            UserModel* atModel = self.memberList[0];
            if ([atModel.userId isEqualToString:kImSDK_MesssageAtALL]) {
                NSMutableArray *list = [dataDict objectForKey:@" "];
                if (!list) {
                    list = @[].mutableCopy;
                    dataDict[@" "] = list;
                    [groupList addObject:@" "];
                }
                [list addObject:atModel];
            }
        }
    
        for (V2TIMGroupMemberFullInfo *info in memberList) {
            if ([info.userID isEqualToString:[TUICallUtils loginUser]]) {
                continue;
            }
            UserModel *model = [[UserModel alloc] init];
            model.userId = info.userID;
            if (info.nameCard != nil) {
                model.name = info.nameCard;
            } else if (info.friendRemark != nil) {
                model.name = info.friendRemark;
            } else if (info.nickName != nil) {
                model.name = info.nickName;
            } else {
                model.name = info.userID;
            }
            if (info.faceURL != nil) {
                model.avatar = info.faceURL;
            }
            [self.memberList addObject:model];
            
            NSString *group = [[model.name firstPinYin] uppercaseString];
            if (group.length == 0 || !isalpha([group characterAtIndex:0])) {
                [nonameList addObject:model];
                continue;
            }
            NSMutableArray *list = [dataDict objectForKey:group];
            if (!list) {
                list = @[].mutableCopy;
                dataDict[group] = list;
                [groupList addObject:group];
            }
            [list addObject:model];
        }
        
        [groupList sortUsingSelector:@selector(localizedStandardCompare:)];
        if (nonameList.count) {
            [groupList addObject:@"#"];
            dataDict[@"#"] = nonameList;
        }
        for (NSMutableArray *list in [dataDict allValues]) {
            [list sortUsingSelector:@selector(compare:)];
        }

        self.groupList = groupList;
        self.dataDict = dataDict;
        
        [self.selectTable reloadData];
    } fail:nil];
}

- (void)getMembersWithOptionalStyle {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getMembersWithOptionalStyle];
        });
        return;
    }
    
    if (self.optionalStyle == TUISelectMemberOptionalStyleNone) {
        return;
    }
    
    if (self.optionalStyle & TUISelectMemberOptionalStyleAtAll) {
        UserModel *model = [[UserModel alloc] init];
        model.userId = kImSDK_MesssageAtALL;
        model.name = @"所有人";
        [self.memberList addObject:model];
    }

}

- (BOOL)isUserSelected:(UserModel *)user {
    BOOL isSelected = NO;
    for (UserModel *selectUser in self.selectedUsers) {
        if ([selectUser.userId isEqualToString:user.userId] && ![selectUser.userId isEqualToString:[TUICallUtils loginUser]]) {
            isSelected = YES;
            break;
        }
    }
    return isSelected;
}

- (void)textDidChange:(NSString *)searchText {
     [self.searchList removeAllObjects];
     dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
     dispatch_async(globalQueue, ^{
     if (searchText != nil && searchText.length > 0) {
         NSMutableDictionary *dataDict = @{}.mutableCopy;
         NSMutableArray *groupList = @[].mutableCopy;
         NSMutableArray *nonameList = @[].mutableCopy;
         
         //遍历需要搜索的所有内容,其中self.selectedUsers为存放总数据的数组
         for (UserModel *model in self.memberList) {
               NSString *nickname = model.name;
               if ([nickname rangeOfString:searchText options:NSCaseInsensitiveSearch].length >0) {
                 [self.searchList addObject:model];
                   
                   NSString *group = [[nickname firstPinYin] uppercaseString];
                   if ([group isEqualToString:@" "]) {
                       NSMutableArray *list = [dataDict objectForKey:group];
                       if (!list) {
                           list = @[].mutableCopy;
                           dataDict[group] = list;
                           [groupList addObject:group];
                       }
                       [list addObject:model];
                       continue;
                   }
                   
                   if (group.length == 0 || !isalpha([group characterAtIndex:0])) {
                       [nonameList addObject:model];
                       continue;
                   }
                   NSMutableArray *list = [dataDict objectForKey:group];
                   if (!list) {
                       list = @[].mutableCopy;
                       dataDict[group] = list;
                       [groupList addObject:group];
                   }
                   [list addObject:model];
               }
             [groupList sortUsingSelector:@selector(localizedStandardCompare:)];
             if (nonameList.count) {
                 [groupList addObject:@"#"];
                 dataDict[@"#"] = nonameList;
             }
             for (NSMutableArray *list in [dataDict allValues]) {
                 [list sortUsingSelector:@selector(compare:)];
             }
            self.searchGroupList = groupList;
            self.searchDataDict = dataDict;
           }
      }else{
          self.searchList = [[NSMutableArray alloc]init];
          self.searchGroupList = [[NSMutableArray alloc]init];
          self.searchDataDict = @{}.mutableCopy;
      }
       //回到主线程
      dispatch_async(dispatch_get_main_queue(), ^{
            [self.selectTable reloadData];
        });
      });
}



@end
