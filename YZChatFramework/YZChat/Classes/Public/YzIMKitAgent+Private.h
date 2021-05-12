//
//  YzIMKitAgent+Private.h
//  YZChat
//
//  Created by 安笑 on 2021/4/25.
//

#import "YzIMKitAgent.h"

#import "TUIGroupPendencyCellData.h"

#import "YzCustomMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface YzIMKitAgent (Private_Message)

- (void)sendCustomMessage:(YzCustomMessageData*)message
                   userId:(nullable NSString *)userId
                  groupId:(nullable NSString *)groupId
                  success:(YzChatSysUserSuccess)success
                  failure:(YzChatSysUserFailure)failure;

@end

@interface YzIMKitAgent (Private_Group)

/// 群申请列表
@property (nonatomic, strong, readonly) NSArray <TUIGroupPendencyCellData *>*groupApplicationList;
/// 有加群申请的群id
@property (nonatomic, strong, readonly) NSSet <NSString *>*groupApplicationGroupIDs;

/// 重新加载加群申请列表
- (void)reloadGroupApplicationList;
/// 同意加群
- (void)acceptGroupApplication:(TUIGroupPendencyCellData *)data;
/// 拒绝加群
- (void)rejectGroupApplication:(TUIGroupPendencyCellData *)data;

@end

NS_ASSUME_NONNULL_END
