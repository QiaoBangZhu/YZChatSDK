//
//  NSArray+YChatExtension.m
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "NSArray+YChatExtension.h"

@implementation NSArray (YChatExtension)

- (void)safelyAddObject:(id)object;
{
    if (!object) {
        NSLog(@"safely add Object nil");
        return;
    }
//    [self addObject:object];
}

@end
