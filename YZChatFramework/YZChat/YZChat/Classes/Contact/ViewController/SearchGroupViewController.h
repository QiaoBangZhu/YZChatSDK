//
//  SearchGroupViewController.h
//  YChat
//
//  Created by magic on 2020/9/19.
//  Copyright © 2020 Apple. All rights reserved.
//
/** 
 *  本文件实现了查找群组的视图控制器，使用户能够根据群组ID查找指定群组
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchGroupSearchResultViewController : UIViewController

@end

@interface SearchGroupViewController : UIViewController

@property (nonatomic,retain) UISearchController *searchController;

@end

NS_ASSUME_NONNULL_END
