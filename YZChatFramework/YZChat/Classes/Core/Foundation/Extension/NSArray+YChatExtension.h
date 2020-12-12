//
//  NSArray+YChatExtension.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YChat_Precompile.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (YChatExtension)

- (void)safelyAddObject:(id)object;

@end

NS_ASSUME_NONNULL_END
