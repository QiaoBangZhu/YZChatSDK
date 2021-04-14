/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMAlbumViewController.m
//  cigam
//
//  Created by CIGAM Team on 15/5/3.
//

#import "CIGAMAlbumViewController.h"
#import "CIGAMCore.h"
#import "CIGAMNavigationButton.h"
#import "UIView+CIGAM.h"
#import "CIGAMAssetsManager.h"
#import "CIGAMImagePickerViewController.h"
#import "CIGAMImagePickerHelper.h"
#import "CIGAMAppearance.h"
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHAsset.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHCollection.h>
#import <Photos/PHFetchResult.h>

#pragma mark - CIGAMAlbumTableViewCell

@implementation CIGAMAlbumTableViewCell

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [CIGAMAlbumTableViewCell appearance].albumImageSize = 72;
        [CIGAMAlbumTableViewCell appearance].albumImageMarginLeft = 16;
        [CIGAMAlbumTableViewCell appearance].albumNameInsets = UIEdgeInsetsMake(0, 14, 0, 3);
        [CIGAMAlbumTableViewCell appearance].albumNameFont = UIFontMake(17);
        [CIGAMAlbumTableViewCell appearance].albumNameColor = TableViewCellTitleLabelColor;
        [CIGAMAlbumTableViewCell appearance].albumAssetsNumberFont = UIFontMake(17);
        [CIGAMAlbumTableViewCell appearance].albumAssetsNumberColor = TableViewCellTitleLabelColor;
    });
}

- (void)didInitializeWithStyle:(UITableViewCellStyle)style {
    [super didInitializeWithStyle:style];
    
    [self cigam_applyAppearance];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.borderWidth = PixelOne;
    self.imageView.layer.borderColor = UIColorMakeWithRGBA(0, 0, 0, .1).CGColor;
}

- (void)updateCellAppearanceWithIndexPath:(NSIndexPath *)indexPath {
    [super updateCellAppearanceWithIndexPath:indexPath];
    self.textLabel.font = self.albumNameFont;
    self.detailTextLabel.font = self.albumAssetsNumberFont;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageEdgeTop = CGFloatGetCenter(CGRectGetHeight(self.contentView.bounds), self.albumImageSize);
    CGFloat imageEdgeLeft = self.albumImageMarginLeft == -1 ? imageEdgeTop : self.albumImageMarginLeft;
    self.imageView.frame = CGRectMake(imageEdgeLeft, imageEdgeTop, self.albumImageSize, self.albumImageSize);
    
    self.textLabel.frame = CGRectSetXY(self.textLabel.frame, CGRectGetMaxX(self.imageView.frame) + self.albumNameInsets.left, [self.textLabel cigam_topWhenCenterInSuperview]);
    
    CGFloat textLabelMaxWidth = CGRectGetWidth(self.contentView.bounds) - CGRectGetMinX(self.textLabel.frame) - CGRectGetWidth(self.detailTextLabel.bounds) - self.albumNameInsets.right;
    if (CGRectGetWidth(self.textLabel.bounds) > textLabelMaxWidth) {
        self.textLabel.frame = CGRectSetWidth(self.textLabel.frame, textLabelMaxWidth);
    }
    
    self.detailTextLabel.frame = CGRectSetXY(self.detailTextLabel.frame, CGRectGetMaxX(self.textLabel.frame) + self.albumNameInsets.right, [self.detailTextLabel cigam_topWhenCenterInSuperview]);
}

- (void)setAlbumNameFont:(UIFont *)albumNameFont {
    _albumNameFont = albumNameFont;
    self.textLabel.font = albumNameFont;
}

- (void)setAlbumNameColor:(UIColor *)albumNameColor {
    _albumNameColor = albumNameColor;
    self.textLabel.textColor = albumNameColor;
}

- (void)setAlbumAssetsNumberFont:(UIFont *)albumAssetsNumberFont {
    _albumAssetsNumberFont = albumAssetsNumberFont;
    self.detailTextLabel.font = albumAssetsNumberFont;
}

- (void)setAlbumAssetsNumberColor:(UIColor *)albumAssetsNumberColor {
    _albumAssetsNumberColor = albumAssetsNumberColor;
    self.detailTextLabel.textColor = albumAssetsNumberColor;
}

@end


#pragma mark - CIGAMAlbumViewController (UIAppearance)

@implementation CIGAMAlbumViewController (UIAppearance)

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
    CIGAMAlbumViewController.appearance.albumTableViewCellHeight = 88;
}

@end


#pragma mark - CIGAMAlbumViewController

@interface CIGAMAlbumViewController ()

@property(nonatomic, strong) NSMutableArray<CIGAMAssetsGroup *> *albumsArray;
@property(nonatomic, strong) CIGAMImagePickerViewController *imagePickerViewController;
@end

@implementation CIGAMAlbumViewController

- (void)didInitialize {
    [super didInitialize];
    _shouldShowDefaultLoadingView = YES;
    [self cigam_applyAppearance];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    if (!self.title) {
        self.title = @"照片";
    }
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem cigam_itemWithTitle:@"取消" target:self action:@selector(handleCancelSelectAlbum:)];
}

