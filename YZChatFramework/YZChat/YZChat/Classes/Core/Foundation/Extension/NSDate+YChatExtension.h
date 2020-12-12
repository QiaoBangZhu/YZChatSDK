//
//  NSDate+YChatExtension.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YChat_Precompile.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (YChatExtension)

@property (nonatomic, readonly) NSString *    string;
@property (nonatomic, readonly) NSNumber *    number;

- (NSString *)stringWithDateFormat:(NSString *)format;
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format;
- (NSNumber *)number;
+ (NSUInteger)timeStamp;
+ (NSInteger)getCurrentDay;
//获取当前年月 比如 2017年7月
+ (NSString *)getCurrentYearMonth;
//获取当前年月日 时分秒 比如 2017年7月 10:12:14
+ (NSString *)getCurrentDateTime;
- (BOOL)isdaysBeforeDate:(NSDate *)date;
+ (BOOL)isTimeBetween:(double)earlier later:(double)later;

@end

NS_ASSUME_NONNULL_END
