//
//  YzChatController.m
//  YZChat
//
//  Created by 安笑 on 2021/4/9.
//

#import "YzChatController.h"

#import <ImSDKForiOS/ImSDK.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "THelper.h"
#import "THeader.h"
#import "TUITextMessageCellData.h"

#import "YUIChatController.h"
#import "CommonConstant.h"
#import "NSBundle+YZBundle.h"
#import "UIColor+ColorExtension.h"
#import "TUIConversationCellData+Conversation.h"
#import "YZUtil.h"
#import "YZMapViewController.h"
#import "YZLocationMessageCell.h"
#import "YZMapInfoViewController.h"
#import "YZWebViewController.h"
#import "YzCustomMessageCell.h"
#import "YzCustomMessageCellData.h"
#import "YzCustomMsg.h"
#import "YZCardMsgCell.h"

@implementation YzChatInfo

- (instancetype)initWithChatId:(NSString *)chatId
                      chatName:(NSString *)chatName
                       isGroup:(BOOL)isGroup {
    self = [super init];
    if (self) {
        _chatId = chatId;
        _chatName = chatName;
        _isGroup = isGroup;
    }
    return self;
}

@end

@implementation YzChatControllerConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _disableSendPhotoAction = NO;
        _disableCaptureAction = NO;
        _disableVideoRecordAction = NO;
        _disableSendFileAction = NO;
        _disableSendLocationAction = NO;
        _disableAudioCall = YES;
        _disableVideoCall = YES;
        _disableChatInput = NO;
    }
    return self;
}

@end

@interface RegisteredCustomMessageClasses : NSObject

@property (nonatomic, assign) Class viewClass;
@property (nonatomic, assign) Class dataClass;

@end

@implementation RegisteredCustomMessageClasses
@end

@interface YzChatController () <YUIChatControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate> {
    YzChatInfo *_chatInfo;
    YzChatControllerConfig *_chatConfig;
    NSMutableDictionary <NSString *, RegisteredCustomMessageClasses *> * _registeredCustomMessageClass;
}

@property (nonatomic, strong) TUIConversationCellData *conversationCellData;
@property (nonatomic, strong) YUIChatController *chatController;

@end

@implementation YzChatController

- (instancetype)initWithChatInfo:(YzChatInfo *)chatInfo
                          config:(nullable YzChatControllerConfig *)config {
    self = [super init];
    if (self) {
        _chatInfo = chatInfo;
        _chatConfig = config ?: [[YzChatControllerConfig alloc] init];
        _registeredCustomMessageClass = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _chatInfo.chatName;
    [self setupChatController];
    [self registerViewClass: [YZCardMsgView class] forDataClass: [YZCardMsgData self]];
}

- (void)setupChatController {
    self.chatController.delegate = self;
    [self addChildViewController: self.chatController];
    [self.view addSubview: self.chatController.view];
    self.chatController.messageController.tableView.backgroundColor = [UIColor colorWithHex: KCommonChatBgColor];
    for (NSString * key in _registeredCustomMessageClass) {
        [self.chatController.messageController.tableView registerClass: [YzCustomMessageCell class]
                                                forCellReuseIdentifier: key];
    }
    
    [TUIBubbleMessageCellData setOutgoingBubble:[YZChatResource(@"SenderTextNodeBkg") resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 22, 20) resizingMode:UIImageResizingModeStretch]];
    
    [TUIBubbleMessageCellData setOutgoingHighlightedBubble:[YZChatResource(@"SenderTextNodeBkg") resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 22, 20) resizingMode:UIImageResizingModeStretch]];
    
    [TUIBubbleMessageCellData setIncommingBubble:[YZChatResource(@"ReceiverTextNodeBkg") resizableImageWithCapInsets:UIEdgeInsetsMake(30, 22, 22, 22) resizingMode:UIImageResizingModeStretch]];
    [TUIBubbleMessageCellData setIncommingHighlightedBubble:[YZChatResource(@"ReceiverTextNodeBkg") resizableImageWithCapInsets:UIEdgeInsetsMake(30, 22, 22, 22) resizingMode:UIImageResizingModeStretch]];
    
    // 设置发送文字消息的字体和颜色；设置接收的方法类似
    [TUITextMessageCellData setOutgoingTextColor:[UIColor blackColor]];
    
    [TUITextMessageCellData setIncommingTextColor:[UIColor blackColor]];
}

