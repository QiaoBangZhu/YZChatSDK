//
//  TResponderTextView.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TResponderTextView.h"

@implementation TResponderTextView

- (UIResponder *)nextResponder
{
    if(_overrideNextResponder == nil){
        return [super nextResponder];
    }
    else{
        return _overrideNextResponder;
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (_overrideNextResponder != nil)
        return NO;
    else
        return [super canPerformAction:action withSender:sender];
}

- (instancetype)init{
    if (self = [super init]){
        self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 7, 100, 18)];
        self.placeholderLabel.textColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1];
        [self addSubview:self.placeholderLabel];
    }
    return self;
}

- (void)layoutSubviews{
    self.placeholderLabel.text = self.placeholder;
}

@end
