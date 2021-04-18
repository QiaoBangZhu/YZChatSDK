//
//  CommonConstant.h
//  YChat
//
//  Created by magic on 2020/9/24.
//  Copyright © 2020 Apple. All rights reserved.
//

#ifndef CommonConstant_h
#define CommonConstant_h

#ifdef DEBUG
#define sdkBusiId 22627
#else
#define sdkBusiId 22628
#endif

static const int SDKAPPID = 1400432221;
//元讯的appId
static NSString*  const ychatAppId = @"de241446a50499bb77a8684cf610fd04";

//高德地图
static NSString * const amapKey = @"7892fa637e3dffeb7f7352790a510398";

//腾讯会议相关参数
static NSString * const kSdkId = @"2009233371";
static NSString * const kSdkToken = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiIyMDA5MjMzMzcxIiwiaWF0IjoxNjAxMjgyNTY2LCJleHAiOjE2MDY1NTI5NjYsImF1ZCI6IlRlbmNlbnQgTWVldGluZyIsInN1YiI6Inl1YW56aGlfdGVzdDAxIn0.9DXh4MFF490mVipau7QgotrFvCe-tupj3JtefbTLQ44";
static NSString * const SSOFormatString = @"https://yzmetax-idp.id.meeting.qq.com/cidp/login/ai-2f96eed8349d4c7e8424cbe5a7136645?state=aHR0cHM6Ly95em1ldGF4LmlkLm1lZXRpbmcucXEuY29tL3Nzby9haS0xZTJlMzA5NjVhZjE0OGM3YWY5ODhjNGY3NzA3YTdlNg==&id_token=";

static  NSString * const wxPreUrl = @"https://wx.tenpay.com/cgi-bin/mmpayweb-bin/checkmweb";
static  NSString * const scheme = @"tg.tripg.com";

#define YZChatResource(name) [UIImage imageNamed:name inBundle:[NSBundle yzBundle] compatibleWithTraitCollection:nil]

//取消了视频或者语音通话
#define TUIKitNotification_Call_Cancelled @"TUIKitNotification_Call_Cancelled"

static NSString * const userAgreementUrl = @"https://yinsi.yzmetax.com/agreement.html";
static NSString * const privacyPolicyUrl = @"https://yinsi.yzmetax.com/conceal.html";

#define kHeadImageContentFile @"kHeadImageContentFile"
// 屏幕宽
#define KScreenWidth ([UIScreen mainScreen].bounds.size.width)
// 屏幕高
#define KScreenHeight ([UIScreen mainScreen].bounds.size.height)

#define KKeyWindow [UIApplication sharedApplication].keyWindow


#define SEARCHBAR_HEIGHT (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0") ? 52.0f : 44.0f)

#define safeAreaTopHeight (KScreenWidth >= 812.0 ? 88 : 64)


//color
#define kCommonBlueTextColor            (0x2F7AFF)       //蓝色
#define KCommonBlackColor               (0x212121)       //黑色
#define KCommonBlackTextColor           (0x2D3034)       //黑色标题
#define KCommonBlueBubbleColor          (0x3386F2)       //蓝色气泡
#define KCommonChatBgColor              (0xF6F9FF)       //聊天页面背景色
#define KCommonBackgroundColor          (0xF0F3F8)       //背景色
#define kCommonIconGrayColor            (0xE4E6E9)       //灰色
#define kCommonGrayTextColor            (0x787878)       //浅灰色
#define KCommonSepareteLineColor        (0xE9EBEC)       //浅色
#define KCommonBorderColor              (0xA8AFBA)       //灰色
#define KCommonlittleLightGrayColor     (0xAAAAAA)       //一点灰
#define KCommonYellowColor              (0xfdac3b)       //黄色
#define KCommonTimeColor                (0xC7CBD5)       //浅色
#define KCommonInputBorderColor         (0xD9D9D9)       //边框颜色
#define KCommonBubbleTextGrayColor      (0x8B94A1)       //发送位置的气泡文字灰色
#define KCommonRecordBtnBorderColor     (0xCBCBCB)       //发送语音按钮边框颜色
#define KCommonSearchBarBackgroundColor (0xF9F9FA)       // 搜索框背景色
#define KCommonGraySubTextColor         (0x999999)       // 浅灰色
#define KCommonVoiceTitleColor          (0x6D7587)       // 黑色

#pragma mark - # 设备型号

#define IS_IOS11orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)
#define IS_IOS10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 11.0)
#define IS_IOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0)
#define IOS11_OR_LATER ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)
#define IOS10_3_OR_LATER ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 10.3)
#define IOS10_OR_LATER ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define IOS9_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IOS8_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IOS7_OR_LATER    ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IOS13_OR_LATER  ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0)

#pragma mark -- 手机型号参数

#define kscale  kScreenHeight / 667
#define kscaleW kScreenWidth / 375

#define iPhone4s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)) : NO)
#define iPhone7 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)) : NO)
#define iPhone6plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)
// 320宽度
#define width_320 ([UIScreen mainScreen].bounds.size.width == 320)

#define iPadAir2 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1536, 2048), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)
#define IS_IPHONEX  (KScreenWidth >= 375 && KScreenHeight >= 812.0)


#pragma mark - # 系统版本
#define     SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define     SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define     SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define     SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define     SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

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

#endif /* CommonConstant_h */
