#import "TCommonAvatarCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "THeader.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImage+TUIKIT.h"
#import "TUIKit.h"
#import <Masonry/Masonry.h>


@implementation TCommonAvatarCellData
- (instancetype)init {
    self = [super init];
    if(self){
         _avatarImage = DefaultAvatarImage;
    }
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return TPersonalCommonCell_Image_Size.height + 2 * TPersonalCommonCell_Margin;
}

@end

@interface TCommonAvatarCell()
@property TCommonAvatarCellData *avatarData;
@end

@implementation TCommonAvatarCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])
    {
        [self setupViews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.changeColorWhenTouched = YES;
    }
    return self;
}

- (void)fillWithData:(TCommonAvatarCellData *) avatarData
{
    [super fillWithData:avatarData];

    self.avatarData = avatarData;

    RAC(_keyLabel, text) = [RACObserve(avatarData, key) takeUntil:self.rac_prepareForReuseSignal];
    RAC(_valueLabel, text) = [RACObserve(avatarData, value) takeUntil:self.rac_prepareForReuseSignal];
     @weakify(self)
    [[RACObserve(avatarData, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
        @strongify(self)
        [self.avatar sd_setImageWithURL:x placeholderImage:self.avatarData.avatarImage];
    }];

    if (avatarData.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)setupViews
{
    CGSize headSize = CGSizeMake(56, 56);
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(TPersonalCommonCell_Margin, TPersonalCommonCell_Margin, headSize.width, headSize.height)];
    _avatar.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_avatar];

    _keyLabel = self.textLabel;
    _valueLabel = self.detailTextLabel;

    [self.contentView addSubview:_keyLabel];
    [self.contentView addSubview:_valueLabel];
    
    [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-10);
        make.centerY.equalTo(@0);
        make.size.equalTo(@56);
    }];
    
    if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = headSize.height / 2;
    } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
        self.avatar.layer.masksToBounds = YES;
        self.avatar.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

@end
