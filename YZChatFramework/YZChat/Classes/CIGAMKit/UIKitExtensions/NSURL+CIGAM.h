/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSURL+CIGAM.h
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/11/11.
//

#import <UIKit/UIKit.h>

@interface NSURL (CIGAM)

/**
 *  获取当前 query 的参数列表。
 *
 *  @return query 参数列表，以字典返回。如果 absoluteString 为 nil 则返回 nil
 */
@property(nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *cigam_queryItems;

@end
