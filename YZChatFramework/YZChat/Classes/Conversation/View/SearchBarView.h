//
//  SearchBarView.h
//  YChat
//
//  Created by magic on 2020/10/25.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SearchBarDelegate <NSObject>
@required
- (void)textDidChange:(NSString *)searchText;
@optional
- (void)onCancle;

@end

@interface SearchBarView : UIView
@property (nonatomic, assign)BOOL isShowCancle;
@property (nonatomic, assign)BOOL isCanEdit;
@property (nonatomic, copy)NSString *placeholder;
@property (nonatomic, assign)id<SearchBarDelegate>delegate;
@property (nonatomic, assign)BOOL resginTextView;
@end

NS_ASSUME_NONNULL_END
