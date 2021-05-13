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
#import "YzSelectGroupMemberViewController.h"

@interface YzGroupInfoViewController () <TGroupMembersCellDelegate>

@property (nonatomic, strong) NSMutableArray <NSMutableArray *>*cellDatas;
@property (nonatomic, strong) NSMutableArray *members;
@property (nonatomic, strong) NSMutableArray *admins;
@property (nonatomic, strong) V2TIMGroupInfo *groupInfo;
@property (nonatomic, strong) V2TIMGroupMemberInfo *selfInfo;
@property (nonatomic, strong) TGroupMembersCellData *groupMembersCellData;
@property (nonatomic, strong) TCommonTextCellData *groupMembersCountCellData;
@property (nonatomic, strong) TCommonTextCellData *groupNickNameCellData;
@property (nonatomic, strong) TCommonTextCellData *groupAdminsCountCellData;
@property (nonatomic, strong) TGroupMembersCellData *groupAdminsCellData;
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

// 禁言
- (void)didSelectAllMuted:(TCommonSwitchCell *)cell {
    self.groupInfo.allMuted = !self.groupInfo.allMuted;
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupID = self.groupId;
    info.allMuted = self.groupInfo.allMuted;

    [[V2TIMManager sharedInstance] setGroupInfo: info succ:^{
    } fail:^(int code, NSString *desc) {
        [THelper makeToastError: code msg: desc];
    }];
}

- (void)didSelectOnTop:(TCommonSwitchCell *)cell {
    if (cell.switcher.on) {
        [[TUILocalStorage sharedInstance] addTopConversation:[NSString stringWithFormat:@"group_%@", _groupId]];
    } else {
        [[TUILocalStorage sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@", _groupId]];
    }
}

- (void)groupMembersCell:(TUIGroupMembersCell *)cell didSelectItemAtIndex:(NSInteger)index {
    if ([cell.data isEqual: self.groupMembersCellData]) {
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
    } else {
        TGroupMemberCellData *member = self.groupAdminsCellData.members[index];
        if (member.tag == 0) {
            [self didSelectMemberAvatar: member.identifier];
        }
        else if(member.tag == 1) {
            [self clickAddAdmin];
        }
        else if(member.tag == 2) {
            [self clickDeleteAdmin];
        }
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
    YzSelectGroupMemberViewController *viewController = [[YzSelectGroupMemberViewController alloc] initWithGroupId: self.groupId filter: V2TIM_GROUP_MEMBER_FILTER_ALL multipleSelection: YES];
    viewController.title = @"移除成员";
    viewController.emptyTip = @"暂无可移除成员";
    [self.navigationController pushViewController: viewController animated: YES];

    NSString *userId = [[V2TIMManager sharedInstance] getLoginUser];
    [viewController setAvailableFilter:^BOOL(NSString * _Nonnull memberId) {
        return ![memberId isEqualToString: userId];
    }];
    @weakify(self)
    [viewController setSelectCompleted:^(NSArray<NSString *> * _Nonnull ids) {
        @strongify(self)
        [self deleteMembers: ids];
        [self.navigationController popToViewController: self animated: YES];
    }];
}

- (void)deleteMembers:(NSArray *)members {
    [[V2TIMManager sharedInstance] kickGroupMember: self.groupId memberList: members reason:@"" succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        [THelper makeToast:@"移除成功"];
        [self fetchGroupMemberList];
    } fail:^(int code, NSString *desc) {
        [THelper makeToastError:code msg: desc];
    }];
}

// 添加管理员
- (void)clickAddAdmin {
    YzSelectGroupMemberViewController *viewController = [[YzSelectGroupMemberViewController alloc] initWithGroupId: self.groupId filter: V2TIM_GROUP_MEMBER_FILTER_COMMON multipleSelection: NO];
    viewController.title = @"添加管理员";
    viewController.emptyTip = @"暂无可添加管理员";
    [self.navigationController pushViewController: viewController animated: YES];

    @weakify(self)
    [viewController setSelectCompleted:^(NSArray<NSString *> * _Nonnull ids) {
        @strongify(self)
        [self setGroupMemberRole: ids[0] newRole: V2TIM_GROUP_MEMBER_ROLE_ADMIN];
        [self.navigationController popToViewController: self animated: YES];
    }];
}

// 删除管理员
- (void)clickDeleteAdmin {
    YzSelectGroupMemberViewController *viewController = [[YzSelectGroupMemberViewController alloc] initWithGroupId: self.groupId filter: V2TIM_GROUP_MEMBER_FILTER_ADMIN multipleSelection: NO];
    viewController.title = @"移除管理员";
    viewController.emptyTip = @"暂无可移除管理员";
    [self.navigationController pushViewController: viewController animated: YES];

    @weakify(self)
    [viewController setSelectCompleted:^(NSArray<NSString *> * _Nonnull ids) {
        @strongify(self)
        [self setGroupMemberRole: ids[0] newRole: V2TIM_GROUP_MEMBER_ROLE_MEMBER];
        [self.navigationController popToViewController: self animated: YES];
    }];
}

- (void)setGroupMemberRole:(NSString *)member newRole:(V2TIMGroupMemberRole)newRole {
    @weakify(self)
    [[V2TIMManager sharedInstance] setGroupMemberRole: self.groupId member: member newRole: newRole succ:^{
        @strongify(self);
        [self fetchGroupMemberList];
        [THelper makeToast:@"设置成功"];
    } fail:^(int code, NSString *desc) {
        [THelper makeToastError: code msg: desc];
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
        _footerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.cigam_width, 100)];
        [_footerView addSubview: self.deleteButton];

        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@20);
            make.trailing.equalTo(@-20);
            make.height.equalTo(@40);
            make.bottom.equalTo(@-20);
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
        NSMutableArray *members = [[NSMutableArray alloc] init];
        NSMutableArray *admins = [[NSMutableArray alloc] init];
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
            [members addObject: data];
            if (fullInfo.role == V2TIM_GROUP_MEMBER_ROLE_ADMIN) {
                [admins addObject: data];
            }
        }

        self.members = members;
        self.admins = admins;
        if (self.groupInfo) {
            self.groupMembersCellData.members = [self getShowMembers];
            self.groupMembersCountCellData.value = [NSString stringWithFormat:@"%ld人", members.count];
            self.groupAdminsCellData.members = [self getShowAdmins];
            self.groupAdminsCountCellData.value = [NSString stringWithFormat:@"%ld人", admins.count];
            [self.tableView reloadData];
        }
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
}

