//
//  YUIChatController.m
//  YChat
//
//  Created by magic on 2020/10/16.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YUIChatController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

#import "THeader.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TUIGroupPendencyViewModel.h"
#import "TUITextMessageCellData.h"
#import "TUIImageMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIFileMessageCellData.h"
#import "TUIGroupPendencyController.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "THelper.h"
#import "UIColor+TUIDarkMode.h"
#import "TUICallManager.h"

#import "YUIMessageController.h"
#import "YZProfileViewController.h"
#import "YZMapViewController.h"
#import "YZLocationMessageCellData.h"
#import "YChatDocumentPickerViewController.h"
#import "YUISelectMemberViewController.h"
#import "YZBaseManager.h"
#import "TUIConversationCellData+Conversation.h"

@interface YUIChatController ()<YMessageControllerDelegate, TInputControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate> {
    YzChatControllerConfig *_chatConfig;
    YzChatInfo *_chatInfo;
}
@property (nonatomic, strong) TUIConversationCellData *conversationData;
@property (nonatomic, strong) UIView *tipsView;
@property (nonatomic, strong) UILabel *pendencyLabel;
@property (nonatomic, strong) UIButton *pendencyBtn;
@property (nonatomic, strong) UIButton *atBtn;
@property (nonatomic, strong) TUIGroupPendencyViewModel *pendencyViewModel;
@property (nonatomic, strong) NSMutableArray<UserModel *> *atUserList;
@property (nonatomic, assign) BOOL responseKeyboard;
@property (nonatomic, assign) BOOL isLoading;

@end

@implementation YUIChatController

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

        if (conversationData.groupID.length > 0) {
            _pendencyViewModel = [[TUIGroupPendencyViewModel alloc] init];
            _pendencyViewModel.groupId = _conversationData.groupID;
        }

        _atUserList = [[NSMutableArray alloc] init];
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

        if (chatInfo.isGroup) {
            _pendencyViewModel = [[TUIGroupPendencyViewModel alloc] init];
            _pendencyViewModel.groupId = chatInfo.chatId;
        }

        _atUserList = [[NSMutableArray alloc] init];
    }
    [self fetchConversation];

    return  self;
}

/// 获取会话信息
- (void)fetchConversation {
    NSString *conversationId = [(_chatInfo.isGroup ? @"group_" : @"c2c_") stringByAppendingString: _chatInfo.chatId];
    @weakify(self)
    [[V2TIMManager sharedInstance] getConversation: conversationId succ:^(V2TIMConversation *conv) {
        @strongify(self)
        TUIConversationCellData *data = [TUIConversationCellData makeDataByConversation: conv];
        self.conversationData = data;
        [self.messageController setConversation: data];
        self.inputController.inputBar.inputTextView.text = data.draftText;
        [self getPendencyList];
    } fail:^(int code, NSString *desc) {
        [THelper makeToastError: code msg: desc];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.responseKeyboard = YES;
    self.isLoading = NO;
    if ([[self.inputController.inputBar getInput] length] > 0) {
        [self.inputController.inputBar refreshTextViewFrame];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.responseKeyboard = NO;
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [self saveDraft];
    }
}

- (void)setupViews {
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];

    @weakify(self)
    //message
    _messageController = [[YUIMessageController alloc] init];
    _messageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight);
    _messageController.delegate = self;
    [self addChildViewController:_messageController];
    [self.view addSubview:_messageController.view];

    //input
    _inputController = [[TUIInputController alloc] init];
    _inputController.view.frame = CGRectMake(0, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight, self.view.frame.size.width, TTextView_Height + Bottom_SafeHeight);
    if (_chatConfig.disableChatInput) {
        _messageController.view.frame = self.view.bounds;
        _inputController.view.hidden = YES;
    }
    _inputController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _inputController.delegate = self;
    [RACObserve(self, moreMenus) subscribeNext:^(NSArray *x) {
        @strongify(self)
        [self.inputController.moreView setData:x];
    }];
    [self addChildViewController:_inputController];
    [self.view addSubview:_inputController.view];

    if (self.conversationData) {
        [self.messageController setConversation: self.conversationData];
        self.inputController.inputBar.inputTextView.text = self.conversationData.draftText;
    }
    self.tipsView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tipsView.backgroundColor = RGB(246, 234, 190);
    [self.view addSubview:self.tipsView];
    self.tipsView.mm_height(24).mm_width(self.view.mm_w);

    self.pendencyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.tipsView addSubview:self.pendencyLabel];
    self.pendencyLabel.font = [UIFont systemFontOfSize:12];


    self.pendencyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.tipsView addSubview:self.pendencyBtn];
    [self.pendencyBtn setTitle:@"点击处理" forState:UIControlStateNormal];
    [self.pendencyBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.pendencyBtn addTarget:self action:@selector(openPendency:) forControlEvents:UIControlEventTouchUpInside];
    [self.pendencyBtn sizeToFit];
    self.tipsView.hidden = YES;
    

    [RACObserve(self.pendencyViewModel, unReadCnt) subscribeNext:^(NSNumber *unReadCnt) {
        @strongify(self)
        if ([unReadCnt intValue]) {
            self.pendencyLabel.text = [NSString stringWithFormat:@"%@条入群请求", unReadCnt];
            [self.pendencyLabel sizeToFit];
            CGFloat gap = (self.tipsView.mm_w - self.pendencyLabel.mm_w - self.pendencyBtn.mm_w-8)/2;
            self.pendencyLabel.mm_left(gap).mm__centerY(self.tipsView.mm_h/2);
            self.pendencyBtn.mm_hstack(8);

            [UIView animateWithDuration:1.f animations:^{
                self.tipsView.hidden = NO;
                self.tipsView.mm_top(self.navigationController.navigationBar.mm_maxY);
            }];
        } else {
            self.tipsView.hidden = YES;
        }
    }];
    [self getPendencyList];
    
    //监听入群请求通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPendencyList) name:TUIKitNotification_onReceiveJoinApplication object:nil];
    
    //群 @ ,UI 细节比较多，放在二期实现
    //    if (self.conversationData.groupID.length > 0 && self.conversationData.atMsgSeqList.count > 0) {
    //        self.atBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.mm_w - 100, 100, 100, 40)];
    //        [self.atBtn setTitle:@"有人@我" forState:UIControlStateNormal];
    //        [self.atBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //        [self.atBtn setBackgroundColor:[UIColor whiteColor]];
    //        [self.atBtn addTarget:self action:@selector(loadMessageToAT) forControlEvents:UIControlEventTouchUpInside];
    //        [self.view addSubview:_atBtn];
    //    }
}

