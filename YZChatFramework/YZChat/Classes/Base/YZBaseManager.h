//
//  YZBaseManager.h
//  YChat
//
//  Created by magic on 2020/12/12.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YzTabBarViewController.h"
#import "YUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZBaseManager : NSObject
@property (nonatomic, strong)YUserInfo *userInfo;
@property (nonatomic, strong)NSData   *deviceToken;
@property (nonatomic, strong)YzTabBarViewController * tabController;
@property (nonatomic,   copy)NSString* appId;
@property (nonatomic, strong)UIViewController* rootViewController;

+ (YZBaseManager *)shareInstance;

- (YzTabBarViewController *)getMainController;

- (void)logout;

-(void)statisticsUsedTime:(int)seconds isVideo:(BOOL)isVideo;


@end

NS_ASSUME_NONNULL_END
