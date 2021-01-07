//
//  NSObject+YChatTypeConversion.m
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "NSObject+YZTypeConversion.h"

@implementation NSObject (YZTypeConversion)

- (BOOL)isNotKindOfClass:(Class)aClass
{
    return NO == [self isKindOfClass:aClass];
}

- (NSNumber *)asNSNumber
{
    if ( [self isKindOfClass:[NSNumber class]] )
    {
        return (NSNumber *)self;
    }
    else if ( [self isKindOfClass:[NSString class]] )
    {
        return [NSNumber numberWithInteger:[(NSString *)self integerValue]];
    }
    else if ( [self isKindOfClass:[NSDate class]] )
    {
        return [NSNumber numberWithDouble:[(NSDate *)self timeIntervalSince1970]];
    }
    else if ( [self isKindOfClass:[NSNull class]] )
    {
        return [NSNumber numberWithInteger:0];
    }
    
    return nil;
}

- (NSString *)asNSString
{
    if ( [self isKindOfClass:[NSString class]] )
    {
        return (NSString *)self;
    }
    else
    {
        return [NSString stringWithFormat:@"%@", self];
    }
}

- (NSDate *)asNSDate
{
    if ( [self isKindOfClass:[NSDate class]] )
    {
        return (NSDate *)self;
    }
    else if ( [self isKindOfClass:[NSString class]] )
    {
        NSTimeZone * local = [NSTimeZone localTimeZone];
        
        NSString * format = @"yyyy-MM-dd HH:mm:ss";
        NSString * text = [(NSString *)self substringToIndex:format.length];
        
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:format];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        return [NSDate dateWithTimeInterval:(3600 + [local secondsFromGMT])
                                  sinceDate:[dateFormatter dateFromString:text]];
    }
    else
    {
        return [NSDate dateWithTimeIntervalSince1970:[self asNSNumber].doubleValue];
    }
    
    return nil;
}

@end
