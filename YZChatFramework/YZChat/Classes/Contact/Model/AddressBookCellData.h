//
//  AddressBookCellData.h
//  YChat
//
//  Created by magic on 2020/12/29.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TCommonCell.h"

NS_ASSUME_NONNULL_BEGIN

/// 通讯录好友状态
typedef NS_ENUM(NSInteger, AddressBookApplicationType) {
    ADDRESSBOOK_APPLICATION_FRIEND           = 1,  ///< 已经是我的好友
    ADDRESSBOOK_APPLICATION_NOT_FRIEND       = 2,  ///< 不是我的好友但存在于系统中，可以加好友
    ADDRESSBOOK_APPLICATION_INVITE           = 3,  ///< 可以邀请加好友
};

@interface AddressBookCellData : TCommonCellData
@property NSString *identifier;
@property NSURL *avatarUrl;
@property NSString* userIcon;
@property NSString* mobile;
@property NSString *title;
@property NSString *nickname;
@property SEL cbuttonSelector;
@property AddressBookApplicationType type;
@property BOOL readyAgree;
@end

NS_ASSUME_NONNULL_END
