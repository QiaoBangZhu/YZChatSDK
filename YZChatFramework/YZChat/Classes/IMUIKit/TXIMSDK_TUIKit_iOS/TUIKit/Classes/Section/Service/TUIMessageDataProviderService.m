//
//  TElemDataProviderService.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/20.
//

#import "TUIMessageDataProviderService.h"
#import "TCServiceManager.h"
#import "TUITextMessageCell.h"
#import "TUISystemMessageCell.h"
#import "TUIVoiceMessageCell.h"
#import "TUIImageMessageCell.h"
#import "TUIFaceMessageCell.h"
#import "TUIVideoMessageCell.h"
#import "TUIFileMessageCell.h"
#import "LocationMessageCellData.h"
#import "TUIFaceView.h"
#import "TUIKit.h"
#import "NSString+TUICommon.h"
#import "TIMMessage+DataProvider.h"
#import "TIMUserProfile+DataProvider.h"
#import "TUIJoinGroupMessageCellData.h"
#import "TUICallManager.h"
//#import <ImSDK/ImSDK.h>
#import <ImSDKForiOS/ImSDK.h>

@TCServiceRegister(TUIMessageDataProviderServiceProtocol, TUIMessageDataProviderService)

@implementation TUIMessageDataProviderService

+ (BOOL)singleton
{
    return YES;
}

