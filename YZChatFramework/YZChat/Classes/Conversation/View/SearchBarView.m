//
//  SearchBarView.m
//  YChat
//
//  Created by magic on 2020/10/25.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "SearchBarView.h"
#import "UIColor+ColorExtension.h"
#import <Masonry/Masonry.h>
#import "UIImage+Foundation.h"

@interface SearchBarView ()<UISearchBarDelegate>

@property (nonatomic, strong)UIButton       * cancleBtn;
@property (nonatomic, strong)UISearchBar    * searchBar;

@end

@implementation SearchBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return  self;
}

- (void)setup {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.searchBar];
    self.searchBar.delegate = self;
    [self addSubview:self.cancleBtn];
    [self.cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-16);
        make.centerY.equalTo(@0);
        make.width.equalTo(@40);
    }];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.right.equalTo(@-10);
        make.top.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar =  [[UISearchBar alloc]init];
        _searchBar.placeholder = @"搜索";
        [_searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]];
        [_searchBar setTintColor:[UIColor colorWithHex:kCommonBlueTextColor]];
        [_searchBar setTranslucent:NO];
        UITextField *tf = [[[self.searchBar.subviews firstObject] subviews] lastObject];
        [tf.layer setMasksToBounds:YES];
        tf.layer.cornerRadius = 8;
        if (@available(iOS 13.0, *)) {
            self.searchBar.searchTextField.inputAccessoryView = [UIView new];
            self.searchBar.searchTextField.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
            self.searchBar.searchTextField.font = [UIFont systemFontOfSize:16];
        } else {
            tf.inputAccessoryView = [UIView new];
            _searchBar.subviews.firstObject.subviews[1].backgroundColor
            = [UIColor colorWithHex:KCommonBackgroundColor];
        }
        for (UIView *view in self.searchBar.subviews) {
            if ([view isKindOfClass:NSClassFromString(@"_UISearchBarSearchFieldBackgroundView")]) {
                view.layer.cornerRadius = 8;
                view.layer.masksToBounds = YES;
                break;
            }
        }
        
    }
    return _searchBar;
}

- (void)setIsShowCancle:(BOOL)isShowCancle {
    _isShowCancle = isShowCancle;
    if (isShowCancle) {
        self.cancleBtn.hidden = NO;
        self.searchBar.userInteractionEnabled = YES;
        [self.searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.right.equalTo(@-60);
            make.top.equalTo(@0);
            make.bottom.equalTo(@0);
        }];
    }else {
        self.cancleBtn.hidden = YES;
        self.searchBar.userInteractionEnabled = NO;
        [self.searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.right.equalTo(@-12);
            make.top.equalTo(@0);
            make.bottom.equalTo(@0);
        }];
    }
}

- (void)setIsCanEdit:(BOOL)isCanEdit {
    _isCanEdit = isCanEdit;
    _searchBar.userInteractionEnabled = isCanEdit;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    _searchBar.placeholder = _placeholder;
}

- (void)setResginTextView:(BOOL)resginTextView {
    _resginTextView = resginTextView;
    if (resginTextView) {
        [self.searchBar resignFirstResponder];
    }
}

- (UIButton *)cancleBtn {
    if (!_cancleBtn) {
        _cancleBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:[UIColor colorWithHex:kCommonBlueTextColor] forState:UIControlStateNormal];
        [_cancleBtn addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancleBtn;
}

- (void)cancleAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCancle)]) {
        self.searchBar.text = nil;
        [self.searchBar resignFirstResponder];
        [self.delegate onCancle];
    }
}

- (BOOL)resignFirstResponder{
    return self.searchBar.resignFirstResponder;
}

- (BOOL)becomeFirstResponder {
    return self.searchBar.becomeFirstResponder;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    NSLog(@"搜索结束");
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textDidChange:)]) {
        [self.delegate textDidChange:searchText];
    }
}


@end
