/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMImagePickerPreviewViewController.m
//  cigam
//
//  Created by CIGAM Team on 15/5/3.
//

#import "CIGAMImagePickerPreviewViewController.h"
#import "CIGAMCore.h"
#import "CIGAMImagePickerViewController.h"
#import "CIGAMImagePickerHelper.h"
#import "CIGAMAssetsManager.h"
#import "CIGAMZoomImageView.h"
#import "CIGAMAsset.h"
#import "CIGAMButton.h"
#import "CIGAMNavigationButton.h"
#import "CIGAMImagePickerHelper.h"
#import "CIGAMPieProgressView.h"
#import "CIGAMAlertController.h"
#import "UIImage+CIGAM.h"
#import "UIView+CIGAM.h"
#import "CIGAMLog.h"
#import "CIGAMAppearance.h"

#pragma mark - CIGAMImagePickerPreviewViewController (UIAppearance)

@implementation CIGAMImagePickerPreviewViewController (UIAppearance)

+ (instancetype)appearance {
    return [CIGAMAppearance appearanceForClass:self];
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initAppearance];
    });
}

+ (void)initAppearance {
    CIGAMImagePickerPreviewViewController.appearance.toolBarBackgroundColor = UIColorMakeWithRGBA(27, 27, 27, .9f);
    CIGAMImagePickerPreviewViewController.appearance.toolBarTintColor = UIColorWhite;
}

@end

@implementation CIGAMImagePickerPreviewViewController {
    BOOL _singleCheckMode;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.maximumSelectImageCount = INT_MAX;
        self.minimumSelectImageCount = 0;
        
        [self cigam_applyAppearance];
    }
    return self;
}

- (void)initSubviews {
    [super initSubviews];
    
    self.imagePreviewView.delegate = self;
    
    _topToolBarView = [[UIView alloc] init];
    self.topToolBarView.backgroundColor = self.toolBarBackgroundColor;
    self.topToolBarView.tintColor = self.toolBarTintColor;
    [self.view addSubview:self.topToolBarView];
    
    _backButton = [[CIGAMNavigationButton alloc] initWithType:CIGAMNavigationButtonTypeBack];
    [self.backButton addTarget:self action:@selector(handleCancelPreviewImage:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.cigam_outsideEdge = UIEdgeInsetsMake(-30, -20, -50, -80);
    [self.topToolBarView addSubview:self.backButton];
    
    _checkboxButton = [[CIGAMButton alloc] init];
    self.checkboxButton.adjustsTitleTintColorAutomatically = YES;
    self.checkboxButton.adjustsImageTintColorAutomatically = YES;
    UIImage *checkboxImage = [CIGAMHelper imageWithName:@"CIGAM_previewImage_checkbox"];
    UIImage *checkedCheckboxImage = [CIGAMHelper imageWithName:@"CIGAM_previewImage_checkbox_checked"];
    [self.checkboxButton setImage:checkboxImage forState:UIControlStateNormal];
    [self.checkboxButton setImage:checkedCheckboxImage forState:UIControlStateSelected];
    [self.checkboxButton setImage:[self.checkboxButton imageForState:UIControlStateSelected] forState:UIControlStateSelected|UIControlStateHighlighted];
    [self.checkboxButton sizeToFit];
    [self.checkboxButton addTarget:self action:@selector(handleCheckButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.checkboxButton.cigam_outsideEdge = UIEdgeInsetsMake(-6, -6, -6, -6);
    [self.topToolBarView addSubview:self.checkboxButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_singleCheckMode) {
        CIGAMAsset *imageAsset = self.imagesAssetArray[self.imagePreviewView.currentImageIndex];
        self.checkboxButton.selected = [self.selectedImageAssetArray containsObject:imageAsset];
    }
    
    if ([self conformsToProtocol:@protocol(CIGAMCustomNavigationBarTransitionDelegate)]) {
        UIViewController<CIGAMCustomNavigationBarTransitionDelegate> *vc = (UIViewController<CIGAMCustomNavigationBarTransitionDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomizeNavigationBarTransitionIfHideable)] &&
            [vc shouldCustomizeNavigationBarTransitionIfHideable]) {
        } else {
            [self.navigationController setNavigationBarHidden:YES animated:NO];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self conformsToProtocol:@protocol(CIGAMCustomNavigationBarTransitionDelegate)]) {
        UIViewController<CIGAMCustomNavigationBarTransitionDelegate> *vc = (UIViewController<CIGAMCustomNavigationBarTransitionDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomizeNavigationBarTransitionIfHideable)] &&
            [vc shouldCustomizeNavigationBarTransitionIfHideable]) {
        } else {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.topToolBarView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), NavigationContentTopConstant);
    CGFloat topToolbarPaddingTop = SafeAreaInsetsConstantForDeviceWithNotch.top;
    CGFloat topToolbarContentHeight = CGRectGetHeight(self.topToolBarView.bounds) - topToolbarPaddingTop;
    self.backButton.frame = CGRectSetXY(self.backButton.frame, 16 + self.view.cigam_safeAreaInsets.left, topToolbarPaddingTop + CGFloatGetCenter(topToolbarContentHeight, CGRectGetHeight(self.backButton.frame)));
    if (!self.checkboxButton.hidden) {
        self.checkboxButton.frame = CGRectSetXY(self.checkboxButton.frame, CGRectGetWidth(self.topToolBarView.frame) - 10 - self.view.cigam_safeAreaInsets.right - CGRectGetWidth(self.checkboxButton.frame), topToolbarPaddingTop + CGFloatGetCenter(topToolbarContentHeight, CGRectGetHeight(self.checkboxButton.frame)));
    }
}

