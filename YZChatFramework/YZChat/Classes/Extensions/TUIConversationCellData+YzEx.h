//
//  TUIConversationCellData+YzEx.h
//  YZChat
//
//  Created by 安笑 on 2021/4/11.
//

#import "TUIConversationCellData.h"

#import <ImSDKForiOS/ImSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIConversationCellData (YzEx)

+ (TUIConversationCellData *)makeDataByConversation:(V2TIMConversation *)conversation;
+ (TUIConversationCellData *)makeDataByConversation:(V2TIMConversation *)conversation
                                 hasJoinApplication:(BOOL)hasJoinApplication;

@end

NS_ASSUME_NONNULL_END
