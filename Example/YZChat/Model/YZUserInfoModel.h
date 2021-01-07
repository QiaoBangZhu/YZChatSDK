//
//  YZUserInfoModel.h
//  YZChat_Example
//
//  Created by magic on 2021/1/5.
//  Copyright © 2021 QiaoBangZhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZUserInfoModel : NSObject<NSCoding,NSCopying>
@property (nonatomic ,   copy) NSString              * userSign;
@property (nonatomic ,   copy) NSString              * userId;
@property (nonatomic ,   copy) NSString              * nickName;
@property (nonatomic ,   copy) NSString              * companyId;
@property (nonatomic ,   copy) NSString              * companyName;
@property (nonatomic ,   copy) NSString              * departMentId;
@property (nonatomic ,   copy) NSString              * departName;
@property (nonatomic ,   copy) NSString              * card;
@property (nonatomic ,   copy) NSString              * createId;
@property (nonatomic ,   copy) NSString              * createTime;
@property (nonatomic ,   copy) NSString              * dimension;
@property (nonatomic ,   copy) NSString              * email;
@property (nonatomic ,   copy) NSString              * uid;
@property (nonatomic ,   copy) NSString              * lastModifyId;
@property (nonatomic ,   copy) NSString              * lastModifyTime;
@property (nonatomic ,   copy) NSString              * longitude;
@property (nonatomic ,   copy) NSString              * mobile;
@property (nonatomic ,   copy) NSString              * password;
@property (nonatomic ,   copy) NSString              * position;
@property (nonatomic ,   copy) NSString              * userIcon;
@property (nonatomic ,   copy) NSString              * token;
@property (nonatomic , assign) NSInteger               functionPerm;

@end

NS_ASSUME_NONNULL_END
