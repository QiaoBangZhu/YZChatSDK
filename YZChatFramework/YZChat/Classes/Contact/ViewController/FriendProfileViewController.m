//
//  FriendProfileViewController.m
//  YChat
//
//  Created by magic on 2020/9/30.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "FriendProfileViewController.h"
#import "TCommonTextCell.h"
#import "TCommonSwitchCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "THeader.h"
#import "TTextEditController.h"
#import "ChatViewController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIKit.h"
#import "TUIAvatarViewController.h"
#import "THelper.h"
#import "UserInfoAvatarTableViewCell.h"
#import "UserInfo.h"
#import "YChatSettingStore.h"
#import "ButtonTableViewCell.h"
#import "YChatNetworkEngine.h"
#import "UIColor+ColorExtension.h"
#import "WeChatActionSheet.h"
#import "TUICallManager.h"
#import <QMUIKit/QMUIKit.h>
#import "TUICallManager.h"
#import "TextEditViewController.h"
#import "ContactSelectViewController.h"
#import "YChatIMCreateGroupMemberInfo.h"
#import "YZBaseManager.h"
#import "ConversationViewController.h"

@TCServiceRegister(TUIFriendProfileControllerServiceProtocol, FriendProfileViewController)
@interface FriendProfileViewController ()<UserInfoAvatarTableViewCellDelegate>
@property NSArray<NSArray *> *dataList;
@property BOOL isInBlackList;
@property BOOL modified;
@property V2TIMUserFullInfo *userFullInfo;
@property (nonatomic, strong) UserInfo* user;
@end

@implementation FriendProfileViewController
@synthesize friendProfile;
@synthesize isShowConversationAtTop;
@synthesize isShowGrpEntrance;

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    self.tableView.tableFooterView = UIView.new;

    return self;
}

- (void)willMoveToParentViewController:(nullable UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    if (parent == nil) {
        if (self.modified) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onFriendInfoUpdate object:self.friendProfile];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详细资料";
//    [self addLongPressGesture];
    [[V2TIMManager sharedInstance] getBlackList:^(NSArray<V2TIMFriendInfo *> *infoList) {
        for (V2TIMFriendInfo *friend in infoList) {
            if ([friend.userID isEqualToString:self.friendProfile.userID])
            {
                self.isInBlackList = true;
                break;
            }
        }
        [self fetchUserInfo];
    } fail:nil];

    self.userFullInfo = self.friendProfile.userFullInfo;
    [self.tableView registerClass:[TCommonTextCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[TCommonSwitchCell class] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerClass:[UserInfoAvatarTableViewCell class] forCellReuseIdentifier:@"CardCell"];
    [self.tableView registerClass:[ButtonTableViewCell class] forCellReuseIdentifier:@"ButtonCell"];
    self.tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    self.tableView.separatorColor  = [UIColor colorWithHex:KCommonSepareteLineColor];
    //如果不加这一行代码，依然可以实现点击反馈，但反馈会有轻微延迟，体验不好。
    self.tableView.delaysContentTouches = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)fetchUserInfo {
    [YChatNetworkEngine requestUserInfoWithUserId:self.friendProfile.userID completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"]intValue] == 200) {
                UserInfo* info = [UserInfo yy_modelWithDictionary:result[@"data"]];
                self.user = info;
                [self loadData];
            }else {
                [QMUITips showError:result[@"msg"]];
            }
        }
    }];
}

/**
 *初始化视图显示数据
 */
