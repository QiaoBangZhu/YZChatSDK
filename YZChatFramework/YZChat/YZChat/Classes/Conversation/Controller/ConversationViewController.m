//
//  ConversationViewController.m
//  YChat
//
//  Created by magic on 2020/9/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "ConversationViewController.h"
#import "THeader.h"
#import "YPopView.h"
#import "YPopCell.h"
#import "TNaviBarIndicatorView.h"
#import "YUIConversationListController.h"
#import "TUIKit.h"
#import "THelper.h"
#import "ReactiveObjC/ReactiveObjC.h"

//#import <ImSDK/ImSDK.h>
#import <ImSDKForiOS/ImSDK.h>

#import "ChatViewController.h"
#import "ContactSelectViewController.h"
#import "SearchFriendViewController.h"
#import "YChatNetworkEngine.h"
#import "YChatIMCreateGroupMemberInfo.h"
#import "SearchViewController.h"
#import "FriendProfileViewController.h"
#import "GroupInfoController.h"
#import "ContactSearchViewController.h"
//#import "AppDelegate.h"
#import "TUITabBarController.h"
#import "UIColor+ColorExtension.h"
#import "SearchBarView.h"
#import <Masonry/Masonry.h>
#import "UIBarButtonItem+Extensions.h"
#import "SearchMyFriendsViewController.h"
#import "SearchConversationViewController.h"
#import "QRScanViewController.h"
#import "YChatSettingStore.h"

@interface ConversationViewController ()<YUIConversationListControllerDelegate, YPopViewDelegate,UISearchBarDelegate>
@property (nonatomic, strong) TNaviBarIndicatorView *titleview;
@property (nonatomic, strong) YUIConversationListController* listController;
@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupNavigation];
}


- (void)setupView {
    YUIConversationListController *conv = [[YUIConversationListController alloc] init];
    conv.delegate = self;
    [self addChildViewController:conv];
    [self.view addSubview:conv.view];
    self.listController = conv;
    
    SearchBarView* searchBarView = [[SearchBarView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 52)];
    searchBarView.placeholder = @"昵称/备注/群昵称";
    searchBarView.isShowCancle = NO;
    searchBarView.isCanEdit = NO;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(searchAction)];
    [searchBarView addGestureRecognizer:tap];
    
    [conv.view addSubview:searchBarView];
    [conv.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.bottom.equalTo(@0);
        make.top.equalTo(searchBarView.mas_bottom);
    }];
    
    //如果不加这一行代码，依然可以实现点击反馈，但反馈会有轻微延迟，体验不好。
    conv.tableView.delaysContentTouches = NO;
    conv.tableView.separatorColor = [UIColor colorWithHex:KCommonSepareteLineColor];
    conv.tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    conv.tableView.contentInset = UIEdgeInsetsZero;

//    if (([[YChatSettingStore sharedInstance]getfunctionPerm] & 2) > 0) {
        UIBarButtonItem* moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addFriend_icon"] target:self action:@selector(rightBarButtonClick:)];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceItem.width = -15;
        self.navigationItem.rightBarButtonItems =  @[spaceItem,moreItem];
//    }
  
//    @weakify(self)
//    [RACObserve(conv.viewModel, dataList) subscribeNext:^(id  _Nullable x) {
//        @strongify(self)
//        self.searchResult.viewModel = conv.viewModel;
//    }];
//
    //添加未读计数的监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChangeUnReadCount:)
                                                 name:TUIKitNotification_onChangeUnReadCount
                                               object:nil];
}

- (void) onChangeUnReadCount:(NSNotification *)notifi{
//    NSMutableArray *convList = (NSMutableArray *)notifi.object;
//    int unReadCount = 0;
//    for (V2TIMConversation *conv in convList) {
//        unReadCount += conv.unreadCount;
//    }
//    TUITabBarItem* item = app.tabController.tabBarItems[0];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (unReadCount > 0) {
//            if (unReadCount > 99) {
//                item.controller.tabBarItem.badgeValue = @"99+";
//            }else {
//                item.controller.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)unReadCount];
//            }
//        }else {
//            item.controller.tabBarItem.badgeValue = nil;
//        }
//    });
}

/**
 *初始化导航栏
 */
- (void)setupNavigation
{
//    self.titleview = [[TNaviBarIndicatorView alloc] init];
//    [self.titleview setTitle:@"元信"];
//    self.navigationItem.titleView = self.titleview;
    self.titleName = @"消息";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkChanged:) name:TUIKitNotification_TIMConnListener object:nil];
}

/**
 *初始化导航栏Title，不同连接状态下Title显示内容不同
 */