- (void)setupData {
    if (self.groupInfo) {
        [self.cellDatas removeAllObjects];

        // 群成员
        {
            NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity: 2];
            {
                TCommonTextCellData *cellData = [[TCommonTextCellData alloc] init];
                cellData.key = @"群成员";
                cellData.value = [NSString stringWithFormat: @"%ld人", self.members.count];
                cellData.cselector = @selector(didSelectMembers);
                cellData.showAccessory = YES;
                self.groupMembersCountCellData = cellData;
                [temp addObject: cellData];
            }
            {
                TGroupMembersCellData *cellData = [[TGroupMembersCellData alloc] init];
                cellData.members = [self getShowMembers];
                self.groupMembersCellData = cellData;
                [temp addObject: cellData];
            }
            [self.cellDatas addObject: temp];
        }

        //group info
        {
            NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity: 2];
            {
                TCommonTextCellData *cellData = [[TCommonTextCellData alloc] init];
                cellData.key = @"群聊名称";
                cellData.value = self.groupInfo.groupName;
                cellData.cselector = @selector(didSelectGroupName:);
                cellData.showAccessory = YES;
                [temp addObject:cellData];
            }
            {
                TCommonTextCellData *cellData = [[TCommonTextCellData alloc] init];
                cellData.key = @"群公告";
                cellData.value = self.groupInfo.notification;
                cellData.cselector = @selector(didSelectGroupNotice:);
                cellData.showAccessory = YES;
                [temp addObject:cellData];
            }
            [self.cellDatas addObject: temp];
        }

        if ([self.groupInfo isMeOwner]) {
            TCommonTextCellData *cellData = [[TCommonTextCellData alloc] init];
            cellData.key = @"转让群主";
            cellData.cselector = @selector(didSelectTransferGroupOwner:);
            cellData.showAccessory = YES;
            [self.cellDatas addObject: @[cellData].mutableCopy];
        }

        //personal info
        {
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            {
                TCommonTextCellData *cellData = [[TCommonTextCellData alloc] init];
                cellData.key = @"管理员";
                cellData.value = [NSString stringWithFormat: @"%ld人", self.admins.count];
                self.groupAdminsCountCellData = cellData;
                [temp addObject: cellData];
            }
            {
                TGroupMembersCellData *cellData = [[TGroupMembersCellData alloc] init];
                cellData.members = [self getShowAdmins];
                self.groupAdminsCellData = cellData;
                [temp addObject: cellData];
            }
            {
                TCommonTextCellData *cellData = [[TCommonTextCellData alloc] init];
                cellData.key = @"我的群昵称";
                cellData.value = self.selfInfo.nameCard;
                cellData.cselector = @selector(didSelectGroupNickname:);
                cellData.showAccessory = YES;
                self.groupNickNameCellData = cellData;
                [temp addObject: cellData];
            }
            {
                TCommonSwitchCellData *cellData = [[TCommonSwitchCellData alloc] init];
                cellData.on = self.groupInfo.recvOpt == V2TIM_GROUP_RECEIVE_NOT_NOTIFY_MESSAGE;
                cellData.title = @"消息免打扰";
                cellData.cswitchSelector = @selector(didSelectMsgDND:);
                [temp addObject: cellData];
            }

            if ([self isOwnerOrAdmin]) {
                TCommonSwitchCellData *cellData = [[TCommonSwitchCellData alloc] init];
                cellData.on = self.groupInfo.allMuted;
                cellData.title = @"全体禁言";
                cellData.cswitchSelector = @selector(didSelectAllMuted:);
                [temp addObject: cellData];
            }

            {
                TCommonSwitchCellData *cellData = [[TCommonSwitchCellData alloc] init];
                cellData.on = [[[TUILocalStorage sharedInstance] topConversationList] containsObject: [NSString stringWithFormat:@"group_%@", self.groupId]];
                cellData.title = @"置顶聊天";
                cellData.cswitchSelector = @selector(didSelectOnTop:);
                [temp addObject: cellData];
            }

            [self.cellDatas addObject: temp];
        }

        NSString *title = [self.groupInfo isMeOwner] ? @"解散该群" :  @"退出群聊";
        [self.deleteButton setTitle: title forState: UIControlStateNormal];

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

