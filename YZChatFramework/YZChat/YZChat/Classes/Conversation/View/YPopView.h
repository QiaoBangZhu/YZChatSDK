//
//  YPopView.h
//  YChat
//
//  Created by magic on 2020/10/3.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  YPopView;

@protocol YPopViewDelegate <NSObject>

- (void)popView:(YPopView*)popView didSelectRowAtIndex:(NSInteger)index;

@end

@interface YPopView : UIView
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGPoint arrowPoint;
@property (nonatomic, weak) id<YPopViewDelegate> delegate;
- (void)setData:(NSMutableArray *)data;
- (void)showInWindow:(UIWindow *)window;

@end

