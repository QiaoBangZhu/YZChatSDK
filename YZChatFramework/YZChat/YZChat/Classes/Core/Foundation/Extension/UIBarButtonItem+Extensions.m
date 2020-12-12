//
//  UIBarButtonItem+Extensions.m
//  YChat
//
//  Created by magic on 2020/10/7.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "UIBarButtonItem+Extensions.h"

@implementation UIBarButtonItem (Extensions)

- (id)initWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
    if((self = [self init]))
    {
        UIButton *cutstomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cutstomBtn setImage:image forState:UIControlStateNormal];
        cutstomBtn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [cutstomBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        self.customView = cutstomBtn;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image clickImage:(UIImage *)clickImage target:(id)target action:(SEL)action{
    if((self = [self init]))
    {
        UIButton *cutstomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cutstomBtn setImage:image forState:UIControlStateNormal];
        [cutstomBtn setImage:clickImage forState:UIControlStateHighlighted];
        cutstomBtn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [cutstomBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        self.customView = cutstomBtn;
    }
    return self;
}

@end
