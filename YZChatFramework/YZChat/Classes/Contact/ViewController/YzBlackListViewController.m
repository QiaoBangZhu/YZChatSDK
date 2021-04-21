//
//  YzBlackListViewController.m
//  YZChat
//
//  Created by 安笑 on 2021/4/21.
//

#import "YzBlackListViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>

#import "THeader.h"
#import "TUIBlackListViewModel.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"

#import "YzCommonImport.h"

static NSString *kReuseIdentifier_ContactCell = @"ReuseIdentifier_ContactCell";

@interface YzBlackListViewController ()

@property (nonatomic, strong) TUIBlackListViewModel *viewModel;

@end

@implementation YzBlackListViewController

#pragma mark - 初始化

- (void)didInitialize {
    [super didInitialize];

    self.viewModel = [[TUIBlackListViewModel alloc] init];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addNotificationCenterObserver];
    [self.viewModel loadBlackList];
}

#pragma mark - NSNotificationCenter

- (void)addNotificationCenterObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBlackListChanged:)
                                                 name:TUIKitNotification_onBlackListAdded
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBlackListChanged:)
                                                 name:TUIKitNotification_onBlackListDeleted
                                               object:nil];
}

- (void)onBlackListChanged:(NSNotification *)notify {
    [self.viewModel loadBlackList];
}

#pragma mark - 用户交互

- (void)subscribe {
    [super subscribe];


    @weakify(self)
    [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(id finished) {
        @strongify(self)
        if ([(NSNumber *)finished boolValue])
            [self.tableView reloadData];
    }];
}

-(void)didSelectBlackList:(TCommonContactCell *)cell
{
    TCommonContactCellData *data = cell.contactData;

    id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
    if ([vc isKindOfClass:[UIViewController class]]) {
        vc.friendProfile = data.friendProfile;
        vc.isShowConversationAtTop = YES;
        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.blackListData.count > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.blackListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier: kReuseIdentifier_ContactCell forIndexPath: indexPath];
    TCommonContactCellData *data = self.viewModel.blackListData[indexPath.row];
    data.cselector = @selector(didSelectBlackList:);
    [cell fillWithData:data];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

#pragma mark - 页面布局

- (void)initTableView {
    [super initTableView];

    self.tableView.separatorColor = [UIColor colorWithHex: KCommonSeparatorLineColor];
    [self.tableView registerClass: [TCommonContactCell class] forCellReuseIdentifier: kReuseIdentifier_ContactCell];
}


- (void)setupSubviews {
    [super setupSubviews];

    self.titleView.title = @"黑名单";
    self.view.backgroundColor = [UIColor colorWithHex: KCommonBackgroundColor];
}

@end
