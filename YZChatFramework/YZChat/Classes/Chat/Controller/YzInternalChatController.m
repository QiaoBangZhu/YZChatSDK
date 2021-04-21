//
//  YzInternalChatController.m
//  YZChat
//
//  Created by 安笑 on 2021/4/17.
//

#import "YzInternalChatController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

#import <ReactiveObjC/ReactiveObjC.h>
#import <MMLayout/UIView+MMLayout.h>

#import "TUIKit.h"
#import "THelper.h"
#import "TCServiceManager.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "TUIGroupPendencyViewModel.h"
#import "TUITextMessageCellData.h"
#import "TUIImageMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIFileMessageCellData.h"
#import "TUIGroupPendencyController.h"
#import "TUnReadView.h"

#import "YzCommonImport.h"
#import "YzExtensions.h"
#import "YZCardMsgView.h"
#import "YZLocationMessageCell.h"

// navigation
#import "YUISelectMemberViewController.h"
#import "YZMapViewController.h"
#import "YZProfileViewController.h"
#import "YGroupInfoController.h"
#import "YUserProfileController.h"
#import "YZMapInfoViewController.h"
#import "YZWebViewController.h"
#import "YUIImageViewController.h"
#import "YUIFileViewController.h"

@interface YzInternalChatController () <TMessageControllerDelegate, TInputControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate> {
    YzChatControllerConfig *_chatConfig;
    YzChatInfo *_chatInfo;
    BOOL _isInternal;
    BOOL _isGroup;
    BOOL _responseKeyboard;
    BOOL _isLoading;
}

@property (nonatomic, strong) TUIConversationCellData *conversationData;
@property (nonatomic, strong) UIView *tipsView;
@property (nonatomic, strong) CIGAMLabel *pendencyLabel;
@property (nonatomic, strong) CIGAMButton *pendencyButton;
@property (nonatomic, strong) TUIGroupPendencyViewModel *pendencyViewModel;
@property (nonatomic, strong) NSMutableArray<UserModel *> *atUserList;
@property (nonatomic, strong) TUnReadView *unreadView;

@end

@implementation YzInternalChatController

#pragma mark - 初始化

- (instancetype)initWithConversation:(TUIConversationCellData *)conversationData {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _conversationData = conversationData;
        NSMutableArray *moreMenus = [[NSMutableArray alloc] init];
        [moreMenus addObject:[TUIInputMoreCellData photoData]];
        [moreMenus addObject:[TUIInputMoreCellData pictureData]];
        [moreMenus addObject:[TUIInputMoreCellData videoData]];
        [moreMenus addObject:[TUIInputMoreCellData fileData]];
        if (([YZBaseManager shareInstance].userInfo.functionPerm & 32)> 0) {
            [moreMenus addObject:[TUIInputMoreCellData videoCallData]];
        }
        if (([YZBaseManager shareInstance].userInfo.functionPerm & 16)> 0) {
            [moreMenus addObject:[TUIInputMoreCellData audioCallData]];
        }
        [moreMenus addObject:[TUIInputMoreCellData locationData]];
        
        _moreMenus = moreMenus;
        _isGroup = conversationData.groupID.length > 0;
        _isInternal = YES;
    }
    return self;
}

- (instancetype)initWithChatInfo:(YzChatInfo *)chatInfo
                          config:(YzChatControllerConfig *)config {
    self = [super initWithNibName:nil bundle:nil];
    _chatInfo = chatInfo;
    _chatConfig = config;
    if (self) {
        NSMutableArray *moreMenus = [[NSMutableArray alloc] init];
        if (!config.disableSendPhotoAction) {
            [moreMenus addObject:[TUIInputMoreCellData photoData]];
        }
        if (!config.disableCaptureAction) {
            [moreMenus addObject:[TUIInputMoreCellData pictureData]];
        }
        if (!config.disableVideoRecordAction) {
            [moreMenus addObject:[TUIInputMoreCellData videoData]];
        }
        if (!config.disableSendFileAction) {
            [moreMenus addObject:[TUIInputMoreCellData fileData]];
        }
        if (!config.disableVideoCall) {
            [moreMenus addObject:[TUIInputMoreCellData videoCallData]];
        }
        if (!config.disableAudioCall) {
            [moreMenus addObject:[TUIInputMoreCellData audioCallData]];
        }
        if (!config.disableSendLocationAction) {
            [moreMenus addObject:[TUIInputMoreCellData locationData]];
        }
        
        _moreMenus = moreMenus;
        _isInternal = NO;
        _isGroup = chatInfo.isGroup;
    }
    [self fetchConversation];
    
    return  self;
}

