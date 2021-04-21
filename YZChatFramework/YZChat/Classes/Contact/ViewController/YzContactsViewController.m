//
//  YzContactsViewController.m
//  YZChat
//
//  Created by 安笑 on 2021/4/19.
//

#import "YzContactsViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>
#import <MMLayout/UIView+MMLayout.h>
#import <ImSDKForiOS/ImSDK.h>

#import "THeader.h"
#import "THelper.h"
#import "TCommonContactCell.h"
#import "TUIContactActionCell.h"
#import "TContactViewModel.h"
#import "TUIContactActionCellData.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"

#import "YzCommonImport.h"
#import "YZMsgManager.h"

// navigation
#import "YzGroupConversationListController.h"
#import "NewFriendViewController.h"
#import "YUIBlackListViewController.h"
#import "YzSearchMyFriendsViewController.h"

static NSString *kReuseIdentifier_ContactCell = @"ReuseIdentifier_ContactCell";
static NSString *kReuseIdentifier_ContactActionCell = @"ReuseIdentifier_ContactActionCell";

@interface YzContactsViewController () {
    YzCustomMsg *_customMessage;
    BOOL _isInternal;
}

@property (nonatomic, strong) TContactViewModel *viewModel;
@property (nonatomic, strong) NSArray<TUIContactActionCellData *> *firstGroupData;
@property (nonatomic, strong) NSArray<TCommonContactCellData *> *searchList;
@property (nonatomic, copy) NSString *keywords;

@end

@implementation YzContactsViewController

#pragma mark - 初始化

- (instancetype)initWithCustomMessage:(YzCustomMsg *)customMessage {
    _customMessage = customMessage;
    self = [super initWithNibName: nil bundle: nil];
    if (self) {}

    return self;
}

- (void)didInitialize {
    [super didInitialize];

    _isInternal = !_customMessage;
    _viewModel = [[TContactViewModel alloc] init];
    TUIContactActionCellData *group = [[TUIContactActionCellData alloc] init];
    group.icon = YZChatResource(@"myGrps");
    group.title = @"我的群聊";
    group.cselector = @selector(clickGroupConversation:);

    if (_isInternal) {
        TUIContactActionCellData *contacts = [[TUIContactActionCellData alloc] init];
        contacts.icon = YZChatResource(@"icon_add_contact");
        contacts.title = @"新的好友";
        contacts.cselector = @selector(clickAddNewFriend:);

        TUIContactActionCellData *black = [[TUIContactActionCellData alloc] init];
        black.icon = YZChatResource(@"icon_blackList");
        black.title = @"黑名单";
        black.cselector = @selector(clickBlackList:);

        _firstGroupData = @[contacts, group, black];
    } else {
        _firstGroupData = @[group];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addNotificationCenterObserver];
    [self.viewModel loadContacts];
}

#pragma mark - NSNotificationCenter

- (void)addNotificationCenterObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onFriendListChanged)
                                                 name:TUIKitNotification_onFriendListAdded
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onFriendListChanged)
                                                 name:TUIKitNotification_onFriendListDeleted
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onFriendListChanged)
                                                 name:TUIKitNotification_onFriendInfoUpdate
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onFriendApplicationListChanged)
                                                 name:TUIKitNotification_onFriendApplicationListAdded
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onFriendApplicationListChanged)
                                                 name:TUIKitNotification_onFriendApplicationListDeleted
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onFriendApplicationListChanged)
                                                 name:TUIKitNotification_onFriendApplicationListRead
                                               object:nil];
}

- (void)onFriendListChanged {
    [self.viewModel loadContacts];
}

- (void)onFriendApplicationListChanged {
    [self.viewModel loadFriendApplication];
}

#pragma mark - 用户交互

- (void)subscribe {
    [super subscribe];

    @weakify(self)
    [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(NSNumber *finished) {
        @strongify(self)
        if ([finished boolValue]) {
            [self.tableView reloadData];
        }
    }];

    [[[RACObserve(self, keywords) distinctUntilChanged] throttle: 0.25]
     subscribeNext:^(NSString  *_Nullable keywords) {
        @strongify(self)
        [self searchKeywords: keywords];
    }];

    [RACObserve(self.viewModel, pendencyCnt) subscribeNext:^(NSNumber *count) {
        @strongify(self)
        [self updatePendencyCount: count];
    }];
}