- (BOOL)preferredNavigationBarHidden {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setToolBarBackgroundColor:(UIColor *)toolBarBackgroundColor {
    _toolBarBackgroundColor = toolBarBackgroundColor;
    self.topToolBarView.backgroundColor = self.toolBarBackgroundColor;
}

- (void)setToolBarTintColor:(UIColor *)toolBarTintColor {
    _toolBarTintColor = toolBarTintColor;
    self.topToolBarView.tintColor = toolBarTintColor;
}

- (void)setDownloadStatus:(CIGAMAssetDownloadStatus)downloadStatus {
    _downloadStatus = downloadStatus;
    if (!_singleCheckMode) {
        self.checkboxButton.hidden = NO;
    }
}

- (void)updateImagePickerPreviewViewWithImagesAssetArray:(NSMutableArray<CIGAMAsset *> *)imageAssetArray
                                 selectedImageAssetArray:(NSMutableArray<CIGAMAsset *> *)selectedImageAssetArray
                                       currentImageIndex:(NSInteger)currentImageIndex
                                         singleCheckMode:(BOOL)singleCheckMode {
    self.imagesAssetArray = imageAssetArray;
    self.selectedImageAssetArray = selectedImageAssetArray;
    self.imagePreviewView.currentImageIndex = currentImageIndex;
    _singleCheckMode = singleCheckMode;
    if (singleCheckMode) {
        self.checkboxButton.hidden = YES;
    }
}

#pragma mark - <CIGAMImagePreviewViewDelegate>

- (NSUInteger)numberOfImagesInImagePreviewView:(CIGAMImagePreviewView *)imagePreviewView {
    return [self.imagesAssetArray count];
}

- (CIGAMImagePreviewMediaType)imagePreviewView:(CIGAMImagePreviewView *)imagePreviewView assetTypeAtIndex:(NSUInteger)index {
    CIGAMAsset *imageAsset = [self.imagesAssetArray objectAtIndex:index];
    if (imageAsset.assetType == CIGAMAssetTypeImage) {
        if (imageAsset.assetSubType == CIGAMAssetSubTypeLivePhoto) {
            return CIGAMImagePreviewMediaTypeLivePhoto;
        }
        return CIGAMImagePreviewMediaTypeImage;
    } else if (imageAsset.assetType == CIGAMAssetTypeVideo) {
        return CIGAMImagePreviewMediaTypeVideo;
    } else {
        return CIGAMImagePreviewMediaTypeOthers;
    }
}

- (void)imagePreviewView:(CIGAMImagePreviewView *)imagePreviewView renderZoomImageView:(CIGAMZoomImageView *)zoomImageView atIndex:(NSUInteger)index {
    [self requestImageForZoomImageView:zoomImageView withIndex:index];
}

- (void)imagePreviewView:(CIGAMImagePreviewView *)imagePreviewView willScrollHalfToIndex:(NSUInteger)index {
    if (!_singleCheckMode) {
        CIGAMAsset *imageAsset = self.imagesAssetArray[index];
        self.checkboxButton.selected = [self.selectedImageAssetArray containsObject:imageAsset];
    }
}

#pragma mark - <CIGAMZoomImageViewDelegate>

- (void)singleTouchInZoomingImageView:(CIGAMZoomImageView *)zoomImageView location:(CGPoint)location {
    self.topToolBarView.hidden = !self.topToolBarView.hidden;
}

- (void)didTouchICloudRetryButtonInZoomImageView:(CIGAMZoomImageView *)imageView {
    NSInteger index = [self.imagePreviewView indexForZoomImageView:imageView];
    [self.imagePreviewView.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
}

- (void)zoomImageView:(CIGAMZoomImageView *)imageView didHideVideoToolbar:(BOOL)didHide {
    self.topToolBarView.hidden = didHide;
}

#pragma mark - 按钮点击回调

- (void)handleCancelPreviewImage:(CIGAMButton *)button {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
//        [self exitPreviewAutomatically];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewViewControllerDidCancel:)]) {
        [self.delegate imagePickerPreviewViewControllerDidCancel:self];
    }
}

- (void)handleCheckButtonClick:(CIGAMButton *)button {
    [CIGAMImagePickerHelper removeSpringAnimationOfImageCheckedWithCheckboxButton:button];
    
    if (button.selected) {
        if ([self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:willUncheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewViewController:self willUncheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
        
        button.selected = NO;
        CIGAMAsset *imageAsset = self.imagesAssetArray[self.imagePreviewView.currentImageIndex];
        [self.selectedImageAssetArray removeObject:imageAsset];
        
        if ([self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:didUncheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewViewController:self didUncheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
    } else {
        if ([self.selectedImageAssetArray count] >= self.maximumSelectImageCount) {
            if (!self.alertTitleWhenExceedMaxSelectImageCount) {
                self.alertTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"你最多只能选择%@张图片", @(self.maximumSelectImageCount)];
            }
            if (!self.alertButtonTitleWhenExceedMaxSelectImageCount) {
                self.alertButtonTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"我知道了"];
            }
            
            CIGAMAlertController *alertController = [CIGAMAlertController alertControllerWithTitle:self.alertTitleWhenExceedMaxSelectImageCount message:nil preferredStyle:CIGAMAlertControllerStyleAlert];
            [alertController addAction:[CIGAMAlertAction actionWithTitle:self.alertButtonTitleWhenExceedMaxSelectImageCount style:CIGAMAlertActionStyleCancel handler:nil]];
            [alertController showWithAnimated:YES];
            return;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:willCheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewViewController:self willCheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
        
        button.selected = YES;
        [CIGAMImagePickerHelper springAnimationOfImageCheckedWithCheckboxButton:button];
        CIGAMAsset *imageAsset = [self.imagesAssetArray objectAtIndex:self.imagePreviewView.currentImageIndex];
        [self.selectedImageAssetArray addObject:imageAsset];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:didCheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewViewController:self didCheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
    }
}

#pragma mark - Request Image

- (void)requestImageForZoomImageView:(CIGAMZoomImageView *)zoomImageView withIndex:(NSInteger)index {
    CIGAMZoomImageView *imageView = zoomImageView ? : [self.imagePreviewView zoomImageViewAtIndex:index];
    // 如果是走 PhotoKit 的逻辑，那么这个 block 会被多次调用，并且第一次调用时返回的图片是一张小图，
    // 拉取图片的过程中可能会多次返回结果，且图片尺寸越来越大，因此这里调整 contentMode 以防止图片大小跳动
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CIGAMAsset *imageAsset = [self.imagesAssetArray objectAtIndex:index];
    // 获取资源图片的预览图，这是一张适合当前设备屏幕大小的图片，最终展示时把图片交给组件控制最终展示出来的大小。
    // 系统相册本质上也是这么处理的，因此无论是系统相册，还是这个系列组件，由始至终都没有显示照片原图，
    // 这也是系统相册能加载这么快的原因。
    // 另外这里采用异步请求获取图片，避免获取图片时 UI 卡顿
    PHAssetImageProgressHandler phProgressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        imageAsset.downloadProgress = progress;
        dispatch_async(dispatch_get_main_queue(), ^{
            CIGAMLogInfo(@"CIGAMImagePickerLibrary", @"Download iCloud image in preview, current progress is: %f", progress);
            
            if (self.downloadStatus != CIGAMAssetDownloadStatusDownloading) {
                self.downloadStatus = CIGAMAssetDownloadStatusDownloading;
                imageView.cloudDownloadStatus = CIGAMAssetDownloadStatusDownloading;

                // 重置 progressView 的显示的进度为 0
                [imageView.cloudProgressView setProgress:0 animated:NO];
            }
            // 拉取资源的初期，会有一段时间没有进度，猜测是发出网络请求以及与 iCloud 建立连接的耗时，这时预先给个 0.02 的进度值，看上去好看些
            float targetProgress = fmax(0.02, progress);
            if (targetProgress < imageView.cloudProgressView.progress) {
                [imageView.cloudProgressView setProgress:targetProgress animated:NO];
            } else {
                imageView.cloudProgressView.progress = fmax(0.02, progress);
            }
            if (error) {
                CIGAMLog(@"CIGAMImagePickerLibrary", @"Download iCloud image Failed, current progress is: %f", progress);
                self.downloadStatus = CIGAMAssetDownloadStatusFailed;
                imageView.cloudDownloadStatus = CIGAMAssetDownloadStatusFailed;
            }
        });
    };
    if (imageAsset.assetType == CIGAMAssetTypeVideo) {
        imageView.tag = -1;
        imageAsset.requestID = [imageAsset requestPlayerItemWithCompletion:^(AVPlayerItem *playerItem, NSDictionary *info) {
            // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
            // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
                BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
                BOOL loadICloudImageFault = !playerItem || info[PHImageErrorKey];
                if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
                    imageView.videoPlayerItem = playerItem;
                }
            });
        } withProgressHandler:phProgressHandler];
        imageView.tag = imageAsset.requestID;
    } else {
        if (imageAsset.assetType != CIGAMAssetTypeImage) {
            return;
        }
        
        // 这么写是为了消除 Xcode 的 API available warning
        BOOL isLivePhoto = NO;
        if (imageAsset.assetSubType == CIGAMAssetSubTypeLivePhoto) {
            isLivePhoto = YES;
            imageView.tag = -1;
            imageAsset.requestID = [imageAsset requestLivePhotoWithCompletion:^void(PHLivePhoto *livePhoto, NSDictionary *info) {
                // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
                // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
                    BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
                    BOOL loadICloudImageFault = !livePhoto || info[PHImageErrorKey];
                    if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
                        // 如果是走 PhotoKit 的逻辑，那么这个 block 会被多次调用，并且第一次调用时返回的图片是一张小图，
                        // 这时需要把图片放大到跟屏幕一样大，避免后面加载大图后图片的显示会有跳动
                        imageView.livePhoto = livePhoto;
                    }
                    BOOL downloadSucceed = (livePhoto && !info) || (![[info objectForKey:PHLivePhotoInfoCancelledKey] boolValue] && ![info objectForKey:PHLivePhotoInfoErrorKey] && ![[info objectForKey:PHLivePhotoInfoIsDegradedKey] boolValue]);
                    if (downloadSucceed) {
                        // 资源资源已经在本地或下载成功
                        [imageAsset updateDownloadStatusWithDownloadResult:YES];
                        self.downloadStatus = CIGAMAssetDownloadStatusSucceed;
                        imageView.cloudDownloadStatus = CIGAMAssetDownloadStatusSucceed;
                    } else if ([info objectForKey:PHLivePhotoInfoErrorKey] ) {
                        // 下载错误
                        [imageAsset updateDownloadStatusWithDownloadResult:NO];
                        self.downloadStatus = CIGAMAssetDownloadStatusFailed;
                        imageView.cloudDownloadStatus = CIGAMAssetDownloadStatusFailed;
                    }
                });
            } withProgressHandler:phProgressHandler];
            imageView.tag = imageAsset.requestID;
        }
        
        if (isLivePhoto) {
        } else if (imageAsset.assetSubType == CIGAMAssetSubTypeGIF) {
            [imageAsset requestImageData:^(NSData *imageData, NSDictionary<NSString *,id> *info, BOOL isGIF, BOOL isHEIC) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *resultImage = [UIImage cigam_animatedImageWithData:imageData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = resultImage;
                    });
                });
            }];
        } else {
            imageView.tag = -1;
            imageView.image = [imageAsset thumbnailWithSize:CGSizeMake([CIGAMImagePickerViewController appearance].minimumImageWidth, [CIGAMImagePickerViewController appearance].minimumImageWidth)];
            imageAsset.requestID = [imageAsset requestOriginImageWithCompletion:^void(UIImage *result, NSDictionary *info) {
                // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
                // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
                    BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
                    BOOL loadICloudImageFault = !result || info[PHImageErrorKey];
                    if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
                        imageView.image = result;
                    }
                    BOOL downloadSucceed = (result && !info) || (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    if (downloadSucceed) {
                        // 资源资源已经在本地或下载成功
                        [imageAsset updateDownloadStatusWithDownloadResult:YES];
                        self.downloadStatus = CIGAMAssetDownloadStatusSucceed;
                        imageView.cloudDownloadStatus = CIGAMAssetDownloadStatusSucceed;
                    } else if ([info objectForKey:PHImageErrorKey] ) {
                        // 下载错误
                        [imageAsset updateDownloadStatusWithDownloadResult:NO];
                        self.downloadStatus = CIGAMAssetDownloadStatusFailed;
                        imageView.cloudDownloadStatus = CIGAMAssetDownloadStatusFailed;
                    }
                });
            } withProgressHandler:phProgressHandler];
            imageView.tag = imageAsset.requestID;
        }
    }
}

@end
