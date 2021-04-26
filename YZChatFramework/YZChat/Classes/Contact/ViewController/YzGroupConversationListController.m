//
//  YzGroupConversationListController.m
//  YZChat
//
//  Created by 安笑 on 2021/4/21.
//

#import "YzGroupConversationListController.h"

#import <ReactiveObjC/ReactiveObjC.h>

#import "THelper.h"
#import "THeader.h"
#import "TUIGroupConversationListViewModel.h"

#import "YzCommonImport.h"
#import "YzIMKitAgent+Private.h"

// navigation
#import "YzInternalChatController.h"

static NSString *kReuseIdentifier_ContactCell = @"ReuseIdentifier_ContactCell";

@interface YzGroupConversationListController () {
    YzCustomMessageData *_customMessage;
    BOOL _isInternal;
}

@property (nonatomic, strong) TUIGroupConversationListViewModel *viewModel;

@end

@implementation YzGroupConversationListController

#pragma mark - 初始化

- (instancetype)initWithCustomMessage:(YzCustomMessageData *)customMessage {
    _customMessage = customMessage;
    self = [super initWithNibName: nil bundle: nil];
    if (self) {}

    return self;
}

- (void)didInitialize {
    [super didInitialize];

    _isInternal = !_customMessage;
    self.viewModel = [[TUIGroupConversationListViewModel alloc] init];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"群聊";
    [self addNotificationCenterObserver];
    [self.viewModel loadConversation];
}

#pragma mark - NSNotificationCenter

- (void)addNotificationCenterObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRefreshConversations:)
                                                 name: TUIKitNotification_TIMRefreshListener
                                               object:nil];
}

- (void)onRefreshConversations:(NSNotification *)notify {
    [self.viewModel loadConversation];
}

#pragma mark - 用户交互

- (void)subscribe {
    [super subscribe];

    @weakify(self)
    [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.tableView reloadData];
    }];
}

- (void)didSelectConversation:(TCommonContactCell *)cell {
    TUIConversationCellData *cellData = [[TUIConversationCellData alloc] init];
    cellData.groupID = cell.contactData.identifier;
    if(_isInternal) {
        YzInternalChatController *chat = [[YzInternalChatController alloc] initWithConversation: cellData];

        [self.navigationController pushViewController:chat animated:YES];
        return;
    }

    @weakify(self)
    [[YzIMKitAgent shareInstance] sendCustomMessage: _customMessage userId: nil groupId: cellData.groupID success:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } failure:^(NSInteger errCode, NSString * _Nonnull errMsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [THelper makeToastError: errCode msg: errMsg];
        });
    }];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.groupList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataDict[self.viewModel.groupList[section]].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return _isInternal;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.viewModel.groupList[section];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        TCommonContactCellData *data = self.viewModel.dataDict[self.viewModel.groupList[indexPath.section]][indexPath.row];
        [self.viewModel removeData:data];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 33;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier: kReuseIdentifier_ContactCell forIndexPath: indexPath];
    TCommonContactCellData *data = self.viewModel.dataDict[self.viewModel.groupList[indexPath.section]][indexPath.row];
    if (!data.cselector) {
        data.cselector = @selector(didSelectConversation:);
    }
    [cell fillWithData:data];
    [cell createGrpAvatarByGrpId:data.identifier];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

#pragma mark - 页面布局

- (void)initTableView {
    [super initTableView];

    [self.tableView registerClass: [TCommonContactCell class] forCellReuseIdentifier: kReuseIdentifier_ContactCell];
}


- (void)setupSubviews {
    [super setupSubviews];

    self.view.backgroundColor = [UIColor colorWithHex: KCommonBackgroundColor];
}

@end
