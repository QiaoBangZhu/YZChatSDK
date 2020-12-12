//
//  WorkZoneModel.h
//  YChat
//
//  Created by magic on 2020/10/4.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppInfoModel : BaseModel
@property (nonatomic,   copy)NSString *chargeMobile;
@property (nonatomic,   copy)NSString *chargeName;
@property (nonatomic,   copy)NSString *createId;
@property (nonatomic,   copy)NSString *createTime;
@property (nonatomic,   copy)NSString *iconUrl;
@property (nonatomic,   copy)NSString *lastModifyId;
@property (nonatomic,   copy)NSString *lastModifyTime;
@property (nonatomic,   copy)NSString* toolCode;
@property (nonatomic,   copy)NSString *toolDesc;
@property (nonatomic,   copy)NSString *toolName;
@property (nonatomic,   copy)NSString *toolUrl;
@property (nonatomic, assign)NSInteger deleteStatus;
@property (nonatomic, assign)NSInteger appId;
@property (nonatomic, assign)NSInteger orderNum;
@property (nonatomic, assign)NSInteger status;
@property (nonatomic, copy) NSString  *sdkToken;

@end

@interface WorkZoneModel : BaseModel
@property (nonatomic, copy)NSString* toolCategory;
@property (nonatomic, strong)NSMutableArray<AppInfoModel*>*toolDataList;

@end

NS_ASSUME_NONNULL_END

