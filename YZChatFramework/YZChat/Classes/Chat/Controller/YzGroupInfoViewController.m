//
//  YzGroupInfoViewController.m
//  YZChat
//
//  Created by 安笑 on 2021/5/10.
//

#import "YzGroupInfoViewController.h"

#import <ImSDKForiOS/ImSDK.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

#import "THeader.h"
#import "THelper.h"
#import "TIMGroupInfo+DataProvider.h"
#import "TUILocalStorage.h"
#import "TCommonTextCell.h"
#import "TUIGroupMembersCell.h"
#import "TCommonSwitchCell.h"
#import "TUIGroupMemberCell.h"
#import "TUIProfileCardCell.h"
#import "TAddCell.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"

#import "YzCommonImport.h"

// navigation
#import "YZTextEditViewController.h"
#import "YZTransferGrpOwnerViewController.h"
#import "TUIAvatarViewController.h"
#import "YGroupMemberController.h"
#import "YZProfileViewController.h"
#import "YContactSelectViewController.h"

@interface YzGroupInfoViewController () <TGroupMembersCellDelegate>

@property (nonatomic, strong) NSMutableArray <NSMutableArray *>*cellDatas;
@property (nonatomic, strong) NSMutableArray *members;
@property (nonatomic, strong) V2TIMGroupInfo *groupInfo;
@property (nonatomic, strong) V2TIMGroupMemberInfo *selfInfo;
@property (nonatomic, strong) TGroupMembersCellData *groupMembersCellData;
@property (nonatomic, strong) TCommonTextCellData *groupMembersCountCellData;
@property (nonatomic, strong) TCommonTextCellData *groupNickNameCellData;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) CIGAMButton *deleteButton;

@end

@implementation YzGroupInfoViewController

#pragma mark - 初始化

- (instancetype)initWithGroupId:(NSString *)groupId {
    _groupId = groupId;

    return [super initWithStyle: CIGAMTableViewStyleInsetGrouped];
}

- (void)didInitialize {
    [super didInitialize];

    self.cellDatas = [[NSMutableArray alloc] init];
    self.members = [[NSMutableArray alloc] init];
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"群聊详情";
    [self updateData];
}

#pragma mark - Public

- (void)updateData {
    [self fetchGroupsInfo];
    [self fetchGroupMemberList];
}

#pragma mark - 用户交互

- (void)didSelectMembers {
    YGroupMemberController *viewController = [[YGroupMemberController alloc] init];
    viewController.groupId = self.groupId;
    viewController.title = @"群成员";
    [self.navigationController pushViewController: viewController animated: YES];
}

- (void)didSelectGroupName:(TCommonTextCell *)cell {
    if ([self.groupInfo isPrivate] || [self.groupInfo isMeOwner]) {
        YZTextEditViewController *vc = [[YZTextEditViewController alloc] initWithText: self.groupInfo.groupName editType: EditTypeNickname];
        vc.title = @"修改群名称";
        [self.navigationController pushViewController:vc animated:YES];

        @weakify(self)
        [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *x) {
            @strongify(self)
            V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
            info.groupID = self.groupId;
            info.groupName = x;
            [[V2TIMManager sharedInstance] setGroupInfo:info succ:^{
                @strongify(self)
                self.groupInfo.groupName = x;
                [self setupData];
            } fail:^(int code, NSString *msg) {
                [THelper makeToastError:code msg:msg];
            }];
        }];
    } else {
        [CIGAMTips showError:@"您没有权限修改"];
    }
}

- (void)didSelectGroupNotice:(TCommonTextCell *)cell {
    if ([self.groupInfo isMeOwner]) {
        YZTextEditViewController *vc = [[YZTextEditViewController alloc] initWithText: self.groupInfo.notification editType:EditTypeNickname];
        vc.title = @"修改群公告";
        [self.navigationController pushViewController:vc animated:YES];
        @weakify(self)
        [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *x) {
            @strongify(self)
            V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
            info.groupID = self.groupId;
            info.notification = x;
            [[V2TIMManager sharedInstance] setGroupInfo:info succ:^{
                @strongify(self)
                self.groupInfo.notification = x;
                [self setupData];
            } fail:^(int code, NSString *msg) {
                [THelper makeToastError:code msg:msg];
            }];
        }];
    }else {
        [CIGAMTips showError:@"您没有权限修改"];
    }
}

