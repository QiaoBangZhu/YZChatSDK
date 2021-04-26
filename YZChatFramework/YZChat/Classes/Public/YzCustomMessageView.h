//
//  YzCustomMessageView.h
//  YZChat
//
//  Created by 安笑 on 2021/4/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YzCustomMessageData : NSObject

/**
 * 消息气泡标识符
 *
 * 子类重写
 */
@property (nonatomic, copy) NSString *reuseIdentifier;

/**
 * 一个气泡内容的视图大小
 *
 * 子类重写
 */
- (CGSize)contentSize;

/**
 * 自定义消息二进制数据
 *
 * 子类重写
 */
- (NSData *)data;

@end


/**
 * 自定义消息内容控件
 */
@interface YzCustomMessageView : UIView

@property (nonatomic, strong, readonly) YzCustomMessageData *data;

- (void)fillWithData:(YzCustomMessageData *)data;

@end

NS_ASSUME_NONNULL_END