- (void)loadData
{
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            AvatarProfileCardCellData *personal = [[AvatarProfileCardCellData alloc] init];
            personal.mobile = self.user.mobile;
            personal.avatarImage = DefaultAvatarImage;
            personal.avatarUrl = [NSURL URLWithString:self.user.userIcon];
            personal.name = self.user.nickName;
            personal.reuseId = @"CardCell";
            personal.isShowGrpBtn = isShowGrpEntrance;
            personal;
        })];
        inlist;
    })];
    
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
//        [inlist addObject:({
//            TCommonTextCellData *data = [TCommonTextCellData new];
//            data.key = @"部门";
//            data.value = [self.user.departName length] == 0 ? @"待完善" : self.user.departName;
//            data.showAccessory = NO;
//            data.reuseId = @"TextCell";
//            data;
//        })];
//
//        [inlist addObject:({
//            TCommonTextCellData *data = [TCommonTextCellData new];
//            data.key = @"职位";
//            data.value = [self.user.position length] == 0 ? @"待完善" : self.user.position;
//            data.showAccessory = NO;
//            data.reuseId = @"TextCell";
//            data;
//        })];

//         [inlist addObject:({
//            TCommonTextCellData *data = [TCommonTextCellData new];
//            data.key = @"工号";
//            data.value = [self.user.departMentId length] == 0 ? @"待完善": self.user.departMentId;
//            data.showAccessory = NO;
//            data.reuseId = @"TextCell";
//            data;
//        })];

        [inlist addObject:({
            TCommonTextCellData *data = [TCommonTextCellData new];
            data.key = @"邮箱";
            data.value = [self.user.email length] == 0 ? @"待完善" : self.user.email;
            data.showAccessory = NO;
            data.reuseId = @"TextCell";
            data;
        })];
        inlist;
    })];
    
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            TCommonTextCellData *data = TCommonTextCellData.new;
            data.key = @"设置备注";
            data.value = self.friendProfile.friendRemark;
            if (data.value.length == 0)
            {
                data.value = @"";
            }
            data.showAccessory = YES;
            data.cselector = @selector(onChangeRemark:);
            data.reuseId = @"TextCell";
            data;
        })];
        inlist;
    })];

    if (self.isShowConversationAtTop) {
        [list addObject:({
               NSMutableArray *inlist = @[].mutableCopy;
               [inlist addObject:({
                   TCommonSwitchCellData *data = TCommonSwitchCellData.new;
                   data.title = @"置顶聊天";
                   if ([[[TUILocalStorage sharedInstance] topConversationList] containsObject:[NSString stringWithFormat:@"c2c_%@",self.friendProfile.userID]]) {
                       data.on = YES;
                   }
                   data.cswitchSelector =  @selector(onTopMostChat:);
                   data.reuseId = @"SwitchCell";
                   data;
               })];
               inlist;
           })];
    }
   
    if (self.user.userId != [[YChatSettingStore sharedInstance]getUserId]) {
        [list addObject:({
            NSMutableArray *inlist = @[].mutableCopy;
            [inlist addObject:({
                TCommonSwitchCellData *data = TCommonSwitchCellData.new;
                data.title = @"加入黑名单";
                data.on = self.isInBlackList;
                data.cswitchSelector =  @selector(onChangeBlackList:);
                data.reuseId = @"SwitchCell";
                data;
            })];
            inlist;
        })];
    }
    
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            ButtonCellData *data = ButtonCellData.new;
            data.title = @"发送消息";
            data.style = BtnBlueText;
            data.cbuttonSelector = @selector(onSendMessage:);
            data.reuseId = @"ButtonCell";
            data.hasLine = YES;
            data;
        })];
        [inlist addObject:({
            ButtonCellData *data = ButtonCellData.new;
            data.title = @"音视频通话";
            data.style = BtnBlueText;
            data.cbuttonSelector = @selector(showMediaPlayer);
            data.reuseId = @"ButtonCell";
            data.hasLine = NO;
            data;
        })];
        inlist;
    })];
    
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            ButtonCellData *data = ButtonCellData.new;
            data.title = @"删除好友";
            data.style = ButtonRedText;
            data.cbuttonSelector =  @selector(onDeleteFriend:);
            data.reuseId = @"ButtonCell";
            data.hasLine = NO;
            data;
        })];
        inlist;
    })];
    self.dataList = list;
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (void)onChangeBlackList:(TCommonSwitchCell *)cell
{
    if (cell.switcher.on) {
        [[V2TIMManager sharedInstance] addToBlackList:@[self.friendProfile.userID] succ:nil fail:nil];
    } else {
        [[V2TIMManager sharedInstance] deleteFromBlackList:@[self.friendProfile.userID] succ:nil fail:nil];
    }
}