- (void)updatePendencyCount:(NSNumber *)count {
    if (_isInternal) {
        self.firstGroupData[0].readNum = [count integerValue];
    }
}

- (void)clickSearchMyFriends {
    [self.navigationController pushViewController: [[YzSearchMyFriendsViewController alloc] init] animated: YES];
}

/// 新的好友
- (void)clickAddNewFriend:(TCommonTableViewCell *)cell {
    NewFriendViewController *vc = [[NewFriendViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [self.viewModel clearApplicationCnt];
}

/// 我的群聊
- (void)clickGroupConversation:(TCommonTableViewCell *)cell {
    YzGroupConversationListController *viewController = [[YzGroupConversationListController alloc] initWithCustomMessage: _customMessage];
    [self.navigationController pushViewController: viewController animated: YES];
}

/// 黑名单
- (void)clickBlackList:(TCommonContactCell *)cell {
    YUIBlackListViewController *vc = [[YUIBlackListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)selectedFriend:(TCommonContactCell *)cell {
    TCommonContactCellData *data = cell.contactData;
    if (_isInternal) {
        id<TUIFriendProfileControllerServiceProtocol> vieController = [[TCServiceManager shareInstance] createService: @protocol(TUIFriendProfileControllerServiceProtocol)];
        if ([vieController isKindOfClass:[UIViewController class]]) {
            vieController.friendProfile = data.friendProfile;
            vieController.isShowConversationAtTop = YES;
            [self.navigationController pushViewController: (UIViewController *)vieController animated:YES];
        }

        return;
    }


    @weakify(self)
    [[YZMsgManager shareInstance] sendMessageWithMsgType: YZSendMsgTypeC2C message: _customMessage userId: data.friendProfile.userID grpId:nil loginSuccess:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } loginFailed:^(int errCode, NSString *errMsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [THelper makeToastError: errCode msg: errMsg];
        });
    }];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) return self.viewModel.groupList.count + 1;
    return self.searchList.count == 0 ? 0 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchController.tableView) return self.searchList.count;
    if (section == 0) return self.firstGroupData.count;
    NSString *group = self.viewModel.groupList[section-1];
    return self.viewModel.dataDict[group].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchController.tableView) return 0;
    if (section == 0) return 0;
    return 33;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.searchController.tableView) return nil;
    NSMutableArray *array = [NSMutableArray arrayWithObject:@""];
    [array addObjectsFromArray:self.viewModel.groupList];
    return array;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchController.tableView) return nil;
    if (section == 0) return @"";
    return self.viewModel.groupList[section - 1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView && indexPath.section == 0) {
        TUIContactActionCell *cell = [tableView dequeueReusableCellWithIdentifier: kReuseIdentifier_ContactActionCell forIndexPath: indexPath];
        cell.avatarView.mm_width(30).mm_height(30).mm__centerY(27).mm_left(16);
        cell.titleLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
        cell.titleLabel.mm_left(cell.avatarView.mm_maxX+8).mm_height(22).mm__centerY(cell.avatarView.mm_centerY).mm_flexToRight(0);
        [cell fillWithData: self.firstGroupData[indexPath.row]];
        //可以在此处修改，也可以在对应cell的初始化中进行修改。用户可以灵活的根据自己的使用需求进行设。
        cell.changeColorWhenTouched = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }

    TCommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier: kReuseIdentifier_ContactCell forIndexPath:indexPath];

    TCommonContactCellData *data;
    if (tableView == self.tableView) {
        NSString *group = self.viewModel.groupList[indexPath.section-1];
        data = self.viewModel.dataDict[group][indexPath.row];
    } else {
        data = self.searchList[indexPath.row];
        data.responder = self;
    }
    data.cselector = @selector(selectedFriend:);
    [cell fillWithData:data];
    //可以在此处修改，也可以在对应cell的初始化中进行修改。用户可以灵活的根据自己的使用需求进行设置。
    cell.changeColorWhenTouched = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

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

    if (!_isInternal) return;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem cigam_itemWithImage: YZChatResource(@"contact_search") target: self action: @selector(clickSearchMyFriends)];
}

