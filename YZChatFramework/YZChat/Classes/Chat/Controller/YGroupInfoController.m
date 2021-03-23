//
//  YGroupInfoController.m
//  YChat
//
//  Created by magic on 2020/9/26.
//  Copyright © 2020 Apple. All rights reserved.
//
/** 群组信息视图
 *  本文件实现了群组信息的展示页面
 *
 *  您可以通过此界面查看特定群组的信息，包括群名称、群成员、群类型等
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */

#import "YGroupInfoController.h"
#import "TUIGroupInfoController.h"
#import "YGroupMemberController.h"
#import "TUIGroupMemberCell.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "Toast/Toast.h"
#import "THelper.h"
#import <ImSDKForiOS/ImSDK.h>
#import "TIMGroupInfo+DataProvider.h"
#import "TCommonTextCell.h"
#import "TUIGroupMembersCell.h"
#import "TCommonSwitchCell.h"
#import "YZButtonTableViewCell.h"
#import "TUILocalStorage.h"
#import "YUIGroupInfoController.h"
#import "YContactSelectViewController.h"
#import "UIColor+ColorExtension.h"
#import <Masonry/Masonry.h>
#import "YZProfileViewController.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"

@interface YGroupInfoController ()<YGroupInfoControllerDelegate>

@end

@implementation YGroupInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"群聊详情";
    
    YUIGroupInfoController *info = [[YUIGroupInfoController alloc] init];
    info.groupId = _groupId;
    info.delegate = self;
    info.view.frame = self.view.bounds;
    [self addChildViewController:info];
    [self.view addSubview:info.view];
    info.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
//    [info.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(@0);
//    }];
}

/*
 *点击了群成员头像
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didSelectMemberAvatar:(NSString *)memberId {
    @weakify(self)
    [[V2TIMManager sharedInstance] getFriendsInfo:@[memberId] succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
        V2TIMFriendInfoResult *result = resultList.firstObject;
        if (result.relation == V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST || result.relation == V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY) {
            @strongify(self)
            id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
            if ([vc isKindOfClass:[UIViewController class]]) {
                vc.friendProfile = result.friendInfo;
                vc.isShowConversationAtTop = YES;
                [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
            }
        } else {
            [[V2TIMManager sharedInstance] getUsersInfo:@[memberId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                @strongify(self)
                if ([infoList.firstObject.userID isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
                    YZProfileViewController* profileVc = [[YZProfileViewController alloc]init];
                    [self.navigationController pushViewController:profileVc animated:true];
                    return;
                }
                id<TUIUserProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileControllerServiceProtocol)];
                if ([vc isKindOfClass:[UIViewController class]]) {
                    vc.userFullInfo = infoList.firstObject;
                    if ([vc.userFullInfo.userID isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
                        vc.actionType = PCA_NONE;
                    } else {
                        vc.actionType = PCA_ADD_FRIEND;
                    }
                    [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
                }
            } fail:^(int code, NSString *msg) {
                [THelper makeToastError:code msg:msg];
            }];
        }
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
}

/**
 *点击 群成员 按钮后的响应函数
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didSelectMembersInGroup:(NSString *)groupId
{
    YGroupMemberController *membersController = [[YGroupMemberController alloc] init];
    membersController.groupId = groupId;
    membersController.title = @"群成员";
    [self.navigationController pushViewController:membersController animated:YES];
}

/**
 *点击添加群成员后的响应函数->进入添加群成员视图
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didAddMembersInGroup:(NSString *)groupId members:(NSArray<TGroupMemberCellData *> *)members
{
    YContactSelectViewController *vc = [[YContactSelectViewController alloc] initWithNibName:nil bundle:nil];
    vc.title = @"添加联系人";
    vc.viewModel.disableFilter = ^BOOL(TCommonContactSelectCellData *data) {
        for (TGroupMemberCellData *cd in members) {
            if ([cd.identifier isEqualToString:data.identifier])
                return YES;
        }
        return NO;
    };
    @weakify(self)
    [self.navigationController pushViewController:vc animated:YES];
    //添加成功后默认返回群组聊天界面
    vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *selectArray) {
        @strongify(self)
        NSMutableArray *list = @[].mutableCopy;
        for (TCommonContactSelectCellData *data in selectArray) {
            [list addObject:data.identifier];
        }
        [self.navigationController popToViewController:self animated:YES];
        [self addGroupId:groupId memebers:list controller:controller];
    };
}

/**
 *点击删除群成员后的响应函数->进入删除群成员视图
 *删除群成员按钮为群成员头像队列后的 "-" 按钮
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didDeleteMembersInGroup:(NSString *)groupId members:(NSArray<TGroupMemberCellData *> *)members
{
    YContactSelectViewController *vc = [[YContactSelectViewController alloc] initWithNibName:nil bundle:nil];
    vc.title = @"删除联系人";
    NSMutableArray *ids = NSMutableArray.new;
    for (TGroupMemberCellData *cd in members) {
        if (![cd.identifier isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
            [ids addObject:cd.identifier];
        }
    }
    [vc setSourceIds:ids];

    @weakify(self)
    [self.navigationController pushViewController:vc animated:YES];
    //删除成功后默认返回群组聊天界面
    vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> *selectArray) {
        @strongify(self)
        NSMutableArray *list = @[].mutableCopy;
        for (TCommonContactSelectCellData *data in selectArray) {
            [list addObject:data.identifier];
        }
        [self.navigationController popToViewController:self animated:YES];
        [self deleteGroupId:groupId memebers:list controller:controller];
    };
}

/**
 *确认添加群成员后的执行函数，函数内包含请求后的回调
 */
- (void)addGroupId:(NSString *)groupId memebers:(NSArray *)members controller:(TUIGroupInfoController *)controller
{
    [[V2TIMManager sharedInstance] inviteUserToGroup:_groupId userList:members succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        [THelper makeToast:@"添加成功"];
        [controller updateData];
    } fail:^(int code, NSString *desc) {
        [THelper makeToastError:code msg:desc];
    }];
}

/**
 *确认删除群成员后的执行函数，函数内包含请求后的回调
 */
- (void)deleteGroupId:(NSString *)groupId memebers:(NSArray *)members controller:(TUIGroupInfoController *)controller
{
    [[V2TIMManager sharedInstance] kickGroupMember:groupId memberList:members reason:@"" succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        [THelper makeToast:@"删除成功"];
        [controller updateData];
    } fail:^(int code, NSString *desc) {
        [THelper makeToastError:code msg:desc];
    }];
}

/**
 *解散群组后执行的函数，默认回到上一界面
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didDeleteGroup:(NSString *)groupId
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers firstObject] animated:YES];
}

/**
 *退出群组后执行的函数，默认回到上一界面
 */
- (void)groupInfoController:(TUIGroupInfoController *)controller didQuitGroup:(NSString *)groupId
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers firstObject] animated:YES];
}

- (void)groupInfoController:(YUIGroupInfoController *)controller didSelectChangeAvatar:(NSString *)groupId {
    
}

@end