-(void)didSelectTransferGroupOwner:(TCommonTextCell *)cell {
    YZTransferGrpOwnerViewController* viewController = [[YZTransferGrpOwnerViewController alloc] init];
    viewController.dataArray = [self.members mutableCopy];
    viewController.groupInfo = self.groupInfo;
    [self.navigationController pushViewController: viewController animated: YES];

    @weakify(self)
    [[RACObserve(viewController, finished) skip:1] subscribeNext: ^(NSNumber * isFinished){
        @strongify(self)
        if ([isFinished boolValue]) {
            [self updateData];
        }
    }];
}

- (void)didSelectGroupNickname:(TCommonTextCell *)cell {
    YZTextEditViewController *vc = [[YZTextEditViewController alloc] initWithText: self.groupNickNameCellData.value editType:EditTypeNickname];
    vc.title = @"修改我的群昵称";
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self)
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *x) {
        @strongify(self)
        NSString *user = [V2TIMManager sharedInstance].getLoginUser;
        V2TIMGroupMemberFullInfo *info = [[V2TIMGroupMemberFullInfo alloc] init];
        info.userID = user;
        info.nameCard = x;
        [[V2TIMManager sharedInstance] setGroupMemberInfo:self.groupId info:info succ:^{
            @strongify(self)
            self.selfInfo.nameCard = x;
            [self setupData];
        } fail:^(int code, NSString *msg) {
            [THelper makeToastError:code msg:msg];
        }];
    }];
}

- (void)didSelectMsgDND:(TCommonSwitchCell *)cell {
    if (cell.switcher.on) {
        [[V2TIMManager sharedInstance]setReceiveMessageOpt:self.groupId opt:V2TIM_GROUP_RECEIVE_NOT_NOTIFY_MESSAGE succ:^{
            NSLog(@"开启了消息免打扰功能");
        } fail:^(int code, NSString *desc) {
            [THelper makeToastError:code msg:desc];
        }];
    } else {
        [[V2TIMManager sharedInstance]setReceiveMessageOpt:self.groupId opt:V2TIM_GROUP_RECEIVE_MESSAGE succ:^{
            NSLog(@"关闭了消息免打扰功能,可以正常接收消息");
        } fail:^(int code, NSString *desc) {
            [THelper makeToastError:code msg:desc];
        }];
    }
}

- (void)didSelectOnTop:(TCommonSwitchCell *)cell {
    if (cell.switcher.on) {
        [[TUILocalStorage sharedInstance] addTopConversation:[NSString stringWithFormat:@"group_%@", _groupId]];
    } else {
        [[TUILocalStorage sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@", _groupId]];
    }
}

- (void)groupMembersCell:(TUIGroupMembersCell *)cell didSelectItemAtIndex:(NSInteger)index {
    TGroupMemberCellData *member = self.groupMembersCellData.members[index];
    if (member.tag == 0) {
        [self didSelectMemberAvatar: member.identifier];
    }
    else if(member.tag == 1) {
        [self clickAddMembers];
    }
    else if(member.tag == 2) {
        [self clickDeleteMembers];
    }
}

// 点击群成员头像
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
                    YZProfileViewController* profileVc = [[YZProfileViewController alloc]init];
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

-(void)clickAddMembers {
    YContactSelectViewController *viewController = [[YContactSelectViewController alloc] init];
    viewController.title = @"添加联系人";

    NSMutableSet *members = [[NSMutableSet alloc] init];
    for (TGroupMemberCellData *data in self.members){
        [members addObject: data.identifier];
    }
    viewController.viewModel.disableFilter = ^BOOL(TCommonContactSelectCellData *data) {
        return [members containsObject: data.identifier];
    };
    [self.navigationController pushViewController:viewController animated:YES];

    @weakify(self)
    viewController.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *selectArray) {
        @strongify(self)
        [self.navigationController popToViewController: self animated: YES];
        [self addMembers: selectArray];
    };
}

- (void)addMembers:(NSArray *)members {
    NSMutableArray *userList = [[NSMutableArray alloc] init];
    for (TCommonContactSelectCellData *data in members) {
        [userList addObject: data.identifier];
    }

    [[V2TIMManager sharedInstance] inviteUserToGroup: self.groupId userList: userList succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        [THelper makeToast:@"添加成功"];
        [self fetchGroupMemberList];
    } fail:^(int code, NSString *desc) {
        [THelper makeToastError:code msg:desc];
    }];
}