- (void)initSubviews {
    [super initSubviews];

    self.shouldShowSearchBar = YES;
}

- (void)initTableView {
    [super initTableView];

    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    self.tableView.separatorColor = [UIColor colorWithHex: KCommonSeparatorLineColor];
    [self.tableView registerClass: [TCommonContactCell class] forCellReuseIdentifier: kReuseIdentifier_ContactCell];
    [self.tableView registerClass: [TUIContactActionCell class] forCellReuseIdentifier: kReuseIdentifier_ContactActionCell];
}

- (void)initSearchController {
    [super initSearchController];

    self.searchController.searchBar.placeholder = @"昵称/备注";
    self.searchController.launchView = [[UIView alloc] init];
    self.searchController.launchView.backgroundColor = self.searchController.tableView.backgroundColor;
    self.searchController.tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    self.searchController.tableView.separatorColor = [UIColor colorWithHex: KCommonSeparatorLineColor];
    [self.searchController.tableView registerClass: [TCommonContactCell class] forCellReuseIdentifier: kReuseIdentifier_ContactCell];
}

- (void)setupSubviews {
    [super setupSubviews];

    self.titleView.title = _isInternal ? @"通讯录" : @"请选择";
    self.view.backgroundColor = [UIColor colorWithHex: KCommonBackgroundColor];
}

#pragma mark - 数据

- (void)searchKeywords:(NSString *)keywords {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        if (keywords.length > 0) {
            for (TCommonContactCellData *model in self.viewModel.contacts) {
                if ([model.title rangeOfString: keywords options: NSCaseInsensitiveSearch].length >0) {
                    [temp addObject: model];
                }
            }
        }

        if (temp.count == 0 && keywords.length > 0) {
            [self fetchFriendsInfoByMobile: keywords];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.searchList = [temp copy];
        });
    });
}

- (void)setSearchList:(NSArray <TCommonContactCellData *>*)searchList {
    _searchList = searchList;
    if (self.searchController.active) {
        [self.searchController.tableView reloadData];
    }
}

- (void)fetchFriendsInfoByMobile:(NSString *)mobile {
    [YChatNetworkEngine requestFriendsInfoByMobile: mobile completion:^(NSDictionary *result, NSError *error) {
        if (mobile != self.keywords || !self.searchController.isActive) return;
        if (!error && [result[@"code"] intValue] == 200) {
            NSMutableArray *temp = [[NSMutableArray alloc] initWithArray: self.searchList];
            for (NSDictionary *user in result[@"data"]) {
                NSArray *items = user[@"SnsProfileItem"];
                TCommonContactCellData *cellData = [[TCommonContactCellData alloc] init];
                cellData.identifier = user[@"To_Account"];
                V2TIMFriendInfo* info = [[V2TIMFriendInfo alloc] init];
                info.userID = user[@"To_Account"];
                for (NSDictionary* item in items) {
                    if ([item[@"Tag"] isEqualToString:@"Tag_Profile_IM_Nick"]) {
                        cellData.title = item[@"Value"];
                        info.userFullInfo.nickName = item[@"Value"];
                    }
                    if ([item[@"Tag"] isEqualToString:@"Tag_Profile_IM_Image"]) {
                        cellData.avatarUrl = [NSURL URLWithString:item[@"Value"]];
                        info.userFullInfo.faceURL = item[@"Value"];
                    }
                    if ([item[@"Tag"] isEqualToString:@"Tag_SNS_IM_Remark"]) {
                        info.friendRemark = item[@"Value"];
                    }
                }
                cellData.friendProfile = info;
                [temp addObject: cellData];
            }
            self.searchList = [temp copy];
        }
    }];
}

@end