#pragma mark - Public

- (void)updateInputTextByNames:(NSArray<NSString *> *)names
                           ids:(NSArray<NSString *> *)ids {
    NSUInteger count = MIN(ids.count, ids.count);
    NSMutableArray *users = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++) {
        UserModel *user = [[UserModel alloc] init];
        user.userId = ids[i];
        user.name = names[i];
        user.avatar = @"";
    }
    [self.chatController updateInputTextByUsers: users];
}

- (void)registerViewClass:(Class)viewClass forDataClass:(Class)dataClass {
    NSAssert([viewClass isSubclassOfClass: [YzCustomMessageView class]],
             @"自定义消息视图类型，需继承自 YzCustomMessageView");
    NSAssert([dataClass isSubclassOfClass: [YzCustomMessageData class]],
             @"自定义消息数据类型，需继承自 YzCustomMessageData");
    RegisteredCustomMessageClasses *classes = [[RegisteredCustomMessageClasses alloc] init];
    classes.viewClass = viewClass;
    classes.dataClass = dataClass;
    NSString *key = NSStringFromClass(dataClass);
    _registeredCustomMessageClass[key] = classes;
    [self.chatController.messageController.tableView registerClass: [YzCustomMessageCell class]
                                            forCellReuseIdentifier: key];
}

- (YUIChatController *)chatController {
    if (!_chatController) {
        _chatController = [[YUIChatController alloc] initWithChatInfo: _chatInfo config: _chatConfig];
    }

    return  _chatController;
}

#pragma mark - YUIChatControllerDelegate

- (void)chatController:(YUIChatController *)controller
        didSendMessage:(TUIMessageCellData *)msgCellData {
}

