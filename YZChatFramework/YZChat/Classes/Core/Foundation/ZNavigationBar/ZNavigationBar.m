//
//  ZNavigationBar.m
//  YChat
//
//  Created by magic on 2020/9/15.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "ZNavigationBar.h"
#import "CommonConstant.h"
#import "UIColor+Foundation.h"
#import "UIButton+Foundation.h"
#import <Masonry/Masonry.h>

#define TAG_TITLELABEL_NAVIGATIONBAR   50000

@interface ZNavigationBar()

@property (nonatomic, weak) UILabel *subTitleLabel;
@property (nonatomic, strong) UIView *textTitleView;
@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation ZNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.clipsToBounds = NO;
        self.titleColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        self.barButtonTitleColor = [UIColor whiteColor];
        self.barButtonDisabledTitleColor = [UIColor colorWithHex:0xB9BBBE];
        self.barButtonHighlightedTitleColor = [UIColor colorWithHex:0xB9BBBE];
        self.containerView = [[UIView alloc] init];
        UIImage *image = [UIImage imageNamed:@"title_bg"];

        self.imageView = [[UIImageView alloc] initWithImage:[image stretchableImageWithLeftCapWidth:floorf(image.size.width / 2) topCapHeight:floorf(image.size.height / 2)]];
        [self addSubview:self.imageView];
        [self addSubview:self.containerView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.leading.trailing.equalTo(self);
            make.top.equalTo(self).offset(ZStatusBarHeight);
        }];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setTitleView:(UIView *)view {
    [_textTitleView removeFromSuperview];
    _textTitleView = nil;
    _titleView = view;
    view.bounds = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    view.center = CGPointMake(self.containerView.bounds.size.width * 0.5, self.containerView.bounds.size.height * 0.5);
    [self.containerView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.containerView);
        make.size.mas_equalTo(CGSizeMake(view.bounds.size.width, view.bounds.size.height));
    }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self addTextTitleView];
    UILabel *titleLabel = (UILabel*)[_titleView viewWithTag:TAG_TITLELABEL_NAVIGATIONBAR];
    titleLabel.text = title;
}

- (void)addTextTitleView
{
    if (_textTitleView)
    {
        return;
    }
    [_titleView removeFromSuperview];
    _titleView = nil;
    _textTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, self.containerView.bounds.size.height)];
    _titleView = _textTitleView;
    CGPoint point = _textTitleView.center;
    point.x = self.center.x;
    _textTitleView.center = point;
    [self.containerView addSubview:_textTitleView];
    [_textTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.bottom.height.equalTo(self.containerView);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8.5f, _textTitleView.frame.size.width, 22.5f)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [self titleColor];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.minimumScaleFactor = 14 / 18.f;
    titleLabel.tag = TAG_TITLELABEL_NAVIGATIONBAR;
    [_textTitleView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.textTitleView);
        make.centerY.equalTo(_textTitleView);
        make.width.lessThanOrEqualTo(@(KScreenWidth - 88.f));
    }];
    
    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22.5f, _textTitleView.frame.size.width, 14.f)];
    subTitleLabel.backgroundColor = [UIColor clearColor];
    subTitleLabel.textColor = [self titleColor];
    subTitleLabel.font = [UIFont systemFontOfSize:10.f];
    subTitleLabel.textAlignment = NSTextAlignmentCenter;
    subTitleLabel.minimumScaleFactor = 14 / 18.f;
    self.subTitleLabel = subTitleLabel;
    [_textTitleView addSubview:subTitleLabel];
    [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.textTitleView);
        make.top.equalTo(self.textTitleView).offset(22.5f);
    }];
}

-(void)setSubTitle:(NSString *)subTitle
{
    _subTitle = subTitle;
    [self addTextTitleView];
    _subTitleLabel.text = subTitle;
    UILabel *titleLabel = (UILabel*)[_titleView viewWithTag:TAG_TITLELABEL_NAVIGATIONBAR];
    
    if (subTitle.length)
    {
        [titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textTitleView).offset(0.f);
        }];
    }
    else
    {
        [titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textTitleView).offset(7.5f);
        }];
    }
}

