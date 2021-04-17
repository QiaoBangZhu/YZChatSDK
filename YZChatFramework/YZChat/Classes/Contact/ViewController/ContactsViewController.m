//
//  ContactsViewController.m
//  YChat
//
//  Created by magic on 2020/9/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "ContactsViewController.h"
#import "TUIContactSelectController.h"
#import "TPopView.h"
#import "TPopCell.h"
#import "THeader.h"
#import "SearchFriendViewController.h"
#import "SearchGroupViewController.h"
#import "NewFriendViewController.h"
#import <ImSDKForiOS/ImSDK.h>
#import "YZFriendProfileViewController.h"
#import "TUIContactActionCellData.h"
#import "TUIGroupConversationListController.h"
#import "TUIBlackListController.h"
#import "YZContactSearchViewController.h"
#import "UIImage+YChatExtension.h"
#import "UIColor+ColorExtension.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "YUIContactViewController.h"
#import "YUIGroupConversationListController.h"
#import "YUIBlackListViewController.h"
#import "UIBarButtonItem+Extensions.h"
#import "YZSearchBarView.h"
#import <Masonry/Masonry.h>
#import "SearchMyFriendsViewController.h"
#import "SearchMyContactsViewController.h"
#import "TUITabBarController.h"
#import "YZBaseManager.h"
#import "NSBundle+YZBundle.h"
#import "CommonConstant.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import "YzCustomMsg.h"

@interface ContactsViewController ()<CNContactPickerDelegate>
@property NSArray<TUIContactActionCellData *> *firstGroupData;
@property (nonatomic, strong)YUIContactViewController*  contactVc;
@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleName = self.isFromOtherApp ? @"请选择":@"通讯录";
    
    YUIContactViewController *contacts = [[YUIContactViewController alloc] init];
    contacts.isFromOtherApp = self.isFromOtherApp;
    contacts.customMsg = self.customMsg;
    [self addChildViewController:contacts];
    [self.view addSubview:contacts.view];
    self.contactVc = contacts;
    //如果不加这一行代码，依然可以实现点击反馈，但反馈会有轻微延迟，体验不好。
    contacts.tableView.delaysContentTouches = NO;
    
    YZSearchBarView* searchBarView = [[YZSearchBarView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 52)];
    searchBarView.placeholder = @"昵称/备注";
    searchBarView.isShowCancle = NO;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(searchAction)];
    [searchBarView addGestureRecognizer:tap];
    [contacts.view addSubview:searchBarView];
    
    [contacts.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.top.equalTo(searchBarView.mas_bottom);
    }];
    
    [self setupView];
}

- (void)setupView {
    if (!self.isFromOtherApp) {
        UIBarButtonItem* moreItem = [[UIBarButtonItem alloc] initWithImage:YZChatResource(@"contact_search") target:self action:@selector(searchMyFriends)];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceItem.width = -15;
        self.navigationItem.rightBarButtonItems =  @[spaceItem,moreItem];
    }
    
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
        TUIContactActionCellData *data = [[TUIContactActionCellData alloc] init];
        UIImage* image = YZChatResource(@"icon_add_contact");
        data.icon = image;
        data.title = @"新的联系人";
        data.cselector = @selector(onAddNewFriend:);
        data;
    })];
    [list addObject:({
        TUIContactActionCellData *data = [[TUIContactActionCellData alloc] init];
        data.icon = YZChatResource(@"myGrps");
        data.title = @"我的群聊";
        data.cselector = @selector(onGroupConversation:);
        data;
    })];
    [list addObject:({
        TUIContactActionCellData *data = [[TUIContactActionCellData alloc] init];
        data.icon = YZChatResource(@"icon_blackList");
        data.title = @"黑名单";
        data.cselector = @selector(onBlackList:);
        data;
    })];
    self.firstGroupData = [NSArray arrayWithArray:list];
    
    [RACObserve(self.contactVc.viewModel, pendencyCnt) subscribeNext:^(NSNumber *x) {
        self.firstGroupData[0].readNum = [x integerValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[YZBaseManager shareInstance].tabController setContactsBadge: x.integerValue];
        });
    }];
}

- (void)onRightItem
{
    UIViewController *add = [[YZContactSearchViewController alloc] init];
    [self.navigationController pushViewController:add animated:YES];
}

- (void)onAddNewFriend:(TCommonTableViewCell *)cell
{
    NewFriendViewController *vc = NewFriendViewController.new;
    [self.navigationController pushViewController:vc animated:YES];
    [self.contactVc.viewModel clearApplicationCnt];
}

- (void)onGroupConversation:(TCommonTableViewCell *)cell
{
    YUIGroupConversationListController *vc = YUIGroupConversationListController.new;
    vc.customMsg = self.customMsg;
    vc.isFromOtherApp = self.isFromOtherApp;
    vc.title = @"群聊";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onBlackList:(TCommonContactCell *)cell
{
    YUIBlackListViewController *vc = YUIBlackListViewController.new;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)searchAction {
    SearchMyContactsViewController* searchVc = [[SearchMyContactsViewController alloc]init];
    [self.navigationController pushViewController:searchVc animated:true];
}

- (void)searchMyFriends {
    SearchMyFriendsViewController* searchVc = [[SearchMyFriendsViewController alloc]init];
    [self.navigationController pushViewController:searchVc animated:true];
}



@end