- (void)chatController:(YUIChatController *)chatController
      onSelectMoreCell:(TUIInputMoreCell *)cell {
    if ([cell.data.title isEqualToString:@"发送卡片"]) {
        NSString *text = @"元信IM生态工具元信";//IM生态工具元信IM生态工具元信IM生态工具元信IM生态工具
        NSString *link = @"http://yzmsri.com/";
        NSString *desc = @"欢迎加入元信大家庭！欢迎加入元信大家庭！欢迎加入元信大家庭！欢迎加入元信大家庭！";
        NSString * logo = @"https://yzkj-im.oss-cn-beijing.aliyuncs.com/user/16037885020911603788500745.png";
        YzCustomMessageCellData *cellData = [[YzCustomMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
        YZCardMsgData *msg = [[YZCardMsgData alloc] init];
        msg.title = text;
        msg.link = link;
        msg.des = desc;
        msg.logo = logo;
        cellData.customMessageData = msg;
        cellData.innerMessage = [[V2TIMManager sharedInstance] createCustomMessage:[YZUtil dictionary2JsonData:@{@"version": @(TextLink_Version),@"businessID": CardLink,@"title":text,@"link":link,@"desc":desc, @"logo": logo}]];
        [chatController sendMessage:cellData];
        
    }else if([cell.data.title isEqualToString:@"发送位置"]) {
        YZMapViewController* map = [[YZMapViewController alloc]init];
        @weakify(self)
        [self.navigationController pushViewController:map animated:YES];
        map.locationBlock = ^(NSString *name, NSString *address, double latitude, double longitude) {
            @strongify(self)
            [self.navigationController popToViewController:self animated:YES];
            YZLocationMessageCellData* cellData = [[YZLocationMessageCellData alloc]initWithDirection:MsgDirectionOutgoing];
            cellData.text = [NSString stringWithFormat:@"%@##%@",name,address];
            cellData.latitude = latitude;
            cellData.longitude = longitude;
            [chatController sendMessage:cellData];
            [chatController.messageController scrollToBottom:NO];
        };
    }
}

- (TUIMessageCellData *)chatController:(YUIChatController *)controller
                          onNewMessage:(V2TIMMessage *)msg {
    /// 自定义消息
    if (msg.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        NSDictionary *param = [YZUtil jsonData2Dictionary: msg.customElem.data];
        if (param) {
            NSString *businessID = param[@"businessID"];
            NSString *text = param[@"title"];
            NSString *link = param[@"link"];
            if (text.length == 0 || link.length == 0) {
                return nil;
            }
            if ([businessID isEqualToString:CardLink]) {
                YzCustomMessageCellData *cellData = [[YzCustomMessageCellData alloc] initWithMessage: msg];
                YZCardMsgData *custom = [[YZCardMsgData alloc] init];
                custom.title = text;
                custom.des = param[@"desc"];
                custom.link = link;
                custom.logo = param[@"logo"];
                cellData.customMessageData = custom;
                return cellData;
            }
        }
        // 用户自定
        else if (self.dataSource && [self.dataSource respondsToSelector: @selector(customMessageForData:)]) {
            YzCustomMessageData *custom = [self.dataSource customMessageForData: msg.customElem.data];
            if (custom) {
                YzCustomMessageCellData *cellData = [[YzCustomMessageCellData alloc] initWithMessage: msg];
                cellData.customMessageData = custom;
                return cellData;
            }
        }
    }
    return nil;
}

- (TUIMessageCell *)chatController:(YUIChatController *)controller
                 onShowMessageData:(TUIMessageCellData *)data {
    if ([data isKindOfClass:[YzCustomMessageCellData class]]) {
        Class viewClass = _registeredCustomMessageClass[data.reuseId].viewClass;
        YzCustomMessageCell *cell = [controller.messageController.tableView
                                     dequeueReusableCellWithIdentifier: data.reuseId];
        cell.customerViewClass = viewClass;
        [cell.customerView fillWithData: ((YzCustomMessageCellData *)data).customMessageData];
        [cell fillWithData: data];
        return cell;
    }

    return nil;
}

- (void)chatController:(YUIChatController *)controller onSelectMessageContent:(TUIMessageCell *)cell {
    if ([cell isKindOfClass:[YZLocationMessageCell class]]) {
        YZLocationMessageCellData* data = [(YZLocationMessageCell *)cell locationData];
        YZMapInfoViewController* map = [[YZMapInfoViewController alloc]init];
        map.locationData = data;
        [self.navigationController pushViewController:map animated:YES];
    }
    // 自定义消息
    else if ([cell isKindOfClass:[YzCustomMessageCell class]]) {
        YzCustomMessageCellData *cellData = (YzCustomMessageCellData *)cell.messageData;
        if ([cellData.customMessageData isKindOfClass: [YZCardMsgData class]]) {
            YZCardMsgData *msg = (YZCardMsgData *)cellData.customMessageData;
            if (msg.link) {
                YZWebViewController* web = [[YZWebViewController alloc]init];
                web.url = [NSURL URLWithString: msg.link];
                [self.navigationController pushViewController:web animated:YES];
            }
        }
        // 用户自定义
        else {
            if (self.delegate && [self.delegate respondsToSelector: @selector(onSelectedCustomMessageView:)]) {
                [self.delegate onSelectedCustomMessageView: [(YzCustomMessageCell *)cell customerView]];
            }
        }
    }
}

- (BOOL)chatController:(YUIChatController *)controller onSelectMessageAvatar:(TUIMessageCell *)cell {
    if ([self.delegate respondsToSelector: @selector(onUserIconClick:)]) {
        [self.delegate onUserIconClick: cell.messageData.identifier];
        return YES;
    }

    return NO;
}

- (BOOL)onAtGroupMember {
    if ([self.delegate respondsToSelector: @selector(onAtGroupMember)]) {
        return [self.delegate onAtGroupMember];
    }

    return NO;
}

@end
