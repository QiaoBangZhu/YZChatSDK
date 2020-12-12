//
//  TMRTCAppDelegate.h
//  WeMeetApp
//
//  Created by ulee on 2020/4/13.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMRTCAppDelegateInitAttributes : NSObject

@property (nonatomic, copy) NSString *resourceBundlePath;
@property (nonatomic, copy) NSString *extensionGroupId;
@property (nonatomic, copy) NSString *sdkId;
@property (nonatomic, copy) NSString *sdkToken;

@end

@interface TMRTCAppDelegate : NSObject

/*!
@brief Get the default rootViewController.
@return The default rootViewController.
@warning present as rootviewcontroller when received notification of authorized successfully, see details in TMRTCAuthServiceDelegate.
*/
@property (nonatomic, strong, readonly) UIViewController *rootViewController;

/*!
@brief Call the function to get the TMRTC client.
@warning The sharedSDK will be instantiated only once over the lifespan of the application. Configure the client with the specified appid, key and token.
@return A preconfigured MobileRTC client.
*/
+ (instancetype)sharedRTC;

/*! @brief Call the function to initialize TMRTC.
 *
 * @param attributes params of inital config, details in TMRTCAppDelegateInitAttributes
 * @return YES indicates successfully. Otherwise not.
*/
- (BOOL)initWithAttributes:(TMRTCAppDelegateInitAttributes * _Nonnull)attributes;

/*! @brief destroy TMRTC client
*/
- (void)destroy;

@end

@class TMRTCAuthService;
@class TMRTCMeetingService;

@interface TMRTCAppDelegate (Service)
/*!
@brief Get the default auth service.
@return The default auth service.
*/
@property (nonatomic, strong, readonly) TMRTCAuthService *authService;

/*!
@brief Get the default meeting service.
@return The default meeting service.
*/
@property (nonatomic, strong, readonly) TMRTCMeetingService *meetingService;
@end

NS_ASSUME_NONNULL_END
