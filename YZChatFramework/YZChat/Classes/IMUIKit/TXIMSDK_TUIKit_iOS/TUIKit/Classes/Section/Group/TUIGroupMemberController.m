//
//  GroupMemberController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/27.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIGroupMemberController.h"
#import "TUIGroupMemberCell.h"
#import "THeader.h"
#import "TAddCell.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "Toast/Toast.h"
#import "TIMGroupInfo+DataProvider.h"
#import "TIMUserProfile+DataProvider.h"
#import "UIColor+TUIDarkMode.h"
//#import <ImSDK/ImSDK.h>
#import <ImSDKForiOS/ImSDK.h>
#import "SearchBarView.h"
#import "UIColor+Foundation.h"
#import "CommonConstant.h"
#import "YGroupMembersTableViewCell.h"
#import <Masonry/Masonry.h>
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "ProfileViewController.h"
#import "THelper.h"
#import "NSString+TUICommon.h"

@interface TUIGroupMemberController ()<SearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray<UserModel *> *members;
@property V2TIMGroupInfo *groupInfo;
@property (nonatomic,strong) SearchBarView * searchBar;
@property (nonatomic,strong) UITableView   * tableView;
@property (nonatomic,strong) NSMutableArray* searchList;

@property NSDictionary<NSString *, NSArray<UserModel *> *> *dataDict;
@property NSArray *groupList;

@property NSDictionary<NSString *, NSArray<UserModel *> *> *searchDataDict;
@property NSArray *searchGroupList;


@end

@implementation TUIGroupMemberController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self updateData];
}

- (void)updateData
{
    _members = [NSMutableArray array];
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupsInfo:@[_groupId] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        @strongify(self)
        if(groupResultList.count == 1){
            self.groupInfo = groupResultList[0].info;
        }
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        [self.view makeToast:msg];
    }];
    [[V2TIMManager sharedInstance] getGroupMemberList:_groupId filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        @strongify(self)
        
        NSMutableDictionary *dataDict = @{}.mutableCopy;
        NSMutableArray *groupList = @[].mutableCopy;
        NSMutableArray *nonameList = @[].mutableCopy;

        for (V2TIMGroupMemberFullInfo *member in memberList) {
            UserModel *user = [[UserModel alloc] init];
            user.userId = member.userID;
            if (member.nameCard.length > 0) {
                user.name = member.nameCard;
            } else if (member.friendRemark.length > 0) {
                user.name = member.friendRemark;
            } else if (member.nickName.length > 0) {
                user.name = member.nickName;
            } else {
                user.name = member.userID;
            }
            [self.members addObject:user];
            
            NSString *group = [[user.name firstPinYin] uppercaseString];
            if (group.length == 0 || !isalpha([group characterAtIndex:0])) {
                [nonameList addObject:user];
                continue;
            }
            NSMutableArray *list = [dataDict objectForKey:group];
            if (!list) {
                list = @[].mutableCopy;
                dataDict[group] = list;
                [groupList addObject:group];
            }
            [list addObject:user];
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
        
        [self.tableView reloadData];
        NSString *title = [NSString stringWithFormat:@"群成员(%ld人)", (long)self.members.count];
        self.parentViewController.title = title;;
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        [self.view makeToast:msg];
    }];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];

    //left
//    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
//    [leftButton addTarget:self action:@selector(leftBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    [leftButton setImage:[UIImage imageNamed:TUIKitResource(@"back")] forState:UIControlStateNormal];
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
//    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    spaceItem.width = -10.0f;
//    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)) {
//        leftButton.contentEdgeInsets =UIEdgeInsetsMake(0, -15, 0, 0);
//        leftButton.imageEdgeInsets =UIEdgeInsetsMake(0, -15, 0, 0);
//    }
//    self.navigationItem.leftBarButtonItems = @[spaceItem,leftItem];
//    self.parentViewController.navigationItem.leftBarButtonItems = @[spaceItem,leftItem];

    //right
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitle:@"管理" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark] forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.parentViewController.navigationItem.rightBarButtonItem = rightItem;
//magic
//    _groupMembersView = [[TUIGroupMembersView alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    _groupMembersView.delegate = self;
//    _groupMembersView.backgroundColor = self.view.backgroundColor;
//    [self.view addSubview:_groupMembersView];
    
    [self.view addSubview:self.searchBar];
    self.searchList = [[NSMutableArray alloc]init];
}

- (void)leftBarButtonClick{
    if(_delegate && [_delegate respondsToSelector:@selector(didCancelInGroupMemberController:)]){
        [_delegate didCancelInGroupMemberController:self];
    }
}

- (void)rightBarButtonClick {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    if ([self.groupInfo canInviteMember]) {
        [ac addAction:[UIAlertAction actionWithTitle:@"添加成员" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(groupMemberController:didAddMembersInGroup:hasMembers:)]){
                [self.delegate groupMemberController:self didAddMembersInGroup:self.groupId hasMembers:self.members];
            }
        }]];
    }
    if ([self.groupInfo canRemoveMember]) {
        [ac addAction:[UIAlertAction actionWithTitle:@"删除成员" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(groupMemberController:didDeleteMembersInGroup:hasMembers:)]){
                [self.delegate groupMemberController:self didDeleteMembersInGroup:self.groupId hasMembers:self.members];
            }
        }]];
    }
    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:ac animated:YES completion:nil];
}

