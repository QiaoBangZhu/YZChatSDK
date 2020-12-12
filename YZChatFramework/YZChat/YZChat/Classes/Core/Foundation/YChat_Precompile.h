//
//  YChat_Precompile.h
//  YChat
//
//  Created by magic on 2020/9/24.
//  Copyright © 2020 Apple. All rights reserved.
//

#ifndef YChat_Precompile_h
#define YChat_Precompile_h

#ifdef __OBJC__
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <TargetConditionals.h>

#else    // #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#endif    // #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
#endif

// Global compile option
#define DEF_URL(urlname, url) \
static NSString * const urlname = @""#url;

#define DEF_URL_SPEICIAL(urlname, url)\
static NSString* const urlname = @"&"#url;
#endif

#define UNUSED_VAR __attribute__((unused))