- (void)clickDeleteMembers {
    YContactSelectViewController *vc = [[YContactSelectViewController alloc] init];
    vc.title = @"删除联系人";
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    for (TGroupMemberCellData *data in self.members) {
        if (![data.identifier isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
            [ids addObject: data.identifier];
        }
    }
    [vc setSourceIds:ids];

    @weakify(self)
    [self.navigationController pushViewController:vc animated:YES];
    //删除成功后默认返回群组聊天界面
    vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *selectArray) {
        @strongify(self)
        [self.navigationController popToViewController: self animated: YES];
        [self deleteMembers: selectArray];
    };
}

- (void)deleteMembers:(NSArray *)members {
    NSMutableArray *userList = [[NSMutableArray alloc] init];
    for (TCommonContactSelectCellData *data in members) {
        [userList addObject: data.identifier];
    }

    [[V2TIMManager sharedInstance] kickGroupMember: self.groupId memberList: userList reason:@"" succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        [THelper makeToast:@"删除成功"];
        [self fetchGroupMemberList];
    } fail:^(int code, NSString *desc) {
        [THelper makeToastError:code msg:desc];
    }];
}

- (void)clickDeleteButton {
    CIGAMAlertController *alert = [CIGAMAlertController alertControllerWithTitle: nil message: @"退出后不会再接收到此群聊消息" preferredStyle: CIGAMAlertControllerStyleAlert];

    @weakify(self)
    [alert addAction: [CIGAMAlertAction actionWithTitle: @"确定" style: CIGAMAlertActionStyleDestructive handler:^(__kindof CIGAMAlertController * _Nonnull aAlertController, CIGAMAlertAction * _Nonnull action) {
        @strongify(self)
        [self.groupInfo isMeOwner] ? [self dismissGroup] : [self quitGroup];
    }]];
    [alert addAction: [CIGAMAlertAction actionWithTitle: @"取消" style: CIGAMAlertActionStyleCancel handler: nil]];
    [alert showWithAnimated: YES];
}

// 点击头像查看大图
-(void)didTapOnAvatar:(TUIProfileCardCell *)cell{
    TUIAvatarViewController *viewController = [[TUIAvatarViewController alloc] init];
    viewController.avatarData = cell.cardData;
    [self.navigationController pushViewController: viewController animated: YES];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellDatas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellDatas[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!section) return 0;
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *data = self.cellDatas[indexPath.section][indexPath.row];
    if([data isKindOfClass:[TUIProfileCardCellData class]]){
        return [(TUIProfileCardCellData *)data heightOfWidth:Screen_Width - 30];
    }
    else if([data isKindOfClass:[TGroupMembersCellData class]]){
        return [TUIGroupMembersCell getHeight:(TGroupMembersCellData *)data];
    }

    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *data = self.cellDatas[indexPath.section][indexPath.row];
    if([data isKindOfClass:[TCommonTextCellData class]]){
        TCommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier: TKeyValueCell_ReuseId forIndexPath: indexPath];
        cell.keyLabel.font = [UIFont systemFontOfSize:14];
        cell.valueLabel.font = [UIFont systemFontOfSize:14];
        cell.valueLabel.textColor = [UIColor colorWithHex: kCommonBlueTextColor];
        [cell fillWithData: (TCommonTextCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TGroupMembersCellData class]]){
        TUIGroupMembersCell *cell = [tableView dequeueReusableCellWithIdentifier: TGroupMembersCell_ReuseId forIndexPath: indexPath];
        cell.delegate = self;
        [cell setData: (TGroupMembersCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TCommonSwitchCellData class]]){
        TCommonSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier: TSwitchCell_ReuseId forIndexPath: indexPath];
        cell.titleLabel.font = [UIFont systemFontOfSize: 14];
        [cell fillWithData: (TCommonSwitchCellData *)data];
        return cell;
    }

    return nil;
}

#pragma mark - 页面布局

