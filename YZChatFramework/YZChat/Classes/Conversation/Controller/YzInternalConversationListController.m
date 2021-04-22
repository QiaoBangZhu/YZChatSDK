//
//  YzInternalConversationListController.m
//  YZChat
//
//  Created by 安笑 on 2021/4/15.
//

#import "YzInternalConversationListController.h"

#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

#import "THeader.h"
#import "TUIKit.h"
#import "THelper.h"
#import "TUIConversationCell.h"
#import "TIMMessage+DataProvider.h"

#import "YzExtensions.h"
#import "YzCommonImport.h"
#import "YzConversationListController.h"
#import "YChatIMCreateGroupMemberInfo.h"

// navigation
#import "YContactSelectViewController.h"
#import "QRScanViewController.h"
#import "YzInternalChatController.h"
#import "YzSearchMyFriendsViewController.h"

typedef NS_ENUM(NSInteger, GroupMessageType) {
    GroupMessageTypeRecycled = 1,//群已经回收
    GroupMessageTypeKickOff = 2,//被踢出群
    GroupMessageTypeLeave = 3,//退出群
    GroupMessageTypeDismissGroup = 4,//解散群
};

static NSString *kReuseIdentifier_ConversationCell = @"ReuseIdentifier_ConversationCell";

@interface YzInternalConversationListController () <UITableViewDataSource, UITableViewDelegate, CIGAMSearchControllerDelegate> {
    YzChatType _chatType;
    BOOL _isInternal;
}

@property (nonatomic, strong) NSArray<TUIConversationCellData *> *dataList;
@property (nonatomic, strong) NSArray<TUIConversationCellData *> *searchList;
@property (nonatomic, strong) NSMutableArray<V2TIMConversation *> *localConversationList;
@property (nonatomic, copy) NSString *keywords;

@end

@implementation YzInternalConversationListController

#pragma mark - 初始化

- (instancetype)initWithChatType:(YzChatType)chatType {
    self = [super init];
    if (self) {
        _chatType = chatType;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _chatType = YzChatTypeC2C | YzChatTypeGroup;
        _isInternal = YES;
    }
    return self;
}

- (void)didInitialize {
    [super didInitialize];

    self.localConversationList = [[NSMutableArray alloc] init];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addNotificationCenterObserver];
    [self fetchConversation];
}

#pragma mark - NSNotificationCenter

- (void)addNotificationCenterObserver {
    // 新增会话
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRefreshNotificationAdded:)
                                                 name:TUIKitNotification_TIMRefreshListener_Add
                                               object:nil];
    // 更新会话
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRefreshNotificationChanged:)
                                                 name:TUIKitNotification_TIMRefreshListener_Changed
                                               object:nil];
    // 群组
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGroupDismiss:)
                                                 name:TUIKitNotification_onGroupDismissed
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGroupRecycled:)
                                                 name:TUIKitNotification_onGroupRecycled
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKickOffFromGroup:)
                                                 name:TUIKitNotification_onKickOffFromGroup
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLeaveFromGroup:)
                                                 name:TUIKitNotification_onLeaveFromGroup
                                               object:nil];
    // 置顶变化
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topConversationListChanged:)
                                                 name:kTopConversationListChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChangeUnReadCount:)
                                                 name:TUIKitNotification_onChangeUnReadCount
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNetworkChanged:)
                                                 name:TUIKitNotification_TIMConnListener
                                               object:nil];
}

- (void)onRefreshNotificationAdded:(NSNotification *)notify {
    [self updateConversation: notify.object];
}

- (void)onRefreshNotificationChanged:(NSNotification *)notify {
    [self updateConversation: notify.object];
}

- (void)onGroupDismiss:(NSNotification *)notify {
    TUIConversationCellData *data = [self cellDataOf: notify.object];
    if (data) {
        [self requestGroupMsgTisWithType: GroupMessageTypeDismissGroup data:data];
    }
}

