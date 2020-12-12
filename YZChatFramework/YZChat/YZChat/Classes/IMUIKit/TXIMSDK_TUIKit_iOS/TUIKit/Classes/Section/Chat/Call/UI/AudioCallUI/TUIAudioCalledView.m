//
//  TUIAudioCalledView.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/13.
//

#import "TUIAudioCalledView.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"
#import "TUIKit.h"

@implementation TUIAudioCalledView
{
    UIImageView *_imageView;
    UILabel *_label;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-60)];
        [self addSubview:_imageView];
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 20 - 4 - 25, frame.size.width, 25)];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        
        _dailingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 20, frame.size.width, 20)];
        _dailingLabel.textColor = [UIColor whiteColor];
        _dailingLabel.textAlignment = NSTextAlignmentCenter;
        _dailingLabel.text = @"正在呼叫...";
        [self addSubview:_dailingLabel];
        
        if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
            _imageView.layer.masksToBounds = YES;
            _imageView.layer.cornerRadius = (frame.size.height-60)/2;
        }else if([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner){
            _imageView.layer.masksToBounds = YES;
            _imageView.layer.cornerRadius = TAvatarTypeRadiusCorner;
        }
    }
    return self;
}

- (void)fillWithData:(CallUserModel *)model {
    [_imageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"defaultAvatarImage"] options:SDWebImageHighPriority];
    if (model.name.length > 0) {
        _label.text = model.name;
    } else {
        _label.text = model.userId;
    }
    _dailingLabel.hidden = model.isEnter;
}

@end
