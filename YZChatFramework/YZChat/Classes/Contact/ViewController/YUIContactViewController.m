//
//  YUIContactViewController.m
//  YChat
//
//  Created by magic on 2020/10/11.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YUIContactViewController.h"
#import "THeader.h"
#import "TUIKit.h"
#import "NSString+TUICommon.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TUIBlackListController.h"
#import "YUIBlackListViewController.h"
#import "TUINewFriendViewController.h"
#import "NewFriendViewController.h"
#import "YUIGroupConversationListController.h"

#import "TUIConversationListController.h"
#import "TUIChatController.h"
#import "TUIGroupConversationListController.h"
#import "TUIContactActionCell.h"
#import "UIColor+TUIDarkMode.h"
#import "UIColor+ColorExtension.h"
#import <Masonry/Masonry.h>
#import "CIGAMKit.h"

#import <ImSDKForiOS/ImSDK.h>
#import "NSBundle+YZBundle.h"
#import "CommonConstant.h"
#import "YZCardMsgData.h"
#import "YZUtil.h"
#import "TUICallUtils.h"
#import "TUISystemMessageCellData.h"
#import "THelper.h"
#import "YZMsgManager.h"

#define kContactCellReuseId @"ContactCellReuseId"
#define kContactActionCellReuseId @"ContactActionCellReuseId"

@interface YUIContactViewController () <UITableViewDelegate,UITableViewDataSource,TUIConversationListControllerDelegate>
@property NSArray<TUIContactActionCellData *> *firstGroupData;

@end

@implementation YUIContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSMutableArray *list = @[].mutableCopy;
    if (_isFromOtherApp) {
        [list addObject:({
            TUIContactActionCellData *data = [[TUIContactActionCellData alloc] init];
            data.icon = YZChatResource(@"myGrps");
            data.title = @"我的群聊";
            data.cselector = @selector(onGroupConversation:);
            data;
        })];
    }else {
        [list addObject:({
            TUIContactActionCellData *data = [[TUIContactActionCellData alloc] init];
            UIImage* image = YZChatResource(@"icon_add_contact") ;
            data.icon = image;
            data.title = @"新的好友";
            data.cselector = @selector(onAddNewFriend:);
            data;
        })];
        [list addObject:({
            TUIContactActionCellData *data = [[TUIContactActionCellData alloc] init];
            data.icon = YZChatResource(@"myGrps");
            data.title = @"我的群聊";
            data.cselector = @selector(onGroupConversation:);
            data;
        })];
        [list addObject:({
            TUIContactActionCellData *data = [[TUIContactActionCellData alloc] init];
            data.icon = YZChatResource(@"icon_blackList");
            data.title = @"黑名单";
            data.cselector = @selector(onBlackList:);
            data;
        })];
    }
    
    self.firstGroupData = [NSArray arrayWithArray:list];

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    [_tableView setSectionIndexColor:[UIColor colorWithHex:KCommonlittleLightGrayColor]];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorColor = [UIColor colorWithHex:KCommonSepareteLineColor];
    [self.view addSubview:_tableView];
     
    //cell无数据时，不显示间隔线
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:v];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 58, 0, 0);
    [_tableView registerClass:[TCommonContactCell class] forCellReuseIdentifier:kContactCellReuseId];
    [_tableView registerClass:[TUIContactActionCell class] forCellReuseIdentifier:kContactActionCellReuseId];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFriendListChanged) name:TUIKitNotification_onFriendListAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFriendListChanged) name:TUIKitNotification_onFriendListDeleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFriendListChanged) name:TUIKitNotification_onFriendInfoUpdate object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFriendApplicationListChanged) name:TUIKitNotification_onFriendApplicationListAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFriendApplicationListChanged) name:TUIKitNotification_onFriendApplicationListDeleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFriendApplicationListChanged) name:TUIKitNotification_onFriendApplicationListRead object:nil];
    
    @weakify(self)
    [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(id finished) {
        @strongify(self)
        if ([(NSNumber *)finished boolValue]) {
            [self.tableView reloadData];
        }
    }];
    [RACObserve(self.viewModel, pendencyCnt) subscribeNext:^(NSNumber *x) {
        self.firstGroupData[0].readNum = [x integerValue];
    }];
    [_viewModel loadContacts];
}

- (TContactViewModel *)viewModel
{
    if (_viewModel == nil) {
        _viewModel = [TContactViewModel new];
    }
    return _viewModel;
}