/**
 *点击 修改备注 按钮后所执行的函数。包含数据的获取与请求回调
 */
- (void)onChangeRemark:(TCommonTextCell *)cell
{
    TextEditViewController *vc = [[TextEditViewController alloc] initWithText:self.friendProfile.friendRemark editType:EditTypeNickname];
    vc.title = @"修改备注";
    vc.textValue = self.friendProfile.friendRemark;
    [self.navigationController pushViewController:vc animated:YES];

    @weakify(self)
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *value) {
        @strongify(self)
        self.modified = YES;
        self.friendProfile.friendRemark = value;
        [[V2TIMManager sharedInstance] setFriendInfo:self.friendProfile succ:^{
            [self loadData];;
        } fail:nil];
    }];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!section) {
        return 0;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView*  view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width,10)];
    view.backgroundColor = [UIColor colorWithRed:242/255.0 green:246/255.0 blue:249/255.0 alpha:1];
    return  view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSObject *data = self.dataList[indexPath.section][indexPath.row];
    if([data isKindOfClass:[AvatarProfileCardCellData class]]){
        UserInfoAvatarTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:@"CardCell" forIndexPath:indexPath];
        cell.delegate = self;
        [cell fillWithData:(AvatarProfileCardCellData *)data];
        return cell;

    }   else if([data isKindOfClass:[ButtonCellData class]]){
        ButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
        if(!cell){
            cell = [[ButtonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ButtonCell"];
        }
        [cell fillWithData:(ButtonCellData *)data];
        return cell;

    }  else if([data isKindOfClass:[TCommonTextCellData class]]) {
        TCommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell" forIndexPath:indexPath];
        [cell fillWithData:(TCommonTextCellData *)data];
        cell.keyLabel.font = [UIFont systemFontOfSize:16];
        cell.valueLabel.font = [UIFont systemFontOfSize:16];
        cell.keyLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
        cell.valueLabel.textColor = [UIColor colorWithRed:62/255.0 green:109/255.0 blue:183/255.0 alpha:1];
        return cell;

    }  else if([data isKindOfClass:[TCommonSwitchCellData class]]) {
        TCommonSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
        cell.titleLabel.font = [UIFont systemFontOfSize:16];
        cell.titleLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
        [cell fillWithData:(TCommonSwitchCellData *)data];
        return cell;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    TCommonCellData *data = self.dataList[indexPath.section][indexPath.row];
    return [data heightOfWidth:Screen_Width];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

/**
 *点击 删除好友 后执行的函数，包括好友信息获取和请求回调
 */
- (void)onDeleteFriend:(id)sender
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:@"是否删除好友?" preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[V2TIMManager sharedInstance] deleteFromFriendList:@[self.friendProfile.userID] deleteType:V2TIM_FRIEND_TYPE_BOTH succ:^(NSArray<V2TIMFriendOperationResult *> *resultList) {
            self.modified = YES;
            [self.navigationController popViewControllerAnimated:YES];
        } fail:nil];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
    
}

/**
 *点击 发送消息 后执行的函数，默认跳转到对应好友的聊天界面
 */
- (void)onSendMessage:(id)sender
{
    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
    data.conversationID = [NSString stringWithFormat:@"c2c_%@",self.userFullInfo.userID];
    data.userID = self.friendProfile.userID;
    data.title = [self.friendProfile.userFullInfo showName];
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversationData = data;
    [self.navigationController pushViewController:chat animated:YES];
}

/**
 *操作 置顶 开关后执行的函数，将对应好友添加/移除置顶队列
 */
- (void)onTopMostChat:(TCommonSwitchCell *)cell
{
    if (cell.switcher.on) {
        [[TUILocalStorage sharedInstance] addTopConversation:[NSString stringWithFormat:@"c2c_%@",self.friendProfile.userID]];
    } else {
        [[TUILocalStorage sharedInstance] removeTopConversation:[NSString stringWithFormat:@"c2c_%@",self.friendProfile.userID]];
    }
}

/**
 *  以下两个函数实现了在好友界面长按的复制功能。
 */
- (void)addLongPressGesture{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressAtCell:)];
    [self.tableView addGestureRecognizer:longPress];
}