- (SearchBarView *)searchBar {
    if (!_searchBar) {
        _searchBar = [[SearchBarView alloc]initWithFrame:CGRectMake(0,0, KScreenWidth,44)];
        _searchBar.backgroundColor = [UIColor whiteColor];
        _searchBar.placeholder = @"昵称/备注";
        _searchBar.isShowCancle = NO;
        _searchBar.isCanEdit = YES;
        _searchBar.delegate = self;
    }
    return _searchBar;
}

///选择用户列表
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView registerClass:[YGroupMembersTableViewCell class] forCellReuseIdentifier:@"YGroupMembersTableViewCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        _tableView.separatorColor = [UIColor colorWithHex:KCommonSepareteLineColor];
        [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [_tableView setSectionIndexColor:[UIColor colorWithHex:KCommonlittleLightGrayColor]];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(@0);
            make.top.equalTo(@(_searchBar.mm_maxY));
        }];
    }
    return _tableView;
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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"YGroupMembersTableViewCell";
    YGroupMembersTableViewCell *cell = (YGroupMembersTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[YGroupMembersTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    UserModel* model = [[UserModel alloc]init];
    if ([self.searchGroupList count] > 0) {
        NSString *group = self.searchGroupList[indexPath.section];
        NSArray *list = self.searchDataDict[group];
        model = list[indexPath.row];
        [cell fillWithData:model];
        return cell;
    }
    if (indexPath.section < [self.groupList count]) {
        NSString *group = self.groupList[indexPath.section];
        NSArray *list = self.dataDict[group];
        model = list[indexPath.row];
        [cell fillWithData:model];
    }
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
    return 33;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *array = [NSMutableArray arrayWithObject:@""];
    [array addObjectsFromArray:self.groupList];
    return array;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 54;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if ([self.searchList count] > 0) {
//        if (indexPath.row < self.searchList.count) {
//            UserModel *user = self.searchList[indexPath.row];
//            [self didSelectMemberAvatar:user.userId];
//        }
//    }else {
//        if (indexPath.row < self.members.count) {
//            UserModel *user = self.members[indexPath.row];
//            [self didSelectMemberAvatar:user.userId];
//        }
//    }
//
    if ([self.searchGroupList count] > 0) {
        NSString *group = self.searchGroupList[indexPath.section];
        NSArray *list = self.searchDataDict[group];
        UserModel *user = list[indexPath.row];
        [self didSelectMemberAvatar:user.userId];
        return;
    }
    
    if (indexPath.section < [self.groupList count]) {
        NSString *group = self.groupList[indexPath.section];
        NSArray *list = self.dataDict[group];
        UserModel *user = list[indexPath.row];
        [self didSelectMemberAvatar:user.userId];
    }
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
         for (UserModel *model in self.members) {
               NSString *nickname = model.name;
               if ([nickname rangeOfString:searchText options:NSCaseInsensitiveSearch].length >0) {
                 [self.searchList addObject:model];
                   
                   NSString *group = [[nickname firstPinYin] uppercaseString];
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
         
        }else{
          self.searchGroupList = [[NSMutableArray alloc]init];
          self.searchDataDict = @{}.mutableCopy;
      }
       //回到主线程
      dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
      });
}

/*
 *点击了群成员头像
 */
- (void)didSelectMemberAvatar:(NSString *)memberId {
    @weakify(self)
    [[V2TIMManager sharedInstance] getFriendsInfo:@[memberId] succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
        V2TIMFriendInfoResult *result = resultList.firstObject;
        if (result.relation == V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST || result.relation == V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY) {
            @strongify(self)
            id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
            if ([vc isKindOfClass:[UIViewController class]]) {
                vc.friendProfile = result.friendInfo;
                vc.isShowConversationAtTop = YES;
                [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
            }
        } else {
            [[V2TIMManager sharedInstance] getUsersInfo:@[memberId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                @strongify(self)
                if ([infoList.firstObject.userID isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
                    ProfileViewController* profileVc = [[ProfileViewController alloc]init];
                    [self.navigationController pushViewController:profileVc animated:true];
                    return;
                }
                id<TUIUserProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileControllerServiceProtocol)];
                if ([vc isKindOfClass:[UIViewController class]]) {
                    vc.userFullInfo = infoList.firstObject;
                    if ([vc.userFullInfo.userID isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
                        vc.actionType = PCA_NONE;
                    } else {
                        vc.actionType = PCA_ADD_FRIEND;
                    }
                    [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
                }
            } fail:^(int code, NSString *msg) {
                [THelper makeToastError:code msg:msg];
            }];
        }
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
}


/*
- (BOOL)isMeOwner
{
    return [self.groupInfo.owner isEqualToString:[[TIMManager sharedInstance] getLoginUser]];
}
 */
/*
- (BOOL)isPrivate
{
    return [self.groupInfo.groupType isEqualToString:@"Private"];
}
 */
/*
- (BOOL)canInviteMember
{
    if([self.groupInfo.groupType isEqualToString:@"Private"]){
        return YES;
    }
    else if([self.groupInfo.groupType isEqualToString:@"Public"]){
        return NO;
    }
    else if([self.groupInfo.groupType isEqualToString:@"ChatRoom"]){
        return NO;
    }
    return NO;
}
 */
/**
- (BOOL)canRemoveMember
{
    return [self isMeOwner] && (self.members.count > 1);
}
 **/
@end
