//
//  YZUserInfoModel.m
//  YZChat_Example
//
//  Created by magic on 2021/1/5.
//  Copyright © 2021 QiaoBangZhu. All rights reserved.
//

#import "YZUserInfoModel.h"

@implementation YZUserInfoModel

- (void)encodeWithCoder:(NSCoder *)aCoder { [self yy_modelEncodeWithCoder:aCoder]; }
- (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self yy_modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(NSZone *)zone { return [self yy_modelCopy]; }
- (NSUInteger)hash { return [self yy_modelHash]; }
- (BOOL)isEqual:(id)object { return [self yy_modelIsEqual:object]; }
- (NSString *)description { return [self yy_modelDescription]; }
+ (BOOL)supportsSecureCoding {
    return  YES;
}

+ (NSDictionary *)modelCustomPropertyMapper{
    
    return @{@"uid":@"id"};
}

@end