- (void)onGroupRecycled:(NSNotification *)notify {
    TUIConversationCellData *data = [self cellDataOf: notify.object];
    if (data) {
        [self requestGroupMsgTisWithType: GroupMessageTypeRecycled data:data];
    }
}

- (void)onKickOffFromGroup:(NSNotification *)notify {
    TUIConversationCellData *data = [self cellDataOf: notify.object];
    if (data) {
        [self requestGroupMsgTisWithType:GroupMessageTypeKickOff data:data];
    }
}

- (void)onLeaveFromGroup:(NSNotification *)notify {
    TUIConversationCellData *data = [self cellDataOf: notify.object];
    if (data) {
        [self requestGroupMsgTisWithType: GroupMessageTypeLeave data:data];
    }
}

- (void)topConversationListChanged:(NSNotification *)notify {
    NSMutableArray *dataList = [NSMutableArray arrayWithArray: self.dataList];
    [self sortDataList: dataList];
    self.dataList = dataList;
}

- (void)onChangeUnReadCount:(NSNotification *)notify {
    NSMutableArray *list = (NSMutableArray *)notify.object;
    int unReadCount = 0;
    for (V2TIMConversation *conversation in list) {
        unReadCount += conversation.unreadCount;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[YZBaseManager shareInstance].tabController setConversationBadge: unReadCount];
    });
}

- (void)onNetworkChanged:(NSNotification *)notify {
    NSString *title;
    switch ((TUINetStatus)[notify.object intValue]) {
        case TNet_Status_Succ:
            title = @"消息";
            break;
        case TNet_Status_Connecting:
            title = @"连接中...";
            break;
        case TNet_Status_Disconnect:
            title = @"消息(未连接)";
            break;
        case TNet_Status_ConnFailed:
            title = @"消息(未连接)";
            break;
        default:
            break;
    }

    if (title) {
        self.titleView.title = title;
        if (self.delegate && [self.delegate respondsToSelector: @selector(onTitleChanged:)]) {
            [self.delegate onTitleChanged: title];
        }
    }
}

#pragma mark - 用户交互

- (void)subscribe {
    [super subscribe];

    if (!_isInternal) return;

    @weakify(self)
    [[[RACObserve(self, keywords) distinctUntilChanged] throttle: 0.25]
     subscribeNext:^(NSString  *_Nullable keywords) {
        @strongify(self)
        [self searchKeywords: keywords];
    }];
}

- (void)clickAdd:(UIBarButtonItem *)barItem {
    @weakify(self)
    CIGAMPopupMenuButtonItem *friend = [CIGAMPopupMenuButtonItem itemWithImage: nil title: @"添加好友" handler:^(CIGAMPopupMenuButtonItem * _Nonnull aItem) {
        @strongify(self)
        YzSearchMyFriendsViewController *add = [[YzSearchMyFriendsViewController alloc] init];
        [self.navigationController pushViewController: add animated: NO];
        [aItem.menuView hideWithAnimated: YES];
    }];

    CIGAMPopupMenuButtonItem *group = [CIGAMPopupMenuButtonItem itemWithImage: nil title: @"发起群聊" handler:^(CIGAMPopupMenuButtonItem * _Nonnull aItem) {
        @strongify(self)
        [self selectContacts];
        [aItem.menuView hideWithAnimated: YES];
    }];

    CIGAMPopupMenuButtonItem *scan = [CIGAMPopupMenuButtonItem itemWithImage: nil title: @"扫一扫" handler:^(CIGAMPopupMenuButtonItem * _Nonnull aItem) {
        @strongify(self)
        QRScanViewController* qr = [[QRScanViewController alloc]init];
        qr.title = @"扫一扫";
        [self.navigationController pushViewController: qr animated:YES];
        [aItem.menuView hideWithAnimated: YES];
    }];

    CIGAMPopupMenuView *menu = [CIGAMPopupMenuView yz_default];
    menu.items = @[friend, group, scan];
    menu.sourceBarItem = barItem;
    [menu showWithAnimated: YES];
}

