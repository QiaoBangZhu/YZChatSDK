//
//  YzConversationListController.m
//  YZChat
//
//  Created by 安笑 on 2021/4/9.
//

#import <ReactiveObjC/ReactiveObjC.h>

#import "YzConversationListController.h"
#import "YzInternalConversationListController.h"

@interface YzConversationListController ()<CIGAMNavigationControllerDelegate> {
    YzChatType _chatType;
}

@property (nonatomic, strong) YzInternalConversationListController *conversationList;
@property (nonatomic, strong) CIGAMNavigationTitleView *titleView;

@end

@implementation YzConversationListController

- (instancetype)initWithChatType:(YzChatType)chatType {
    if(self = [super initWithNibName: nil bundle: nil]) {
        _chatType = chatType;
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithChatType: YzChatTypeC2C | YzChatTypeGroup];
}

- (instancetype)init {
    return [self initWithChatType: YzChatTypeC2C | YzChatTypeGroup];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self initWithChatType: YzChatTypeC2C | YzChatTypeGroup];
}

- (void)didInitialize {
    self.conversationList = [[YzInternalConversationListController alloc] initWithChatType: _chatType];
    self.titleView = [[CIGAMNavigationTitleView alloc] init];
    self.titleView.title = self.title;
    self.navigationItem.titleView = self.titleView;

    self.extendedLayoutIncludesOpaqueBars = YES;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addChildViewController: self.conversationList];
    [self.view addSubview: self.conversationList.view];
    self.conversationList.delegate = self.delegate;

    [self subscribe];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];

    if (self.conversationList.searchController.isActive) {
        [self.navigationController setNavigationBarHidden: YES animated: YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];

    if (self.conversationList.searchController.isActive) {
        [self.navigationController setNavigationBarHidden: NO animated: YES];
    }
}

#pragma mark - 用户交互

- (void)subscribe {
    @weakify(self)
    [[RACObserve(self.conversationList, title) distinctUntilChanged] subscribeNext:^(NSString *title) {
        @strongify(self)
        self.title = title;
    }];
}

- (void)setDelegate:(id<YzConversationListControllerDelegate>)delegate {
    _delegate = delegate;
    self.conversationList.delegate = delegate;
}

@end
