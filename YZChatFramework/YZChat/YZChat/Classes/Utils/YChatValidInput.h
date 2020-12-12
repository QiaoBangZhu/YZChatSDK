//
//  YChatValidInput.h
//  YChat
//
//  Created by magic on 2020/10/28.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YChatValidInput : NSObject

+ (BOOL)isPassword:(NSString *)password;
/*
 *  判断输入的是否是手机号
 */
+ (BOOL)isMobile:(NSString *)mobile;
/*
 *  判断输入的邮箱格式是否正确
 */
+ (BOOL)isEmail:(NSString *)email;
/*
 *  判断输入的身份证格式和合法性是否正确
 */
+ (BOOL)isValidCardNumber:(NSString *)identityCard;
/*
 *  判断输入的车牌号格式是否正确
 */
+ (BOOL)isValidCarID:(NSString *)carID;
/*
 *  判断银行卡输入是否正确
 */
+ (BOOL)isValidBankCardNo:(NSString *)cardId;
/*
 * 判断字符串是否是空
 */
+ (BOOL)isBlankString:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