- (void)initTableView {
    [super initTableView];

    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    [self.tableView registerClass: [TCommonTextCell class] forCellReuseIdentifier: TKeyValueCell_ReuseId];
    [self.tableView registerClass: [TUIGroupMembersCell class] forCellReuseIdentifier: TGroupMembersCell_ReuseId];
    [self.tableView registerClass: [TCommonSwitchCell class] forCellReuseIdentifier: TSwitchCell_ReuseId];
}

- (CIGAMButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[CIGAMButton alloc] init];
        _deleteButton.cornerRadius = 6;
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize: 18];
        [_deleteButton setTitleColor: UIColorWhite forState: UIControlStateNormal];
        [_deleteButton setBackgroundColor: [UIColor colorWithHex: 0xD42231]];
        [_deleteButton addTarget: self action: @selector(clickDeleteButton) forControlEvents: UIControlEventTouchUpInside];
    }

    return _deleteButton;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.cigam_width, 80)];
        [_footerView addSubview: self.deleteButton];

        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_footerView);
            make.leading.equalTo(@20);
            make.trailing.equalTo(@-20);
            make.height.equalTo(@40);
        }];
    }

    return _footerView;
}

#pragma mark - 数据

- (void)fetchGroupsInfo {
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupsInfo:@[_groupId] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        @strongify(self)
        if(groupResultList.count == 1){
            self.groupInfo = groupResultList[0].info;
            [self setupData];
        }
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
}

- (void)fetchGroupMemberList {
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupMemberList: self.groupId filter: V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq: 0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        @strongify(self)
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (V2TIMGroupMemberFullInfo *fullInfo in memberList) {
            if([fullInfo.userID isEqualToString:[V2TIMManager sharedInstance].getLoginUser]){
                self.selfInfo = fullInfo;
            }
            TGroupMemberCellData *data = [[TGroupMemberCellData alloc] init];
            data.identifier = fullInfo.userID;
            data.name = fullInfo.userID;
            if (fullInfo.nameCard.length > 0) {
                data.name = fullInfo.nameCard;
            } else if (fullInfo.friendRemark.length > 0) {
                data.name = fullInfo.friendRemark;
            } else if (fullInfo.nickName.length > 0) {
                data.name = fullInfo.nickName;
            }
            [temp addObject:data];
        }

        self.members = temp;
        if (self.groupInfo) {
            self.groupMembersCellData.members = [self getShowMembers: temp];
            self.groupMembersCountCellData.value = [NSString stringWithFormat:@"%lu人", (unsigned long)self.members.count];
            [self.tableView reloadData];
        }
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
}