/** 选择联系人 */
- (void)selectContacts {
    YContactSelectViewController *contacts = [[YContactSelectViewController alloc] init];
    contacts.title = @"选择联系人";
    @weakify(self)
    contacts.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *array) {
        @strongify(self)//GroupType_Work
        [self addGroup:@"Private" addOption: V2TIM_GROUP_ADD_ANY withContacts: array];
    };
    [self.navigationController pushViewController: contacts animated:YES];
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
    [YChatNetworkEngine requestCreateMembersGroupWithGroupName: info.groupName type: info.groupType memberList: members ownerAccount: owner completion:^(NSDictionary *result, NSError *error) {
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

                [[V2TIMManager sharedInstance] sendMessage: msg receiver: nil groupID: groupID priority: V2TIM_PRIORITY_DEFAULT onlineUserOnly: NO offlinePushInfo: nil progress: nil succ: nil fail: nil];

                //创建成功后，默认跳转到群组对应的聊天界面
                TUIConversationCellData *cellData = [[TUIConversationCellData alloc] init];
                cellData.groupID = groupID;
                cellData.title = groupName;
                YzInternalChatController *chat = [[YzInternalChatController alloc] initWithConversation: cellData];
                [self.navigationController pushViewController:chat animated:YES];

                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                [tempArray removeObjectAtIndex:tempArray.count-2];
                self.navigationController.viewControllers = tempArray;
            }else {
                [THelper makeToast:result[@"msg"]];
            }
        }
    }];
}

// TODO: 用途？
- (void)clickClose {
    [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return self.dataList.count;
    }

    return  self.searchList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView == self.tableView;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        TUIConversationCellData *data = self.dataList[indexPath.row];
        [self removeData: data];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
}

