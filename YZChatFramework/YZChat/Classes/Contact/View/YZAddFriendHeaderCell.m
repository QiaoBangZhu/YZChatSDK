//
//  YZAddFriendHeaderCell.m
//  YChat
//
//  Created by magic on 2020/10/9.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZAddFriendHeaderCell.h"
#import "THeader.h"
#import <Masonry.h>
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImage+TUIKIT.h"
#import "UIColor+ColorExtension.h"

@interface YZAddFriendHeaderCell()<CIGAMTextViewDelegate>


@end

@implementation YZAddFriendHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    CGSize headSize = CGSizeMake(56, 56);
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, headSize.width, headSize.height)];
    _avatar.contentMode = UIViewContentModeScaleAspectFill;
    _avatar.layer.masksToBounds = YES;
    _avatar.userInteractionEnabled = YES;
    self.avatar.layer.cornerRadius = headSize.height/2;
    [self.contentView addSubview:_avatar];
    
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOnAvatar)];
    [self.avatar addGestureRecognizer:tapGes];
    
    
    _name = [[UILabel alloc] init];
    [_name setFont:[UIFont systemFontOfSize:18 weight:UIFontWeightMedium]];
    [_name setTextColor:[UIColor blackColor]];
    [self.contentView addSubview:_name];
    
    _mobile = [[UILabel alloc] init];
    [_mobile setFont:[UIFont systemFontOfSize:14]];
    _mobile.textColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    [self.contentView addSubview:_mobile];
    
    
//    _textView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    
    [self.contentView addSubview:self.textView];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)fillWithData:(ProfileCardCellData *)data
{
    [super fillWithData:data];
    self.cardData = data;
    //set data
    @weakify(self)
    
    RAC(_mobile, text) = [RACObserve(data, signature) takeUntil:self.rac_prepareForReuseSignal];
    [[[RACObserve(data, signature) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
//        if ([data.signature length] >7) {
//            self.mobile.text = [data.signature stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
//        }else {
            self.mobile.text = data.signature;
//        }
    }];
    
    [[[RACObserve(data, name) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.name.text = x;
    }];
    
    [[RACObserve(data, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
        @strongify(self)
        [self.avatar sd_setImageWithURL:x placeholderImage:self.cardData.avatarImage];
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatar.mas_right).offset(12);
        make.top.equalTo(_avatar.mas_top).offset(8);
        make.right.equalTo(@-10);
    }];
    
    [_mobile mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.name.mas_left);
        make.top.equalTo(self.name.mas_bottom).offset(2);
        make.right.equalTo(@-10);
    }];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.right.equalTo(@-16);
        make.bottom.equalTo(@-20);
        make.top.equalTo(_avatar.mas_bottom).offset(30);
    }];
    
}

- (CIGAMTextView *)textView {
    if (!_textView) {
        _textView = [[CIGAMTextView alloc] init];
        _textView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        _textView.scrollsToTop = NO;
        _textView.placeholder = @"发送给对方的验证消息";
        _textView.placeholderColor = [UIColor colorWithHex:kCommonGrayTextColor];
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.layer.masksToBounds = YES;
        _textView.layer.cornerRadius = 8;
        _textView.delegate = self;
        if (@available(iOS 11, *)) {
            _textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _textView;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addFriendWords:)]) {
        if ([textView.text length] > 30) {
            textView.text = [textView.text substringToIndex:30];
        }
        [self.delegate addFriendWords:textView.text];
    }
}


- (void)didTapOnAvatar{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapOnAvatar:)]) {
        [self.delegate didTapOnAvatar: self.data];
    }
}

@end
