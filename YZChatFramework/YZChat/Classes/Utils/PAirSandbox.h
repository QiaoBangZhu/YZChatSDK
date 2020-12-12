//
//  PAirSandbox.h
//  YChat
//
//  Created by magic on 2020/9/19.
//  Copyright © 2020 Apple. All rights reserved..
//

#import <Foundation/Foundation.h>

@interface PAirSandbox : NSObject

+ (instancetype)sharedInstance;

- (void)enableSwipe;
- (void)showSandboxBrowser;

- (void)addAppGroup:(NSString *)groupId;

@end

