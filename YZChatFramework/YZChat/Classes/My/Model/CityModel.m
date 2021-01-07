//
//  CityModel.m
//  YChat
//
//  Created by magic on 2020/12/28.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "CityModel.h"

@implementation CityModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"area" : [NSString class]};
}

//排序 for 群成员列表等
- (NSComparisonResult)compare:(CityModel *)data
{
    return [self.city localizedCompare:data.city];
}

@end