- (UILabel *)titleLabel {
    return (UILabel*)[_titleView viewWithTag:TAG_TITLELABEL_NAVIGATIONBAR];
}

- (void)setTitleColor:(UIColor*)color
{
    _titleColor = color;
    UILabel *titleLabel = (UILabel*)[_titleView viewWithTag:TAG_TITLELABEL_NAVIGATIONBAR];
    titleLabel.textColor = color;
}

- (void)setBarButtonTitleColor:(UIColor *)barButtonTitleColor
{
    _barButtonTitleColor = barButtonTitleColor;
    [_leftBarButton setTitleColor:barButtonTitleColor forState:UIControlStateNormal];
    [_secondLeftBarButton setTitleColor:barButtonTitleColor forState:UIControlStateNormal];
    [_rightBarButton setTitleColor:barButtonTitleColor forState:UIControlStateNormal];
    [_secondRightBarButton setTitleColor:barButtonTitleColor forState:UIControlStateNormal];
}

- (void)setBarButtonDisabledTitleColor:(UIColor *)barButtonDisabledTitleColor
{
    _barButtonDisabledTitleColor = barButtonDisabledTitleColor;
    [_leftBarButton setTitleColor:barButtonDisabledTitleColor forState:UIControlStateDisabled];
    [_secondLeftBarButton setTitleColor:barButtonDisabledTitleColor forState:UIControlStateDisabled];
    [_rightBarButton setTitleColor:barButtonDisabledTitleColor forState:UIControlStateDisabled];
    [_secondRightBarButton setTitleColor:barButtonDisabledTitleColor forState:UIControlStateDisabled];
}

- (void)setBarButtonHighlightedTitleColor:(UIColor *)barButtonHighlightedTitleColor
{
    _barButtonHighlightedTitleColor = barButtonHighlightedTitleColor;
    [_leftBarButton setTitleColor:barButtonHighlightedTitleColor forState:UIControlStateHighlighted];
    [_secondLeftBarButton setTitleColor:barButtonHighlightedTitleColor forState:UIControlStateHighlighted];
    [_rightBarButton setTitleColor:barButtonHighlightedTitleColor forState:UIControlStateHighlighted];
    [_secondRightBarButton setTitleColor:barButtonHighlightedTitleColor forState:UIControlStateHighlighted];
}

- (void)setLeftBarButton:(UIButton *)leftBarButton
{
    [_leftBarButton removeFromSuperview];
    _leftBarButton = nil;
    if (leftBarButton) {
        _leftBarButton = leftBarButton;
        _leftBarButton.center = CGPointMake(_leftBarButton.bounds.size.width/2, self.containerView.bounds.size.height/2);
        _leftBarButton.titleLabel.font = [UIFont systemFontOfSize:ZBarButtonLabelFontSize];
        [_leftBarButton setTitleColor:self.barButtonTitleColor forState:UIControlStateNormal];
        [_leftBarButton setTitleColor:self.barButtonDisabledTitleColor forState:UIControlStateDisabled];
        [_leftBarButton setTitleColor:self.barButtonHighlightedTitleColor forState:UIControlStateHighlighted];
        [self.containerView addSubview:_leftBarButton];
        [_leftBarButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.containerView);
            make.leading.equalTo(self.containerView).offset(_leftBarButton.titleLabel.text.length ? 10.f : 8.f);
            make.size.mas_equalTo(_leftBarButton.bounds.size);
        }];
//        [self updateBarButtonHitTest];
    }
}

