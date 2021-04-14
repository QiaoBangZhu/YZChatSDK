/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  CIGAMThemeManagerCenter.m
//  CIGAMKit
//
//  Created by MoLice on 2019/S/4.
//

#import "CIGAMThemeManagerCenter.h"

NSString *const CIGAMThemeManagerNameDefault = @"Default";

@interface CIGAMThemeManager ()

// 这个方法的实现在 CIGAMThemeManager.m 里，这里只是为了内部使用而显式声明一次
- (instancetype)initWithName:(__kindof NSObject<NSCopying> *)name;
@end

@interface CIGAMThemeManagerCenter ()

@property(nonatomic, strong) NSMutableArray<CIGAMThemeManager *> *allManagers;
@end

@implementation CIGAMThemeManagerCenter

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static CIGAMThemeManagerCenter *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
        instance.allManagers = NSMutableArray.new;
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

+ (CIGAMThemeManager *)themeManagerWithName:(__kindof NSObject<NSCopying> *)name {
    CIGAMThemeManagerCenter *center = [CIGAMThemeManagerCenter sharedInstance];
    for (CIGAMThemeManager *manager in center.allManagers) {
        if ([manager.name isEqual:name]) return manager;
    }
    CIGAMThemeManager *manager = [[CIGAMThemeManager alloc] initWithName:name];
    [center.allManagers addObject:manager];
    return manager;
}

+ (CIGAMThemeManager *)defaultThemeManager {
    return [CIGAMThemeManagerCenter themeManagerWithName:CIGAMThemeManagerNameDefault];
}

+ (NSArray<CIGAMThemeManager *> *)themeManagers {
    return [CIGAMThemeManagerCenter sharedInstance].allManagers.copy;
}

@end
