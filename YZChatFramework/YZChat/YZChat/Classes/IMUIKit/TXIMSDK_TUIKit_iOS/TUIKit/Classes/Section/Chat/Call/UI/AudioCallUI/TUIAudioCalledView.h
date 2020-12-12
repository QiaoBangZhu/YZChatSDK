//
//  TUIAudioCalledView.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/13.
//

#import <UIKit/UIKit.h>
#import "TUICallModel.h"

@interface TUIAudioCalledView : UIView
@property (nonatomic, strong)UILabel *dailingLabel;

- (void)fillWithData:(CallUserModel *)model;
@end

