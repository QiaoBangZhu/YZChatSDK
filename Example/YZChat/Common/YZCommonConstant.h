//
//  YZCommonConstant.h
//  YZChat_Example
//
//  Created by magic on 2021/3/28.
//  Copyright © 2021 QiaoBangZhu. All rights reserved.
//

#ifndef YZCommonConstant_h
#define YZCommonConstant_h

static NSString*  const yzchatAppId = @"de241446a50499bb77a8684cf610fd04";
static NSString * const yzuserAgreementUrl = @"https://yinsi.yzmetax.com/agreement.html";
static NSString * const yzprivacyPolicyUrl = @"https://yinsi.yzmetax.com/conceal.html";


// Macro for Singleton
#define SingletonH(methodName) + (instancetype _Nonnull)shared##methodName;
#define SingletonM(methodName) \
static id _instace = nil; \
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
if (_instace == nil) { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instace = [super allocWithZone:zone]; \
}); \
} \
return _instace; \
} \
\
- (id)init \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instace = [super init]; \
}); \
return _instace; \
} \
\
+ (instancetype)shared##methodName \
{ \
return [[self alloc] init]; \
} \
+ (id)copyWithZone:(struct _NSZone *)zone \
{ \
return _instace; \
} \
\
+ (id)mutableCopyWithZone:(struct _NSZone *)zone \
{ \
return _instace; \
}

#undef    AS_SINGLETON
#define AS_SINGLETON( __class ) \
+ (__class *_Nullable)sharedInstance;

#undef    DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
+ (__class *_Nullable)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}




#endif /* YZCommonConstant_h */