- (void)didSelectConversation:(TUIConversationCell *)cell {
    if (_isInternal) {
        YzInternalChatController *chat = [[YzInternalChatController alloc] initWithConversation: cell.convData];
        [self.navigationController pushViewController:chat animated:YES];

        return;
    }

    NSIndexPath *indexPath = [self.tableView indexPathForCell: cell];
    if(indexPath && self.delegate &&
       [self.delegate respondsToSelector: @selector(didSelectConversation:indexPath:)]) {
        [self.delegate didSelectConversation: self.localConversationList[indexPath.row]
                                   indexPath: indexPath];

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier_ConversationCell forIndexPath:indexPath];

    NSArray *dataList = tableView == self.tableView ? self.dataList : self.searchList;
    TUIConversationCellData *data = [dataList objectAtIndex: indexPath.row];
    if (!data.responder) {
        data.responder = self;
    }
    if (!data.cselector) {
        data.cselector = @selector(didSelectConversation:);
    }
    [cell fillWithData:data];
    cell.titleLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
    cell.subTitleLabel.textColor = [UIColor colorWithHex:KCommonBorderColor];
    cell.timeLabel.textColor = [UIColor colorWithHex:KCommonTimeColor];

    //可以在此处修改，也可以在对应cell的初始化中进行修改。用户可以灵活的根据自己的使用需求进行设置。
    cell.changeColorWhenTouched = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector: @selector(setSeparatorInset:)]) {
        [cell setSeparatorInset: UIEdgeInsetsMake(0, 78, 0, 0)];
        if (indexPath.row == (self.dataList.count - 1)) {
            [cell setSeparatorInset: UIEdgeInsetsZero];
        }
    }

    if ([cell respondsToSelector: @selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    if ([cell respondsToSelector: @selector(setLayoutMargins:)]) {
        [cell setLayoutMargins: UIEdgeInsetsZero];
    }
}

#pragma mark - CIGAMSearchControllerDelegate

- (void)searchController:(CIGAMSearchController *)searchController
updateResultsForSearchString:(NSString *)searchString {
    self.keywords = searchString;
}

- (void)willPresentSearchController:(CIGAMSearchController *)searchController {
    [self.tabBarController.tabBar setHidden: YES];
    self.searchList = @[];
    [searchController.tableView reloadData];
}

- (void)willDismissSearchController:(CIGAMSearchController *)searchController {
    [self.tabBarController.tabBar setHidden: NO];
}

#pragma mark - 页面布局

- (void)setupNavigationItems {
    [super setupNavigationItems];

    if (([[YChatSettingStore sharedInstance] getFunctionPerm] & 2) > 0) {
        UIBarButtonItem* add = [[UIBarButtonItem alloc] initWithImage: [YZChatResource(@"addFriend_icon") imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal] style: UIBarButtonItemStylePlain target: self action: @selector(clickAdd:)];
        self.navigationItem.rightBarButtonItems =  @[add];
    }

    if (self.isNeedCloseBarButton) {
        UIBarButtonItem* close = [[UIBarButtonItem alloc] initWithImage: [YZChatResource(@"icon_back") imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal] style: UIBarButtonItemStylePlain target: self action: @selector(clickClose)];
        self.navigationItem.leftBarButtonItem = close;
    }
}

- (void)initSubviews {
    [super initSubviews];

    if (_isInternal) {
        self.shouldShowSearchBar = YES;
    }
}

- (void)initTableView {
    [super initTableView];

    [self.tableView registerClass:[TUIConversationCell class] forCellReuseIdentifier: kReuseIdentifier_ConversationCell];
}

- (void)initSearchController {
    [super initSearchController];

    if (_isInternal) {
        self.searchController.launchView = [[UIView alloc] init];
        self.searchController.launchView.backgroundColor = self.searchController.tableView.backgroundColor;
        [self.searchController.tableView registerClass:[TUIConversationCell class] forCellReuseIdentifier: kReuseIdentifier_ConversationCell];
    }
}

- (void)setupSubviews {
    [super setupSubviews];

    self.titleView.title = @"消息";
}

#pragma mark - 数据

- (void)fetchConversation {
    @weakify(self)
    [[V2TIMManager sharedInstance] getConversationList:0 count:INT_MAX succ:^(NSArray<V2TIMConversation *> *list, uint64_t lastTS, BOOL isFinished) {
        @strongify(self)
        [self updateConversation:list];
    } fail:^(int code, NSString *msg) {
        // 拉取会话列表失败
    }];
}

- (void)updateConversation:(NSArray<V2TIMConversation *> *)conversationList {
    YzChatType type = _chatType ?: YzChatTypeC2C | YzChatTypeGroup;

    NSMutableDictionary *indexMap = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < self.localConversationList.count; ++ i) {
        indexMap[self.localConversationList[i].conversationID] = @(i);
    }

    // 更新 UI 会话列表，如果 UI 会话列表有新增的会话，就替换，如果没有，就新增
    for (V2TIMConversation *conversation in conversationList) {
        // 根据type过滤对话类型
        if ((type & conversation.type) != conversation.type) continue;

        NSNumber *index = indexMap[conversation.conversationID];
        if (index) {
            [self.localConversationList replaceObjectAtIndex: index.intValue withObject: conversation];
        } else {
            [self.localConversationList addObject: conversation];
        }
    }
    // 更新 cell data
    NSMutableArray *dataList = [NSMutableArray array];
    for (V2TIMConversation *conversation in self.localConversationList) {
        TUIConversationCellData *data = [TUIConversationCellData makeDataByConversation: conversation];
        if (data.subTitle == nil || data.time == nil) {
            continue;
        }
        [dataList addObject: data];
    }

    // UI 会话列表根据 lastMessage 时间戳重新排序
    [self sortDataList: dataList];
    self.dataList = dataList;
}

