/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMLog.h
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/1/22.
//

#import <Foundation/Foundation.h>
#import "CIGAMLogItem.h"
#import "CIGAMLogNameManager.h"
#import "CIGAMLogger.h"
#import <stdio.h>

/// 以下是 CIGAM 提供的用于代替 NSLog() 的打 log 的方法，可根据 logName、logLevel 两个维度来控制某些 log 是否要被打印，以便在调试时去掉不关注的 log。

#define CIGAMLog(_name, ...) [[CIGAMLogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[CIGAMLogItem logItemWithLevel:CIGAMLogLevelDefault name:_name logString:__VA_ARGS__]]
#define CIGAMLogInfo(_name, ...) [[CIGAMLogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[CIGAMLogItem logItemWithLevel:CIGAMLogLevelInfo name:_name logString:__VA_ARGS__]]
#define CIGAMLogWarn(_name, ...) [[CIGAMLogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[CIGAMLogItem logItemWithLevel:CIGAMLogLevelWarn name:_name logString:__VA_ARGS__]]

//#ifdef DEBUG
//
//// iOS 11 之前用真正的方法替换去实现拦截 NSLog 的功能，iOS 11 之后这种方法失效了，所以只能用宏定义的方式覆盖 NSLog。这也就意味着在 iOS 11 下一些如果某些代码编译时机比 CIGAM 早，则这些代码里的 NSLog 是无法被替换为 CIGAMLog 的
//extern void _NSSetLogCStringFunction(void (*)(const char *string, unsigned length, BOOL withSyslogBanner));
//static void PrintNSLogMessage(const char *string, unsigned length, BOOL withSyslogBanner) {
//    CIGAMLog(@"NSLog", @"%s", string);
//}
//
//static void HackNSLog(void) __attribute__((constructor));
//static void HackNSLog(void) {
//    _NSSetLogCStringFunction(PrintNSLogMessage);
//}
//
//#define NSLog(...) CIGAMLog(@"NSLog", __VA_ARGS__)// iOS 11 以后真正生效的是这一句
//#endif
