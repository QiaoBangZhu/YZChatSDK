//
//  YUIButtonTableViewCell.m
//  YChat
//
//  Created by magic on 2020/9/20.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YUIButtonTableViewCell.h"
#import "THeader.h"
#import "MMLayout/UIView+MMLayout.h"
#import "UIColor+TUIDarkMode.h"
#import "UIColor+ColorExtension.h"

@implementation YUIButtonCellData

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return TButtonCell_Height;
}
@end

@implementation YUIButtonTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
        self.changeColorWhenTouched = YES;
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = [UIColor clearColor];
    //阴影view
    self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(9, 14, Screen_Width-50, 40)];
    self.shadowView.layer.shadowOffset = CGSizeMake(5,5);
    self.shadowView.layer.shadowOpacity = 1;
    self.shadowView.layer.shadowRadius = 9;
    self.shadowView.layer.cornerRadius = 6;
    [self.contentView addSubview:self.shadowView];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    _button.layer.cornerRadius = 6;
    _button.layer.shadowColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5].CGColor;
    _button.layer.shadowOffset = CGSizeMake(-5,-5);
    _button.layer.shadowOpacity = 1;
    _button.layer.shadowRadius = 9;
    [self.contentView addSubview:_button];

    [self setSeparatorInset:UIEdgeInsetsMake(0, Screen_Width, 0, 0)];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.changeColorWhenTouched = NO;
}


- (void)fillWithData:(YUIButtonCellData *)data
{
    [super fillWithData:data];
    self.buttonData = data;
    [_button setTitle:data.title forState:UIControlStateNormal];
    switch (data.style) {
        case YButtonGreen: {
            [_button.titleLabel setTextColor:[UIColor d_colorWithColorLight:[UIColor whiteColor] dark:RGB(180, 180, 180)]];
            [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _button.backgroundColor = [UIColor d_colorWithColorLight:RGB(28, 185, 31) dark:RGB(35, 35, 35)];
            //对于背景色为绿色的按钮，高亮颜色比原本略深（原本的5/6）。由于无法直接设置高亮时的背景色，所以高亮背景色的变化通过生成并设置纯色图片来实现。
            [_button setBackgroundImage:[self imageWithColor:[UIColor d_colorWithColorLight:RGB(23, 154, 26) dark:RGB(47, 47, 47)]] forState:UIControlStateHighlighted];
        }
            break;
        case YButtonWhite: {
            [_button.titleLabel setTextColor:[UIColor blackColor]];
            [_button setTitleColor:[UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark] forState:UIControlStateNormal];
            _button.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
            //对于原本白色背景色的按钮，高亮颜色保持和白色 cell 统一。由于无法直接设置高亮时的背景色，所以高亮背景色的变化通过生成并设置纯色图片来实现。
            [_button setBackgroundImage:[self imageWithColor:self.colorWhenTouched] forState:UIControlStateHighlighted];
        }
            break;
        case YButtonRedText: {
            [_button.titleLabel setTextColor:[UIColor whiteColor]];
            [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _button.backgroundColor = [UIColor colorWithHex:0xD42231];
            
            _shadowView.layer.backgroundColor = [UIColor colorWithRed:212/255.0 green:34/255.0 blue:49/255.0 alpha:1.0].CGColor;
            _shadowView.layer.shadowColor = [UIColor colorWithRed:127/255.0 green:9/255.0 blue:19/255.0 alpha:0.2].CGColor;

            break;
        }
        case YButtonBlue:{
            [_button.titleLabel setTextColor:[UIColor whiteColor]];
            [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            _button.backgroundColor = [UIColor colorWithHex:0x2F7AFF];
            
            _shadowView.layer.backgroundColor = [UIColor colorWithRed:47/255.0 green:122/255.0 blue:255/255.0 alpha:1.0].CGColor;
            _shadowView.layer.shadowColor = [UIColor colorWithRed:7/255.0 green:59/255.0 blue:179/255.0 alpha:0.19].CGColor;
        }
            break;
        default:
            break;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _button.mm_width(Screen_Width-50)
    .mm_height(40)
    .mm_left(9).mm_top(14);
}

- (void)onClick:(UIButton *)sender
{
    if (self.buttonData.cbuttonSelector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.buttonData.cbuttonSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.buttonData.cbuttonSelector withObject:self];
#pragma clang diagnostic pop
        }
    }
}

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    if (subview != self.contentView) {
        [subview removeFromSuperview];
    }
}

//本函数实现了生成纯色背景的功能，从而配合 setBackgroundImage: forState: 来实现高亮时纯色按钮的点击反馈。
- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}



@end
