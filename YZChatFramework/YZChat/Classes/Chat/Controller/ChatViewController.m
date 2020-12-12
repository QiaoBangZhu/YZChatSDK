//
//  ChatViewController.m
//  YChat
//
//  Created by magic on 2020/9/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "ChatViewController.h"
#import "GroupInfoController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "TUIVideoMessageCell.h"
#import "TUIFileMessageCell.h"
#import "TUITextMessageCell.h"
#import "TUISystemMessageCell.h"
#import "TUIVoiceMessageCell.h"
#import "TUIImageMessageCell.h"
#import "TUIFaceMessageCell.h"
#import "TUIVideoMessageCell.h"
#import "TUIFileMessageCell.h"
#import "UserProfileController.h"
#import <ImSDKForiOS/TIMFriendshipManager.h>
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "MyCustomCell.h"
#import "TCUtil.h"
#import "THelper.h"
#import "TCConstants.h"
#import "MyCustomCellData.h"
#import "UIColor+ColorExtension.h"
#import "YChatNetworkEngine.h"
#import "UserInfo.h"
#import <QMUIKit/QMUIKit.h>
#import "MapViewController.h"
#import "LocationMessageCellData.h"
#import "LocationMessageCell.h"
#import "MapInfoViewController.h"
#import "CardMsgCell.h"
#import "CardMsgCellData.h"
#import "WebViewController.h"

// MLeaksFinder 会对这个类误报，这里需要关闭一下
@implementation UIImagePickerController (Leak)

- (BOOL)willDealloc {
    return NO;
}

@end


@interface ChatViewController ()<YUIChatControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate>
@property (nonatomic, strong) YUIChatController *chat;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _chat = [[YUIChatController alloc] initWithConversation:self.conversationData];
    _chat.delegate = self;
    
    [self addChildViewController:_chat];
    [self.view addSubview:_chat.view];
    _chat.messageController.tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    
    RAC(self, title) = [RACObserve(_conversationData, title) distinctUntilChanged];
    [self checkTitle];

//    NSMutableArray *moreMenus = [NSMutableArray arrayWithArray:_chat.moreMenus];
//    [moreMenus addObject:({
//        TUIInputMoreCellData *data = [TUIInputMoreCellData new];
//        data.image = [UIImage imageNamed:@"more_location"];
//        data.title = @"发送卡片";
//        data;
//    })];
//    _chat.moreMenus = moreMenus;

    [self setupNavigator];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRefreshNotification:)
                                                 name:TUIKitNotification_TIMRefreshListener_Changed
                                               object:nil];

    //添加未读计数的监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChangeUnReadCount:)
                                                 name:TUIKitNotification_onChangeUnReadCount
                                               object:nil];
    //呼叫方主动取消呼叫的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallingCancel:) name:TUIKitNotification_Call_Cancled object:nil];
    
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPopNotify) name:@"POPTOCONVERSIONLIISTNOTIFY" object:nil];
        
    
    [TUIBubbleMessageCellData setOutgoingBubble:[[UIImage imageNamed:@"SenderTextNodeBkg"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 22, 20) resizingMode:UIImageResizingModeStretch]];

    [TUIBubbleMessageCellData setOutgoingHighlightedBubble:[[UIImage imageNamed:@"SenderTextNodeBkg"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 22, 20) resizingMode:UIImageResizingModeStretch]];

    [TUIBubbleMessageCellData setIncommingBubble:[[UIImage imageNamed:@"ReceiverTextNodeBkg"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 22, 22, 22) resizingMode:UIImageResizingModeStretch]];
    [TUIBubbleMessageCellData setIncommingHighlightedBubble:[[UIImage imageNamed:@"ReceiverTextNodeBkg"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 22, 22, 22) resizingMode:UIImageResizingModeStretch]];
//
    // 设置发送文字消息的字体和颜色；设置接收的方法类似
    [TUITextMessageCellData setOutgoingTextColor:[UIColor whiteColor]];
}

- (void)onCallingCancel:(NSNotification *)noti {
    NSDictionary* dic = (NSDictionary *)noti.object;
    NSString* userId = dic[@"uid"];
    if ([userId length] > 0) {
        [self fetchUserInfoByUserId:userId];
    }
}

