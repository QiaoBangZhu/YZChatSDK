//
//  TMRTCAuthService.h
//  WeMeetApp
//
//  Created by lokiyu on 2020/4/26.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, kTMRTCMeetingError) {
    kTMRTCMeetingErrorSuccess         = 0,
    kTMRTCMeetingErrorNotInit         = 20001,
    kTMRTCMeetingErrorNotAuth         = 20002,
    kTMRTCMeetingErrorInvalidParam    = 20003,
};


@protocol TMRTCMeetingServiceDelegate;
@interface TMRTCMeetingService : NSObject

@property (nonatomic, weak) id <TMRTCMeetingServiceDelegate> delegate;

/*!
@brief Specify to join meeting with scheme.
@param scheme copy from share meeting info, ususally has prefix of @"https://meeting.tencent.com/s/" or @"https://meeting.qq.com/s/"
@return see details in kTMRTCMeetingError.
@warning must be called adfter initial SDK and login.
*/
- (kTMRTCMeetingError)joinMeetingWithScheme:(NSString *)scheme;
@end

NS_ASSUME_NONNULL_END
