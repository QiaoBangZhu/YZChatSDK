//
//  YzCustomMessageCellData.h
//  YZChat
//
//  Created by 安笑 on 2021/4/12.
//

#import "TUIMessageCellData.h"

#import "YzCustomMessageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YzCustomMessageCellData : TUIMessageCellData

@property (nonatomic, strong) YzCustomMessageData *customMessageData;

- (instancetype)initWithMessage:(V2TIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
