//
//  YzConversationListController.m
//  YZChat
//
//  Created by 安笑 on 2021/4/9.
//


#import "YzConversationListController.h"
#import "YzInternalConversationListController.h"

@interface YzConversationListController ()<YzInternalConversationListControllerDelegate> {
    YzChatType _chatType;
}

@end

@implementation YzConversationListController

- (instancetype)initWithChatType:(YzChatType)chatType {
    self = [super init];
    if (self) {
        _chatType = chatType;
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"init not implemented, use initWithChatType");
    self = [super init];
    if (self) {
        _chatType = YzChatTypeC2C | YzChatTypeGroup;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"消息";
    YzInternalConversationListController *conversationList = [[YzInternalConversationListController alloc] initWithChatType: _chatType];
    [self addChildViewController: conversationList];
    [self.view addSubview: conversationList.view];
    conversationList.delegate = self;
}

#pragma mark - YzInternalConversationListControllerDelegate

- (void)onTitleChanged:(NSString *)title {
    self.title = title;
}

- (void)didSelectConversation:(V2TIMConversation *)conversation indexPath:(NSIndexPath *)indexPath {
    if(self.delegate && [self.delegate respondsToSelector: @selector(didSelectConversation:indexPath:)]) {
        [self.delegate didSelectConversation: conversation indexPath: indexPath];
    }
}

@end
