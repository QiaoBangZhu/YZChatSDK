//
//  YzIMKitAgent+Private.h
//  YZChat
//
//  Created by 安笑 on 2021/4/25.
//

#import "YzIMKitAgent.h"

#import "YzCustomMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface YzIMKitAgent (Private_Message)

- (void)sendCustomMessage:(YzCustomMessageData*)message
                   userId:(nullable NSString *)userId
                  groupId:(nullable NSString *)groupId
                  success:(YzChatSysUserSuccess)success
                  failure:(YzChatSysUserFailure)failure;

@end

NS_ASSUME_NONNULL_END
