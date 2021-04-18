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
 * @default
 */
@property (nonatomic, copy) NSString *reuseIdentifier;

/**
 *  内容大小
 *  返回一个气泡内容的视图大小。
 */
- (CGSize)contentSize;

@end


/**
 * 自定义消息内容控件
 */
@interface YzCustomMessageView : UIView

@property (nonatomic, strong, readonly) YzCustomMessageData *data;

- (void)fillWithData:(YzCustomMessageData *)data;

@end

NS_ASSUME_NONNULL_END
