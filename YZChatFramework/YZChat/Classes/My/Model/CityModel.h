//
//  CityModel.h
//  YChat
//
//  Created by magic on 2020/12/28.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CityModel : BaseModel
@property (nonatomic, strong)NSArray * area;
@property (nonatomic, copy)NSString* city;
@end

NS_ASSUME_NONNULL_END
