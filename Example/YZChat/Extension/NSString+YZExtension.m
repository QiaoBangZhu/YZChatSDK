//
//  NSString+YChatExtension.m
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "NSString+YZExtension.h"

#import "NSData+YZExtension.h"
#import "NSObject+YZTypeConversion.h"

#include <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (YZExtension)

@dynamic data;
@dynamic date;

@dynamic MD5;
@dynamic MD5Data;

@dynamic SHA1;

@dynamic APPEND;

- (NSData *)data
{
    return [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
}

- (NSDate *)date
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

+ (NSString *)random32bitString {
    char data[32];
    for (int x = 0; x < 32; data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
}

- (NSDate*)dateFromTimeInterval;
{
    NSTimeInterval timeInterval = [self doubleValue];
    return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}

- (NSStringAppendBlock)APPEND
{
    NSStringAppendBlock block = ^ NSString * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * className = [[self class] description];
        
        if ( [className isEqualToString:@"NSMutableString"] )
        {
            NSString * append = [[NSString alloc] initWithFormat:first arguments:args];
            [(NSMutableString *)self appendString:append];
            va_end( args );
            return self;
        }
        else
        {
            NSMutableString * copy = [self mutableCopy];
            
            NSString * append = [[NSString alloc] initWithFormat:first arguments:args];
            [copy appendString:append];
            va_end( args );
            return copy;
        }
    };
    
    return [block copy];
}

- (NSArray *)allURLs
{
    NSMutableArray * array = [NSMutableArray array];
    
    NSInteger stringIndex = 0;
    while ( stringIndex < self.length )
    {
        NSRange searchRange = NSMakeRange(stringIndex, self.length - stringIndex);
        NSRange httpRange = [self rangeOfString:@"http://" options:NSCaseInsensitiveSearch range:searchRange];
        NSRange httpsRange = [self rangeOfString:@"https://" options:NSCaseInsensitiveSearch range:searchRange];
        
        NSRange startRange;
        if ( httpRange.location == NSNotFound )
        {
            startRange = httpsRange;
        }
        else if ( httpsRange.location == NSNotFound )
        {
            startRange = httpRange;
        }
        else
        {
            startRange = (httpRange.location < httpsRange.location) ? httpRange : httpsRange;
        }
        
        if (startRange.location == NSNotFound)
        {
            break;
        }
        else
        {
            NSRange beforeRange = NSMakeRange( searchRange.location, startRange.location - searchRange.location );
            if ( beforeRange.length )
            {
                //                NSString * text = [string substringWithRange:beforeRange];
                //                [array addObject:text];
            }
            
            NSRange subSearchRange = NSMakeRange(startRange.location, self.length - startRange.location);
            NSRange endRange = [self rangeOfString:@" " options:NSCaseInsensitiveSearch range:subSearchRange];
            if ( endRange.location == NSNotFound)
            {
                NSString * url = [self substringWithRange:subSearchRange];
                [array addObject:url];
                break;
            }
            else
            {
                NSRange URLRange = NSMakeRange(startRange.location, endRange.location - startRange.location);
                NSString * url = [self substringWithRange:URLRange];
                [array addObject:url];
                
                stringIndex = endRange.location;
            }
        }
    }
    
    return array;
}

+ (NSString *)queryStringFromDictionary:(NSDictionary *)dict
{
    NSMutableArray * pairs = [NSMutableArray array];
    for ( NSString * key in dict.allKeys )
    {
        NSString * value = [((NSObject *)[dict objectForKey:key]) asNSString];
        NSString * urlEncoding = [value URLEncoding];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, urlEncoding]];
    }
    
    return [pairs componentsJoinedByString:@"&"];
}

+ (NSString *)queryStringFromArray:(NSArray *)array
{
    NSMutableArray *pairs = [NSMutableArray array];
    
    for ( NSUInteger i = 0; i < [array count]; i += 2 )
    {
        NSObject * obj1 = [array objectAtIndex:i];
        NSObject * obj2 = [array objectAtIndex:i + 1];
        
        NSString * key = nil;
        NSString * value = nil;
        
        if ( [obj1 isKindOfClass:[NSNumber class]] )
        {
            key = [(NSNumber *)obj1 stringValue];
        }
        else if ( [obj1 isKindOfClass:[NSString class]] )
        {
            key = (NSString *)obj1;
        }
        else
        {
            continue;
        }
        
        if ( [obj2 isKindOfClass:[NSNumber class]] )
        {
            value = [(NSNumber *)obj2 stringValue];
        }
        else if ( [obj2 isKindOfClass:[NSString class]] )
        {
            value = (NSString *)obj2;
        }
        else
        {
            continue;
        }
        
        NSString * urlEncoding = [value URLEncoding];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, urlEncoding]];
    }
    
    return [pairs componentsJoinedByString:@"&"];
}

+ (NSString *)queryStringFromKeyValues:(id)first, ...
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    va_list args;
    va_start( args, first );
    
    for ( ;; )
    {
        NSObject<NSCopying> * key = [dict count] ? va_arg( args, NSObject * ) : first;
        if ( nil == key )
            break;
        
        NSObject * value = va_arg( args, NSObject * );
        if ( nil == value )
            break;
        
        [dict setObject:value forKey:key];
    }
    va_end( args );
    return [NSString queryStringFromDictionary:dict];
}

- (NSString *)urlByAppendingDict:(NSDictionary *)params
{
    NSURL * parsedURL = [NSURL URLWithString:self];
    NSString * queryPrefix = parsedURL.query ? @"&" : @"?";
    NSString * query = [NSString queryStringFromDictionary:params];
    return [NSString stringWithFormat:@"%@%@%@", self, queryPrefix, query];
}

