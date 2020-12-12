//
//  DefaultPortraitView.h
//  YChat
//
//  Created by magic on 2020/11/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DefaultPortraitView : NSObject

+ (UIImage *)portraitView:(NSString *)userId name:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