- (void)initTableView {
    [super initTableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([CIGAMAssetsManager authorizationStatus] == CIGAMAssetAuthorizationStatusNotAuthorized) {
        // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
        NSString *tipString = self.tipTextWhenNoPhotosAuthorization;
        if (!tipString) {
            NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
            if (!appName) {
                appName = [mainInfoDictionary objectForKey:(NSString *)kCFBundleNameKey];
            }
            tipString = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
        }
        [self showEmptyViewWithText:tipString detailText:nil buttonTitle:nil buttonAction:nil];
    } else {
        self.albumsArray = [[NSMutableArray alloc] init];
        // 获取相册列表较为耗时，交给子线程去处理，因此这里需要显示 Loading
        if ([self.albumViewControllerDelegate respondsToSelector:@selector(albumViewControllerWillStartLoading:)]) {
            [self.albumViewControllerDelegate albumViewControllerWillStartLoading:self];
        }
        if (self.shouldShowDefaultLoadingView) {
            [self showEmptyViewWithLoading];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[CIGAMAssetsManager sharedInstance] enumerateAllAlbumsWithAlbumContentType:self.contentType usingBlock:^(CIGAMAssetsGroup *resultAssetsGroup) {
                if (resultAssetsGroup) {
                    [self.albumsArray addObject:resultAssetsGroup];
                } else {
                    // 意味着遍历完所有的相簿了
                    [self sortAlbumArray];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self refreshAlbumAndShowEmptyTipIfNeed];
                    });
                }
            }];
        });
    }
}

- (void)sortAlbumArray {
    // 把隐藏相册排序强制放到最后
    __block CIGAMAssetsGroup *hiddenGroup = nil;
    [self.albumsArray enumerateObjectsUsingBlock:^(CIGAMAssetsGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.phAssetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) {
            hiddenGroup = obj;
            *stop = YES;
        }
    }];
    if (hiddenGroup) {
        [self.albumsArray removeObject:hiddenGroup];
        [self.albumsArray addObject:hiddenGroup];
    }
}

- (void)refreshAlbumAndShowEmptyTipIfNeed {
    if ([self.albumsArray count] > 0) {
        if ([self.albumViewControllerDelegate respondsToSelector:@selector(albumViewControllerWillFinishLoading:)]) {
            [self.albumViewControllerDelegate albumViewControllerWillFinishLoading:self];
        }
        if (self.shouldShowDefaultLoadingView) {
            [self hideEmptyView];
        }
        [self.tableView reloadData];
    } else {
        NSString *tipString = self.tipTextWhenPhotosEmpty ? : @"空照片";
        [self showEmptyViewWithText:tipString detailText:nil buttonTitle:nil buttonAction:nil];
    }
}

- (void)pickAlbumsGroup:(CIGAMAssetsGroup *)assetsGroup animated:(BOOL)animated {
    if (!assetsGroup) return;
    
    if (!self.imagePickerViewController) {
        self.imagePickerViewController = [self.albumViewControllerDelegate imagePickerViewControllerForAlbumViewController:self];
    }
    NSAssert(self.imagePickerViewController, @"self.%@ 必须实现 %@ 并返回一个 %@ 对象", NSStringFromSelector(@selector(albumViewControllerDelegate)), NSStringFromSelector(@selector(imagePickerViewControllerForAlbumViewController:)), NSStringFromClass([CIGAMImagePickerViewController class]));
    
    [self.imagePickerViewController refreshWithAssetsGroup:assetsGroup];
    self.imagePickerViewController.title = [assetsGroup name];
    [self.navigationController pushViewController:self.imagePickerViewController animated:animated];
}

- (void)pickLastAlbumGroupDirectlyIfCan {
    CIGAMAssetsGroup *assetsGroup = [CIGAMImagePickerHelper assetsGroupOfLastPickerAlbumWithUserIdentify:nil];
    [self pickAlbumsGroup:assetsGroup animated:NO];
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.albumsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.albumTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifer = @"cell";
    CIGAMAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifer];
    if (!cell) {
        cell = [[CIGAMAlbumTableViewCell alloc] initForTableView:tableView withStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifer];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    CIGAMAssetsGroup *assetsGroup = self.albumsArray[indexPath.row];
    cell.imageView.image = [assetsGroup posterImageWithSize:CGSizeMake(self.albumTableViewCellHeight, self.albumTableViewCellHeight)];
    cell.textLabel.text = [assetsGroup name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"· %@", @(assetsGroup.numberOfAssets)];
    [cell updateCellAppearanceWithIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self pickAlbumsGroup:self.albumsArray[indexPath.row] animated:YES];
}

- (void)handleCancelSelectAlbum:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void) {
        if (self.albumViewControllerDelegate && [self.albumViewControllerDelegate respondsToSelector:@selector(albumViewControllerDidCancel:)]) {
            [self.albumViewControllerDelegate albumViewControllerDidCancel:self]; 
        }
        [self.imagePickerViewController.selectedImageAssetArray removeAllObjects];
    }];
}

@end