- (void)didInitialize {
    [super didInitialize];
    
    if (_isGroup) {
        _pendencyViewModel = [[TUIGroupPendencyViewModel alloc] init];
        _pendencyViewModel.groupId = _conversationData.groupID ?: _chatInfo.chatId;
    }
    _atUserList = [[NSMutableArray alloc] init];
    _registeredCustomMessageClass = [[NSMutableDictionary alloc] init];
    _registeredCustomMessageClass[@"YZCardMsgCell"] = [YZCardMsgView class];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNotificationCenterObserver];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _responseKeyboard = YES;
    _isLoading = NO;
    if ([[self.inputController.inputBar getInput] length] > 0) {
        [self.inputController.inputBar refreshTextViewFrame];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _responseKeyboard = NO;
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [self saveDraft];
    }
}

#pragma mark - Public

- (void)registerClass:(nullable Class)viewClass forCustomMessageViewReuseIdentifier:(NSString *)identifier {
    NSAssert([viewClass isSubclassOfClass: [YzCustomMessageView class]], @"自定义消息视图类型，需继承自 YzCustomMessageView");
    _registeredCustomMessageClass[identifier] = viewClass;
    [self.messageController.tableView registerClass: [YzCustomMessageCell class] forCellReuseIdentifier: identifier];
}

- (void)updateInputTextByUsers:(NSArray<UserModel *> *)users {
    NSMutableString *atText = [[NSMutableString alloc] init];
    for (int i = 0; i < users.count; i++) {
        UserModel *user = users[i];
        [self.atUserList addObject: user];
        if (i == 0) {
            [atText appendString:[NSString stringWithFormat:@"%@ ",user.name]];
        } else {
            [atText appendString:[NSString stringWithFormat:@"@%@ ",user.name]];
        }
    }
    NSString *inputText = self.inputController.inputBar.inputTextView.text;
    self.inputController.inputBar.inputTextView.text = [NSString stringWithFormat:@"%@%@ ",inputText,atText];
    [self.inputController.inputBar updateTextViewFrame];
    [self.inputController.inputBar.inputTextView becomeFirstResponder];
}

#pragma mark - NSNotificationCenter

- (void)addNotificationCenterObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRefreshNotification:)
                                                 name:TUIKitNotification_TIMRefreshListener_Changed
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCallingCancel:) name:TUIKitNotification_Call_Cancelled
                                               object:nil];
    if (!_isInternal) return;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getPendencyList) name:TUIKitNotification_onReceiveJoinApplication
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChangeUnReadCount:)
                                                 name:TUIKitNotification_onChangeUnReadCount
                                               object:nil];
}

- (void)onRefreshNotification:(NSNotification *)notify {
    for (V2TIMConversation *conversation in notify.object) {
        if ([conversation.conversationID isEqualToString: self.conversationData.conversationID]) {
            self.conversationData.title = conversation.showName;
            break;
        }
    }
}

- (void)getPendencyList {
    if (_isGroup) {
        [self.pendencyViewModel loadData];
    }
}

- (void)onChangeUnReadCount:(NSNotification *)notify{
    int count = 0;
    for (V2TIMConversation *conversation in notify.object) {
        // 忽略当前会话的未读数
        if (![conversation.conversationID isEqual: self.conversationData.conversationID]) {
            count += conversation.unreadCount;
        }
    }
    [_unreadView setNum: count];
}

