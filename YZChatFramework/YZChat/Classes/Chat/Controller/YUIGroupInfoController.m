//
//  YUIGroupInfoController.m
//  YChat
//
//  Created by magic on 2020/10/2.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YUIGroupInfoController.h"
#import "TUIProfileCardCell.h"
#import "TUIGroupMembersCell.h"
#import "TUIGroupMemberCell.h"
#import "TUIButtonCell.h"
#import "TCommonSwitchCell.h"
#import "THeader.h"
#import "TUIGroupMemberController.h"
#import "TModifyView.h"
#import "TAddCell.h"
#import "TUILocalStorage.h"
#import "UIImage+TUIKIT.h"
#import "TCommonTextCell.h"
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "Toast/Toast.h"
#import "THelper.h"
#import "TIMGroupInfo+DataProvider.h"
#import "TUIAvatarViewController.h"
#import "UIColor+TUIDarkMode.h"
#import "YZButtonTableViewCell.h"
#import "UIColor+ColorExtension.h"
#import "YZTextEditViewController.h"
#import "YChatNetworkEngine.h"
#import "CIGAMKit.h"
#import "YChatNetworkEngine.h"
#import "YZTransferGrpOwnerViewController.h"
#import <ImSDKForiOS/ImSDK.h>
#import "CommonConstant.h"
#import "NSBundle+YZBundle.h"
#import <Masonry/Masonry.h>
#import "YUIButtonTableViewCell.h"


#define ADD_TAG @"-1"
#define DEL_TAG @"-2"

//@import ImSDK;

@interface YUIGroupInfoController ()<TModifyViewDelegate, TGroupMembersCellDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *memberData;
@property (nonatomic, strong) V2TIMGroupInfo *groupInfo;
@property V2TIMGroupMemberInfo *selfInfo;
@property TGroupMembersCellData *groupMembersCellData;
@property TCommonTextCellData *groupMembersCountCellData;
@property TCommonTextCellData *groupNickNameCellData;

@end

@implementation YUIGroupInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self updateData];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        _tableView.separatorColor = [UIColor colorWithHex:KCommonSeparatorLineColor];
    
        [_tableView registerClass:[TCommonTextCell class] forCellReuseIdentifier:TKeyValueCell_ReuseId];
        [_tableView registerClass:[TUIGroupMembersCell class] forCellReuseIdentifier:TGroupMembersCell_ReuseId];
        [_tableView registerClass:[TCommonSwitchCell class] forCellReuseIdentifier:TSwitchCell_ReuseId];
        [_tableView registerClass:[YUIButtonTableViewCell class] forCellReuseIdentifier:TButtonCell_ReuseId];
        
        _tableView.layer.cornerRadius = 8;
        _tableView.layer.shadowColor = [[UIColor colorWithHex:0xAEAEC0] CGColor];
        _tableView.layer.shadowOffset = CGSizeMake(3,3);
        _tableView.layer.shadowOpacity = 1;
        _tableView.layer.shadowRadius = 5;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}



- (void)setupViews
{
    self.title = @"详细资料";
//    self.tableView.tableFooterView = [[UIView alloc] init];
//    self.tableView.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.right.equalTo(@-16);
        make.top.equalTo(@24);
        make.bottom.equalTo(@0);
    }];

    //加入此行，会让反馈更加灵敏
    self.tableView.delaysContentTouches = NO;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor colorWithHex:KCommonSeparatorLineColor];
}