-(void)setSecondLeftBarButton:(UIButton *)secondLeftBarButton
{
    NSAssert(self.leftBarButton, @"You must set leftBarButton first.");
    [_secondLeftBarButton removeFromSuperview];
    _secondLeftBarButton = nil;
    if (secondLeftBarButton) {
        _secondLeftBarButton = secondLeftBarButton;
        _secondLeftBarButton.center = CGPointMake(_leftBarButton.bounds.size.width/2, self.containerView.bounds.size.height/2);
        _secondLeftBarButton.titleLabel.font = [UIFont systemFontOfSize:ZBarButtonLabelFontSize];
        [_secondLeftBarButton setTitleColor:self.barButtonTitleColor forState:UIControlStateNormal];
        [_secondLeftBarButton setTitleColor:self.barButtonDisabledTitleColor forState:UIControlStateDisabled];
        [_secondLeftBarButton setTitleColor:self.barButtonHighlightedTitleColor forState:UIControlStateHighlighted];
        [self.containerView addSubview:_secondLeftBarButton];
        [_secondLeftBarButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.containerView);
            make.leading.equalTo(self.leftBarButton.mas_trailing).offset(15.f);
            make.size.mas_equalTo(_secondLeftBarButton.bounds.size);
        }];
        [self updateBarButtonHitTest];
    }
}

- (void)setRightBarButton:(UIButton *)rightBarButton
{
    [_rightBarButton removeFromSuperview];
    _rightBarButton = nil;
    if (rightBarButton) {
        _rightBarButton = rightBarButton;
        _rightBarButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _rightBarButton.center = CGPointMake(self.containerView.bounds.size.width - (_rightBarButton.bounds.size.width/2), self.containerView.bounds.size.height/2);
        [_rightBarButton setTitleColor:self.barButtonTitleColor forState:UIControlStateNormal];
        [self.containerView addSubview:_rightBarButton];
        [self.containerView bringSubviewToFront:_rightBarButton];
        [_rightBarButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.containerView);
            make.trailing.equalTo(self.containerView).offset(_rightBarButton.titleLabel.text.length ? -10.f : -15.f);
            make.size.mas_equalTo(_rightBarButton.bounds.size);
        }];
//        [self updateBarButtonHitTest];
    }
}

- (void)setSecondRightBarButton:(UIButton *)secondRightBarButton
{
    [_secondRightBarButton removeFromSuperview];
    _secondRightBarButton = nil;
    if (secondRightBarButton)
    {
        _secondRightBarButton = secondRightBarButton;
        _secondRightBarButton.titleLabel.font = [UIFont systemFontOfSize:ZBarButtonLabelFontSize];
        [_secondRightBarButton setTitleColor:self.barButtonTitleColor forState:UIControlStateNormal];
        [_secondRightBarButton setTitleColor:self.barButtonDisabledTitleColor forState:UIControlStateDisabled];
        [_secondRightBarButton setTitleColor:self.barButtonHighlightedTitleColor forState:UIControlStateHighlighted];
        [self.containerView addSubview:_secondRightBarButton];
        [self.containerView bringSubviewToFront:_secondRightBarButton];
        [_secondRightBarButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.containerView);
            make.trailing.equalTo(self.rightBarButton.mas_leading).offset(-15.f);
            make.size.mas_equalTo(secondRightBarButton.bounds.size);
        }];
        [self updateBarButtonHitTest];
    }
}

- (void)updateBarButtonHitTest
{
    if (self.secondLeftBarButton)
    {
        self.secondLeftBarButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20.f, -10.f, -20.f, -10.f);
        self.leftBarButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20.f, -20.f, -20.f, -10.f);
    }
    else
    {
        self.leftBarButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20.f, -20.f, -20.f, -20.f);
    }
    
    if (self.secondRightBarButton)
    {
        self.secondRightBarButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20.f, -10.f, -20.f, -10.f);
        self.rightBarButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20.f, -10.f, -20.f, -20);
    }
    else
    {
        self.rightBarButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20.f, -20.f, -20.f, -20.f);
    }
}

@end
