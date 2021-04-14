/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMImagePickerPreviewViewController.h
//  cigam
//
//  Created by CIGAM Team on 15/5/3.
//

#import <UIKit/UIKit.h>
#import "CIGAMImagePreviewViewController.h"
#import "CIGAMAsset.h"

NS_ASSUME_NONNULL_BEGIN

@class CIGAMButton, CIGAMNavigationButton;
@class CIGAMImagePickerViewController;
@class CIGAMImagePickerPreviewViewController;

@protocol CIGAMImagePickerPreviewViewControllerDelegate <NSObject>

@optional

/// 取消选择图片后被调用
- (void)imagePickerPreviewViewControllerDidCancel:(CIGAMImagePickerPreviewViewController *)imagePickerPreviewViewController;
/// 即将选中图片
- (void)imagePickerPreviewViewController:(CIGAMImagePickerPreviewViewController *)imagePickerPreviewViewController willCheckImageAtIndex:(NSInteger)index;
/// 已经选中图片
- (void)imagePickerPreviewViewController:(CIGAMImagePickerPreviewViewController *)imagePickerPreviewViewController didCheckImageAtIndex:(NSInteger)index;
/// 即将取消选中图片
- (void)imagePickerPreviewViewController:(CIGAMImagePickerPreviewViewController *)imagePickerPreviewViewController willUncheckImageAtIndex:(NSInteger)index;
/// 已经取消选中图片
- (void)imagePickerPreviewViewController:(CIGAMImagePickerPreviewViewController *)imagePickerPreviewViewController didUncheckImageAtIndex:(NSInteger)index;

@end


@interface CIGAMImagePickerPreviewViewController : CIGAMImagePreviewViewController <CIGAMImagePreviewViewDelegate>

@property(nullable, nonatomic, weak) id<CIGAMImagePickerPreviewViewControllerDelegate> delegate;

@property(nullable, nonatomic, strong) UIColor *toolBarBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nullable, nonatomic, strong) UIColor *toolBarTintColor UI_APPEARANCE_SELECTOR;

@property(nullable, nonatomic, strong, readonly) UIView *topToolBarView;
@property(nullable, nonatomic, strong, readonly) CIGAMNavigationButton *backButton;
@property(nullable, nonatomic, strong, readonly) CIGAMButton *checkboxButton;

/// 由于组件需要通过本地图片的 CIGAMAsset 对象读取图片的详细信息，因此这里的需要传入的是包含一个或多个 CIGAMAsset 对象的数组
@property(nullable, nonatomic, strong) NSMutableArray<CIGAMAsset *> *imagesAssetArray;
@property(nullable, nonatomic, strong) NSMutableArray<CIGAMAsset *> *selectedImageAssetArray;

@property(nonatomic, assign) CIGAMAssetDownloadStatus downloadStatus;

/// 最多可以选择的图片数，默认为无穷大
@property(nonatomic, assign) NSUInteger maximumSelectImageCount;
/// 最少需要选择的图片数，默认为 0
@property(nonatomic, assign) NSUInteger minimumSelectImageCount;
/// 选择图片超出最大图片限制时 alertView 的标题
@property(nullable, nonatomic, copy) NSString *alertTitleWhenExceedMaxSelectImageCount;
/// 选择图片超出最大图片限制时 alertView 的标题
@property(nullable, nonatomic, copy) NSString *alertButtonTitleWhenExceedMaxSelectImageCount;

/**
 *  更新数据并刷新 UI，手工调用
 *
 *  @param imageAssetArray         包含所有需要展示的图片的数组
 *  @param selectedImageAssetArray 包含所有需要展示的图片中已经被选中的图片的数组
 *  @param currentImageIndex       当前展示的图片在 imageAssetArray 的索引
 *  @param singleCheckMode         是否为单选模式，如果是单选模式，则不显示 checkbox
 */
- (void)updateImagePickerPreviewViewWithImagesAssetArray:(NSMutableArray<CIGAMAsset *> * _Nullable)imageAssetArray
                                 selectedImageAssetArray:(NSMutableArray<CIGAMAsset *> * _Nullable)selectedImageAssetArray
                                       currentImageIndex:(NSInteger)currentImageIndex
                                         singleCheckMode:(BOOL)singleCheckMode;

@end


@interface CIGAMImagePickerPreviewViewController (UIAppearance)

+ (instancetype)appearance;

@end

NS_ASSUME_NONNULL_END