- (NSMutableArray *)getShowMembers {
    int maxCount = TGroupMembersCell_Column_Count * TGroupMembersCell_Row_Count;
    if ([self.groupInfo canRemoveMember]) maxCount--;
    if ([self.groupInfo canRemoveMember]) maxCount--;
    NSMutableArray *temp = [[NSMutableArray alloc] init];

    for (NSInteger i = 0; i < self.members.count && i < maxCount; ++i) {
        [temp addObject: self.members[i]];
    }
    if ([self.groupInfo canInviteMember]) {
        TGroupMemberCellData *add = [[TGroupMemberCellData alloc] init];
        add.avatarImage = YZChatResource(@"icon_group_add");
        add.tag = 1;
        [temp addObject: add];
    }
    if ([self.groupInfo canRemoveMember]) {
        TGroupMemberCellData *delete = [[TGroupMemberCellData alloc] init];
        delete.avatarImage = YZChatResource(@"icon_group_delete");
        delete.tag = 2;
        [temp addObject: delete];
    }
    return temp;
}

- (NSMutableArray *)getShowAdmins {
    int maxCount = TGroupMembersCell_Column_Count * TGroupMembersCell_Row_Count;
    if (self.groupInfo.isMeOwner) maxCount -= 2;
    NSMutableArray *temp = [[NSMutableArray alloc] init];

    for (NSInteger i = 0; i < self.admins.count && i < maxCount; ++i) {
        [temp addObject: self.admins[i]];
    }
    if (self.groupInfo.isMeOwner) {
        TGroupMemberCellData *add = [[TGroupMemberCellData alloc] init];
        add.avatarImage = YZChatResource(@"icon_group_add");
        add.tag = 1;
        [temp addObject: add];
    }
    if (self.groupInfo.isMeOwner) {
        TGroupMemberCellData *delete = [[TGroupMemberCellData alloc] init];
        delete.avatarImage = YZChatResource(@"icon_group_delete");
        delete.tag = 2;
        [temp addObject: delete];
    }
    return temp;
}

- (BOOL)isOwnerOrAdmin {
    return self.groupInfo.role == V2TIM_GROUP_MEMBER_ROLE_ADMIN || self.groupInfo.role == V2TIM_GROUP_MEMBER_ROLE_SUPER;
}

@end
