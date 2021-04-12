//
//  YzCustomMsg.h
//  YZChat
//
//  Created by magic on 2021/1/8.
//

#import <Foundation/Foundation.h>

#import "YzCustomMessageView.h"

typedef NS_ENUM(NSInteger, YzCustomMsgType)
{
    YzCustomMsgTypeCardMsg = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface YzCustomMsg : NSObject
/*消息类型*/
@property (nonatomic,assign)YzCustomMsgType businessID;
/**标题*/
@property (nonatomic, copy)NSString *title;
/**描述*/
@property (nonatomic, copy)NSString *desc;
/**https链接*/
@property (nonatomic, copy)NSString *link;
/**https链接，不支持本地文件*/
@property (nonatomic, copy)NSString *logo;


@end

NS_ASSUME_NONNULL_END
