/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMConsoleToolbar.h
//  CIGAMKit
//
//  Created by MoLice on 2019/J/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CIGAMButton;
@class CIGAMTextField;

@interface CIGAMConsoleToolbar : UIView

@property(nonatomic, strong, readonly) CIGAMButton *levelButton;
@property(nonatomic, strong, readonly) CIGAMButton *nameButton;
@property(nonatomic, strong, readonly) CIGAMButton *clearButton;
@property(nonatomic, strong, readonly) CIGAMTextField *searchTextField;
@property(nonatomic, strong, readonly) UILabel *searchResultCountLabel;
@property(nonatomic, strong, readonly) CIGAMButton *searchResultPreviousButton;
@property(nonatomic, strong, readonly) CIGAMButton *searchResultNextButton;

- (void)setNeedsLayoutSearchResultViews;
@end

NS_ASSUME_NONNULL_END