- (void)updateData
{
    @weakify(self)
    _memberData = [NSMutableArray array];

    [[V2TIMManager sharedInstance] getGroupsInfo:@[_groupId] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        @strongify(self)
        if(groupResultList.count == 1){
            self.groupInfo = groupResultList[0].info;
            [self setupData];
        }
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
    [[V2TIMManager sharedInstance] getGroupMemberList:self.groupId filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        @strongify(self)
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
            [self.memberData addObject:data];
        }
        [self setupData];;
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
}

- (void)setupData
{
    _data = [NSMutableArray array];
    if (self.groupInfo) {
        NSMutableArray *memberArray = [NSMutableArray array];
        TCommonTextCellData *countData = [[TCommonTextCellData alloc] init];
        countData.key = @"群成员";
        countData.value = [NSString stringWithFormat:@"%d人", self.groupInfo.memberCount];
        countData.cselector = @selector(didSelectMembers);
        countData.showTopCorner = YES;
        countData.showAccessory = YES;
        self.groupMembersCountCellData = countData;
        [memberArray addObject:countData];

        NSMutableArray *tmpArray = [self getShowMembers:self.memberData];
        TGroupMembersCellData *membersData = [[TGroupMembersCellData alloc] init];
        membersData.members = tmpArray;
        [memberArray addObject:membersData];
        self.groupMembersCellData = membersData;
        [self.data addObject:memberArray];
    
        //group info
        NSMutableArray *groupInfoArray = [NSMutableArray array];
        
        TCommonTextCellData *groupChatName = [[TCommonTextCellData alloc] init];
        groupChatName.key = @"群聊名称";
        groupChatName.value = self.groupInfo.groupName;
        groupChatName.cselector = @selector(didSelectGroupName:);
        groupChatName.showAccessory = YES;
        groupChatName.showTopCorner = YES;
        [groupInfoArray addObject:groupChatName];
        
        TCommonTextCellData *groupNotice = [[TCommonTextCellData alloc] init];
        groupNotice.key = @"我的群公告";
        groupNotice.value = self.groupInfo.notification;
        groupNotice.cselector = @selector(didSelectGroupNotice:);
        groupNotice.showAccessory = YES;
        groupNotice.showBottomCorner = YES;
        [groupInfoArray addObject:groupNotice];
        
        [self.data addObject:groupInfoArray];
        
        
        NSMutableArray *transferArray = [NSMutableArray array];
        
        TCommonTextCellData *transferGroupOwner = [[TCommonTextCellData alloc] init];
        transferGroupOwner.key = @"转让群主";
        transferGroupOwner.cselector = @selector(didSelectTransferGroupOwner:);
        transferGroupOwner.showAccessory = YES;
        transferGroupOwner.showCorner = YES;
        [transferArray addObject:transferGroupOwner];
        if ([self.groupInfo isMeOwner]) {
            [self.data addObject:transferArray];
        }

        //personal info
        NSMutableArray *personalArray = [NSMutableArray array];
        TCommonTextCellData *nickData = [[TCommonTextCellData alloc] init];
        nickData.key = @"我的群昵称";
        nickData.value = self.selfInfo.nameCard;
        nickData.cselector = @selector(didSelectGroupNickname:);
        nickData.showAccessory = YES;
        nickData.showTopCorner = YES;
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

        [self.data addObject:personalArray];

        NSMutableArray *buttonArray = [NSMutableArray array];

        //群解散按钮
        if ([self.groupInfo isMeOwner]) {
            YUIButtonCellData *Deletebutton = [[YUIButtonCellData alloc] init];
            Deletebutton.title = @"解散该群";
            Deletebutton.style = YButtonRedText;
            Deletebutton.cbuttonSelector = @selector(deleteGroup:);
            [buttonArray addObject:Deletebutton];
        }else {
            //群删除按钮
            YUIButtonCellData *quitButton = [[YUIButtonCellData alloc] init];
            quitButton.title = @"退出群聊";
            quitButton.style = YButtonRedText;
            quitButton.cbuttonSelector = @selector(deleteGroup:);
            [buttonArray addObject:quitButton];
        }

        [self.data addObject:buttonArray];

        [self.tableView reloadData];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _data.count;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!section) {
        return 1;
    }
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = _data[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TUIProfileCardCellData class]]){
        return [(TUIProfileCardCellData *)data heightOfWidth:Screen_Width];
    }
    else if([data isKindOfClass:[TGroupMembersCellData class]]){
        return [TUIGroupMembersCell getHeight:(TGroupMembersCellData *)data];
    }
    else if([data isKindOfClass:[YUIButtonCellData class]]){
        return [(YUIButtonCellData *)data heightOfWidth:Screen_Width];;
    }

    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TCommonTextCellData class]]){
        TCommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:TKeyValueCell_ReuseId];
        if(!cell){
            cell = [[TCommonTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TKeyValueCell_ReuseId];
            cell.keyLabel.font = [UIFont systemFontOfSize:14];
            cell.valueLabel.font = [UIFont systemFontOfSize:14];
            cell.valueLabel.textColor = [UIColor colorWithHex:kCommonBlueTextColor];
        }
        [cell fillWithData:(TCommonTextCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TGroupMembersCellData class]]){
        TUIGroupMembersCell *cell = [tableView dequeueReusableCellWithIdentifier:TGroupMembersCell_ReuseId];
        if(!cell){
            cell = [[TUIGroupMembersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TGroupMembersCell_ReuseId];
        }
        cell.delegate = self;
        [cell setData:(TGroupMembersCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TCommonSwitchCellData class]]){
        TCommonSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:TSwitchCell_ReuseId];
        if(!cell){
            cell = [[TCommonSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TSwitchCell_ReuseId];
            cell.titleLabel.font = [UIFont systemFontOfSize:14];
        }
        [cell fillWithData:(TCommonSwitchCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[YUIButtonCellData class]]){
        YUIButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TButtonCell_ReuseId];
        if(!cell){
            cell = [[YUIButtonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TButtonCell_ReuseId];
        }
        [cell fillWithData:(YUIButtonCellData *)data];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (void)leftBarButtonClick:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didSelectMembers
{
    if(_delegate && [_delegate respondsToSelector:@selector(groupInfoController:didSelectMembersInGroup:)]){
        [_delegate groupInfoController:self didSelectMembersInGroup:_groupId];
    }
}

- (void)didSelectGroupName:(TCommonTextCell *)cell {
    if ([self.groupInfo isPrivate] || [self.groupInfo isMeOwner]) {
        YZTextEditViewController *vc = [[YZTextEditViewController alloc] initWithText: self.groupInfo.groupName editType:EditTypeNickname];
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
    }else {
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
    YZTransferGrpOwnerViewController* transferGrp = [[YZTransferGrpOwnerViewController alloc]init];
    transferGrp.dataArray = [self.memberData mutableCopy];
    transferGrp.groupInfo = self.groupInfo;
    [self.navigationController pushViewController:transferGrp animated:YES];
     @weakify(self)
    [[RACObserve(transferGrp, finished) skip:1] subscribeNext: ^(NSNumber * isFinished){
     @strongify(self)
        if ([isFinished boolValue]) {
            [self updateData];
        }
    }];
}


- (void)didSelectGroupNickname:(TCommonTextCell *)cell
{
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

- (void)didSelectOnTop:(TCommonSwitchCell *)cell
{
    if (cell.switcher.on) {
        [[TUILocalStorage sharedInstance] addTopConversation:[NSString stringWithFormat:@"group_%@",_groupId]];
    } else {
        [[TUILocalStorage sharedInstance] removeTopConversation:[NSString stringWithFormat:@"group_%@",_groupId]];
    }
}

- (void)deleteGroup:(TUIButtonCell *)cell
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:@"退出后不会再接收到此群聊消息" preferredStyle:UIAlertControllerStyleActionSheet];

    [ac addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

        @weakify(self)
        if ([self.groupInfo isMeOwner]) {
//            [[V2TIMManager sharedInstance] dismissGroup:self.groupId succ:^{
//                @strongify(self)
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if(self.delegate && [self.delegate respondsToSelector:@selector(groupInfoController:didDeleteGroup:)]){
//                        [self.delegate groupInfoController:self didDeleteGroup:self.groupId];
//                    }
//                });
//            } fail:^(int code, NSString *msg) {
//                [THelper makeToastError:code msg:msg];
//            }];
            [self dismissGroup];
        } else {
            [[V2TIMManager sharedInstance] quitGroup:self.groupId succ:^{
                @strongify(self)
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.delegate && [self.delegate respondsToSelector:@selector(groupInfoController:didQuitGroup:)]){
                        [self.delegate groupInfoController:self didQuitGroup:self.groupId];
                    }
                });
            } fail:^(int code, NSString *msg) {
                [THelper makeToastError:code msg:msg];
            }];
        }
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)groupMembersCell:(TUIGroupMembersCell *)cell didSelectItemAtIndex:(NSInteger)index
{
    TGroupMemberCellData *mem = self.groupMembersCellData.members[index];
    if (mem.tag == 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(groupInfoController:didSelectMemberAvatar:)]) {
            [_delegate groupInfoController:self didSelectMemberAvatar:mem.identifier];
        }
        
    }
    if(mem.tag == 1){
        //add
        if(_delegate && [_delegate respondsToSelector:@selector(groupInfoController:didAddMembersInGroup:members:)]){
            [_delegate groupInfoController:self didAddMembersInGroup:_groupId members:_memberData];
        }
    }
    else if(mem.tag == 2) {
        //delete
        if(_delegate && [_delegate respondsToSelector:@selector(groupInfoController:didDeleteMembersInGroup:members:)]){
            [_delegate groupInfoController:self didDeleteMembersInGroup:_groupId members:_memberData];
        }
    }
    else
    {
        // TODO:
    }
}

