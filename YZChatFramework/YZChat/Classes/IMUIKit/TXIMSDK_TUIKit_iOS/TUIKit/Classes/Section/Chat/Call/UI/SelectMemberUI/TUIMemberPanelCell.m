//
//  TUISelectedUserCollectionViewCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//

#import "TUIMemberPanelCell.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TUIKit.h"
#import "NSBundle+YZBundle.h"
#import "CommonConstant.h"

@implementation TUIMemberPanelCell
{
    UIImageView *_imageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_imageView];
        
        if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
            _imageView.layer.cornerRadius = frame.size.height/2;
            _imageView.layer.masksToBounds =  YES;
        }else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
            _imageView.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
            _imageView.layer.masksToBounds =  YES;
        }
    }
    return self;
}

- (void)fillWithData:(UserModel *)model
{
    [_imageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:YZChatResource(@"defaultAvatarImage") options:SDWebImageHighPriority];

}



@end
