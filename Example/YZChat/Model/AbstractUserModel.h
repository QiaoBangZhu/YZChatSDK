//
//  AbstractUserModel.h
//  YZChat_Example
//
//  Created by magic on 2021/1/5.
//  Copyright © 2021 QiaoBangZhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AbstractUserModel : NSObject<NSSecureCoding, NSCopying>

@property (nonatomic ,   copy) NSString *userId;
@property (nonatomic , assign) int gender;
@property (nonatomic ,   copy) NSString *userIcon;
@property (nonatomic ,   copy) NSString *city;
@property (nonatomic ,   copy) NSString *departName;
@property (nonatomic ,   copy) NSString *userSign;
@property (nonatomic ,   copy) NSString *userSignature;
@property (nonatomic ,   copy) NSString *departmentId;
@property (nonatomic ,   copy) NSString *nickName;
@property (nonatomic ,   copy) NSString *companyId;
@property (nonatomic ,   copy) NSString *token;

@end

NS_ASSUME_NONNULL_END