+ (id)shareInstance
{
    static TUIMessageDataProviderService *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (NSString *)getShowName:(V2TIMMessage *)message {
    NSString *showName = message.sender;
    if (message.nameCard.length > 0) {
        showName = message.nameCard;
    } else if (message.friendRemark.length > 0) {
        showName = message.friendRemark;
    } else if (message.nickName.length > 0) {
        showName = message.nickName;
    }
    return showName;
}

- (NSString *)getDisplayString:(V2TIMMessage *)msg
{
    NSString *str;
    if(msg.status == V2TIM_MSG_STATUS_LOCAL_REVOKED){
        if(msg.isSelf){
            str = @"你撤回了一条消息";
        }
        else if(msg.groupID != nil){
            //对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
            NSString *userString = msg.nameCard;;
            if(userString.length == 0){
                userString = msg.nickName;
            }
            if (userString.length == 0) {
                userString = msg.sender;
            }
            str = [NSString stringWithFormat:@"\"%@\"撤回了一条消息", userString];
        }
        else if(msg.userID != nil){
            str = @"对方撤回了一条消息";
        }
    } else {
        switch (msg.elemType) {
            case V2TIM_ELEM_TYPE_TEXT:
            {
                str = msg.textElem.text;
            }
                break;
            case V2TIM_ELEM_TYPE_CUSTOM:
            {
                str = [self getCustomElemContent:msg];
            }
                break;
            case V2TIM_ELEM_TYPE_IMAGE:
            {
                str = @"[图片]";
            }
                break;
            case V2TIM_ELEM_TYPE_SOUND:
            {
                str = @"[语音]";
            }
                break;
            case V2TIM_ELEM_TYPE_VIDEO:
            {
                str = @"[视频]";
            }
                break;
            case V2TIM_ELEM_TYPE_FILE:
            {
                str = @"[文件]";
            }
                break;
            case V2TIM_ELEM_TYPE_LOCATION:
            {
                str = @"[位置]";
                
            }
                break;
            case V2TIM_ELEM_TYPE_FACE:
            {
                str = @"[动画表情]";
            }
                break;
            
            case V2TIM_ELEM_TYPE_GROUP_TIPS:
            {
                V2TIMGroupTipsElem *tips = msg.groupTipsElem;
                NSString *opUser = [self getOpUserName:tips.opMember];
                NSMutableArray<NSString *> *userList = [self getUserNameList:tips.memberList];
                switch (tips.type) {
                        case V2TIM_GROUP_TIPS_TYPE_JOIN:
                        {
                            if (opUser.length > 0) {
                                str = [NSString stringWithFormat:@"\"%@\"加入群组", opUser];
                            }
                        }
                            break;
                        case V2TIM_GROUP_TIPS_TYPE_INVITE:
                        {
                            if (userList.count > 0) {
                                NSString *users = [userList componentsJoinedByString:@"、"];
//                                str = [NSString stringWithFormat:@"\"%@\"邀请\"%@\"加入群组", opUser, users];
                                str = [NSString stringWithFormat:@"\"%@\"加入群组", users];

                            }
                        }
                            break;
                        case V2TIM_GROUP_TIPS_TYPE_QUIT:
                        {
                            if (opUser.length > 0) {
                                str = [NSString stringWithFormat:@"\"%@\"退出了群聊", opUser];
                            }
                        }
                            break;
                        case V2TIM_GROUP_TIPS_TYPE_KICKED:
                        {
                            if (userList.count > 0) {
                                NSString *users = [userList componentsJoinedByString:@"、"];
//                                str = [NSString stringWithFormat:@"\"%@\"将\"%@\"踢出群组", opUser, users];
                                str = [NSString stringWithFormat:@"\"%@\"被踢出群组", users];

                            }
                        }
                            break;
                        case V2TIM_GROUP_TIPS_TYPE_SET_ADMIN:
                        {
                            if (userList.count > 0) {
                                NSString *users = [userList componentsJoinedByString:@"、"];
                                str = [NSString stringWithFormat:@"\"%@\"被设置管理员", users];
                            }
                        }
                            break;
                        case V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN:
                        {
                            if (userList.count > 0) {
                                NSString *users = [userList componentsJoinedByString:@"、"];
                                str = [NSString stringWithFormat:@"\"%@\"被取消管理员", users];
                            }
                        }
                            break;
                        case V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE:
                        {
                            str = [NSString stringWithFormat:@"\"%@\"", opUser];
                            for (V2TIMGroupChangeInfo *info in tips.groupChangeInfoList) {
                                switch (info.type) {
                                    case V2TIM_GROUP_INFO_CHANGE_TYPE_NAME:
                                    {
                                        str = [NSString stringWithFormat:@"%@修改群名为\"%@\"、", str, info.value];
                                    }
                                        break;
                                    case V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION:
                                    {
                                        str = [NSString stringWithFormat:@"%@修改群简介为\"%@\"、", str, info.value];
                                    }
                                        break;
                                    case V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION:
                                    {
                                        str = [NSString stringWithFormat:@"%@修改群公告为\"%@\"、", str, info.value];
                                    }
                                        break;
                                    case V2TIM_GROUP_INFO_CHANGE_TYPE_FACE:
                                    {
                                        str = [NSString stringWithFormat:@"%@修改群头像、", str];
                                    }
                                        break;
                                    case V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER:
                                    {
#pragma  mark -- private by magic
                                        str = [NSString stringWithFormat:@"%@转让了群主\"、", str];
//                                        str = [NSString stringWithFormat:@"%@修改群主为\"%@\"、", str, info.value];
                                    }
                                        break;
                                    default:
                                        break;
                                }
                            }
                            if (str.length > 0) {
                                str = [str substringToIndex:str.length - 1];
                            }
                        }
                            break;
                        default:
                            break;
                    }
            }
                break;
            default:
                break;
        }
//        for (int i = 0; i < msg.elemCount; ++i) {
//
//            else if([elem isKindOfClass:[TIMGroupTipsElem class]]){
//
//            }
//            else if ([elem isKindOfClass:[TIMGroupSystemElem class]]) {
//                // TODO: 退群消息由于SDK的bug，导致经常接收不到
//                // GroupSeystem的conv->groupId为空
//                TIMGroupSystemElem *tips = (TIMGroupSystemElem *)elem;
//                switch (tips.type) {
//                    case TIM_GROUP_SYSTEM_DELETE_GROUP_TYPE: {
//                        str = @"您所在的群已解散";
//                    }
//                        break;
//                    default:
//                        break;
//                }
//            }
//        }
    }
    return str;
}

-(TUIMessageCellData *) getCellData:(V2TIMMessage *)message{
    TUIMessageCellData *data = nil;
    switch (message.elemType) {
        case V2TIM_ELEM_TYPE_TEXT:
        {
            data = [self getTextCellData:message fromElem:message.textElem];
        }
            break;
        case V2TIM_ELEM_TYPE_CUSTOM:
        {
            data = [self getCustomCellData:message fromElem:message.customElem];
        }
            break;
        case V2TIM_ELEM_TYPE_IMAGE:
        {
            data = [self getImageCellData:message fromElem:message.imageElem];
        }
            break;
        case V2TIM_ELEM_TYPE_SOUND:
        {
            data = [self getVoiceCellData:message fromElem:message.soundElem];
        }
            break;
        case V2TIM_ELEM_TYPE_VIDEO:
        {
            data = [self getVideoCellData:message fromElem:message.videoElem];
        }
            break;
        case V2TIM_ELEM_TYPE_FILE:
        {
            data = [self getFileCellData:message fromElem:message.fileElem];
        }
            break;
        case V2TIM_ELEM_TYPE_LOCATION:
        {
            data = [self getLocationCellData:message fromElem:message.locationElem];
         
        }
            break;
        case V2TIM_ELEM_TYPE_FACE:
        {
            data = [self getFaceCellData:message fromElem:message.faceElem];
        }
            break;
        case V2TIM_ELEM_TYPE_GROUP_TIPS:
        {
            data = [self getSystemCellData:message fromElem:message.groupTipsElem];
        }
            break;
        default:
            break;
    }
    data.avatarUrl = [NSURL URLWithString:message.faceURL];
    return data;
}

- (TUITextMessageCellData *) getTextCellData:(V2TIMMessage *)message  fromElem:(V2TIMTextElem *)elem{
    TUITextMessageCellData *textData = [[TUITextMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    textData.content = elem.text;
    return textData;
}

- (TUIFaceMessageCellData *) getFaceCellData:(V2TIMMessage *)message  fromElem:(V2TIMFaceElem *)elem{
    TUIFaceMessageCellData *faceData = [[TUIFaceMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    faceData.groupIndex = elem.index;
    faceData.faceName = [[NSString alloc] initWithData:elem.data encoding:NSUTF8StringEncoding];
    for (TFaceGroup *group in [TUIKit sharedInstance].config.faceGroups) {
        if(group.groupIndex == faceData.groupIndex){
            NSString *path = [group.groupPath stringByAppendingPathComponent:faceData.faceName];
            faceData.path = path;
            break;
        }
    }
    faceData.reuseId = TFaceMessageCell_ReuseId;
    return faceData;
}

- (TUIImageMessageCellData *) getImageCellData:(V2TIMMessage *)message fromElem:(V2TIMImageElem *)elem{
    TUIImageMessageCellData *imageData = [[TUIImageMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    imageData.path = [elem.path safePathString];
    imageData.items = [NSMutableArray array];
    for (V2TIMImage *item in elem.imageList) {
        TUIImageItem *itemData = [[TUIImageItem alloc] init];
        itemData.uuid = item.uuid;
        itemData.size = CGSizeMake(item.width, item.height);
//        itemData.url = item.url;
        if(item.type == V2TIM_IMAGE_TYPE_THUMB){
            itemData.type = TImage_Type_Thumb;
        }
        else if(item.type == V2TIM_IMAGE_TYPE_LARGE){
            itemData.type = TImage_Type_Large;
        }
        else if(item.type == V2TIM_IMAGE_TYPE_ORIGIN){
            itemData.type = TImage_Type_Origin;
        }
        [imageData.items addObject:itemData];
    }
    return imageData;
}

- (TUIVoiceMessageCellData *) getVoiceCellData:(V2TIMMessage *) message fromElem:(V2TIMSoundElem *) elem{
    TUIVoiceMessageCellData *soundData = [[TUIVoiceMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    soundData.duration = elem.duration;
    soundData.length = elem.dataSize;
    soundData.uuid = elem.uuid;
    return soundData;
}

- (TUIVideoMessageCellData *) getVideoCellData:(V2TIMMessage *)message fromElem:(V2TIMVideoElem *) elem{
    TUIVideoMessageCellData *videoData = [[TUIVideoMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    videoData.videoPath = [elem.videoPath safePathString];
    videoData.snapshotPath = [elem.snapshotPath safePathString];

    videoData.videoItem = [[TUIVideoItem alloc] init];
    videoData.videoItem.uuid = elem.videoUUID;
    videoData.videoItem.type = elem.videoType;
    videoData.videoItem.length = elem.videoSize;
    videoData.videoItem.duration = elem.duration;

    videoData.snapshotItem = [[TUISnapshotItem alloc] init];
    videoData.snapshotItem.uuid = elem.snapshotUUID;
//    videoData.snapshotItem.type = elem.snaps;
    videoData.snapshotItem.length = elem.snapshotSize;
    videoData.snapshotItem.size = CGSizeMake(elem.snapshotWidth, elem.snapshotHeight);

    return videoData;
}

- (TUIFileMessageCellData *) getFileCellData:(V2TIMMessage *)message fromElem:(V2TIMFileElem *)elem{
    TUIFileMessageCellData *fileData = [[TUIFileMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    fileData.path = [elem.path safePathString];
    fileData.fileName = elem.filename;
    fileData.length = elem.fileSize;
    fileData.uuid = elem.uuid;
    return fileData;
}

- (LocationMessageCellData *) getLocationCellData:(V2TIMMessage *)message fromElem:(V2TIMLocationElem *)elem {
    LocationMessageCellData *locationData = [[LocationMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    locationData.latitude = elem.latitude;
    locationData.longitude = elem.longitude;
    locationData.text = elem.desc;
    return locationData;
}

-(TUIMessageCellData *)getCustomCellData:(V2TIMMessage *)message fromElem:(V2TIMCustomElem *)elem {
    if (elem == nil || elem.data == nil || elem.data.length == 0) {
        return nil;
    }
    if (message.groupID.length > 0) {
        TUISystemMessageCellData *cellData = [[TUISystemMessageCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
        cellData.content = [self getCustomElemContent:message];
        return cellData;
    } else {
        TUITextMessageCellData *cellData = [[TUITextMessageCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
        NSString *content = [self getCustomElemContent:message];
        if (content.length > 0) {
            cellData.content = content;
        } else {
            cellData = nil;
        }
        return cellData;
    }
}

- (NSString *)getCustomElemContent:(V2TIMMessage *)message {
    if (message.customElem == nil || message.customElem.data == nil) {
        return nil;
    }
    // 先判断下是不是信令消息
    V2TIMSignalingInfo *info = [[V2TIMManager sharedInstance] getSignallingInfo:message];
    if (info != nil) {
        return [self getCustomSignalingContentWithMessage:message signalingInfo:info];
    }
    NSError *err = nil;
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingMutableContainers error:&err];
    if (param != nil) {
        NSInteger version = [param[@"version"] integerValue];
        NSString *businessID = param[@"businessID"];
        // 判断是不是音视频通话自定义消息
        if ([businessID isEqualToString:AVCall]) {
            return @"";
        }
        // 判断是不是群直播自定义消息
        else if ([businessID isEqualToString:GroupLive]) {
            // **的直播
            if ([param.allKeys containsObject:@"anchorName"] && [param.allKeys containsObject:@"anchorId"]) {
                NSString *anchorName = param[@"anchorName"];
                if (anchorName.length == 0) {
                    anchorName = param[@"anchorId"];
                }
                return [NSString stringWithFormat:@"[%@的直播]", anchorName];
            }
        }
        // 判断是不是群创建自定义消息
        else if ([businessID isEqualToString:GroupCreate]) {
            if (version <= GroupCreate_Version) {
                return [NSString stringWithFormat:@"\"%@\"%@",param[@"opUser"],param[@"content"]];
            }
        }
        // 老版本的群创建自定义消息 businessID ，这里要兼容下
        else if ([param.allKeys containsObject:GroupCreate]) {
            NSString *opUser = message.sender;
            if (message.nameCard.length > 0) {
                opUser = message.nameCard;
            } else if (message.friendRemark.length > 0) {
                opUser = message.friendRemark;
            } if (message.nickName.length > 0) {
                opUser = message.nickName;
            }
            return [NSString stringWithFormat:@"\"%@\"创建群组",opUser];
        }
        else if ([businessID isEqualToString:CardLink]) {
            if (version <= TextLink_Version) {
                return @"[链接]";
            }
        }
    }
    // 不支持的自定义消息
    return @"[不支持的自定义消息]";
}

/// 信令消息对应的自定义文本，默认是音视频通话
- (NSString *)getCustomSignalingContentWithMessage:(V2TIMMessage *)message signalingInfo:(V2TIMSignalingInfo *)info
{
    // 解析透传的data字段
    NSError *err = nil;
    NSDictionary *param = nil;
    if (info.data != nil) {
        param = [NSJSONSerialization JSONObjectWithData:[info.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    }
    
    // 判断是否为TRTC的信令
    NSString *liveRoomContent = @"";
    if ([self isLiveRoomSignalingInfo:info infoData:param withCustomContent:&liveRoomContent]) {
        return liveRoomContent;
    }
    
    // .... 此处补充其他的业务，业务的区分目前仅仅是以info.data的接口来区分的，所以自行判断
    
    
    // 默认是音视频通话的信令
    NSMutableString *content = [NSMutableString string];
    switch (info.actionType) {
        case SignalingActionType_Invite:
        {
            // 结束通话
            if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_CALL_END]) {
                int duration = [param[SIGNALING_EXTRA_KEY_CALL_END] intValue];
                [content appendString:message.groupID.length > 0 ? @"结束群聊" : [NSString stringWithFormat:@"结束通话，通话时长：%.2d:%.2d",duration / 60,duration % 60]];
            } else {
            // 发起通话
                if (message.groupID.length > 0) {
                    [content appendString:[NSString stringWithFormat:@"\"%@\" 发起群通话",[self getShowName:message]]];
                } else {
                    [content appendString:@"发起通话"];
                }
            }
        }
            break;
        case SignalingActionType_Cancel_Invite:
        {
            // 取消通话
            if (message.groupID.length > 0) {
                [content appendString:[NSString stringWithFormat:@"\"%@\" 取消群通话",[self getShowName:message]]];
            } else {
                [content appendString:@"取消通话"];
            }
        }
            break;
        case SignalingActionType_Accept_Invite:
        {
            // 接受通话
            if (message.groupID.length > 0) {
                [content appendString:[NSString stringWithFormat:@"\"%@\" 已接听",[self getShowName:message]]];
            } else {
                [content appendString:@"已接听"];
            }
        }
            break;
        case SignalingActionType_Reject_Invite:
        {
            // 拒绝通话
            if (message.groupID.length > 0) {
                if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_LINE_BUSY]) {
                    [content appendString:[NSString stringWithFormat:@"\"%@\" 忙线",[self getShowName:message]]];
                } else {
                    [content appendString:[NSString stringWithFormat:@"\"%@\" 拒绝通话",[self getShowName:message]]];
                }
            } else {
                if ([param.allKeys containsObject:SIGNALING_EXTRA_KEY_LINE_BUSY]) {
                    [content appendString:@"对方忙线"];
                } else {
                    [content appendString:@"拒绝通话"];
                }
            }
        }
            break;
        case SignalingActionType_Invite_Timeout:
        {
            // 通话超时
            if (message.groupID.length > 0) {
                for (NSString *invitee in info.inviteeList) {
                    [content appendString:@"\""];
                    [content appendString:invitee];
                    [content appendString:@"\"、"];
                }
                [content replaceCharactersInRange:NSMakeRange(content.length - 1, 1) withString:@" "];
            }
//            [content appendString:@"无应答"];
            // magic
            content = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"有%lu人无应答",(unsigned long)info.inviteeList.count]];
        }
            break;
        default:
        {
            [content appendString:@"不能识别的通话指令"];
        }
            break;
    }
    return content;
}

// 直播间自定义信令文本
- (BOOL)isLiveRoomSignalingInfo:(V2TIMSignalingInfo *)info infoData:(NSDictionary *)param withCustomContent:(NSString **)content
{
    *content = @"";
    
    if (param == nil) {
        return NO;
    }
    
    NSArray *allKeys = param.allKeys;
    if (![allKeys containsObject:@"businessID"]) {
        return NO;
    }
    
    NSString *businessId = [param objectForKey:@"businessID"];
    if (![businessId isEqualToString:Signal_Business_Live]) {
        return NO;
    }
    
    NSInteger actionCode = [[param objectForKey:@"action"] integerValue];
    switch (actionCode) {
        case 100: *content = @"直播间申请上麦"; break;
        case 101:
            if (info.actionType == SignalingActionType_Reject_Invite) {
                *content = @"直播间申请上麦被拒绝";
            } else if (info.actionType == SignalingActionType_Accept_Invite) {
                *content = @"直播间同意上麦";
            }
            break;
        case 102: *content = @"直播间申请关闭连麦"; break;
        case 103: *content = @"直播间关闭连麦"; break;
        case 200:
            if (info.actionType == SignalingActionType_Invite) {
                *content = @"直播间申请PK";
            }
            break;
        case 201:
            if (info.actionType == SignalingActionType_Reject_Invite) {
                *content = @"直播间申请PK被拒绝";
            } else if (info.actionType == SignalingActionType_Accept_Invite) {
                *content = @"直播间同意PK";
            }
            break;
        case 202: *content = @"直播间退出PK"; break;
        default:
            *content = @"不能识别的通话指令";
            break;
    }
    return YES;
}

- (TUISystemMessageCellData *) getSystemCellData:(V2TIMMessage *)message fromElem:(V2TIMGroupTipsElem *)elem{
    V2TIMGroupTipsElem *tip = (V2TIMGroupTipsElem *)elem;
    NSString *opUserName = [self getOpUserName:tip.opMember];
    NSMutableArray<NSString *> *userNameList = [self getUserNameList:tip.memberList];
    NSMutableArray<NSString *> *userIDList = [self getUserIDList:tip.memberList];
    if(tip.type == V2TIM_GROUP_TIPS_TYPE_JOIN || tip.type == V2TIM_GROUP_TIPS_TYPE_INVITE || tip.type == V2TIM_GROUP_TIPS_TYPE_KICKED || tip.type == V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE || tip.type == V2TIM_GROUP_TIPS_TYPE_QUIT){
        TUIJoinGroupMessageCellData *joinGroupData = [[TUIJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        joinGroupData.content = [self getDisplayString:message];
        joinGroupData.opUserName = opUserName;
        joinGroupData.opUserID = tip.opMember.userID;
        joinGroupData.userNameList = userNameList;
        joinGroupData.userIDList = userIDList;
        return joinGroupData;
    } else {
        //其他群Tips消息正常处理
        TUISystemMessageCellData *sysdata = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        sysdata.content = [self getDisplayString:message];
        if (sysdata.content.length) {
            return sysdata;
        }
    }
    return nil;
}

- (TUISystemMessageCellData *) getRevokeCellData:(V2TIMMessage *)message{

    TUISystemMessageCellData *revoke = [[TUISystemMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    if(message.isSelf){
        revoke.content = @"你撤回了一条消息";
        revoke.innerMessage = message;
        return revoke;
    } else if (message.userID.length > 0){
        revoke.content = @"对方撤回了一条消息";
        revoke.innerMessage = message;
        return revoke;
    } else if (message.groupID.length > 0) {
        //对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
        NSString *userName = message.sender;
        if (message.nameCard.length > 0) {
            userName = message.nameCard;
        } else if (message.nickName.length > 0) {
            userName = message.nickName;
        }
        TUIJoinGroupMessageCellData *joinGroupData = [[TUIJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        joinGroupData.content = [NSString stringWithFormat:@"\"%@\"撤回了一条消息",userName];
        joinGroupData.opUserID = message.sender;
        joinGroupData.opUserName = userName;
        return joinGroupData;
    }
    return nil;
}

-(NSString *)getOpUserName:(V2TIMGroupMemberInfo *)info{
    NSString *opUser;
    if (info.nameCard.length > 0){
        opUser = info.nameCard;
    } else if (info.nickName.length > 0) {
        opUser = info.nickName;
    } else {
        opUser = info.userID;
    }
    return opUser;
}

-(NSMutableArray *)getUserNameList:(NSArray<V2TIMGroupMemberInfo *> *)infoList{
    NSMutableArray<NSString *> *userNameList = [NSMutableArray array];
    for (V2TIMGroupMemberInfo *info in infoList) {
        if(info.nameCard.length > 0) {
            [userNameList addObject:info.nameCard];
        } else if (info.nickName.length > 0){
            [userNameList addObject:info.nickName];
        }else{
            [userNameList addObject:info.userID];
        }
    }
    return userNameList;
}

-(NSMutableArray *)getUserIDList:(NSArray<V2TIMGroupMemberInfo *> *)infoList{
    NSMutableArray<NSString *> *userIDList = [NSMutableArray array];
    for (V2TIMGroupMemberInfo *info in infoList) {
        [userIDList addObject:info.userID];
    }
    return userIDList;
}
@end
