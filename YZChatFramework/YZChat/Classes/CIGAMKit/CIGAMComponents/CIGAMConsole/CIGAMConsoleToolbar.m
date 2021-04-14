/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMConsoleToolbar.m
//  CIGAMKit
//
//  Created by MoLice on 2019/J/11.
//

#import "CIGAMConsoleToolbar.h"
#import "CIGAMConsole.h"
#import "CIGAMCore.h"
#import "CIGAMButton.h"
#import "CIGAMTextField.h"
#import "UITextField+CIGAM.h"
#import "UIImage+CIGAM.h"
#import "UIView+CIGAM.h"
#import "UIColor+CIGAM.h"
#import "UIImage+CIGAM.h"
#import "UIControl+CIGAM.h"

@interface CIGAMConsoleToolbar ()

@property(nonatomic, strong) UIView *searchRightView;
@end

@implementation CIGAMConsoleToolbar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _levelButton = [[CIGAMButton alloc] init];
        UIImage *filterImage = [[CIGAMHelper imageWithName:@"CIGAM_console_filter"] cigam_imageResizedInLimitedSize:CGSizeMake(14, 14)];
        UIImage *filterSelectedImage = [[CIGAMHelper imageWithName:@"CIGAM_console_filter_selected"] cigam_imageResizedInLimitedSize:CGSizeMake(14, 14)];
        
        [self.levelButton setImage:filterImage forState:UIControlStateNormal];
        [self.levelButton setImage:filterSelectedImage forState:UIControlStateSelected];
        [self.levelButton setImage:filterSelectedImage forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.levelButton setImage:filterSelectedImage forState:UIControlStateSelected|UIControlStateDisabled];
        [self.levelButton setTitle:@"Level" forState:UIControlStateNormal];
        self.levelButton.titleLabel.font = UIFontMake(7);
        self.levelButton.imagePosition = CIGAMButtonImagePositionTop;
        self.levelButton.tintColorAdjustsTitleAndImage = UIColorWhite;
        [self addSubview:self.levelButton];
        
        _nameButton = [[CIGAMButton alloc] init];
        [self.nameButton setImage:filterImage forState:UIControlStateNormal];
        [self.nameButton setImage:filterSelectedImage forState:UIControlStateSelected];
        [self.nameButton setImage:filterSelectedImage forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.nameButton setImage:filterSelectedImage forState:UIControlStateSelected|UIControlStateDisabled];
        [self.nameButton setTitle:@"Name" forState:UIControlStateNormal];
        self.nameButton.titleLabel.font = UIFontMake(7);
        self.nameButton.imagePosition = CIGAMButtonImagePositionTop;
        self.nameButton.tintColorAdjustsTitleAndImage = UIColorWhite;
        [self addSubview:self.nameButton];
        
        _searchTextField = [[CIGAMTextField alloc] init];
        self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.searchTextField.tintColor = [CIGAMConsole appearance].textAttributes[NSForegroundColorAttributeName];
        self.searchTextField.textColor = self.searchTextField.tintColor;
        self.searchTextField.placeholderColor = [self.searchTextField.textColor colorWithAlphaComponent:.6];
        self.searchTextField.font = [CIGAMConsole appearance].textAttributes[NSFontAttributeName];
        self.searchTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.searchTextField.returnKeyType = UIReturnKeySearch;
        self.searchTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchTextField.layer.borderWidth = PixelOne;
        self.searchTextField.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:.3].CGColor;
        self.searchTextField.layer.cornerRadius = 3;
        self.searchTextField.placeholder = @"Search...";
        [self addSubview:self.searchTextField];
        
        _clearButton = [[CIGAMButton alloc] init];
        [self.clearButton setImage:[CIGAMHelper imageWithName:@"CIGAM_console_clear"] forState:UIControlStateNormal];
        [self addSubview:self.clearButton];
        
        self.searchRightView = [[UIView alloc] init];
        
        _searchResultCountLabel = [[UILabel alloc] init];
        self.searchResultCountLabel.textColor = self.searchTextField.placeholderColor;
        self.searchResultCountLabel.font = UIFontMake(11);
        [self.searchRightView addSubview:self.searchResultCountLabel];
        
        _searchResultPreviousButton = [[CIGAMButton alloc] init];
        self.searchResultPreviousButton.cigam_preventsRepeatedTouchUpInsideEvent = NO;
        [self.searchResultPreviousButton setTitle:@"<" forState:UIControlStateNormal];
        self.searchResultPreviousButton.titleLabel.font = UIFontMake(12);
        [self.searchResultPreviousButton setTitleColor:self.searchTextField.textColor forState:UIControlStateNormal];
        [self.searchResultPreviousButton sizeToFit];
        [self.searchRightView addSubview:self.searchResultPreviousButton];
        
        _searchResultNextButton = [[CIGAMButton alloc] init];
        self.searchResultNextButton.cigam_preventsRepeatedTouchUpInsideEvent = NO;
        [self.searchResultNextButton setTitle:@">" forState:UIControlStateNormal];
        self.searchResultNextButton.titleLabel.font = UIFontMake(12);
        [self.searchResultNextButton setTitleColor:self.searchTextField.textColor forState:UIControlStateNormal];
        [self.searchResultNextButton sizeToFit];
        [self.searchRightView addSubview:self.searchResultNextButton];
        
        self.searchTextField.rightView = self.searchRightView;
        self.searchTextField.rightViewMode = UITextFieldViewModeNever;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIEdgeInsets paddings = UIEdgeInsetsMake(8, 8, 8, 8);
    
    CGFloat x = paddings.left + self.cigam_safeAreaInsets.left;
    CGFloat contentHeight = CGRectGetHeight(self.bounds) - self.cigam_safeAreaInsets.bottom - UIEdgeInsetsGetVerticalValue(paddings);
    
    self.levelButton.frame = CGRectMake(x, paddings.top, contentHeight, contentHeight);
    x = CGRectGetMaxX(self.levelButton.frame);
    
    self.nameButton.frame = CGRectSetX(self.levelButton.frame, CGRectGetMaxX(self.levelButton.frame));
    x = CGRectGetMaxX(self.nameButton.frame);
    
    self.clearButton.frame = CGRectSetX(self.levelButton.frame, CGRectGetWidth(self.bounds) - self.cigam_safeAreaInsets.right - paddings.right - contentHeight);
    
    CGFloat searchTextFieldMarginHorizontal = 8;
    CGFloat searchTextFieldMinX = x + searchTextFieldMarginHorizontal;
    self.searchTextField.frame = CGRectMake(searchTextFieldMinX, paddings.top, CGRectGetMinX(self.clearButton.frame) - searchTextFieldMarginHorizontal - searchTextFieldMinX, contentHeight);
}

