//
//  SearchViewController.h
//  YChat
//
//  Created by magic on 2020/10/6.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIConversationCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchViewController : UIViewController<UISearchResultsUpdating>
@property (nonatomic, strong) UINavigationController *nav;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray<TUIConversationCellData *> *dataListArry;
@end

NS_ASSUME_NONNULL_END
