//
//  FieldInputView.h
//  YChat
//
//  Created by magic on 2020/9/20.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit.h>
#import <Masonry.h>
#import "YZLine.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
  InputTypeNormal,
  InputTypePhone,
  InputTypeCode,
}InputType;

@interface YZFieldInputView : UIView

@property (nonatomic, strong)QMUITextField *textField;
@property (nonatomic, assign)InputType type;
@property (nonatomic, strong)UIImage* image;
@property (nonatomic, strong)UIImage* highlightedImage;
@property (nonatomic, strong)UIImageView* iconView;
@property (nonatomic, strong)QMUIGhostButton* codeButton;
@property (nonatomic, strong)YZLine* line;

- (instancetype)initWith:(InputType)type image:(UIImage*)image highlightImage:(UIImage*)hightImage;


@end

NS_ASSUME_NONNULL_END
