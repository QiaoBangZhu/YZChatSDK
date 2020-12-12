//
//  SysUser.h
//  YChat
//
//  Created by magic on 2020/12/7.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SysUser : NSObject
@property (nonatomic, copy)NSString* userId;
@property (nonatomic, copy)NSString* nickName;
@property (nonatomic, copy)NSString* userIcon;

@end

NS_ASSUME_NONNULL_END
