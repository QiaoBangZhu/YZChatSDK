//
//  CityModel.m
//  YChat
//
//  Created by magic on 2020/12/28.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZCityModel.h"

@implementation YZCityModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"area" : [NSString class]};
}

//排序 for 群成员列表等
- (NSComparisonResult)compare:(YZCityModel *)data
{
    return [self.city localizedCompare:data.city];
}

@end