- (void)setNeedsLayoutSearchResultViews {
    CGFloat paddingHorizontal = 4;
    CGFloat buttonSpacing = 2;
    CGFloat countLabelMarginRight = 4;
    [self.searchResultCountLabel sizeToFit];
    
    self.searchRightView.cigam_width = paddingHorizontal * 2 + self.searchResultCountLabel.cigam_width + countLabelMarginRight + self.searchResultPreviousButton.cigam_width + buttonSpacing + self.searchResultNextButton.cigam_width;
    self.searchRightView.cigam_height = self.searchTextField.cigam_height;
    
    self.searchResultNextButton.cigam_right = self.searchRightView.cigam_width - paddingHorizontal;
    self.searchResultNextButton.cigam_top = self.searchResultNextButton.cigam_topWhenCenterInSuperview;
    self.searchResultNextButton.cigam_outsideEdge = UIEdgeInsetsMake(-self.searchResultNextButton.cigam_top, -buttonSpacing / 2, -self.searchResultNextButton.cigam_top, -paddingHorizontal);
    
    self.searchResultPreviousButton.cigam_right = self.searchResultNextButton.cigam_left - buttonSpacing;
    self.searchResultPreviousButton.cigam_top = self.searchResultPreviousButton.cigam_topWhenCenterInSuperview;
    self.searchResultNextButton.cigam_outsideEdge = UIEdgeInsetsMake(-self.searchResultPreviousButton.cigam_top, -buttonSpacing / 2, -self.searchResultPreviousButton.cigam_top, -paddingHorizontal);
    
    
    self.searchResultCountLabel.cigam_right = self.searchResultPreviousButton.cigam_left - countLabelMarginRight;
    self.searchResultCountLabel.cigam_top = self.searchResultCountLabel.cigam_topWhenCenterInSuperview;
    
    [self.searchTextField setNeedsLayout];
}

@end
