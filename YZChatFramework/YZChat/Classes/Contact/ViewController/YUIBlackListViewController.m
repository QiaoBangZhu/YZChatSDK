//
//  YUIBlackListViewController.m
//  YChat
//
//  Created by magic on 2020/10/28.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YUIBlackListViewController.h"
#import "ReactiveObjC.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "THeader.h"
#import "UIColor+ColorExtension.h"
#import <Masonry/Masonry.h>
#import <ImSDKForiOS/ImSDK.h>

//@import ImSDK;

@interface YUIBlackListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)UITableView *tableView;

@end

@implementation YUIBlackListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"黑名单";
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.top.equalTo(@1);
    }];

    if (!self.viewModel) {
        self.viewModel = TUIBlackListViewModel.new;
        @weakify(self)
        [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(id finished) {
            @strongify(self)
            if ([(NSNumber *)finished boolValue])
                [self.tableView reloadData];
        }];
        [self.viewModel loadBlackList];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBlackListChanged:) name:TUIKitNotification_onBlackListAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBlackListChanged:) name:TUIKitNotification_onBlackListDeleted object:nil];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource =  self;
        _tableView.tableFooterView =  [UIView new];
        [_tableView registerClass:[TCommonContactCell class] forCellReuseIdentifier:@"FriendCell"];
        _tableView.separatorColor = [UIColor colorWithHex:KCommonSeparatorLineColor];
        _tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    }
    return _tableView;
}

- (void)onBlackListChanged:(NSNotification *)no {
    [self.viewModel loadBlackList];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.blackListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    TCommonContactCellData *data = self.viewModel.blackListData[indexPath.row];
    data.cselector = @selector(didSelectBlackList:);
    [cell fillWithData:data];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCommonContactCellData *data = self.viewModel.blackListData[indexPath.row];

    id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
    if ([vc isKindOfClass:[UIViewController class]]) {
        vc.friendProfile = data.friendProfile;
        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
    }
}
 */

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


@end
