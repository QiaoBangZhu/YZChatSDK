/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMLogger+CIGAMConfigurationTemplate.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/7/28.
//

#import "CIGAMLogger+CIGAMConfigurationTemplate.h"
#import "CIGAMCore.h"

@implementation CIGAMLogger (CIGAMConfigurationTemplate)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([CIGAMLogger class], @selector(printLogWithFile:line:func:logItem:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CIGAMLogger *selfObject, const char *file, int line, const char *func, CIGAMLogItem *logItem) {
                // 不同级别的 log 可通过配置表的开关来控制是否要输出
                if (logItem.level == CIGAMLogLevelDefault && !ShouldPrintDefaultLog) return;
                if (logItem.level == CIGAMLogLevelInfo && !ShouldPrintInfoLog) return;
                if (logItem.level == CIGAMLogLevelWarn && !ShouldPrintWarnLog) return;
                
                // call super
                void (*originSelectorIMP)(id, SEL, const char *, int, const char *, CIGAMLogItem *);
                originSelectorIMP = (void (*)(id, SEL, const char *, int, const char *, CIGAMLogItem *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, file, line, func, logItem);
            };
        });
    });
}

@end
