//
//  NSObject+YChatTypeConversion.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZ_Precompile.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (YChatTypeConversion)

- (BOOL)isNotKindOfClass:(Class)aClass;

- (NSNumber *)asNSNumber;
- (NSString *)asNSString;
- (NSDate *)asNSDate;

@end

NS_ASSUME_NONNULL_END
