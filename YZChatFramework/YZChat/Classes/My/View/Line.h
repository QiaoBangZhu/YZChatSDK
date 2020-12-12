//
//  Line.h
//  YChat
//
//  Created by magic on 2020/9/22.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Line : UIView

@property (nonatomic, assign)BOOL     isHighlighted;
@property (nonatomic, strong)UIColor* normalColor;
@property (nonatomic, strong)UIColor* highlightedColor;
@property (nonatomic, assign)BOOL     autoUpdateHeight;

- (void)setIsHighlighted:(BOOL)isHighlighted;

- (instancetype)initWithAutoUpdateHeight:(BOOL)autoUpdateHeight                                              normalColor:(UIColor *)normalColor
                        highlightedColor:(UIColor *)highlightedColor;

@end

NS_ASSUME_NONNULL_END
