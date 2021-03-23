//
//  YZMsgManager.m
//  YZChat
//
//  Created by magic on 2021/1/8.
//

#import "YZMsgManager.h"
#import "YZCardMsgCellData.h"
#import "YZUtil.h"
#import "TUICallUtils.h"
#import "TUISystemMessageCellData.h"
#import "THelper.h"
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import <ImSDKForiOS/ImSDK.h>

@implementation YZMsgManager

+ (YZMsgManager *)shareInstance {
    static dispatch_once_t onceToken;
    static YZMsgManager * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[YZMsgManager alloc] init];
    });
    return g_sharedInstance;
}

- (void)sendMessageWithMsgType:(YZSendMsgType)type
                       message:(YzCustomMsg *)msg
                        userId:(NSString*)userId
                         grpId:(NSString*)grpId
                  loginSuccess:(YZMsgManagerSucc)success
                   loginFailed:(YZMsgManagerFail)fail {
    if ([msg.title length] == 0) {
        [THelper makeToast:@"标题不能为空"];
        return;
    }
    if ([msg.link length] == 0) {
        [THelper makeToast:@"link不能为空"];
        return;
    }
    if ([msg.desc length] == 0) {
        [THelper makeToast:@"描述不能为空"];
        return;
    }
    if ([msg.logo length] == 0) {
        [THelper makeToast:@"图片地址不能为空"];
        return;
    }
    
    YZCardMsgCellData *cellData = [[YZCardMsgCellData alloc] initWithDirection:MsgDirectionOutgoing];
    cellData.title = msg.title;
    cellData.link = msg.link;
    cellData.des = msg.desc;
    cellData.logo = msg.logo;
    cellData.innerMessage = [[V2TIMManager sharedInstance] createCustomMessage:[YZUtil dictionary2JsonData:@{@"version": @(TextLink_Version),@"businessID": CardLink,@"title":msg.title,@"link":msg.link,@"desc":msg.desc, @"logo": msg.logo}]];
    
    V2TIMMessage *imMsg = cellData.innerMessage;
    TUIMessageCellData *dateMsg = nil;
    if (imMsg.status == Msg_Status_Init)
    {
        dateMsg = [self transSystemMsgFromDate:imMsg.timestamp];
    }
    // 设置推送
    V2TIMOfflinePushInfo *info = [[V2TIMOfflinePushInfo alloc] init];
    int chatType = 0;
    NSString *sender = @"";
    if (type == YZSendMsgTypeGrp) {
        chatType = 2;
        sender = grpId;
    } else {
        chatType = 1;
        NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
        if (loginUser.length > 0) {
            sender = loginUser;
        }
    }
    NSDictionary *extParam = @{@"entity":@{@"action":@(APNs_Business_NormalMsg),@"chatType":@(chatType),@"sender":sender,@"version":@(APNs_Version)}};
    info.ext = [TUICallUtils dictionary2JsonStr:extParam];
    // 发消息
    [[V2TIMManager sharedInstance] sendMessage:imMsg receiver:userId groupID:grpId priority:V2TIM_PRIORITY_DEFAULT onlineUserOnly:NO offlinePushInfo:info progress:^(uint32_t progress) {
    } succ:^{
        success();
    } fail:^(int code, NSString *desc) {
        fail(code,desc);
    }];
}

- (TUISystemMessageCellData *)transSystemMsgFromDate:(NSDate *)date
{
    TUISystemMessageCellData *systemCell = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    systemCell.content = [date tk_messageString];
    systemCell.reuseId = TSystemMessageCell_ReuseId;
    return systemCell;
}

@end
