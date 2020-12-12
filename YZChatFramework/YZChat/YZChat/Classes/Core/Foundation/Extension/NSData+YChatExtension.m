//
//  NSData+YChatExtension.m
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "NSData+YChatExtension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (YChatExtension)

@dynamic string;
@dynamic MD5;
@dynamic MD5String;

- (NSString *)string
{
    return [[NSString alloc] initWithData:self encoding:NSStringEncodingConversionAllowLossy];
}

- (NSData *)MD5
{
    unsigned char md5Result[CC_MD5_DIGEST_LENGTH + 1];
    CC_MD5( [self bytes], [self length], md5Result );
    
    NSMutableData * retData = [[NSMutableData alloc] init];
    if ( nil == retData )
        return nil;
    
    [retData appendBytes:md5Result length:CC_MD5_DIGEST_LENGTH];
    return retData;
}

- (NSString *)MD5String
{
    NSData * value = [self MD5];
    if ( value )
    {
        char            tmp[16];
        unsigned char *    hex = (unsigned char *)malloc( 2048 + 1 );
        unsigned char *    bytes = (unsigned char *)[value bytes];
        unsigned long    length = [value length];
        
        hex[0] = '\0';
        
        for ( unsigned long i = 0; i < length; ++i )
        {
            sprintf( tmp, "%02X", bytes[i] );
            strcat( (char *)hex, tmp );
        }
        
        NSString * result = [NSString stringWithUTF8String:(const char *)hex];
        free( hex );
        return result;
    }
    else
    {
        return nil;
    }
}

@end