- (NSString *)urlByAppendingArray:(NSArray *)params
{
    NSURL * parsedURL = [NSURL URLWithString:self];
    NSString * queryPrefix = parsedURL.query ? @"&" : @"?";
    NSString * query = [NSString queryStringFromArray:params];
    return [NSString stringWithFormat:@"%@%@%@", self, queryPrefix, query];
}

- (NSString *)urlByAppendingKeyValues:(id)first, ...
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    va_list args;
    va_start( args, first );
    
    for ( ;; )
    {
        NSObject<NSCopying> * key = [dict count] ? va_arg( args, NSObject * ) : first;
        if ( nil == key )
            break;
        
        NSObject * value = va_arg( args, NSObject * );
        if ( nil == value )
            break;
        
        [dict setObject:value forKey:key];
    }
    va_end( args );
    return [self urlByAppendingDict:dict];
}

- (BOOL)empty
{
    return [self length] > 0 ? NO : YES;
}

- (BOOL)notEmpty
{
    return [self length] > 0 ? YES : NO;
}

- (BOOL)is:(NSString *)other
{
    return [self isEqualToString:other];
}

- (BOOL)isNot:(NSString *)other
{
    return NO == [self isEqualToString:other];
}

- (BOOL)isValueOf:(NSArray *)array
{
    return [self isValueOf:array caseInsens:NO];
}

- (BOOL)isValueOf:(NSArray *)array caseInsens:(BOOL)caseInsens
{
    NSStringCompareOptions option = caseInsens ? NSCaseInsensitiveSearch : NSLiteralSearch;
    
    for ( NSObject * obj in array )
    {
        if ( NO == [obj isKindOfClass:[NSString class]] )
            continue;
        
        if ( [(NSString *)obj compare:self options:option] )
            return YES;
    }
    
    return NO;
}

- (NSString *)URLEncoding
{
    NSString * result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault,
                                                                            (CFStringRef)self,
                                                                            NULL,
                                                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                            kCFStringEncodingUTF8 ));
    return result;
}

- (NSString *)URLDecoding
{
    NSMutableString * string = [NSMutableString stringWithString:self];
    [string replaceOccurrencesOfString:@"+"
                            withString:@" "
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, [string length])];
    return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)MD5
{
    if ([NSString stringIsEmpty:self]) {
        return @"";
    }
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSData *)MD5Data
{
    // TODO:
    return nil;
}

// thanks to @uxyheaven
- (NSString *)SHA1
{
    const char *    cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *        data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = { 0 };
    CC_SHA1( data.bytes, data.length, digest );
    
    NSMutableString * output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for ( int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++ )
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)unwrap
{
    if ( self.length >= 2 )
    {
        if ( self.length == 2 )
            return @"";
        
        if ( [self hasPrefix:@"\""] && [self hasSuffix:@"\""] )
        {
            return [self substringWithRange:NSMakeRange(1, self.length - 2)];
        }
        
        if ( [self hasPrefix:@"'"] && [self hasSuffix:@"'"] )
        {
            return [self substringWithRange:NSMakeRange(1, self.length - 2)];
        }
    }
    
    return self;
}

- (CGSize)sizeWithFont:(UIFont *)font byWidth:(CGFloat)width
{
    NSDictionary *dict = @{NSFontAttributeName :font};
    return [self boundingRectWithSize:CGSizeMake(width, 999999.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
}

- (CGSize)sizeWithFont:(UIFont *)font byHeight:(CGFloat)height
{
    NSDictionary *dict = @{NSFontAttributeName :font};
    return [self boundingRectWithSize:CGSizeMake(999999.0f, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
}

- (BOOL)match:(NSString *)expression
{
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];
    if ( nil == regex )
        return NO;
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self
                                                        options:0
                                                          range:NSMakeRange(0, self.length)];
    if ( 0 == numberOfMatches )
        return NO;
    
    return YES;
}


+ (BOOL)stringIsEmpty:(NSString*)aString
{
    if ([aString isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    
    if ((NSNull *)aString == [NSNull null]) {
        return YES;
    }
    
    if (aString == nil) {
        return YES;
    } else if ([aString isNotKindOfClass:[NSString class]]) {
        return YES;
    } else if ([aString length] == 0) {
        return YES;
    } else {
        aString = [aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([aString length] == 0) {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)stringIsNoEmpty:(NSString*)aString;
{
    return ![self stringIsEmpty:aString];
}

//判断字符串是否是全数字，是返回yes
+ (BOOL)isAllNum:(NSString *)string{
    //    NSString *string = @"1234abcd";
    unichar c;
    for (int i=0; i<string.length; i++) {
        c=[string characterAtIndex:i];
        if (!isdigit(c)) {
            return NO;
        }
    }
    return YES;
}

- (NSInteger)charactersOfString {
    NSInteger number = 0;
    int n = 0;
    for (; n < [self length]; n++) {
        
        NSString *character = [self substringWithRange:NSMakeRange(n, 1)];
        if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 2) {
            number+=2;
        } else {
            number++;
        }
    }
    return ceil(number);
}

-(CGSize)stringSizeWithFont:(UIFont *)font {
    return [self stringSizeWithFont:font width:MAXFLOAT];
}

-(CGSize)stringSizeWithFont:(UIFont *)font width:(CGFloat)width {
    NSDictionary *attr = @{NSFontAttributeName:font};
    CGSize size = CGSizeMake(width, MAXFLOAT);
    CGSize result = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    return result;
}

@end
