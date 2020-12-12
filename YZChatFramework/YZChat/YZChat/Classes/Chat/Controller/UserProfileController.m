//
//  UserProfileController.m
//  YChat
//
//  Created by magic on 2020/9/26.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "UserProfileController.h"
#import "TUIProfileCardCell.h"
#import "TUIButtonCell.h"
#import "THeader.h"
#import "TTextEditController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ChatViewController.h"
#import "FriendRequestViewController.h"
#import "TCommonTextCell.h"
#import "TIMUserProfile+DataProvider.h"
#import "Toast/Toast.h"
#import "TUIKit.h"
#import "TUIGroupPendencyCellData.h"
#import "TCommonPendencyCellData.h"
#import "TUIImageViewController.h"
#import "TUIAvatarViewController.h"
//#import <ImSDK/ImSDK.h>
#import <ImSDKForiOS/ImSDK.h>
#import "AddFriendHeaderCell.h"
#import "ButtonTableViewCell.h"
#import "YChatNetworkEngine.h"
#import "UserInfo.h"
#import "UIColor+ColorExtension.h"
#import "THelper.h"

@TCServiceRegister(TUIUserProfileControllerServiceProtocol, UserProfileController)
@interface UserProfileController ()<AddFriendHeaderCellDelegate>
@property NSMutableArray<NSArray *> *dataList;
@property NSString * helloStr;
@property UserInfo * user;
@property BOOL canEdit;
@end

@implementation UserProfileController {
    V2TIMUserFullInfo *_userFullInfo;
    ProfileControllerAction _actionType;
    TUIGroupPendencyCellData *_groupPendency;
    TCommonPendencyCellData *_pendency;
    
}
@synthesize userFullInfo = _userFullInfo;
@synthesize actionType = _actionType;
@synthesize groupPendency = _groupPendency;
@synthesize pendency = _pendency;

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    return self;
}

- (void)willMoveToParentViewController:(nullable UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"详细资料";
    self.clearsSelectionOnViewWillAppear = YES;

    [self.tableView registerClass:[AddFriendHeaderCell class] forCellReuseIdentifier:@"AddFriendHeaderCell"];
    [self.tableView registerClass:[TUIButtonCell class] forCellReuseIdentifier:@"ButtonCell"];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    
    //如果不加这一行代码，依然可以实现点击反馈，但反馈会有轻微延迟，体验不好。
    self.tableView.delaysContentTouches = NO;

    [self fetchUserInfo];
}

- (void)fetchUserInfo {
    [YChatNetworkEngine requestUserInfoWithUserId:self.userFullInfo.userID completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"]intValue] == 200) {
                UserInfo* info = [UserInfo yy_modelWithDictionary:result[@"data"]];
                self.user = info;
                [self loadData];
            }else {
                [QMUITips showError:result[@"msg"]];
            }
        }
    }];
}

/**
 * 加载视图信息
 */
- (void)loadData
{
    NSMutableArray *list = @[].mutableCopy;
    [list addObject:({
        NSMutableArray *inlist = @[].mutableCopy;
        [inlist addObject:({
            ProfileCardCellData *personal = [[ProfileCardCellData alloc] init];
            personal.avatarImage = DefaultAvatarImage;
            personal.avatarUrl = [NSURL URLWithString:self.userFullInfo.faceURL];
            personal.name = [self.userFullInfo showName];
            personal.signature = self.user.mobile;
            personal.reuseId = @"CardCell";
            personal;
        })];
        inlist;
    })];

    //当用户状态为请求添加好友/请求添加群组时，视图加载出验证消息模块
    if (self.pendency || self.groupPendency) {
        if (self.pendency) {
            _helloStr = self.pendency.addWording;
        } else if (self.groupPendency) {
            _helloStr = self.groupPendency.requestMsg;
        }
    }
    self.dataList = list;

    //当用户为陌生人时，在当前视图给出"加好友"按钮
    if (self.actionType == PCA_ADD_FRIEND) {
        TIMFriendCheckInfo *ck = TIMFriendCheckInfo.new;
        ck.users = @[self.userFullInfo.userID];
        ck.checkType = TIM_FRIEND_CHECK_TYPE_BIDIRECTION;
        [[TIMFriendshipManager sharedInstance] checkFriends:ck succ:^(NSArray<TIMCheckFriendResult *> *results) {
            TIMCheckFriendResult *result = results.firstObject;
            if (result.resultType == TIM_FRIEND_RELATION_TYPE_MY_UNI || result.resultType == TIM_FRIEND_RELATION_TYPE_BOTHWAY) {
                return;
            }
            self.canEdit = YES;
            [self.dataList addObject:({
                NSMutableArray *inlist = @[].mutableCopy;
                [inlist addObject:({
                    ButtonCellData *data = ButtonCellData.new;
                    data.title = @"加好友";
                    data.style = BtnBlueText;
                    data.cbuttonSelector = @selector(onAddFriend);
                    data.reuseId = @"ButtonCell";
                    data;
                })];
                inlist;
            })];
            [self.tableView reloadData];
        } fail:^(int code, NSString *msg) {

        }];
    }

    //当用户请求添加使用者为好友时，在当前视图给出"同意"、"拒绝"，使当前用户进行选择
    if (self.actionType == PCA_PENDENDY_CONFIRM) {
        [self.dataList addObject:({
            NSMutableArray *inlist = @[].mutableCopy;
            [inlist addObject:({
                ButtonCellData *data = ButtonCellData.new;
                data.title = @"同意";
                data.style = BtnBlueText;
                data.cbuttonSelector = @selector(onAgreeFriend);
                data.reuseId = @"ButtonCell";
                data;
            })];
            inlist;
        })];
        
        [self.dataList addObject:({
            NSMutableArray *inlist = @[].mutableCopy;
            [inlist addObject:({
                ButtonCellData *data = ButtonCellData.new;
                data.title = @"拒绝";
                data.style = BtnRedText;
                data.cbuttonSelector =  @selector(onRejectFriend);
                data.reuseId = @"ButtonCell";
                data;
            })];
            inlist;
        })];
    }
    
    

    //当用户请求加入群组时，在当前视图给出"同意"、"拒绝"，使当前群组管理员进行选择
    if (self.actionType == PCA_GROUP_CONFIRM) {
        [self.dataList addObject:({
            NSMutableArray *inlist = @[].mutableCopy;
            [inlist addObject:({
                ButtonCellData *data = ButtonCellData.new;
                data.title = @"同意";
                data.style = BtnBlueText;
                data.cbuttonSelector = @selector(onAgreeGroup);
                data.reuseId = @"ButtonCell";
                data;
            })];
            inlist;
        })];
        
        [self.dataList addObject:({
            NSMutableArray *inlist = @[].mutableCopy;
            [inlist addObject:({
                ButtonCellData *data = ButtonCellData.new;
                data.title = @"拒绝";
                data.style = BtnRedText;
                data.cbuttonSelector =  @selector(onRejectGroup);
                data.reuseId = @"ButtonCell";
                data;
            })];
            inlist;
        })];
    }

    [self.tableView reloadData];
}

