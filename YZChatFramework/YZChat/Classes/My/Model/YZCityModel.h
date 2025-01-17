//
//  CityModel.h
//  YChat
//
//  Created by magic on 2020/12/28.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZCityModel : YBaseModel
@property (nonatomic, strong)NSArray * area;
@property (nonatomic, copy)NSString* city;
@end

NS_ASSUME_NONNULL_END
