//
//  YZMsgManager.h
//  YZChat
//
//  Created by magic on 2021/1/8.
//

#import <Foundation/Foundation.h>
#import "YzCustomMsg.h"

typedef NS_ENUM(NSInteger, YZSendMsgType)
{
    YZSendMsgTypeC2C = 1,//单聊
    YZSendMsgTypeGrp = 2,//群聊
};

/// 成功回调
typedef void (^YZMsgManagerSucc)(void);
/// 失败回调
typedef void (^YZMsgManagerFail)(int errCode, NSString *errMsg);

@interface YZMsgManager : NSObject

+ (YZMsgManager *)shareInstance;

- (void)sendMessageWithMsgType:(YZSendMsgType)type
                       message:(YzCustomMsg*)msg
                        userId:(NSString*)userId
                         grpId:(NSString*)grpId
                  loginSuccess:(YZMsgManagerSucc)success
                   loginFailed:(YZMsgManagerFail)fail;

@end

