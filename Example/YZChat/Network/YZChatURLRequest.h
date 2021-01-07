//
//  YChatURLRequest.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZChatURLRequest : NSMutableURLRequest

@property(nonatomic, strong)NSMutableDictionary* paramDict;

@end

NS_ASSUME_NONNULL_END
