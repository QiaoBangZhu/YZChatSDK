//
//  Line.m
//  YChat
//
//  Created by magic on 2020/9/22.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "Line.h"
#import <Masonry.h>

@implementation Line

- (instancetype)initWithAutoUpdateHeight:(BOOL)autoUpdateHeight normalColor:(UIColor *)normalColor highlightedColor:(UIColor *)highlightedColor {
    
    self.autoUpdateHeight = autoUpdateHeight;
    self.normalColor = normalColor;
    self.highlightedColor = highlightedColor;
    
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    if (_autoUpdateHeight) {
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@1);
        }];
    }
    _isHighlighted = false;
}

- (void)update {
    self.backgroundColor = _isHighlighted ? _highlightedColor : _normalColor;
    if (_autoUpdateHeight) {
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(_isHighlighted ? @2: @1);
        }];
    }
}

- (void)setIsHighlighted:(BOOL)isHighlighted {
    _isHighlighted = isHighlighted;
    [self update];
}

@end
