//
//  GroupMemberController.m
//  YChat
//
//  Created by magic on 2020/9/26.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "GroupMemberController.h"
#import "ContactSelectViewController.h"
#import "UIColor+ColorExtension.h"
#import "TUICallModel.h"

@interface GroupMemberController ()

@end

@implementation GroupMemberController

- (void)viewDidLoad {
    [super viewDidLoad];
    TUIGroupMemberController *members = [[TUIGroupMemberController alloc] init];
    members.groupId = _groupId;
    members.delegate = self;
    [self addChildViewController:members];
    [self.view addSubview:members.view];
    members.groupMembersView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didCancelInGroupMemberController:(TUIGroupMemberController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)groupMemberController:(TUIGroupMemberController *)controller didAddMembersInGroup:(NSString *)groupId hasMembers:(NSMutableArray *)members
{
    ContactSelectViewController *vc = [[ContactSelectViewController alloc] initWithNibName:nil bundle:nil];
    vc.title = @"添加联系人";
    vc.viewModel.disableFilter = ^BOOL(TCommonContactSelectCellData *data) {
        for (UserModel *cd in members) {
            if ([cd.userId isEqualToString:data.identifier])
                return YES;
        }
        return NO;
    };
    @weakify(self)
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)groupMemberController:(TUIGroupMemberController *)controller didDeleteMembersInGroup:(NSString *)groupId hasMembers:(NSMutableArray *)members
{
    ContactSelectViewController *vc = [[ContactSelectViewController alloc] initWithNibName:nil bundle:nil];
    vc.title = @"删除联系人";
    vc.viewModel.avaliableFilter = ^BOOL(TCommonContactSelectCellData *data) {
        for (UserModel *cd in members) {
            if ([cd.userId isEqualToString:data.identifier])
                return YES;
        }
        return NO;
    };
    @weakify(self)
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)addGroupId:(NSString *)groupId memebers:(NSArray *)members controller:(TUIGroupMemberController *)controller
{
    [[V2TIMManager sharedInstance] inviteUserToGroup:_groupId userList:members succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        [THelper makeToast:@"添加成功"];
        [controller updateData];
    } fail:^(int code, NSString *desc) {
        [THelper makeToastError:code msg:desc];
    }];
}

- (void)deleteGroupId:(NSString *)groupId memebers:(NSArray *)members controller:(TUIGroupMemberController *)controller
{
    [[V2TIMManager sharedInstance] kickGroupMember:groupId memberList:members reason:@"" succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        [THelper makeToast:@"删除成功"];
        [controller updateData];
    } fail:^(int code, NSString *desc) {
        [THelper makeToastError:code msg:desc];
    }];
}



@end
