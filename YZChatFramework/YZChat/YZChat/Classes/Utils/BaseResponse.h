//
//  BaseResponse.h
//  YChat
//
//  Created by magic on 2020/9/1.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseResponse : NSObject

@property (nonatomic) NSInteger code;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString* msg;

@end

NS_ASSUME_NONNULL_END