- (void)onNetworkChanged:(NSNotification *)notification
{
    TUINetStatus status = (TUINetStatus)[notification.object intValue];
    switch (status) {
        case TNet_Status_Succ:
//            [self.titleView setTitle:@"元信"];
//            [self.titleview stopAnimating];
            self.titleName = @"消息";
            break;
        case TNet_Status_Connecting:
//            [self.titleView setTitle:@"连接中..."];
//            [self.titleview startAnimating];
            self.titleName = @"连接中...";
            break;
        case TNet_Status_Disconnect:
//            [self.titleView setTitle:@"元信(未连接)"];
//            [self.titleview stopAnimating];
            self.titleName = @"消息(未连接)";
            break;
        case TNet_Status_ConnFailed:
//            [self.titleView setTitle:@"元信(未连接)"];
//            [self.titleview stopAnimating];
            self.titleName = @"消息(未连接)";
            break;

        default:
            break;
    }
}

/**
 *在消息列表内，点击了某一具体会话后的响应函数
 */
- (void)conversationListController:(YUIConversationListController *)conversationController didSelectConversation:(TUIConversationCell *)conversation
{
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversationData = conversation.convData;
    [self.navigationController pushViewController:chat animated:YES];
}

/**
 *推送默认跳转
 */
- (void)pushToChatViewController:(NSString *)groupID userID:(NSString *)userID {
    ChatViewController *chat = [[ChatViewController alloc] init];
    TUIConversationCellData *conversationData = [[TUIConversationCellData alloc] init];
    conversationData.groupID = groupID;
    conversationData.userID = userID;
    chat.conversationData = conversationData;
    [self.navigationController pushViewController:chat animated:YES];
}

/**
 *对导航栏右侧的按钮（即视图右上角按钮）进行初始化，创建对应的popView
 */
- (void)rightBarButtonClick:(UIButton *)rightBarButton
{
    NSMutableArray *menus = [NSMutableArray array];
    YPopCellData *friend = [[YPopCellData alloc] init];
    friend.title = @"添加好友";
    [menus addObject:friend];

    YPopCellData *group = [[YPopCellData alloc] init];
    group.title = @"发起群聊";
    [menus addObject:group];
    
    YPopCellData *scan = [[YPopCellData alloc] init];
    scan.title = @"扫一扫";
    [menus addObject:scan];

    CGFloat height = [YPopCell getHeight] * menus.count + TPopView_Arrow_Size.height;
    CGFloat orginY = StatusBar_Height + NavBar_Height;
    YPopView *popView = [[YPopView alloc] initWithFrame:CGRectMake(Screen_Width - 145, orginY, 135, height)];
//    CGRect frameInNaviView = [self.navigationController.view convertRect:rightBarButton.frame fromView:rightBarButton.superview];
    popView.arrowPoint = CGPointMake(Screen_Width-16-11, orginY);
    popView.delegate = self;
    [popView setData:menus];
    [popView showInWindow:self.view.window];
}

/**
 *点击了popView中具体某一行后的响应函数，popView初始化请参照上述 rightBarButtonClick: 函数
 */
- (void)popView:(YPopView *)popView didSelectRowAtIndex:(NSInteger)index
{
    @weakify(self)
    if(index == 0){
        //添加好友
        SearchMyFriendsViewController *add = [[SearchMyFriendsViewController alloc] init];
        [self.navigationController pushViewController:add animated:YES];
        return;
    }
    else if(index == 1){
       //创建群聊
      ContactSelectViewController *vc = [ContactSelectViewController new];
      vc.title = @"选择联系人";
      [self.navigationController pushViewController:vc animated:YES];
      vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *array) {
          @strongify(self)//GroupType_Work
          [self addGroup:@"Private" addOption:V2TIM_GROUP_ADD_ANY withContacts:array];
      };
      return;
    }else if (index == 2){
        QRScanViewController* qrVc = [[QRScanViewController alloc]init];
        qrVc.title = @"扫一扫";
        [self.navigationController pushViewController:qrVc animated:YES];
    }
    
    else {
        return;
    }
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

                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                [tempArray removeObjectAtIndex:tempArray.count-2];
                self.navigationController.viewControllers = tempArray;
            }else {
                [THelper makeToast:result[@"msg"]];
            }
        }
    }];
}

- (void)searchAction {
    SearchConversationViewController* searchVc = [[SearchConversationViewController alloc]init];
    searchVc.dataArray = [self.listController.viewModel.dataList mutableCopy];
    [self.navigationController pushViewController:searchVc animated:YES];
}



@end