- (void)onCallingCancel:(NSNotification *)notify {
    NSString* userId = notify.object[@"uid"];
    if ([userId length] > 0) {
        [self fetchUserInfoById: userId];
    }
}

#pragma mark - 用户交互

- (void)subscribe {
    [super subscribe];

    [self bindConversationTitleObserver];
    @weakify(self)
    [RACObserve(self, moreMenus) subscribeNext:^(NSArray *x) {
        @strongify(self)
        [self.inputController.moreView setData:x];
    }];

    if (!_isInternal) return;
    if (_isGroup) {
        [RACObserve(self.pendencyViewModel, unReadCnt) subscribeNext:^(NSNumber *count) {
            @strongify(self)
            if ([count intValue]) {
                self.pendencyLabel.text = [NSString stringWithFormat:@"%@条入群请求", count];
                [self.pendencyLabel sizeToFit];
                CGFloat gap = (self.tipsView.mm_w - self.pendencyLabel.mm_w - self.pendencyButton.mm_w-8)/2;
                self.pendencyLabel.mm_left(gap).mm__centerY(self.tipsView.mm_h/2);
                self.pendencyButton.mm_hstack(8);
                
                [UIView animateWithDuration:1.f animations:^{
                    self.tipsView.hidden = NO;
                    self.tipsView.mm_top(self.navigationController.navigationBar.mm_maxY);
                }];
            } else {
                self.tipsView.hidden = YES;
            }
        }];
    }
}

- (void)bindConversationTitleObserver {
    [self updateTitleIfNeed];
    @weakify(self)
    [[RACObserve(self.conversationData, title) distinctUntilChanged] subscribeNext:^(NSString *title) {
        @strongify(self)
        self.title = title;
    }];
}

- (void)sendMessage:(TUIMessageCellData *)message {
    [self.messageController sendMessage:message];
}

- (void)openPendency:(CIGAMButton *)button {
    TUIGroupPendencyController *viewController = [[TUIGroupPendencyController alloc] init];
    viewController.viewModel = self.pendencyViewModel;
    [self.navigationController pushViewController: viewController animated:YES];
}

- (void)moreBarButtonClick {
    // 群
    if (_isGroup) {
        YGroupInfoController *groupInfo = [[YGroupInfoController alloc] init];
        groupInfo.groupId = self.conversationData.groupID;
        [self.navigationController pushViewController: groupInfo animated: YES];
        return;
    }
    
    @weakify(self)
    [[V2TIMManager sharedInstance] getFriendList:^(NSArray<V2TIMFriendInfo *> *infoList) {
        @strongify(self)
        for (V2TIMFriendInfo *friend in infoList) {
            if ([friend.userFullInfo.userID isEqualToString:self.conversationData.userID]) {
                id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
                if ([vc isKindOfClass:[UIViewController class]]) {
                    vc.friendProfile = friend;
                    vc.isShowConversationAtTop = YES;
                    vc.isShowGrpEntrance = YES;
                    [self.navigationController pushViewController:(UIViewController *)vc animated: YES];
                    return;
                }
            }
        }
        [[V2TIMManager sharedInstance] getUsersInfo:@[self.conversationData.userID] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            YUserProfileController *vc = [[YUserProfileController alloc] init];
            vc.userFullInfo = infoList.firstObject;
            vc.actionType = PCA_ADD_FRIEND;
            [self.navigationController pushViewController:vc animated:YES];
        } fail:^(int code, NSString *msg) {
            NSLog(@"拉取用户资料失败！");
        }];
    } fail:^(int code, NSString *msg) {
        NSLog(@"拉取好友列表失败！");
    }];
}

#pragma mark - TMessageControllerDelegate

- (void)didTapInMessageController:(TUIMessageController *)controller {
    [self.inputController reset];
}

- (BOOL)messageController:(TUIMessageController *)controller
       willShowMenuInCell:(TUIMessageCell *)cell {
    if([self.inputController.inputBar.inputTextView isFirstResponder]){
        self.inputController.inputBar.inputTextView.overrideNextResponder = cell;
        return YES;
    }
    return NO;
}

