//
//  NSData+YChatExtension.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (YChatExtension)

@property (nonatomic, readonly) NSString *    string;
@property (nonatomic, readonly) NSData   *    MD5;
@property (nonatomic, readonly) NSString *    MD5String;

@end

NS_ASSUME_NONNULL_END
