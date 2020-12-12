//
//  TMRTCAuthService.h
//  WeMeetApp
//
//  Created by ulee on 2020/4/14.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, kTMRTCAuthResult) {
    kTMRTCAuthResultSuccess     = 0,
    kTMRTCAuthResultAppAuthFailed         = 5000,  // authCode for token failed, should retry with login
    kTMRTCAuthResultTimeOut               = 5002,  // network request timeout
    kTMRTCAuthResultCreateError           = 5003,  // create error

    kTMRTCAuthResultParseError            = 5005,  // Parse xml error.
    kTMRTCAuthResultRequestTimeout        = 5006,  // Request timeout.
    kTMRTCAuthResultServerError           = 5007,  // Receive invalid response.
    kTMRTCAuthResultNetworkError          = 5008,  // network breakup.

    kTMRTCAuthResultProhibitAppVersion    = 5013,   // Prohibit app version, should upgrade sdk version for using
    kTMRTCAuthResultPackageSignIllegal    = 5014,   // illegal package, check your attribute param and website config
    kTMRTCAuthResultTokenParamIllegal     = 5015,   // illegal token, check your sso auth code


};


@protocol TMRTCAuthServiceDelegate;
@protocol TMRTCAuthServiceDataSource;

/*!
@brief The method provides support for authorizing TMRTC.
@warning Users should authorize TMRTC before using meeting service.
*/
@interface TMRTCAuthService : NSObject

@property (nonatomic, weak) id <TMRTCAuthServiceDelegate> delegate;
@property (nonatomic, weak) id <TMRTCAuthServiceDataSource> dataSource;

/*!
@brief Authenticate SDK.
@return YES indicates to call the method successfully. Otherwise not.
@warning using it after initialing sdk with attributes and before pushing sdk view out.
@warning if login successfully before, it will auto login with data before, otherwise,
         ssoAuthCode should be offered for authenticate, see details in TMRTCAuthServiceDataSource.
*/
- (BOOL)login;

/*!
@brief Specify to logout TMRTC.
@return YES indicates to call the method successfully. Otherwise not.
@warning The method is optional, using it only when you should unsubscribe old account and authorize with a new one, otherwise, ignore it.
*/
- (BOOL)logout;
@end

/*!
@brief An authentication service will issue the following values when the authorization state changes.
*/
@protocol TMRTCAuthServiceDelegate <NSObject>
/*!
@brief Specify to get the response of TMRTC login operation.
@param error Notify the user that the authorization maybe failed and specify details in code and localizeddescription,
       if return null or code is kTMRTCAuthResultSuccess, then you should push rootviewControler out.
*/
- (void)auth:(TMRTCAuthService *)auth didFinishLoginWithError:(nullable NSError *)error;

/*!
@brief Specify to get the response of TMRTC logout operation.
@param error Notify the user that the authorization maybe failed and specify details in code and localizeddescription.
*/
- (void)auth:(TMRTCAuthService *)auth didFinishLogoutWithError:(nullable NSError *)error;

/*!
@brief notify when back button did selected, it means that user want to exit TMRTC service.
*/
- (void)exit;
@end

@protocol TMRTCAuthServiceDataSource<NSObject>

@required
/*!
@brief Specify to set the valid authCode for authorization.
@param block for setting ssoCode came from dependable channel like sso.
@warning The method will be called for case no authorization data in database, e.g. never login before.
*/
- (void)ssoAuthCodeForAuth:(void (^)(NSString *ssoCode))block;
@end

NS_ASSUME_NONNULL_END