- (TUIMessageCellData *)messageController:(TUIMessageController *)controller
                             onNewMessage:(V2TIMMessage *)data {
    if (data.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        NSDictionary *param = [YZUtil jsonData2Dictionary: data.customElem.data];
        if (param) {
            NSString *businessID = param[@"businessID"];
            NSString *text = param[@"title"];
            NSString *link = param[@"link"];
            if (text.length == 0 || link.length == 0) {
                return nil;
            }
            if ([businessID isEqualToString: CardLink]) {
                YzCustomMessageCellData *cellData = [[YzCustomMessageCellData alloc] initWithMessage: data];
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
            YzCustomMessageData *custom = [self.dataSource customMessageForData: data.customElem.data];
            if (custom) {
                YzCustomMessageCellData *cellData = [[YzCustomMessageCellData alloc] initWithMessage: data];
                cellData.customMessageData = custom;
                return cellData;
            }
        }
    }
    return nil;
}

- (TUIMessageCell *)messageController:(TUIMessageController *)controller
                    onShowMessageData:(TUIMessageCellData *)data {
    if ([data isKindOfClass: [YZLocationMessageCellData class]]) {
        YzCustomMessageCell *cell = [controller.tableView dequeueReusableCellWithIdentifier: LocationMessageCell_ReuseId];

        [cell fillWithData: data];
        return cell;
    }
    // 自定义
    else if ([data isKindOfClass:[YzCustomMessageCellData class]]) {
        Class viewClass = _registeredCustomMessageClass[data.reuseId];
        YzCustomMessageCell *cell = [controller.tableView dequeueReusableCellWithIdentifier: data.reuseId];
        cell.customViewClass = viewClass;
        [cell.customView fillWithData: ((YzCustomMessageCellData *)data).customMessageData];
        [cell fillWithData: data];
        return cell;
    }
    return nil;
}

- (void)messageController:(TUIMessageController *)controller onSelectMessageAvatar:(TUIMessageCell *)cell {
    if (cell.messageData.identifier == nil) return;
    
    if ([self.delegate respondsToSelector:@selector(onUserIconClick:)]) {
        if ([self.delegate onUserIconClick: cell.messageData.identifier]) return;
    }
    if (_isLoading) return;
    _isLoading = YES;
    @weakify(self)
    [[V2TIMManager sharedInstance] getFriendsInfo:@[cell.messageData.identifier] succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
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
            [[V2TIMManager sharedInstance] getUsersInfo:@[cell.messageData.identifier] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
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

- (void)messageController:(TUIMessageController *)controller onSelectMessageContent:(TUIMessageCell *)cell {
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
                [self.delegate onSelectedCustomMessageView: [(YzCustomMessageCell *)cell customView]];
            }
        }
    }
}

- (void)didHideMenuInMessageController:(TUIMessageController *)controller {
    self.inputController.inputBar.inputTextView.overrideNextResponder = nil;
}

- (void)showImageMessage:(TUIImageMessageCell *)cell {
    YUIImageViewController *image = [[YUIImageViewController alloc] init];
    image.data = [cell imageData];
    [self.navigationController pushViewController: image animated: YES];
}

- (void)showFileMessage:(TUIFileMessageCell *)cell {
    YUIFileViewController *file = [[YUIFileViewController alloc] init];
    file.data = [cell fileData];
    [self.navigationController pushViewController: file animated: YES];
}

#pragma mark - TInputControllerDelegate

- (void)inputController:(TUIInputController *)inputController didChangeHeight:(CGFloat)height {
    if (!_responseKeyboard) return;
    
    @weakify(self);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        @strongify(self);
        CGRect msgFrame = self.messageController.view.frame;
        msgFrame.size.height = self.view.frame.size.height - height;
        self.messageController.view.frame = msgFrame;
        
        CGRect inputFrame = self.inputController.view.frame;
        inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
        inputFrame.size.height = height;
        self.inputController.view.frame = inputFrame;
        [self.messageController scrollToBottom:NO];
    } completion:nil];
}

