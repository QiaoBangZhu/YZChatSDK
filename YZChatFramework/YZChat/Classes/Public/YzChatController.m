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

- (instancetype)initWithConversationId:(NSString *)conversationId
                              showName:(NSString *)showName {
    if (self = [super init]) {
        _conversationId = conversationId;
        _showName = showName;
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

@interface YzChatController () <CIGAMNavigationControllerDelegate> {
    YzChatInfo *_chatInfo;
    YzChatControllerConfig *_chatConfig;
}

@property (nonatomic, strong) YzInternalChatController *chatController;
@property (nonatomic, strong) CIGAMNavigationTitleView *titleView;

@end

@implementation YzChatController

#pragma mark - 初始化

- (instancetype)initWithChatInfo:(YzChatInfo *)chatInfo
                          config:(nullable YzChatControllerConfig *)config {
    self = [super initWithNibName: nil bundle: nil];
    if (self) {
        chatInfo.conversationId = chatInfo.conversationId ?: @"";
        _chatInfo = chatInfo;
        _chatConfig = config ?: [[YzChatControllerConfig alloc] init];
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithChatInfo: [[YzChatInfo alloc] init] config: nil];
}

- (instancetype)init {
    return [self initWithChatInfo: [[YzChatInfo alloc] init] config: nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self initWithChatInfo: [[YzChatInfo alloc] init] config: nil];
}

- (void)didInitialize {
    self.chatController = [[YzInternalChatController alloc] initWithChatInfo: _chatInfo config: _chatConfig];
    self.titleView = [[CIGAMNavigationTitleView alloc] init];
    self.titleView.title = self.title;
    self.navigationItem.titleView = self.titleView;

    self.extendedLayoutIncludesOpaqueBars = YES;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _chatInfo.showName;
    [self addChildViewController: self.chatController];
    [self.view addSubview: self.chatController.view];

    if (!_chatInfo.showName.length) {
        @weakify(self)
        [[RACObserve(self.chatController, title) distinctUntilChanged] subscribeNext:^(NSString *title) {
            @strongify(self)
            self.title = title;
        }];
    }
}

#pragma mark - Public

- (void)registerClass:(nullable Class)viewClass forCustomMessageViewReuseIdentifier:(NSString *)identifier {
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

- (void)setDataSource:(id<YzChatControllerDataSource>)dataSource {
    _dataSource = dataSource;
    self.chatController.dataSource = dataSource;
}

- (void)setDelegate:(id<YzChatControllerDelegate>)delegate {
    _delegate = delegate;
    self.chatController.delegate = delegate;
}

@end
