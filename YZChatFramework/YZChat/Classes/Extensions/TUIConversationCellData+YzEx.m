//
//  TUIConversationCellData+YzEx.m
//  YZChat
//
//  Created by 安笑 on 2021/4/11.
//

#import "TUIConversationCellData+YzEx.h"

#import "THeader.h"
#import "TUIKit.h"
#import "TIMMessage+DataProvider.h"
#import "UIColor+TUIDarkMode.h"

@implementation TUIConversationCellData (Conversation)

+ (TUIConversationCellData *)makeDataByConversation:(V2TIMConversation *)conversation {
    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
    data.conversationID = conversation.conversationID;
    data.groupID = conversation.groupID;
    data.userID = conversation.userID;
    data.title = conversation.showName;
    data.faceUrl = conversation.faceUrl;
    data.subTitle = [self getLastDisplayString: conversation];
    data.atMsgSeqList = [self getGroupAtMsgList: conversation];
    data.time = [self getLastDisplayDate: conversation];
    data.unreadCount = conversation.unreadCount;
    data.draftText = conversation.draftText;
    if (conversation.type == V2TIM_C2C) {   // 设置会话的默认头像
        data.avatarImage = DefaultAvatarImage;
    } else {
        data.avatarImage = DefaultGroupAvatarImage;
    }

    return  data;
}

+ (NSMutableAttributedString *)getLastDisplayString:(V2TIMConversation *)conversation {
    NSString *atStr = [self getGroupAtTipString:conversation];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",atStr]];
    NSDictionary *attributeDict = @{NSForegroundColorAttributeName:[UIColor d_systemRedColor]};
    [attributeString setAttributes:attributeDict range:NSMakeRange(0, attributeString.length)];

    if(conversation.draftText.length > 0){
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"[草稿] %@",conversation.draftText]]];
        return attributeString;
    }
    NSString *lastMsgStr = [conversation.lastMessage getDisplayString];
    if (lastMsgStr.length > 0) {
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:lastMsgStr]];
    }
    return attributeString;
}

+ (NSMutableArray<NSNumber *> *)getGroupAtMsgList:(V2TIMConversation *)conversation {
    NSMutableArray *temp = [NSMutableArray array];
    for (V2TIMGroupAtInfo *atInfo in conversation.groupAtInfolist) {
        [temp addObject:@(atInfo.seq)];
    }
    if (temp.count > 0) {
        return temp;
    }
    return nil;
}

+ (NSDate *)getLastDisplayDate:(V2TIMConversation *)conversation {
    if(conversation.draftText.length > 0) {
        return conversation.draftTimestamp;
    }
    if (conversation.lastMessage) {
        return conversation.lastMessage.timestamp;
    }
    return [NSDate distantPast];
}

+ (NSString *)getGroupAtTipString:(V2TIMConversation *)conversation {
    NSInteger count = conversation.groupAtInfolist.count;
    if (count) {
        switch (conversation.groupAtInfolist[count - 1].atType) {
            case V2TIM_AT_ME:
                return @"[有人@我]";
            case V2TIM_AT_ALL:
                return @"[@所有人]";
            case V2TIM_AT_ALL_AT_ME:
                return @"[有人@我][@所有人]";
            default:
                break;
        }
    }
    return  @"";
}

@end