- (void)inputController:(TUIInputController *)inputController didSendMessage:(TUIMessageCellData *)msg {
    if ([msg isKindOfClass:[TUITextMessageCellData class]]) {
        NSMutableArray *userIDList = [NSMutableArray array];
        for (UserModel *model in self.atUserList) {
            [userIDList addObject:model.userId];
        }
        if (userIDList.count > 0) {
            [msg setAtUserList:userIDList];
        }
        //消息发送完后 atUserList 要重置
        [self.atUserList removeAllObjects];
    }
    [self.messageController sendMessage:msg];
}

- (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell {
    if (cell.data == [TUIInputMoreCellData photoData]) {
        [self selectPhotoForSend];
    } else if (cell.data == [TUIInputMoreCellData videoData]) {
        [self takeVideoForSend];
    } else if (cell.data == [TUIInputMoreCellData fileData]) {
        [self selectFileForSend];
    } else if (cell.data == [TUIInputMoreCellData pictureData]) {
        [self takePictureForSend];
    } else if (cell.data == [TUIInputMoreCellData videoCallData]) {
        [self videoCall];
    } else if (cell.data == [TUIInputMoreCellData audioCallData]) {
        [self audioCall];
    } else if (cell.data == [TUIInputMoreCellData locationData]) {
        [self sendLocation];
    } else if ([cell.data.title isEqualToString:@"发送卡片"]) {
        [self sendCard];
    }
}

- (void)inputControllerDidInputAt:(TUIInputController *)inputController {
    // 检测到 @ 字符的输入
    if (_isGroup) {
        // 自定义@
        if ([self.delegate respondsToSelector: @selector(onAtGroupMember)]) {
            if([self.delegate onAtGroupMember]) return;
        }
        YUISelectMemberViewController *selectViewController = [[YUISelectMemberViewController alloc] init];
        selectViewController.groupId = self.conversationData.groupID;
        selectViewController.name = @"选择提醒人";
        selectViewController.optionalStyle = TUISelectMemberOptionalStyleAtAll;
        @weakify(self)
        selectViewController.selectedFinished = ^(NSMutableArray<UserModel *> * _Nonnull modelList) {
            @strongify(self)
            [self updateInputTextByUsers: modelList];
        };
        [self.navigationController pushViewController:selectViewController animated:YES];
    }
}

- (void)inputController:(TUIInputController *)inputController didDeleteAt:(NSString *)atText {
    // 删除了 @ 信息，atText 格式为：@xxx空格
    for (UserModel *user in self.atUserList) {
        if ([atText rangeOfString:user.name].location != NSNotFound) {
            [self.atUserList removeObject:user];
            break;
        }
    }
}

- (void)selectPhotoForSend {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)takePictureForSend {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraCaptureMode =UIImagePickerControllerCameraCaptureModePhoto;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)takeVideoForSend {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    picker.videoMaximumDuration = 15;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)selectFileForSend {
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeData] inMode: UIDocumentPickerModeOpen];
    picker.allowsMultipleSelection = NO;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)videoCall {
    if (![[TUICallManager shareInstance] checkAudioAuthorization] || ![[TUICallManager shareInstance] checkVideoAuthorization]) {
        [THelper makeToast:@"请开启麦克风和摄像头权限"];
        return;
    }
    
    [[TUICallManager shareInstance] call: self.conversationData.groupID userID: self.conversationData.userID callType: CallType_Video];
}

- (void)audioCall {
    if (![[TUICallManager shareInstance] checkAudioAuthorization]) {
        [THelper makeToast:@"请开启麦克风权限"];
        return;
    }
    
    [[TUICallManager shareInstance] call: self.conversationData.groupID userID: self.conversationData.userID callType: CallType_Audio];
}