- (void)sortDataList:(NSMutableArray<TUIConversationCellData *> *)dataList {
    // 按时间排序，最近会话在上
    [dataList sortUsingComparator:^NSComparisonResult(TUIConversationCellData *obj1, TUIConversationCellData *obj2) {
        return [obj2.time compare:obj1.time];
    }];

    // 将置顶会话固定在最上面
    NSSet *topIds = [[NSSet alloc] initWithArray: [[TUILocalStorage sharedInstance] topConversationList]];
    int existTopListSize = 0;
    for (int i = 0; i < dataList.count; i++) {
        TUIConversationCellData *data = dataList[i];
        if ([topIds containsObject: data.conversationID]) {
            [dataList removeObjectAtIndex: i];
            [dataList insertObject:data atIndex:existTopListSize];
            existTopListSize++;
        }
    }
}

- (void)requestGroupMsgTisWithType:(GroupMessageType)type
                              data:(TUIConversationCellData *)data {
    @weakify(self);
    [YChatNetworkEngine requestFetchGroupMsgWithGroupIdList:@[data.groupID] completion:^(NSDictionary *result, NSError *error) {
        @strongify(self);
        if (!error) {
            if ([result[@"code"]intValue] == 200) {
                if (type == GroupMessageTypeLeave) {
                    NSArray* groupInfo = result[@"data"][@"GroupInfo"];
                    if ([groupInfo count] > 0) {
                        NSDictionary* dic = groupInfo[0];
                        NSString* tips = dic[@"Name"];
                        [self showTipsWithType:type tips:tips data:data];
                    }
                    return;
                }
                [self showTipsWithType:type tips:result[@"data"][@"Name"] data:data];
            }
        }
    }];
}

- (void)removeData:(TUIConversationCellData *)data {
    NSMutableArray *list = [NSMutableArray arrayWithArray: self.dataList];
    [list removeObject: data];
    self.dataList = list;
    for (V2TIMConversation *conversation in self.localConversationList) {
        if ([conversation.conversationID isEqualToString: data.conversationID]) {
            [self.localConversationList removeObject: conversation];
            break;
        }
    }
    [[V2TIMManager sharedInstance] deleteConversation:data.conversationID succ:nil fail:nil];
}

- (void)setDataList:(NSArray<TUIConversationCellData *> *)dataList {
    _dataList = dataList;
    [self.tableView reloadData];
}

- (void)searchKeywords:(NSString *)keywords {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        if (keywords.length > 0) {
            for (TUIConversationCellData *model in self.dataList) {
                if ([model.title rangeOfString: keywords options: NSCaseInsensitiveSearch].length > 0 ) {
                    [temp addObject:model];
                }
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.searchList = [temp copy];
        });
    });
}

- (void)setSearchList:(NSArray<TUIConversationCellData *> *)searchList {
    _searchList = searchList;
    if (self.searchController.active) {
        [self.searchController.tableView reloadData];
    }
}

#pragma mark - Helper

- (TUIConversationCellData *)cellDataOf:(NSString *)groupID {
    for (TUIConversationCellData *data in self.dataList) {
        if ([data.groupID isEqualToString: groupID]) {
            return data;
        }
    }
    return nil;
}

- (void)showTipsWithType:(GroupMessageType)type
                    tips:(NSString *)tips
                    data:(TUIConversationCellData *)data {
    NSString* info = @"";
    if (type ==  GroupMessageTypeRecycled) {
        info = [NSString stringWithFormat:@"%@ 群已回收", tips];
    }else if(type == GroupMessageTypeKickOff) {
        info = [NSString stringWithFormat:@"您已被踢出 %@ 群", tips];
    }else if(type == GroupMessageTypeLeave) {
        info = [NSString stringWithFormat:@"您已退出 %@ 群", tips];
    }else if(type == GroupMessageTypeDismissGroup) {
        info = [NSString stringWithFormat:@"%@ 群已解散",tips];
    }
    [THelper makeToast:info];
    [self removeData:data];
}

@end
