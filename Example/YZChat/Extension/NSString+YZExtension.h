//
//  NSString+YChatExtension.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *_Nullable(^NSStringAppendBlock)(id format, ...);

#pragma mark -

// 密码验证
#define REGEX_PASSWORD_VALID    (@"^[a-zA-Z0-9_]+$")
// 用户名验证
#define REGEX_EMAIL_VALID       (@"^[A-Z0-9a-z._%+-\u4e00-\u9fa5]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$")
//a）电信：开头数字 133、153、180、181、189
//b）联通：开头数字 130、131、132、145、155、156、185、186
//c）移动：开头数字 134、135、136、137、138、139、147、150、151、152、157、158、159、182、183、184、187、188
#define REGEX_USER_NAME_LIMIT @"^.{1,11}$"
#define REGEX_PHONENO     @"13\\d{9}|14[57]\\d{8}|15[012356789]\\d{8}|18[012356789]\\d{8}|17[0678]\\d{8}"
#define VERIFYCODE  @"^[0-9]{6}$"
#define REGEX_BANGYOU @"^[a-zA-Z][a-zA-Z0-9_-]{5,19}$"
#define REGEX_PASSWORD @"^[a-zA-Z][a-zA-Z0-9_]{5,15}$"


@interface NSString (YZExtension)

@property(nonatomic, readonly) NSStringAppendBlock APPEND;

@property(nonatomic, readonly) NSData *data;
@property(nonatomic, readonly) NSDate *date;

@property(nonatomic, readonly) NSString *MD5;
@property(nonatomic, readonly) NSData *MD5Data;

// thanks to @uxyheaven
@property(nonatomic, readonly) NSString *SHA1;

- (NSArray *)allURLs;

- (NSDate *)dateFromTimeInterval;

- (NSString *)urlByAppendingDict:(NSDictionary *)params;

- (NSString *)urlByAppendingArray:(NSArray *)params;

- (NSString *)urlByAppendingKeyValues:(id)first, ...;

+ (NSString *)queryStringFromDictionary:(NSDictionary *)dict;

+ (NSString *)queryStringFromArray:(NSArray *)array;

+ (NSString *)queryStringFromKeyValues:(id)first, ...;

+ (BOOL)stringIsEmpty:(NSString *)aString;

+ (BOOL)stringIsNoEmpty:(NSString *)aString;

- (NSString *)URLEncoding;

- (NSString *)URLDecoding;

- (NSString *)trim;

- (NSString *)unwrap;

- (BOOL)match:(NSString *)expression;

- (BOOL)empty;

- (BOOL)notEmpty;

- (BOOL)is:(NSString *)other;

- (BOOL)isNot:(NSString *)other;

- (BOOL)isValueOf:(NSArray *)array;

- (BOOL)isValueOf:(NSArray *)array caseInsens:(BOOL)caseInsens;

// 计算字符串的字符数，汉字算两个字节。
- (NSInteger)charactersOfString;

- (CGSize)sizeWithFont:(UIFont *)font byWidth:(CGFloat)width;
- (CGSize)sizeWithFont:(UIFont *)font byHeight:(CGFloat)height;

+ (BOOL)isAllNum:(NSString *)string;  //判断字符串是否是全数字，是返回yes

/**
 根据字体算出字符串的size
 
 @param font 字体
 @return CGSize
 */
-(CGSize)stringSizeWithFont:(UIFont *)font;

+ (NSString *)random32bitString;

@end

NS_ASSUME_NONNULL_END