- (void)sendLocation {
    YZMapViewController* map = [[YZMapViewController alloc]init];
    @weakify(self)
    map.locationBlock = ^(NSString *name, NSString *address, double latitude, double longitude) {
        @strongify(self)
        [self.navigationController popToViewController: self animated: YES];
        YZLocationMessageCellData* cellData = [[YZLocationMessageCellData alloc] initWithDirection: MsgDirectionOutgoing];
        cellData.text = [NSString stringWithFormat: @"%@##%@", name, address];
        cellData.latitude = latitude;
        cellData.longitude = longitude;
        [self sendMessage:cellData];
        [self.messageController scrollToBottom: NO];
    };
    [self.navigationController pushViewController: map animated: YES];
}

- (void)sendCard {
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
    [self sendMessage:cellData];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // 快速点的时候会回调多次
    @weakify(self)
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:YES completion:^{
        @strongify(self)
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageOrientation imageOrientation = image.imageOrientation;
            if(imageOrientation != UIImageOrientationUp)
            {
                CGFloat aspectRatio = MIN ( 1920 / image.size.width, 1920 / image.size.height );
                CGFloat aspectWidth = image.size.width * aspectRatio;
                CGFloat aspectHeight = image.size.height * aspectRatio;
                
                UIGraphicsBeginImageContext(CGSizeMake(aspectWidth, aspectHeight));
                [image drawInRect:CGRectMake(0, 0, aspectWidth, aspectHeight)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            NSData *data = UIImageJPEGRepresentation(image, 0.75);
            NSString *path = [TUIKit_Image_Path stringByAppendingString:[THelper genImageName:nil]];
            [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
            
            TUIImageMessageCellData *uiImage = [[TUIImageMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
            uiImage.path = path;
            uiImage.length = data.length;
            [self sendMessage:uiImage];
            
            //            if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
            //                [self.delegate chatController:self didSendMessage:uiImage];
            //            }
        }
        else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
            NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
            
            if(![url.pathExtension  isEqual: @"mp4"]) {
                NSString* tempPath = NSTemporaryDirectory();
                NSURL *urlName = [url URLByDeletingPathExtension];
                NSURL *newUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@%@.mp4", tempPath,[urlName.lastPathComponent stringByRemovingPercentEncoding]]];
                // mov to mp4
                AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
                AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
                exportSession.outputURL = newUrl;
                exportSession.outputFileType = AVFileTypeMPEG4;
                exportSession.shouldOptimizeForNetworkUse = YES;
                
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    switch ([exportSession status])
                    {
                        case AVAssetExportSessionStatusFailed:
                            NSLog(@"Export session failed");
                            break;
                        case AVAssetExportSessionStatusCancelled:
                            NSLog(@"Export canceled");
                            break;
                        case AVAssetExportSessionStatusCompleted:
                        {
                            //Video conversion finished
                            NSLog(@"Successful!");
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self sendVideoWithUrl:newUrl];
                            });
                        }
                            break;
                        default:
                            break;
                    }
                }];
            } else {
                [self sendVideoWithUrl:url];
            }
        }
    }];
}

