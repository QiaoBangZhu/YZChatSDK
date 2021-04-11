//
//  TUIConversationCellData+Conversation.h
//  YZChat
//
//  Created by 安笑 on 2021/4/11.
//

#import "TUIConversationCellData.h"

#import <ImSDKForiOS/ImSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIConversationCellData (Conversation)

+ (TUIConversationCellData *)makeDataByConversation:(V2TIMConversation *)conversation;

@end

NS_ASSUME_NONNULL_END