//
//  YzConversationListController.m
//  YZChat
//
//  Created by 安笑 on 2021/4/9.
//

#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

#import "THeader.h"
#import "TUIKit.h"
#import "THelper.h"
#import "TUIConversationCell.h"
#import "TIMMessage+DataProvider.h"
#import "UIColor+TUIDarkMode.h"

#import "YzConversationListController.h"
#import "UIColor+ColorExtension.h"
#import "YChatNetworkEngine.h"
#import "TUIConversationCellData+Conversation.h"

static NSString *kConversationCell_ReuseId = @"TConversationCell";

typedef NS_ENUM(NSInteger, GroupMessageType) {
    GroupMessageTypeRecycled = 1,//群已经回收
    GroupMessageTypeKickOff = 2,//被踢出群
    GroupMessageTypeLeave = 3,//退出群
    GroupMessageTypeDismissGroup = 4,//解散群
};

@interface YzConversationListController () <UITableViewDataSource, UITableViewDelegate> {
    YzChatType _chatType;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<TUIConversationCellData *> *dataList;
@property (nonatomic, strong) NSMutableArray<V2TIMConversation *> *localConversationList;

@end

@implementation YzConversationListController

- (instancetype)initWithChatType:(YzChatType)chatType {
    self = [super init];
    if (self) {
        _chatType = chatType;
        [self didInitialize];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _chatType = YzChatTypeC2C | YzChatTypeGroup;
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    _localConversationList = [[NSMutableArray alloc] init];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"消息";
    [self setupView];
    [self addNotificationCenterObserver];
    [self fetchConversation];
}

#pragma mark - NSNotificationCenter

- (void)addNotificationCenterObserver {
    // 新增会话
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRefreshNotificationAdded:) name:TUIKitNotification_TIMRefreshListener_Add object:nil];
    // 更新会话
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRefreshNotificationChanged:) name:TUIKitNotification_TIMRefreshListener_Changed object:nil];
    // 群组
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGroupDismiss:) name:TUIKitNotification_onGroupDismissed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGroupRecycled:) name:TUIKitNotification_onGroupRecycled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKickOffFromGroup:) name:TUIKitNotification_onKickOffFromGroup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLeaveFromGroup:) name:TUIKitNotification_onLeaveFromGroup object:nil];
    // 置顶变化
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topConversationListChanged:) name:kTopConversationListChangedNotification object:nil];
}

- (void)onRefreshNotificationAdded:(NSNotification *)notify {
    [self updateConversation: notify.object];
}

- (void)onRefreshNotificationChanged:(NSNotification *)notify {
    [self updateConversation: notify.object];
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

- (TUIConversationCellData *)cellDataOf:(NSString *)groupID {
    for (TUIConversationCellData *data in self.dataList) {
        if ([data.groupID isEqualToString: groupID]) {
            return data;
        }
    }
    return nil;
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


- (void)topConversationListChanged:(NSNotification *)notify {
    NSMutableArray *dataList = [NSMutableArray arrayWithArray: self.dataList];
    [self sortDataList: dataList];
    self.dataList = dataList;
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
    [self.tableView reloadData];
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

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
}

- (void)didSelectConversation:(TUIConversationCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell: cell];
    if(indexPath && self.delegate &&
       [self.delegate respondsToSelector: @selector(didSelectConversation:indexPath:)]) {
        [self.delegate didSelectConversation: self.localConversationList[indexPath.row]
                                   indexPath: indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kConversationCell_ReuseId forIndexPath:indexPath];
    TUIConversationCellData *data = [self.dataList objectAtIndex:indexPath.row];
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

#pragma mark - 页面布局

- (void)setupView {
    self.view.backgroundColor = [UIColor d_colorWithColorLight: TController_Background_Color
                                                          dark: TController_Background_Color_Dark];
    [self setupTableView];
    
    [self.view addSubview: self.tableView];
    [self makeConstraints];
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame: self.view.bounds];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[TUIConversationCell class] forCellReuseIdentifier:kConversationCell_ReuseId];
}

- (void)makeConstraints {
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

@end
