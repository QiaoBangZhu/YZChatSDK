/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMPopupMenuBaseItem.h
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/8/21.
//

#import <UIKit/UIKit.h>
#import "CIGAMPopupMenuItemProtocol.h"

/**
 用于 CIGAMPopupMenuView 的 item 基类，便于自定义各种类型的 item。若有 subview 请直接添加到 self 上，自身大小的计算请写到 sizeThatFits:，布局写到 layoutSubviews。
 */
@interface CIGAMPopupMenuBaseItem : UIView <CIGAMPopupMenuItemProtocol>

@end