- (void)fetchUserInfoByUserId:(NSString *)userId {
    [YChatNetworkEngine requestUserInfoWithUserId:userId completion:^(NSDictionary *result, NSError *error) {
       if (!error) {
           if ([result[@"code"]intValue] == 200) {
               UserInfo* info = [UserInfo yy_modelWithDictionary:result[@"data"]];
               [THelper makeToast:[NSString stringWithFormat:@"%@ 取消了通话",info.nickName]];
           }else {
               [QMUITips showError: result[@"msg"]];
           }
       }
    }];
}

- (void)onPopNotify {
    [self.navigationController popToRootViewControllerAnimated:true];
}


- (void)checkTitle {
    if (_conversationData.title.length == 0) {
        if (_conversationData.userID.length > 0) {
            _conversationData.title = _conversationData.userID;
             @weakify(self)
            [[V2TIMManager sharedInstance] getFriendsInfo:@[_conversationData.userID] succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
                @strongify(self)
                V2TIMFriendInfoResult *result = resultList.firstObject;
                if (result.friendInfo && result.friendInfo.friendRemark.length > 0) {
                    self.conversationData.title = result.friendInfo.friendRemark;
                } else {
                    [[V2TIMManager sharedInstance] getUsersInfo:@[self.conversationData.userID] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                        V2TIMUserFullInfo *info = infoList.firstObject;
                        if (info && info.nickName.length > 0) {
                            self.conversationData.title = info.nickName;
                        }
                    } fail:nil];
                }
            } fail:nil];
        }
        if (_conversationData.groupID.length > 0) {
            _conversationData.title = _conversationData.groupID;
             @weakify(self)
            [[V2TIMManager sharedInstance] getGroupsInfo:@[_conversationData.groupID] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
                @strongify(self)
                V2TIMGroupInfoResult *result = groupResultList.firstObject;
                if (result.info && result.info.groupName.length > 0) {
                    self.conversationData.title = result.info.groupName;
                }
            } fail:nil];
        }
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil) {
        [_chat saveDraft];
    }
}

