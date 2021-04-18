//
//  YzChatController.m
//  YZChat
//
//  Created by 安笑 on 2021/4/9.
//

#import "YzChatController.h"

#import <ReactiveObjC/ReactiveObjC.h>

#import "YzInternalChatController.h"
#import "CommonConstant.h"

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

@interface YzChatController () <YzInternalChatControllerDataSource, YzInternalChatControllerDelegate> {
    YzChatInfo *_chatInfo;
    YzChatControllerConfig *_chatConfig;
}

@property (nonatomic, strong) YzInternalChatController *chatController;

@end

@implementation YzChatController

- (instancetype)initWithChatInfo:(YzChatInfo *)chatInfo
                          config:(nullable YzChatControllerConfig *)config {
    self = [super init];
    if (self) {
        _chatInfo = chatInfo;
        _chatConfig = config ?: [[YzChatControllerConfig alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _chatInfo.chatName;
    [self setupChatController];

    if (!_chatInfo.chatName.length) {
        @weakify(self)
        [[RACObserve(self.chatController, title) distinctUntilChanged] subscribeNext:^(NSString *title) {
            @strongify(self)
            self.title = title;
    //        if (self.delegate && [self.delegate respondsToSelector: @selector(onTitleChanged:)]) {
    //            [self.delegate onTitleChanged: title];
    //        }
        }];
    }
}

- (void)setupChatController {
    self.chatController = [[YzInternalChatController alloc] initWithChatInfo: _chatInfo config: _chatConfig];
    self.chatController.delegate = self;
    self.chatController.dataSource = self;
    [self addChildViewController: self.chatController];
    [self.view addSubview: self.chatController.view];
}

#pragma mark - Public

- (void)registerClass:(nullable Class)viewClass forCustomMessageViewReuseIdentifier:(NSString *)identifier {
    NSAssert([viewClass isSubclassOfClass: [YzCustomMessageView class]], @"自定义消息视图类型，需继承自 YzCustomMessageView");
    [self.chatController registerClass: viewClass forCustomMessageViewReuseIdentifier: identifier];
}


- (void)updateInputTextByNames:(NSArray<NSString *> *)names ids:(NSArray<NSString *> *)ids {
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

#pragma mark - YzInternalChatControllerDataSource

- (YzCustomMessageData *)customMessageForData:(NSData *)data {
    if (self.dataSource && [self.dataSource respondsToSelector: @selector(customMessageForData:)]) {
        YzCustomMessageData *custom = [self.dataSource customMessageForData: data];
        Class cls = self.chatController.registeredCustomMessageClass[custom.reuseIdentifier];
        NSAssert(cls != nil, @"%@ 自定义消息视图未注册", custom);
        return custom;
    }

    return nil;
}


#pragma mark - YzInternalChatControllerDelegate

- (BOOL)onUserIconClick:(NSString *)userId {
    if (self.delegate && [self.delegate respondsToSelector: @selector(onUserIconClick:)]) {
        [self.delegate onUserIconClick: userId];
        return YES;
    }

    return NO;
}

- (BOOL)onAtGroupMember {
    if (self.delegate && [self.delegate respondsToSelector: @selector(onAtGroupMember)]) {
        [self.delegate onAtGroupMember];
        return YES;
    }

    return NO;
}

- (void)onSelectedCustomMessageView:(YzCustomMessageView *)customMessageView {
    if (self.delegate && [self.delegate respondsToSelector: @selector(onSelectedCustomMessageView:)]) {
        [self.delegate onSelectedCustomMessageView: customMessageView];
    }
}

@end
