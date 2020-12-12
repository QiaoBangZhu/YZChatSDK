//
//  NSDate+YChatExtension.m
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "NSDate+YChatExtension.h"
#import "NSDate+Utilities.h"

@implementation NSDate (YChatExtension)

@dynamic string;
@dynamic number;

- (NSString *)string
{
    return self.description;
}

- (NSNumber *)number
{
    return [NSNumber numberWithDouble:self.timeIntervalSince1970];
}

- (NSString *)stringWithDateFormat:(NSString *)format
{
#if 0
    
    NSTimeInterval time = [self timeIntervalSince1970];
    NSUInteger timeUint = (NSUInteger)time;
    return [[NSNumber numberWithUnsignedInteger:timeUint] stringWithDateFormat:format];
    
#else
    
    // thansk @lancy, changed: "NSDate depend on NSNumber" to "NSNumber depend on NSDate"
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:self];
    
#endif
}
//yyyy-MM-dd HH:mm:ss
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}

+ (NSUInteger)timeStamp
{
    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    return (NSUInteger)(time * 1000.0f);
}

+ (NSInteger)getCurrentDay {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd"];
    return [[dateFormatter stringFromDate:[NSDate date]] intValue];
}

+ (NSString *)getCurrentYearMonth{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (NSString *)getCurrentDateTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

- (BOOL)isdaysBeforeDate:(NSDate *)date {
   return [self day] - [date day];
}

//此处用毫秒计算
+ (BOOL)isTimeBetween:(double)earlier later:(double)later {
    double nowDouble = [NSDate date].timeIntervalSince1970*1000;
    if (earlier < nowDouble && nowDouble < later) {
        return YES;
    }
    return NO;
}

@end
