//
//  YzGroupPendencyViewController.m
//  YZChat
//
//  Created by 安笑 on 2021/5/11.
//

#import "YzGroupPendencyViewController.h"

#import <ImSDKForiOS/ImSDK.h>
#import <ReactiveObjC/ReactiveObjC.h>

#import "TUIKit.h"
#import "TUIGroupPendencyCellData.h"
#import "TUIGroupPendencyCell.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"

#import "YzIMKitAgent+Private.h"

@interface YzGroupPendencyViewModel ()

@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, strong) NSArray *dataList;

@property (nonatomic, assign) int unReadCount;

@end

@implementation YzGroupPendencyViewModel

#pragma mark - 初始化

- (instancetype)initWithGroupId:(nullable NSString *)groupId {
    _groupId = groupId;

    if (self = [super init]) {
        [self subscribe];
        if (groupId) {
            [self loadData];
        }
    }

    return self;
}

#pragma mark - Public

- (void)loadData {
    [[YzIMKitAgent shareInstance] reloadGroupApplicationList];
}

- (void)acceptJoin:(TUIGroupPendencyCellData *)data {
    [[YzIMKitAgent shareInstance] acceptGroupApplication: data];
    self.unReadCount--;
}

- (void)rejectJoin:(TUIGroupPendencyCellData *)data {
    [[YzIMKitAgent shareInstance] rejectGroupApplication: data];
    self.unReadCount--;
}

#pragma mark - 监听

- (void)subscribe {
    @weakify(self);
    [RACObserve([YzIMKitAgent shareInstance], groupApplicationList) subscribeNext:^(NSArray *list) {
        @strongify(self)
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        int count = 0;
        for (TUIGroupPendencyCellData *data in list) {
            if (!self.groupId || [data.groupId isEqualToString: self.groupId]) {
                [temp addObject: data];

                if (data.isAccepted) {
                    count ++;
                }
            }
        }
        if (self.unReadCount != [temp count] - count) {
            self.unReadCount = (int)[temp count] - count;
        }
        self.dataList = [temp copy];
    }];
}

@end

static NSString *kReuseIdentifier_PendencyCell = @"ReuseIdentifier_PendencyCell";

@interface YzGroupPendencyViewController ()

@property (nonatomic, strong) YzGroupPendencyViewModel *viewModel;

@end

@implementation YzGroupPendencyViewController

#pragma mark - 初始化

- (instancetype)initWithViewModel:(YzGroupPendencyViewModel *)viewModel {
    _viewModel = viewModel;
    return [super initWithNibName: nil bundle: nil];
}

- (void)didInitialize {
    [super didInitialize];
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title =  !self.viewModel.groupId ? @"全部群申请" : @"群申请";
}

#pragma mark - 用户交互

- (void)acceptJoin:(TUIGroupPendencyCell *)cell {
    [self.viewModel acceptJoin: cell.pendencyData];
    [self.tableView reloadData];
}

- (void)cellClick:(TUIGroupPendencyCell *)cell {
    id<TUIUserProfileControllerServiceProtocol> controller = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileControllerServiceProtocol)];
    if ([controller isKindOfClass:[UIViewController class]]) {
        [[V2TIMManager sharedInstance] getUsersInfo:@[cell.pendencyData.fromUser] succ:^(NSArray<V2TIMUserFullInfo *> *profiles) {
            controller.userFullInfo = profiles.firstObject;
            controller.groupPendency = cell.pendencyData;
            controller.actionType = PCA_GROUP_CONFIRM;
            [self.navigationController pushViewController:(UIViewController *)controller animated:YES];
        } fail:nil];
    }
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.dataList.count > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIGroupPendencyCell *cell = [tableView dequeueReusableCellWithIdentifier: kReuseIdentifier_PendencyCell forIndexPath: indexPath];
    TUIGroupPendencyCellData *data = self.viewModel.dataList[indexPath.row];
    data.cselector = @selector(cellClick:);
    data.cbuttonSelector = @selector(acceptJoin:);
    [cell fillWithData:data];
    cell.changeColorWhenTouched = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.avatarView.layer.masksToBounds = YES;
    cell.avatarView.layer.cornerRadius = cell.avatarView.frame.size.height / 2;

    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector: @selector(setSeparatorInset:)]) {
        [cell setSeparatorInset: UIEdgeInsetsMake(0, 78, 0, 0)];
        if (indexPath.row == (self.viewModel.dataList.count - 1)) {
            [cell setSeparatorInset: UIEdgeInsetsZero];
        }
    }

    if ([cell respondsToSelector: @selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    if ([cell respondsToSelector: @selector(setLayoutMargins:)]) {
        [cell setLayoutMargins: UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tableView beginUpdates];
        [self.viewModel rejectJoin: self.viewModel.dataList[indexPath.row]];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

#pragma mark - 页面布局

- (void)initTableView {
    [super initTableView];

    [self.tableView registerClass: [TUIGroupPendencyCell class] forCellReuseIdentifier: kReuseIdentifier_PendencyCell];
}

@end