-(void)didLongPressAtCell:(UILongPressGestureRecognizer *)longPress {
    if(longPress.state == UIGestureRecognizerStateBegan){
        CGPoint point = [longPress locationInView:self.tableView];
        NSIndexPath *pathAtView = [self.tableView indexPathForRowAtPoint:point];
        NSObject *data = [self.tableView cellForRowAtIndexPath:pathAtView];

        //长按 TCommonTextCell，可以复制 cell 内的字符串。
        if([data isKindOfClass:[TCommonTextCell class]]){
            TCommonTextCell *textCell = (TCommonTextCell *)data;
            if(textCell.textData.value && ![textCell.textData.value isEqualToString:@"未设置"]){
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = textCell.textData.value;
                NSString *toastString = [NSString stringWithFormat:@"已将 %@ 复制到粘贴板",textCell.textData.key];
                [THelper makeToast:toastString];
            }
        }else if([data isKindOfClass:[UserInfoAvatarTableViewCell class]]){
            //长按 profileCard，复制好友的账号。
            AvatarProfileCardCellData *profileCard = (AvatarProfileCardCellData *)data;
            if(profileCard.mobile){
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = profileCard.mobile;
                NSString *toastString = [NSString stringWithFormat:@"已将该用户账号复制到粘贴板"];
                [THelper makeToast:toastString];
            }

        }
    }
}

- (void)showMediaPlayer {
    WeChatActionSheet *sheet = [WeChatActionSheet showActionSheet:nil buttonTitles:@[@"视频通话",@"语音通话"]];
    [sheet setFunction:^(WeChatActionSheet *actionSheet,NSInteger index){
       if (index == WECHATCANCELINDEX) {}else{
           if (index == 0) {
               [self videoCall];
           }
           if (index == 1) {
               [self audioCall];
           }
       }
   }];
}

- (void)videoCall
{
    [[TUICallManager shareInstance] call: nil userID:self.friendProfile.userID callType:CallType_Video];
}

- (void)audioCall
{
    [[TUICallManager shareInstance] call:nil userID:self.friendProfile.userID callType:CallType_Audio];
}

- (void)didTapOnAvatar:(UserInfoAvatarTableViewCell *)cell {
    TUIAvatarViewController *image = [[TUIAvatarViewController alloc] init];
    image.avatarData = (TUIProfileCardCellData*)cell.cardData;
    [self.navigationController pushViewController:image animated:true];
}

- (void)didTapCreateGrp:(UserInfoAvatarTableViewCell *)cell {
    TCommonContactSelectCellData* data = [[TCommonContactSelectCellData alloc]init];
    data.identifier = self.friendProfile.userID;
    ContactSelectViewController *vc = [ContactSelectViewController new];
    vc.isFromFriendProfile = YES;
    vc.friendProfileCellData = data;
    vc.title = @"选择联系人";
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self);
    vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *array) {
        @strongify(self)
        [self addGroup:@"Private" addOption:V2TIM_GROUP_ADD_ANY withContacts:array];
    };
}

/**
 *创建讨论组、群聊、聊天室的函数
 *groupType:创建的具体类型 Private--讨论组  Public--群聊 ChatRoom--聊天室
 *addOption:创建后加群时的选项          TIM_GROUP_ADD_FORBID       禁止任何人加群
                                     TIM_GROUP_ADD_AUTH        加群需要管理员审批
                                     TIM_GROUP_ADD_ANY         任何人可以加群
 *withContacts:群成员的信息数组。数组内每一个元素分别包含了对应成员的头像、ID等信息。具体信息可参照 TCommonContactSelectCellData 定义
 */