- (void)sendVideoWithUrl:(NSURL*)url {
    NSData *videoData = [NSData dataWithContentsOfURL:url];
    NSString *videoPath = [NSString stringWithFormat:@"%@%@.mp4", TUIKit_Video_Path, [THelper genVideoName:nil]];
    [[NSFileManager defaultManager] createFileAtPath:videoPath contents:videoData attributes:nil];
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset =  [AVURLAsset URLAssetWithURL:url options:opts];
    NSInteger duration = (NSInteger)urlAsset.duration.value / urlAsset.duration.timescale;
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
    gen.appliesPreferredTrackTransform = YES;
    gen.maximumSize = CGSizeMake(192, 192);
    NSError *error = nil;
    CMTime actualTime;
    CMTime time = CMTimeMakeWithSeconds(0.0, 10);
    CGImageRef imageRef = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imagePath = [TUIKit_Video_Path stringByAppendingString:[THelper genSnapshotName:nil]];
    [[NSFileManager defaultManager] createFileAtPath:imagePath contents:imageData attributes:nil];
    
    TUIVideoMessageCellData *message = [[TUIVideoMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    message.snapshotPath = imagePath;
    message.snapshotItem = [[TUISnapshotItem alloc] init];
    UIImage *snapshot = [UIImage imageWithContentsOfFile:imagePath];
    message.snapshotItem.size = snapshot.size;
    message.snapshotItem.length = imageData.length;
    message.videoPath = videoPath;
    message.videoItem = [[TUIVideoItem alloc] init];
    message.videoItem.duration = duration;
    message.videoItem.length = videoData.length;
    message.videoItem.type = url.pathExtension;
    message.uploadProgress = 0;
    if (duration <= 0) {
        [THelper makeToast: @"视频太短"];
        return;
    }
    [self sendMessage:message];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (!urls.count) return;
    
    NSURL *url = urls[0];
    [url startAccessingSecurityScopedResource];
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] init];
    NSError *error;
    @weakify(self)
    [coordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
        @strongify(self)
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        NSString *fileName = [url lastPathComponent];
        NSString *filePath = [TUIKit_File_Path stringByAppendingString:fileName];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileData attributes:nil];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
            TUIFileMessageCellData *message = [[TUIFileMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
            message.path = filePath;
            message.fileName = fileName;
            message.length = (int)fileSize;
            message.uploadProgress = 0;
            [self sendMessage: message];
        }
    }];
    [url stopAccessingSecurityScopedResource];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 页面布局

- (void)setupNavigationItems {
    [super setupNavigationItems];
    if (!_isInternal) return;
    
    UIBarButtonItem *unreadBarItem = [[UIBarButtonItem alloc] initWithCustomView: self.unreadView];
    self.navigationItem.leftBarButtonItems = @[unreadBarItem];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem cigam_itemWithImage: YZChatResource(@"more_nav") target: self action: @selector(moreBarButtonClick)];
}

- (void)initSubviews {
    [super initSubviews];
    
    self.messageController = [[TUIMessageController alloc] init];
    self.inputController = [[TUIInputController alloc] init];
    
    if (!_isInternal) return;
    
    self.unreadView = [[TUnReadView alloc] init];
    if (_isGroup) {
        self.tipsView = [[UIView alloc] init];
        self.pendencyLabel = [[CIGAMLabel alloc] init];
        self.pendencyButton = [[CIGAMButton alloc] init];
    }
}

- (void)setupSubviews {
    [super setupSubviews];

    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    [self configMessageCellData];
    
    //message
    self.messageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight);
    self.messageController.delegate = self;
    [self addChildViewController: self.messageController];
    [self.view addSubview: self.messageController.view];
    [self.messageController.tableView registerClass:[YZLocationMessageCell class] forCellReuseIdentifier: LocationMessageCell_ReuseId];
    for (NSString *key in _registeredCustomMessageClass) {
        [self registerClass: _registeredCustomMessageClass[key] forCustomMessageViewReuseIdentifier: key];
    }
    
    //input
    self.inputController.view.frame = CGRectMake(0, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight, self.view.frame.size.width, TTextView_Height + Bottom_SafeHeight);
    self.inputController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.inputController.delegate = self;
    [self addChildViewController: self.inputController];
    [self.view addSubview: self.inputController.view];
    
    if (_chatConfig.disableChatInput) {
        self.messageController.view.frame = self.view.bounds;
        self.inputController.view.hidden = YES;
    }
    if (self.conversationData) {
        [self.messageController setConversation: self.conversationData];
        self.inputController.inputBar.inputTextView.text = self.conversationData.draftText;
    }
    
    if (!_isInternal)  return;
    
    self.unreadView.backgroundColor = UIColorGray;
    if (_isGroup) {
        self.tipsView.backgroundColor = RGB(246, 234, 190);
        [self.view addSubview: self.tipsView];
        self.tipsView.mm_height(24).mm_width(self.view.mm_w);
        
        [self.tipsView addSubview: self.pendencyLabel];
        self.pendencyLabel.font = UIFontMake(12);
        
        [self.tipsView addSubview: self.pendencyButton];
        [self.pendencyButton setTitle:@"点击处理" forState:UIControlStateNormal];
        [self.pendencyButton.titleLabel setFont: UIFontMake(12)];
        [self.pendencyButton addTarget: self action:@selector(openPendency:) forControlEvents: UIControlEventTouchUpInside];
        [self.pendencyButton sizeToFit];
        self.tipsView.hidden = YES;
    }
}

