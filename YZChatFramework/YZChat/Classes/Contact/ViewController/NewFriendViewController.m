//
//  NewFriendViewController.m
//  YChat
//
//  Created by magic on 2020/9/25.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "NewFriendViewController.h"
#import "TUINewFriendViewModel.h"
#import "ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "Toast/Toast.h"
#import "UIColor+TUIDarkMode.h"
#import "THeader.h"
#import "CommonPendencyCell.h"
#import "ContactSearchViewController.h"
#import "UIColor+ColorExtension.h"
#import <ImSDKForiOS/ImSDK.h>
#import "YZAddressBookViewController.h"
#import "NSBundle+YZBundle.h"
#import "CommonConstant.h"


@interface NewFriendViewController ()<UITableViewDelegate,UITableViewDataSource>
@property UITableView *tableView;
@property UIButton  *moreBtn;
@property TUINewFriendViewModel *viewModel;
@end

@implementation NewFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"新的好友";
//    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 1, KScreenWidth, self.view.frame.size.height - 1) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[CommonPendencyCell class] forCellReuseIdentifier:@"PendencyCell"];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 94, 0, 0);
    _tableView.backgroundColor = self.view.backgroundColor;

    _viewModel = TUINewFriendViewModel.new;

    _moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _moreBtn.mm_h = 20;
    _tableView.tableFooterView = _moreBtn;
    _moreBtn.hidden = YES;

    @weakify(self)
    [RACObserve(_viewModel, dataList) subscribeNext:^(id  _Nullable x) {
      @strongify(self)
       [self.tableView reloadData];
    }];
    
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [moreButton setImage:YZChatResource(@"more") forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(onRightItem) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
}

- (void)onRightItem {
    UIViewController *add = [[ContactSearchViewController alloc] init];
    [self.navigationController pushViewController:add animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
}


- (void)loadData
{
    [_viewModel loadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewModel.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommonPendencyCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PendencyCell" forIndexPath:indexPath];
    TCommonPendencyCellData *data = self.viewModel.dataList[indexPath.row];
    data.cselector = @selector(cellClick:);
    data.cbuttonSelector = @selector(btnClick:);
    [cell fillWithData:data];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [self.tableView beginUpdates];
        TCommonPendencyCellData *data = self.viewModel.dataList[indexPath.row];
        [self.viewModel removeData:data];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)btnClick:(CommonPendencyCell *)cell
{
    [self.viewModel agreeData:cell.pendencyData];
    [self.tableView reloadData];
}

- (void)cellClick:(CommonPendencyCell *)cell
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell.pendencyData.application.type == V2TIM_FRIEND_APPLICATION_SEND_OUT) {
        return;
    }
    id<TUIUserProfileControllerServiceProtocol> controller = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileControllerServiceProtocol)];
    if ([controller isKindOfClass:[UIViewController class]]) {
        [[V2TIMManager sharedInstance] getUsersInfo:@[cell.pendencyData.identifier] succ:^(NSArray<V2TIMUserFullInfo *> *profiles) {
            controller.userFullInfo = profiles.firstObject;
            controller.pendency = cell.pendencyData;
            controller.actionType = PCA_PENDENDY_CONFIRM;
            [self.navigationController pushViewController:(UIViewController *)controller animated:YES];
        } fail:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!section) {
        return 110;
    }
    return .1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 110)];
    view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    UIView* topView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, Screen_Width, 60)];
    topView.backgroundColor = [UIColor whiteColor];
    [view addSubview:topView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showAddressBook)];
    [topView addGestureRecognizer:tap];
    
    UIImageView* icon = [[UIImageView alloc]initWithFrame:CGRectMake(16, 16, 28, 28)];
    icon.image = YZChatResource(@"contacts_pressed");
    [topView addSubview:icon];
    
    UILabel* titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(icon.frame.origin.x + icon.frame.size.width + 8, 0, 160, 60)];
    titleLabel.text = @"添加手机联系人";
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
    [topView addSubview:titleLabel];
    
    UIImageView* rightAccessory = [[UIImageView alloc]initWithFrame:CGRectMake(Screen_Width-16-24, 18, 24, 24)];
    UIImage* image = YZChatResource(@"accessory_icon");
    
    rightAccessory.image = image;
    [topView addSubview:rightAccessory];
    
    
    UILabel* tipsLabel =[[UILabel alloc]initWithFrame:CGRectMake(12, topView.frame.origin.y + topView.frame.size.height + 10, 160, 20)];
    tipsLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
    tipsLabel.font = [UIFont systemFontOfSize:12];
    tipsLabel.text = @"好友申请和添加";
    [view addSubview:tipsLabel];
    
    return view;
}

- (void)showAddressBook {
    YZAddressBookViewController* addressBookVc = [[YZAddressBookViewController alloc]init];
    addressBookVc.title = @"添加联系人";
    addressBookVc.viewModel = self.viewModel;
    [self.navigationController pushViewController:addressBookVc animated:YES];
}


@end