- (void)setupData {
    if (self.groupInfo) {
        [self.cellDatas removeAllObjects];

        NSMutableArray *memberArray = [NSMutableArray array];
        TCommonTextCellData *countData = [[TCommonTextCellData alloc] init];
        countData.key = @"群成员";
        countData.value = [NSString stringWithFormat:@"%d人", self.groupInfo.memberCount];
        countData.cselector = @selector(didSelectMembers);
        countData.showAccessory = YES;
        self.groupMembersCountCellData = countData;
        [memberArray addObject:countData];

        NSMutableArray *tmpArray = [self getShowMembers:self.members];
        TGroupMembersCellData *membersData = [[TGroupMembersCellData alloc] init];
        membersData.members = tmpArray;
        [memberArray addObject:membersData];
        self.groupMembersCellData = membersData;
        [self.cellDatas addObject:memberArray];

        //group info
        NSMutableArray *groupInfoArray = [NSMutableArray array];

        TCommonTextCellData *groupChatName = [[TCommonTextCellData alloc] init];
        groupChatName.key = @"群聊名称";
        groupChatName.value = self.groupInfo.groupName;
        groupChatName.cselector = @selector(didSelectGroupName:);
        groupChatName.showAccessory = YES;
        [groupInfoArray addObject:groupChatName];

        TCommonTextCellData *groupNotice = [[TCommonTextCellData alloc] init];
        groupNotice.key = @"我的群公告";
        groupNotice.value = self.groupInfo.notification;
        groupNotice.cselector = @selector(didSelectGroupNotice:);
        groupNotice.showAccessory = YES;
        [groupInfoArray addObject:groupNotice];

        [self.cellDatas addObject:groupInfoArray];

        NSMutableArray *transferArray = [NSMutableArray array];

        TCommonTextCellData *transferGroupOwner = [[TCommonTextCellData alloc] init];
        transferGroupOwner.key = @"转让群主";
        transferGroupOwner.cselector = @selector(didSelectTransferGroupOwner:);
        transferGroupOwner.showAccessory = YES;
        [transferArray addObject:transferGroupOwner];
        if ([self.groupInfo isMeOwner]) {
            [self.cellDatas addObject:transferArray];
        }

        //personal info
        NSMutableArray *personalArray = [NSMutableArray array];
        TCommonTextCellData *nickData = [[TCommonTextCellData alloc] init];
        nickData.key = @"我的群昵称";
        nickData.value = self.selfInfo.nameCard;
        nickData.cselector = @selector(didSelectGroupNickname:);
        nickData.showAccessory = YES;
        self.groupNickNameCellData = nickData;
        [personalArray addObject:nickData];

        TCommonSwitchCellData *msgDND = [[TCommonSwitchCellData alloc] init];
        if (self.groupInfo.recvOpt == V2TIM_GROUP_RECEIVE_NOT_NOTIFY_MESSAGE) {
            msgDND.on = YES;
        }
        msgDND.title = @"消息免打扰";
        msgDND.cswitchSelector = @selector(didSelectMsgDND:);
        [personalArray addObject:msgDND];

        TCommonSwitchCellData *switchData = [[TCommonSwitchCellData alloc] init];
        if ([[[TUILocalStorage sharedInstance] topConversationList] containsObject:[NSString stringWithFormat:@"group_%@",self.groupId]]) {
            switchData.on = YES;
        }
        switchData.title = @"置顶聊天";
        switchData.showBottomCorner = YES;
        switchData.cswitchSelector = @selector(didSelectOnTop:);
        [personalArray addObject:switchData];

        [self.cellDatas addObject:personalArray];

        if ([self.groupInfo isMeOwner]) {
            [self.deleteButton setTitle: @"解散该群" forState: UIControlStateNormal];
        } else {
            [self.deleteButton setTitle: @"退出群聊" forState: UIControlStateNormal];
        }

        self.tableView.tableFooterView = self.footerView;
        [self.tableView reloadData];
    }
}

- (void)dismissGroup {
    @weakify(self)
    [YChatNetworkEngine requestDismissGroupWithGroupId:self.groupId completion:^(NSDictionary *result, NSError *error) {
        @strongify(self)
        if (!error) {
            if ([result[@"code"] intValue] == 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.delegate && [self.delegate respondsToSelector:@selector(viewController:didDeleteGroup:)]){
                        [self.delegate viewController: self didDeleteGroup: self.groupId];
                    }
                });
            }else {
                [THelper makeToastError:[result[@"code"]integerValue] msg:result[@"msg"]];
            }
        }
    }];
}

- (void)quitGroup {
    @weakify(self)
    [[V2TIMManager sharedInstance] quitGroup:self.groupId succ:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.delegate && [self.delegate respondsToSelector:@selector(viewController:didQuitGroup:)]){
                [self.delegate viewController: self didQuitGroup: self.groupId];
            }
        });
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
}

#pragma mark - Helper

- (NSMutableArray *)getShowMembers:(NSMutableArray *)members {
    int maxCount = TGroupMembersCell_Column_Count * TGroupMembersCell_Row_Count;
    if ([self.groupInfo canRemoveMember]) maxCount--;
    if ([self.groupInfo canRemoveMember]) maxCount--;
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];

    for (NSInteger i = 0; i < members.count && i < maxCount; ++i) {
        [tmpArray addObject:members[i]];
    }
    if ([self.groupInfo canInviteMember]) {
        TGroupMemberCellData *add = [[TGroupMemberCellData alloc] init];
        add.avatarImage = YZChatResource(@"icon_group_add");
        add.tag = 1;
        [tmpArray addObject: add];
    }
    if ([self.groupInfo canRemoveMember]) {
        TGroupMemberCellData *delete = [[TGroupMemberCellData alloc] init];
        delete.avatarImage = YZChatResource(@"icon_group_delete");
        delete.tag = 2;
        [tmpArray addObject: delete];
    }
    return tmpArray;
}

@end