- (void)configMessageCellData {
    [TUIBubbleMessageCellData setOutgoingBubble: [self bubbleImageForName: @"SenderTextNodeBkg"]];
    [TUIBubbleMessageCellData setOutgoingHighlightedBubble: [self bubbleImageForName: @"SenderTextNodeBkg"]];
    [TUIBubbleMessageCellData setIncommingBubble: [self bubbleImageForName: @"ReceiverTextNodeBkg"]];
    [TUIBubbleMessageCellData setIncommingHighlightedBubble: [self bubbleImageForName: @"ReceiverTextNodeBkg"]];
    [TUITextMessageCellData setOutgoingTextColor: UIColorBlack];
    [TUITextMessageCellData setIncommingTextColor: UIColorBlack];
}

#pragma mark - 数据

/// 获取会话信息
- (void)fetchConversation {
    NSString *conversationId = [(_chatInfo.isGroup ? @"group_" : @"c2c_") stringByAppendingString: _chatInfo.chatId];
    @weakify(self)
    [[V2TIMManager sharedInstance] getConversation: conversationId succ:^(V2TIMConversation *conv) {
        @strongify(self)
        TUIConversationCellData *data = [TUIConversationCellData makeDataByConversation: conv];
        self.conversationData = data;
        [self bindConversationTitleObserver];
        [self.messageController setConversation: data];
        self.inputController.inputBar.inputTextView.text = data.draftText;
        [self getPendencyList];
    } fail:^(int code, NSString *desc) {
        [THelper makeToastError: code msg: desc];
    }];
}

- (void)fetchUserInfoById:(NSString *)userId {
    [YChatNetworkEngine requestUserInfoWithUserId: userId completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"]intValue] == 200) {
                YUserInfo* info = [YUserInfo yy_modelWithDictionary:result[@"data"]];
                [THelper makeToast:[NSString stringWithFormat:@"%@ 取消了通话",info.nickName]];
            }else {
                [CIGAMTips showError: result[@"msg"]];
            }
        }
    }];
}

- (void)updateTitleIfNeed {
    if (self.conversationData.title.length > 0) return;
    if (self.conversationData.userID.length > 0) {
        self.conversationData.title = self.conversationData.userID;
        @weakify(self)
        [[V2TIMManager sharedInstance] getFriendsInfo:@[self.conversationData.userID] succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
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
    // 群
    else if (self.conversationData.groupID.length > 0) {
        self.conversationData.title = self.conversationData.groupID;
        @weakify(self)
        [[V2TIMManager sharedInstance] getGroupsInfo:@[self.conversationData.groupID] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
            @strongify(self)
            V2TIMGroupInfoResult *result = groupResultList.firstObject;
            if (result.info && result.info.groupName.length > 0) {
                self.conversationData.title = result.info.groupName;
            }
        } fail:nil];
    }
}

#pragma mark - Helper

- (void)saveDraft {
    NSString *draft = self.inputController.inputBar.inputTextView.text;
    draft = [draft stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceAndNewlineCharacterSet];
    [[V2TIMManager sharedInstance] setConversationDraft: self.conversationData.conversationID draftText:draft succ:nil fail:nil];
}

- (UIImage *)bubbleImageForName:(NSString *)name {
    return [YZChatResource(name) resizableImageWithCapInsets: UIEdgeInsetsMake(30, 20, 22, 20) resizingMode: UIImageResizingModeStretch];
}

@end
