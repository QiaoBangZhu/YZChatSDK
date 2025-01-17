/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMLog+CIGAMConsole.m
//  CIGAMKit
//
//  Created by MoLice on 2019/J/15.
//

#import "CIGAMLog+CIGAMConsole.h"
#import "CIGAMConsole.h"
#import "CIGAMCore.h"

@implementation CIGAMLogger (CIGAMConsole)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([CIGAMLogger class], @selector(printLogWithFile:line:func:logItem:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CIGAMLogger *selfObject, const char *file, int line, const char *func, CIGAMLogItem *logItem) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, const char *, int, const char *, CIGAMLogItem *);
                originSelectorIMP = (void (*)(id, SEL, const char *, int, const char *, CIGAMLogItem *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, file, line, func, logItem);
                
                if (!CIGAMCMIActivated || !ShouldPrintCIGAMWarnLogToConsole) return;
                if (!logItem.enabled) return;
                if (logItem.level != CIGAMLogLevelWarn) return;
                
                void (^block)(void) = ^void(void) {
                    NSString *funcString = [NSString stringWithFormat:@"%s", func];
                    NSString *defaultString = [NSString stringWithFormat:@"%@:%@ | %@", funcString, @(line), logItem];
                    [CIGAMConsole logWithLevel:logItem.levelDisplayString name:logItem.name logString:defaultString];
                };
                if (!NSThread.currentThread.isMainThread) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block();
                    });
                } else {
                    block();
                }
                
            };
        });
    });
}

@end