// 聊天窗口标题由上层维护，需要自行设置标题
- (void)onRefreshNotification:(NSNotification *)notifi
{
    NSArray<V2TIMConversation *> *convs = notifi.object;
    for (V2TIMConversation *conv in convs) {
        if ([conv.conversationID isEqualToString:self.conversationData.conversationID]) {
            self.conversationData.title = conv.showName;
            break;
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNavigator
{
    //left
    _unRead = [[TUnReadView alloc] init];
    //可通过此处将未读标记设置为灰色，类似微信，但目前仍使用红色未读视图
    _unRead.backgroundColor = [UIColor grayColor];
    UIBarButtonItem *urBtn = [[UIBarButtonItem alloc] initWithCustomView:_unRead];
    self.navigationItem.leftBarButtonItems = @[urBtn];
    //既显示返回按钮，又显示未读视图
    self.navigationItem.leftItemsSupplementBackButton = YES;

    //right，根据当前聊天页类型设置右侧按钮格式
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    if(_conversationData.userID.length > 0){
        [rightButton setImage:[UIImage imageNamed:@"more_nav"] forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [rightButton setImage:[UIImage imageNamed:@"more_nav"] forState:UIControlStateHighlighted];
    }
    else if(_conversationData.groupID.length > 0){
        [rightButton setImage:[UIImage imageNamed:@"more_nav"] forState:UIControlStateNormal];
        [rightButton setImage:[UIImage imageNamed:@"more_nav"] forState:UIControlStateHighlighted];
    }
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItems = @[rightItem];
}

-(void)leftBarButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonClick
{
    //当前为用户和用户之间通信时，右侧按钮响应为用户信息视图入口
    if (_conversationData.userID.length > 0) {
        @weakify(self)
        [[V2TIMManager sharedInstance] getFriendList:^(NSArray<V2TIMFriendInfo *> *infoList) {
            @strongify(self)
            for (V2TIMFriendInfo *firend in infoList) {
                if ([firend.userFullInfo.userID isEqualToString:self.conversationData.userID]) {
                    id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
                    if ([vc isKindOfClass:[UIViewController class]]) {
                        vc.friendProfile = firend;
                        vc.isShowConversationAtTop = YES;
                        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
                        return;
                    }
                }
            }
            [[V2TIMManager sharedInstance] getUsersInfo:@[self.conversationData.userID] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                UserProfileController *myProfile = [[UserProfileController alloc] init];
                myProfile.userFullInfo = infoList.firstObject;
                myProfile.actionType = PCA_ADD_FRIEND;
                [self.navigationController pushViewController:myProfile animated:YES];
            } fail:^(int code, NSString *msg) {
                NSLog(@"拉取用户资料失败！");
            }];
        } fail:^(int code, NSString *msg) {
            NSLog(@"拉取好友列表失败！");
        }];

    //当前为群组通信时，右侧按钮响应为群组信息入口
    } else {
        GroupInfoController *groupInfo = [[GroupInfoController alloc] init];
        groupInfo.groupId = _conversationData.groupID;
        [self.navigationController pushViewController:groupInfo animated:YES];
    }
}

- (void)chatController:(YUIChatController *)controller didSendMessage:(TUIMessageCellData *)msgCellData
{
    //  to do
}

- (void)chatController:(YUIChatController *)chatController onSelectMoreCell:(TUIInputMoreCell *)cell
{
    if ([cell.data.title isEqualToString:@"发送卡片"]) {
        NSString *text = @"元信IM生态工具元信";//IM生态工具元信IM生态工具元信IM生态工具元信IM生态工具
        NSString *link = @"http://yzmsri.com/";
        NSString *desc = @"欢迎加入元信大家庭！欢迎加入元信大家庭！欢迎加入元信大家庭！欢迎加入元信大家庭！";
        NSString * logo = @"https://yzkj-im.oss-cn-beijing.aliyuncs.com/user/16037885020911603788500745.png";
        CardMsgCellData *cellData = [[CardMsgCellData alloc] initWithDirection:MsgDirectionOutgoing];
        cellData.title = text;
        cellData.link = link;
        cellData.des = desc;
        cellData.logo = logo;
        cellData.innerMessage = [[V2TIMManager sharedInstance] createCustomMessage:[TCUtil dictionary2JsonData:@{@"version": @(TextLink_Version),@"businessID": CardLink,@"title":text,@"link":link,@"desc":desc, @"logo": logo}]];
        [chatController sendMessage:cellData];
//        MapViewController* mapvc = [[MapViewController alloc]init];
//        @weakify(self)
//        [self.navigationController pushViewController:mapvc animated:true];
//        mapvc.locationBlock = ^(NSString *name, NSString *address, double latitude, double longitude) {
//            @strongify(self)
//            LocationMessageCellData* cellData = [[LocationMessageCellData alloc]initWithDirection:MsgDirectionOutgoing];
//            cellData.text = [NSString stringWithFormat:@"%@##%@",name,address];
//            cellData.latitude = latitude;
//            cellData.longitude = longitude;
//            [chatController sendMessage:cellData];
//            [self.navigationController popToViewController:self animated:YES];
//        };
    }else if([cell.data.title isEqualToString:@"发送位置"]) {
        MapViewController* mapvc = [[MapViewController alloc]init];
        @weakify(self)
        [self.navigationController pushViewController:mapvc animated:YES];
        mapvc.locationBlock = ^(NSString *name, NSString *address, double latitude, double longitude) {
            @strongify(self)
            [self.navigationController popToViewController:self animated:YES];
            LocationMessageCellData* cellData = [[LocationMessageCellData alloc]initWithDirection:MsgDirectionOutgoing];
            cellData.text = [NSString stringWithFormat:@"%@##%@",name,address];
            cellData.latitude = latitude;
            cellData.longitude = longitude;
            [chatController sendMessage:cellData];
            [chatController.messageController scrollToBottom:NO];
        };
    }
}

- (TUIMessageCellData *)chatController:(TUIChatController *)controller onNewMessage:(V2TIMMessage *)msg
{
    if (msg.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        NSDictionary *param = [TCUtil jsonData2Dictionary:msg.customElem.data];
        if (param != nil) {
            NSInteger version = [param[@"version"] integerValue];
            NSString *businessID = param[@"businessID"];
            NSString *text = param[@"title"];
            NSString *link = param[@"link"];
            if (text.length == 0 || link.length == 0) {
                return nil;
            }
            if ([businessID isEqualToString:CardLink]) {
                if (version <= TextLink_Version) {
                    CardMsgCellData *cellData = [[CardMsgCellData alloc] initWithDirection:msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
                    cellData.innerMessage = msg;
                    cellData.msgID = msg.msgID;
                    cellData.title = param[@"title"];
                    cellData.des = param[@"desc"];
                    cellData.link = param[@"link"];
                    cellData.logo = param[@"logo"];
                    cellData.avatarUrl = [NSURL URLWithString:msg.faceURL];
                    return cellData;
                }
            } else {
                // 兼容下老版本
                CardMsgCellData *cellData = [[CardMsgCellData alloc] initWithDirection:msg.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
                cellData.innerMessage = msg;
                cellData.msgID = msg.msgID;
                cellData.title = param[@"title"];
                cellData.link = param[@"link"];
                cellData.des = param[@"desc"];
                cellData.logo = param[@"logo"];
                cellData.avatarUrl = [NSURL URLWithString:msg.faceURL];
                return cellData;
            }
        }
    }
    return nil;
}

- (TUIMessageCell *)chatController:(TUIChatController *)controller onShowMessageData:(TUIMessageCellData *)data
{
    if ([data isKindOfClass:[MyCustomCellData class]]) {
        MyCustomCell *myCell = [[MyCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyCell"];
        [myCell fillWithData:(MyCustomCellData *)data];
        return myCell;
    }else if ([data isKindOfClass:[CardMsgCellData class]]) {
        CardMsgCell *cell = [[CardMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CardMsgCell"];
        [cell fillWithData:(CardMsgCellData *)data];
        return cell;
    }
    return nil;
}

- (void)chatController:(TUIChatController *)controller onSelectMessageContent:(TUIMessageCell *)cell
{
    if ([cell isKindOfClass:[MyCustomCell class]]) {
        MyCustomCellData *cellData = [(MyCustomCell *)cell customData];
        if (cellData.link) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cellData.link]];
        }
    }else if ([cell isKindOfClass:[LocationMessageCell class]]) {
        LocationMessageCellData* data = [(LocationMessageCell *)cell locationData];
        MapInfoViewController* mapvc = [[MapInfoViewController alloc]init];
        mapvc.locationData = data;
        [self.navigationController pushViewController:mapvc animated:YES];
    }else if ([cell isKindOfClass:[CardMsgCell class]]) {
        CardMsgCellData* cellData = [(CardMsgCell *)cell msgData];
        if (cellData.link) {
            WebViewController* webvc = [[WebViewController alloc]init];
            webvc.url = [NSURL URLWithString:cellData.link];
            [self.navigationController pushViewController:webvc animated:YES];
        }
    }
}

- (void) onChangeUnReadCount:(NSNotification *)notifi{
    NSMutableArray *convList = (NSMutableArray *)notifi.object;
    int unReadCount = 0;
    for (V2TIMConversation *conv in convList) {
        // 忽略当前会话的未读数
        if (![conv.conversationID isEqual:self.conversationData.conversationID]) {
            unReadCount += conv.unreadCount;
        }
    }
    [_unRead setNum:unReadCount];
}
///此处可以修改导航栏按钮的显示位置，但是无法修改响应位置，暂时不建议使用
- (void)resetBarItemSpacesWithController:(UIViewController *)viewController {
    CGFloat space = 16;
    for (UIBarButtonItem *buttonItem in viewController.navigationItem.leftBarButtonItems) {
        if (buttonItem.customView == nil) { continue; }
        /// 根据实际情况(自己项目UIBarButtonItem的层级)获取button
        UIButton *itemBtn = nil;
        if ([buttonItem.customView isKindOfClass:[UIButton class]]) {
            itemBtn = (UIButton *)buttonItem.customView;
        }
        /// 设置button图片/文字偏移
        itemBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -space,0, 0);
        itemBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -space,0, 0);
        itemBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -space,0, 0);
        /// 改变button事件响应区域
        // itemBtn.hitEdgeInsets = UIEdgeInsetsMake(0, -space, 0, space);
    }
    for (UIBarButtonItem *buttonItem in viewController.navigationItem.rightBarButtonItems) {
        if (buttonItem.customView == nil) { continue; }
        UIButton *itemBtn = nil;
        if ([buttonItem.customView isKindOfClass:[UIButton class]]) {
            itemBtn = (UIButton *)buttonItem.customView;
        }
        itemBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0,0, -space);
        itemBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0,0, -space);
        itemBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0,0, -space);
        //itemBtn.hitEdgeInsets = UIEdgeInsetsMake(0, space, 0, -space);
    }
}

- (void)sendMessage:(TUIMessageCellData*)msg {
    [_chat sendMessage:msg];
}

//- (void)chatController:(TUIChatController *)controller onSelectMessageAvatar:(TUIMessageCell *)cell
//{
//
//}

@end
