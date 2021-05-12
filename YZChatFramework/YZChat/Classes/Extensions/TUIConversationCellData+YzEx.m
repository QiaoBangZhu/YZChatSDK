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

#import "YzCommonImport.h"

@implementation TUIConversationCellData (Conversation)

+ (TUIConversationCellData *)makeDataByConversation:(V2TIMConversation *)conversation {
    return [self makeDataByConversation: conversation hasJoinApplication: NO];
}

+ (TUIConversationCellData *)makeDataByConversation:(V2TIMConversation *)conversation
                                 hasJoinApplication:(BOOL)hasJoinApplication {
    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
    data.conversationID = conversation.conversationID;
    data.groupID = conversation.groupID;
    data.userID = conversation.userID;
    data.title = conversation.showName;
    data.faceUrl = conversation.faceUrl;
    data.subTitle = [self getLastDisplayString: conversation hasJoinApplication: hasJoinApplication];
    data.atMsgSeqList = [self getGroupAtMsgList: conversation];
    data.time = [self getLastDisplayDate: conversation];
    data.unreadCount = conversation.unreadCount;
    data.draftText = conversation.draftText;
    data.avatarImage = conversation.type == V2TIM_C2C ? DefaultAvatarImage : DefaultGroupAvatarImage;

    return  data;
}

+ (NSMutableAttributedString *)getLastDisplayString:(V2TIMConversation *)conversation
                                 hasJoinApplication:(BOOL)hasJoinApplication {
    NSString *atText = [self getGroupAtTipString: conversation];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString: atText];
    if (hasJoinApplication) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString: @"[加群申请]"]];
    }

    if(conversation.draftText.length > 0) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString: @"[草稿] "]];
    }

    NSUInteger length = text.length;
    [text setAttributes: @{ NSForegroundColorAttributeName: [UIColor d_systemRedColor] }
                  range: NSMakeRange(0, length)];

    NSDictionary *attributes = @{ NSForegroundColorAttributeName: [UIColor colorWithHex: KCommonBorderColor] };
    if (conversation.draftText.length > 0) {
        [text appendAttributedString: [[NSAttributedString alloc] initWithString: conversation.draftText]];
        [text setAttributes: attributes range: NSMakeRange(length, conversation.draftText.length)];
        return text;
    }

    NSString *message = [conversation.lastMessage getDisplayString];
    if (message.length > 0) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString: message]];
        [text setAttributes: attributes range: NSMakeRange(length, message.length)];
    }
    return text;
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