- (void)addGroup:(NSString *)groupType addOption:(V2TIMGroupAddOpt)addOption withContacts:(NSArray<TCommonContactSelectCellData *>  *)contacts
{
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    [[V2TIMManager sharedInstance] getUsersInfo:@[loginUser] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        NSString *showName = loginUser;
        if (infoList.firstObject.nickName.length > 0) {
            showName = infoList.firstObject.nickName;
        }
        NSMutableString *groupName = [NSMutableString stringWithString:showName];
        NSMutableArray *members = [NSMutableArray array];

        //遍历contacts，初始化群组成员信息、群组名称信息
        for (TCommonContactSelectCellData *item in contacts) {
            YChatIMCreateGroupMemberInfo *member = [[YChatIMCreateGroupMemberInfo alloc] init];
            member.Member_Account = item.identifier;
            [groupName appendFormat:@"、%@", item.title];
            [members addObject:[member yy_modelToJSONObject]];
        }

        //群组名称默认长度不超过10，如有需求可在此更改，但可能会出现UI上的显示bug
        if ([groupName length] > 10) {
            groupName = [groupName substringToIndex:10].mutableCopy;
        }

        V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
        info.groupName = groupName;
        info.groupType = groupType;
        if(![info.groupType isEqualToString:GroupType_Work]){
            info.groupAddOpt = addOption;
        }
        //发送创建请求后的回调函数
        [self createGroup:info memberList:members showName:showName groupName:groupName owner:loginUser];
    } fail:^(int code, NSString *msg) {
        // to do
    }];
}

- (void)createGroup:(V2TIMGroupInfo *)info
         memberList:(NSMutableArray *)members
           showName:(NSString *)showName
          groupName:(NSString*)groupName
              owner:(NSString *)owner {
    @weakify(self)
    
    [YChatNetworkEngine requestCreateMembersGroupWithGroupName:info.groupName type:info.groupType memberList:members ownerAccount:owner     completion:^(NSDictionary *result, NSError *error) {
        @strongify(self)
        if (!error) {
            if ([result[@"code"] intValue] == 200) {
                if ([result[@"data"][@"ErrorCode"]intValue] != 0) {
                    [THelper makeToast:result[@"data"][@"ErrorInfo"]];
                    return;
                }
                NSString* groupID = result[@"data"][@"GroupId"];
                //创建成功后，在群内推送创建成功的信息
                NSString *content = nil;
                if([info.groupType isEqualToString:GroupType_Work]) {
                    content = @"创建讨论组";
                } else if([info.groupType isEqualToString:GroupType_Public]){
                    content = @"发起群聊";
                } else if([info.groupType isEqualToString:GroupType_Meeting]) {
                    content = @"创建聊天室";
                } else {
                    content = @"创建群组";
                }
                NSDictionary *dic = @{@"version": @(GroupCreate_Version),@"businessID": GroupCreate,@"opUser":showName,@"content":@"创建群组"};
                NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
                V2TIMMessage *msg = [[V2TIMManager sharedInstance] createCustomMessage:data];
                
                [[V2TIMManager sharedInstance] sendMessage:msg receiver:nil groupID:groupID priority:V2TIM_PRIORITY_DEFAULT onlineUserOnly:NO offlinePushInfo:nil progress:nil succ:nil fail:nil];

                //创建成功后，默认跳转到群组对应的聊天界面
                TUIConversationCellData *cellData = [[TUIConversationCellData alloc] init];
                cellData.groupID = groupID;
                cellData.title = groupName;
                ChatViewController *chat = [[ChatViewController alloc] init];
                chat.conversationData = cellData;
                [self.navigationController pushViewController:chat animated:YES];
                
                //删除nav堆栈内其他无关vc用于从聊天页面直接返回会话列表页面
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                [tempArray removeObjectsInRange:NSMakeRange(1, tempArray.count-2)];
                self.navigationController.viewControllers = tempArray;
                
            }else {
                [THelper makeToast:result[@"msg"]];
            }
        }
    }];
}



@end
