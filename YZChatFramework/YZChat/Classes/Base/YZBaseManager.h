//
//  YZBaseManager.h
//  YChat
//
//  Created by magic on 2020/12/12.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TUITabBarController.h"
#import "UserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZBaseManager : NSObject
@property (nonatomic, strong)UserInfo *userInfo;
@property (nonatomic, strong)NSData   *deviceToken;
@property (nonatomic, strong)TUITabBarController * tabController;
@property (nonatomic,   copy)NSString* appId;

+ (YZBaseManager *)shareInstance;

- (UIViewController *)getLoginController;

- (TUITabBarController *)getMainController;

- (void)logout;

-(void)statisticsUsedTime:(int)seconds isVideo:(BOOL)isVideo;


@end

NS_ASSUME_NONNULL_END