#pragma mark - Table view data source
/**
 *  tableView数据源函数
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* view = [[UIView alloc]init];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!section) {
        return 0;
    }
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *data = self.dataList[indexPath.section][indexPath.row];
    if ([data isKindOfClass:[ProfileCardCellData class]]) {
        AddFriendHeaderCell *cell = [[AddFriendHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddFriendHeaderCell"];
        cell.delegate = self;
        [cell fillWithData:(ProfileCardCellData *)data];
        cell.textView.text = self.helloStr;
        cell.textView.editable = _canEdit;
        return  cell;
    }else if ([data isKindOfClass:[ButtonCellData class]]) {
        ButtonTableViewCell *cell = [[ButtonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ButtonCell"];
        [cell fillWithData:(ButtonCellData*)data];
        return cell;;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (!indexPath.section) {
        return 250;
    }
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

/**
 *  点击 发送信息 按钮后执行的函数
 */
- (void)onSendMessage
{
    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
    data.conversationID = [NSString stringWithFormat:@"c2c_%@",self.userFullInfo.userID];
    data.userID = self.userFullInfo.userID;
    data.title = [self.userFullInfo showName];
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversationData = data;
    [self.navigationController pushViewController:chat animated:YES];
}

/**
 *  点击 加好友 按钮后执行的函数
 */
- (void)onAddFriend
{
//    FriendRequestViewController *vc = [FriendRequestViewController new];
//    vc.profile = self.userFullInfo;
//    [self.navigationController pushViewController:vc animated:YES];
    
    [self.view endEditing:YES];
    // display toast with an activity spinner
    [self.view makeToastActivity:CSToastPositionCenter];
    TIMFriendRequest *req = [[TIMFriendRequest alloc] init];
    req.addWording = self.helloStr;
    req.remark = @"";
    req.identifier = self.user.userId;
    req.addSource = @"iOS";
    req.addType = TIM_FRIEND_ADD_TYPE_BOTH;
    
    [[TIMFriendshipManager sharedInstance] addFriend:req succ:^(TIMFriendResult *result) {
        NSString *msg = [NSString stringWithFormat:@"%ld", (long)result.result_code];
        //根据回调类型向用户展示添加结果
        if (result.result_code == TIM_ADD_FRIEND_STATUS_PENDING) {
            msg = @"发送成功,等待审核同意";
        }
        if (result.result_code == TIM_ADD_FRIEND_STATUS_FRIEND_SIDE_FORBID_ADD) {
            msg = @"对方禁止添加";
        }
        if (result.result_code == 0) {
            msg = @"已添加到好友列表";
        }
        if (result.result_code == TIM_FRIEND_PARAM_INVALID) {
            msg = @"好友已存在";
        }

        [self.view hideToastActivity];
        [self.view makeToast:msg
                    duration:3.0
                    position:CSToastPositionBottom];

    } fail:^(int code, NSString *msg) {
        [self.view hideToastActivity];
        [THelper makeToastError:code msg:msg];
    }];
}

/**
 *  点击 同意(好友) 按钮后执行的函数
 */
- (void)onAgreeFriend
{
    [self.pendency agree];
}

- (void)onRejectFriend
{
    [self.pendency reject];
}

- (void)onAgreeGroup
{
    [self.groupPendency accept];
}

- (void)onRejectGroup
{
    [self.groupPendency reject];
}

- (UIView *)toastView
{
    return [UIApplication sharedApplication].keyWindow;
}

- (void)didTapOnAvatar:(ProfileCardCellData*)data{
    TUIAvatarViewController *image = [[TUIAvatarViewController alloc] init];
    image.avatarData = (TUIProfileCardCellData*)data;
    [self.navigationController pushViewController:image animated:true];
}
@end