- (void)onFriendListChanged {
    [_viewModel loadContacts];
}

- (void)onFriendApplicationListChanged {
    [_viewModel loadFriendApplication];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return self.viewModel.groupList.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.firstGroupData.count;
    } else {
        NSString *group = self.viewModel.groupList[section-1];
        NSArray *list = self.viewModel.dataDict[group];
        return list.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return nil;

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
    label.text = self.viewModel.groupList[section-1];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return 0;
    }

    return 33;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *array = [NSMutableArray arrayWithObject:@""];
    [array addObjectsFromArray:self.viewModel.groupList];
    return array;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TUIContactActionCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactActionCellReuseId forIndexPath:indexPath];
        cell.avatarView.mm_width(30).mm_height(30).mm__centerY(27).mm_left(16);
        cell.titleLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
        cell.titleLabel.mm_left(cell.avatarView.mm_maxX+8).mm_height(22).mm__centerY(cell.avatarView.mm_centerY).mm_flexToRight(0);
        [cell fillWithData:self.firstGroupData[indexPath.row]];
        //可以在此处修改，也可以在对应cell的初始化中进行修改。用户可以灵活的根据自己的使用需求进行设。
        cell.changeColorWhenTouched = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    } else {
        TCommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactCellReuseId forIndexPath:indexPath];
        NSString *group = self.viewModel.groupList[indexPath.section-1];
        NSArray *list = self.viewModel.dataDict[group];
        TCommonContactCellData *data = list[indexPath.row];
        data.cselector = @selector(onSelectFriend:);
        [cell fillWithData:data];
        //可以在此处修改，也可以在对应cell的初始化中进行修改。用户可以灵活的根据自己的使用需求进行设置。
        cell.changeColorWhenTouched = YES;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

- (void)sendCardMsgFromOtherAppWithData:(TUIConversationCellData*)cdata {
      @weakify(self)
     [[YZMsgManager shareInstance]sendMessageWithMsgType:YZSendMsgTypeC2C message:self.customMsg userId:cdata.userID grpId:nil loginSuccess:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
     } loginFailed:^(int errCode, NSString *errMsg) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [THelper makeToastError:errCode msg:errMsg];
         });
     }];
}

- (void)onSelectFriend:(TCommonContactCell *)cell
{
    TCommonContactCellData *data = cell.contactData;
    if (_isFromOtherApp) {
        TUIConversationCellData *cdata = [[TUIConversationCellData alloc] init];
        cdata.conversationID = [NSString stringWithFormat:@"c2c_%@",@""];
        cdata.userID = data.friendProfile.userID;
        cdata.title = [data.friendProfile.userFullInfo showName];
        [self sendCardMsgFromOtherAppWithData:cdata];
        return;
    }

    id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
    if ([vc isKindOfClass:[UIViewController class]]) {
        vc.friendProfile = data.friendProfile;
        vc.isShowConversationAtTop = YES;
        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
    }
}

- (void)onAddNewFriend:(TCommonTableViewCell *)cell
{
    NewFriendViewController *vc = NewFriendViewController.new;
    [self.navigationController pushViewController:vc animated:YES];
    [self.viewModel clearApplicationCnt];
}

- (void)onGroupConversation:(TCommonTableViewCell *)cell
{
    YUIGroupConversationListController *vc = YUIGroupConversationListController.new;
    vc.isFromOtherApp = _isFromOtherApp;
    vc.customMsg = self.customMsg;
    vc.title = @"群聊";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onBlackList:(TCommonContactCell *)cell
{
    YUIBlackListViewController *vc = YUIBlackListViewController.new;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)conversationListController:(TUIConversationListController *)conversationController didSelectConversation:(TUIConversationCell *)conversation;
{
    TUIChatController *chat = [[TUIChatController alloc] initWithConversation:conversation.convData];
    chat.title = conversation.convData.title;
    [self.navigationController pushViewController:chat animated:YES];
}


- (void)runSelector:(SEL)selector withObject:(id)object{
    if([self respondsToSelector:selector]){
        //因为 TCommonCell中写了 [vc performSelector:self.data.cselector withObject:self]，所以此处不管有无参数，和父类逻辑保持一致进行传参，防止意外情况
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL, id) = (void *)imp;
        func(self, selector, object);
    }
}

@end
