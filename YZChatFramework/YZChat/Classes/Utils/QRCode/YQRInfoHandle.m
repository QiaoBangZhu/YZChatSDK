//
//  YQRInfoHandle.m
//  YChat
//
//  Created by magic on 2020/11/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YQRInfoHandle.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "FriendProfileViewController.h"
#import "UserProfileController.h"
#import "ProfileViewController.h"
#import <ImSDKForiOS/TIMFriendshipManager.h>
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "THelper.h"

@interface YQRInfoHandle ()
@property (nonatomic, strong) UIViewController *baseController;
@end

@implementation YQRInfoHandle

DEF_SINGLETON(YQRInfoHandle);

- (void)identifyQRCode:(NSString *)info base:(UIViewController *)viewController {
    self.baseController = viewController;
    if (info) {
        if ([info containsString:@"key=ychat://user/info?"]) {
            NSArray *array = [info componentsSeparatedByString:@"key=ychat://user/info?"];
            if (array.count >= 2) {
                NSString *uIdStr = array[1];
                if ([uIdStr hasPrefix:@"u="] && uIdStr.length > 2) {
                    uIdStr = [uIdStr substringWithRange:NSMakeRange(2, uIdStr.length - 2)];
                }
                if (uIdStr.length > 0) {
                    [self handleUserInfo:uIdStr];
                }
            }
        }else if([info hasPrefix:@"http"]) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:info] options:@{} completionHandler:nil];
        }else {
            [self showAlert:@"二维码识别不出来"];
        }
    }else {
        [self showAlert:@"二维码识别不出来"];
    }
}

- (void)handleUserInfo:(NSString *)userId {
    @weakify(self)
    [[V2TIMManager sharedInstance] getFriendsInfo:@[userId] succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
        V2TIMFriendInfoResult *result = resultList.firstObject;
        if (result.relation == V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST || result.relation == V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY) {
            @strongify(self)
            id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
            if ([vc isKindOfClass:[UIViewController class]]) {
                vc.friendProfile = result.friendInfo;
                vc.isShowConversationAtTop = YES;
                [self.baseController.navigationController pushViewController:(UIViewController *)vc animated:YES];
            }
        } else {
            [[V2TIMManager sharedInstance] getUsersInfo:@[userId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                @strongify(self)
                if ([infoList.firstObject.userID isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
                    ProfileViewController* profileVc = [[ProfileViewController alloc]init];
                    [self.baseController.navigationController pushViewController:profileVc animated:true];
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
                    [self.baseController.navigationController pushViewController:(UIViewController *)vc animated:YES];
                }
            } fail:^(int code, NSString *msg) {
                [THelper makeToastError:code msg:msg];
            }];
        }
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
}

- (void)showAlert:(NSString *)alertContent {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:alertContent
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self.baseController presentViewController:alertController animated:YES completion:nil];
}

@end
