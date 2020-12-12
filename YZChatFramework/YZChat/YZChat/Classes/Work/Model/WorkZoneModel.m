//
//  WorkZoneModel.m
//  YChat
//
//  Created by magic on 2020/10/4.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "WorkZoneModel.h"

@implementation AppInfoModel

+ (NSDictionary *)modelCustomPropertyMapper{

    return @{@"appId":@"id"};
}

@end

@implementation WorkZoneModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{ @"toolDataList" : [AppInfoModel class] };
}


@end