- (void)addMembers:(NSArray *)members
{
    for (TAddCellData *addMember in members) {
        TGroupMemberCellData *data = [[TGroupMemberCellData alloc] init];
        data.identifier = addMember.identifier;
        data.name = addMember.name;
        [_memberData addObject:data];
    }

    self.groupMembersCountCellData.value = [NSString stringWithFormat:@"%lu人", (unsigned long)_memberData.count];
    self.groupMembersCellData.members = [self getShowMembers:_memberData];

    [self.tableView reloadData];
}

- (void)deleteMembers:(NSArray *)members
{
    NSMutableArray *delArray = [NSMutableArray array];
    for (TAddCellData *delMember in members) {
        for (TGroupMemberCellData *member in _memberData) {
            if([delMember.identifier isEqualToString:member.identifier]){
                [delArray addObject:member];
            }
        }
    }
    [_memberData removeObjectsInArray:delArray];

    self.groupMembersCountCellData.value = [NSString stringWithFormat:@"%lu人", (unsigned long)_memberData.count];
    self.groupMembersCellData.members = [self getShowMembers:_memberData];

    [self.tableView reloadData];
}

- (NSMutableArray *)getShowMembers:(NSMutableArray *)members
{
    int maxCount = TGroupMembersCell_Column_Count * TGroupMembersCell_Row_Count;
    if ([self.groupInfo canRemoveMember]) maxCount--;
    if ([self.groupInfo canRemoveMember]) maxCount--;
    NSMutableArray *tmpArray = [NSMutableArray array];

    for (NSInteger i = 0; i < members.count && i < maxCount; ++i) {
        [tmpArray addObject:members[i]];
    }
    if ([self.groupInfo canInviteMember]) {
        TGroupMemberCellData *add = [[TGroupMemberCellData alloc] init];
        add.avatarImage = YZChatResource(@"icon_group_add");
        add.tag = 1;
        [tmpArray addObject:add];
    }
    if ([self.groupInfo canRemoveMember]) {
        TGroupMemberCellData *delete = [[TGroupMemberCellData alloc] init];
        delete.avatarImage = YZChatResource(@"icon_group_delete");
        delete.tag = 2;
        [tmpArray addObject:delete];
    }
    return tmpArray;
}

/**
 *  点击头像查看大图的委托实现。
 */
-(void)didTapOnAvatar:(TUIProfileCardCell *)cell{
    TUIAvatarViewController *image = [[TUIAvatarViewController alloc] init];
    image.avatarData = cell.cardData;
    [self.navigationController pushViewController:image animated:YES];
}

- (void)dismissGroup {
    [YChatNetworkEngine requestDismissGroupWithGroupId:self.groupId completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"] intValue] == 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.delegate && [self.delegate respondsToSelector:@selector(groupInfoController:didDeleteGroup:)]){
                        [self.delegate groupInfoController:self didDeleteGroup:self.groupId];
                    }
                });
            }else {
                 [THelper makeToastError:[result[@"code"]integerValue] msg:result[@"msg"]];
            }
        }
    }];
}


@end
