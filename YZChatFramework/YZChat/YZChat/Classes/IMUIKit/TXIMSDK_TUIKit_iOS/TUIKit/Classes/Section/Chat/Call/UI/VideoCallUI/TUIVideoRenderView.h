//
//  TUIVideoRenderView.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/8.
//

#import <UIKit/UIKit.h>
#import "TUICallModel.h"
#import "TUICallUtils.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CallViewLayoutStyle) {
    CallViewLayoutStyleSmall,
    CallViewLayoutStyleBig,
};

@interface TUIVideoRenderView : UIView

@property (nonatomic,strong)CallUserModel *userModel;
@property (nonatomic, assign)CallViewLayoutStyle layout;

- (void)fillWithData:(CallUserModel *)user layout:(CallViewLayoutStyle)style;


@end

NS_ASSUME_NONNULL_END
