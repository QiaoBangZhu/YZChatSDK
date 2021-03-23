//
//  YWorkZoneModel.m
//  YChat
//
//  Created by magic on 2020/10/4.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YWorkZoneModel.h"

@implementation YAppInfoModel

+ (NSDictionary *)modelCustomPropertyMapper{

    return @{@"appId":@"id"};
}

@end

@implementation YWorkZoneModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{ @"toolDataList" : [YAppInfoModel class] };
}


@end