- (void)getPendencyList {
    if (self.conversationData.groupID.length > 0) [self.pendencyViewModel loadData];
}

- (void)openPendency:(id)sender {
    TUIGroupPendencyController *vc = [[TUIGroupPendencyController alloc] init];
    vc.viewModel = self.pendencyViewModel;
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)inputController:(TUIInputController *)inputController didChangeHeight:(CGFloat)height {
    if (!self.responseKeyboard) return;

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
    [_messageController sendMessage:msg];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
        [self.delegate chatController:self didSendMessage:msg];
    }
}

- (void)inputControllerDidInputAt:(TUIInputController *)inputController {
    // 检测到 @ 字符的输入
    if (_conversationData.groupID.length > 0) {
        // 自定义@
        if ([self.delegate respondsToSelector: @selector(onAtGroupMember)]) {
            if ([self.delegate onAtGroupMember]) return;
        }
        YUISelectMemberViewController *vc = [[YUISelectMemberViewController alloc] init];
        vc.groupId = _conversationData.groupID;
        vc.name = @"选择提醒人";
        vc.optionalStyle = TUISelectMemberOptionalStyleAtAll;
        @weakify(self)
        vc.selectedFinished = ^(NSMutableArray<UserModel *> * _Nonnull modelList) {
            @strongify(self)
            [self updateInputTextByUsers: modelList];
        };
        [self.navigationController pushViewController:vc animated:YES];
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

- (void)sendMessage:(TUIMessageCellData *)message {
    [_messageController sendMessage:message];
}

- (void)saveDraft {
    NSString *draft = self.inputController.inputBar.inputTextView.text;
    draft = [draft stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceAndNewlineCharacterSet];
    [[V2TIMManager sharedInstance] setConversationDraft:self.conversationData.conversationID draftText:draft succ:nil fail:nil];
}

- (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell {
    if (cell.data == [TUIInputMoreCellData photoData]) {
        [self selectPhotoForSend];
    }
    if (cell.data == [TUIInputMoreCellData videoData]) {
        [self takeVideoForSend];
    }
    if (cell.data == [TUIInputMoreCellData fileData]) {
        [self selectFileForSend];
    }
    if (cell.data == [TUIInputMoreCellData pictureData]) {
        [self takePictureForSend];
    }
    if (cell.data == [TUIInputMoreCellData videoCallData]) {
        [self videoCall];
    }
    if (cell.data == [TUIInputMoreCellData audioCallData]) {
        [self audioCall];
    }
    //    if (cell.data == [TUIInputMoreCellData locationData]) {
    //        [self sendLocation];
    //    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(chatController:onSelectMoreCell:)]){
        [self.delegate chatController:self onSelectMoreCell:cell];
    }
}

- (void)didTapInMessageController:(YUIMessageController *)controller {
    [_inputController reset];
}

- (BOOL)messageController:(YUIMessageController *)controller
       willShowMenuInCell:(TUIMessageCell *)cell {
    if([_inputController.inputBar.inputTextView isFirstResponder]){
        _inputController.inputBar.inputTextView.overrideNextResponder = cell;
        return YES;
    }
    return NO;
}

- (TUIMessageCellData *)messageController:(YUIMessageController *)controller
                             onNewMessage:(V2TIMMessage *)data {
    if ([self.delegate respondsToSelector:@selector(chatController:onNewMessage:)]) {
        return [self.delegate chatController:self onNewMessage:data];
    }
    return nil;
}

- (TUIMessageCell *)messageController:(YUIMessageController *)controller
                    onShowMessageData:(TUIMessageCellData *)data {
    if ([self.delegate respondsToSelector:@selector(chatController:onShowMessageData:)]) {
        return [self.delegate chatController:self onShowMessageData:data];
    }
    return nil;
}

- (void)messageController:(YUIMessageController *)controller
    onSelectMessageAvatar:(TUIMessageCell *)cell {
    if (cell.messageData.identifier == nil) return;

    if ([self.delegate respondsToSelector:@selector(chatController:onSelectMessageAvatar:)]) {
        if ([self.delegate chatController:self onSelectMessageAvatar:cell]) return;
    }
    if (_isLoading) {
        return;
    }
    self.isLoading = YES;
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

- (void)messageController:(YUIMessageController *)controller
   onSelectMessageContent:(TUIMessageCell *)cell {
    if ([self.delegate respondsToSelector:@selector(chatController:onSelectMessageContent:)]) {
        [self.delegate chatController:self onSelectMessageContent:cell];
        return;
    }
}

- (void)didHideMenuInMessageController:(YUIMessageController *)controller {
    _inputController.inputBar.inputTextView.overrideNextResponder = nil;
}

#pragma mark - TUIInputController

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
    [picker setVideoMaximumDuration:15];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)selectFileForSend {
    YChatDocumentPickerViewController *picker = [[YChatDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeData] inMode:UIDocumentPickerModeOpen];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];

}

- (void)videoCall {
    if (![[TUICallManager shareInstance] checkAudioAuthorization] || ![[TUICallManager shareInstance] checkVideoAuthorization]) {
        [THelper makeToast:@"请开启麦克风和摄像头权限"];
        return;
    }

    [[TUICallManager shareInstance] call:self.conversationData.groupID userID:self.conversationData.userID callType:CallType_Video];
}

- (void)audioCall {
    if (![[TUICallManager shareInstance] checkAudioAuthorization]) {
        [THelper makeToast:@"请开启麦克风权限"];
        return;
    }

    [[TUICallManager shareInstance] call:self.conversationData.groupID userID:self.conversationData.userID callType:CallType_Audio];
}

- (void)sendLocation {
    YZMapViewController * map = [[YZMapViewController alloc]init];
    @weakify(self)
    map.locationBlock = ^(NSString *name, NSString *address, double latitude, double longitude) {
        @strongify(self)
        [self.navigationController popViewControllerAnimated:true];
        YZLocationMessageCellData* cellData = [[YZLocationMessageCellData alloc]initWithDirection:MsgDirectionOutgoing];
        cellData.text = [NSString stringWithFormat:@"%@##%@",name,address];
        cellData.latitude = latitude;
        cellData.longitude = longitude;
        [self sendMessage:cellData];
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
            [self.delegate chatController:self didSendMessage:cellData];
        }
    };
    [self.navigationController pushViewController:map animated:YES];
}

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
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
                [self.delegate chatController:self didSendMessage:uiImage];
            }
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

    TUIVideoMessageCellData *uiVideo = [[TUIVideoMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    uiVideo.snapshotPath = imagePath;
    uiVideo.snapshotItem = [[TUISnapshotItem alloc] init];
    UIImage *snapshot = [UIImage imageWithContentsOfFile:imagePath];
    uiVideo.snapshotItem.size = snapshot.size;
    uiVideo.snapshotItem.length = imageData.length;
    uiVideo.videoPath = videoPath;
    uiVideo.videoItem = [[TUIVideoItem alloc] init];
    uiVideo.videoItem.duration = duration;
    uiVideo.videoItem.length = videoData.length;
    uiVideo.videoItem.type = url.pathExtension;
    uiVideo.uploadProgress = 0;
    if (duration <= 0) {
        [THelper makeToast: @"视频太短"];
        return;
    }
    [self sendMessage:uiVideo];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
        [self.delegate chatController:self didSendMessage:uiVideo];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
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
            TUIFileMessageCellData *uiFile = [[TUIFileMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
            uiFile.path = filePath;
            uiFile.fileName = fileName;
            uiFile.length = (int)fileSize;
            uiFile.uploadProgress = 0;
            [self sendMessage:uiFile];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
                [self.delegate chatController:self didSendMessage:uiFile];
            }
        }
    }];
    [url stopAccessingSecurityScopedResource];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
