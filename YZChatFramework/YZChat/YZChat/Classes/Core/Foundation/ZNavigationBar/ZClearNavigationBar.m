//
//  ZClearNavigationBar.m
//  YChat
//
//  Created by magic on 2020/9/15.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "ZClearNavigationBar.h"
#import "UIColor+ColorExtension.h"

@implementation ZClearNavigationBar


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.clipsToBounds = NO;
        self.imageView.hidden = YES;
        self.titleColor = [UIColor blackColor];
        self.backgroundColor = [UIColor clearColor];
        self.barButtonTitleColor = [UIColor blackColor];
        self.barButtonDisabledTitleColor = [UIColor colorWithHex:0xB9BBBE];
        self.barButtonHighlightedTitleColor = [UIColor colorWithHex:0xB9BBBE];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
