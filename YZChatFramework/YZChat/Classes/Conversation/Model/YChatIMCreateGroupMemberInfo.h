//
//  YChatIMCreateGroupMemberInfo.h
//  YChat
//
//  Created by magic on 2020/10/3.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YChatIMCreateGroupMemberInfo : YBaseModel
@property (nonatomic, copy)NSString *Member_Account;
@property (nonatomic, copy)NSString *Role;


@end

NS_ASSUME_NONNULL_END
