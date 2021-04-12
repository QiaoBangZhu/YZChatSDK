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
@property (nonatomic,   copy)NSString * userId;
@property (nonatomic,   copy)NSString * nickName;
@property (nonatomic,   copy)NSString * userIcon;
@property (nonatomic,   copy)NSString * mobile;
@property (nonatomic,   copy)NSString * email;
@property (nonatomic,   copy)NSString * position;
@property (nonatomic,   copy)NSString * city;
@property (nonatomic,   copy)NSString * card;
@property (nonatomic,   copy)NSString * departMentId;
@property (nonatomic,   copy)NSString * departName;
@property (nonatomic,   copy)NSString * userSignature;
@property (nonatomic, assign)int        gender;

@end

NS_ASSUME_NONNULL_END
