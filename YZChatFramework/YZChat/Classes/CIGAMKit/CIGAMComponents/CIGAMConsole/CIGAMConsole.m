/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMConsole.m
//  CIGAMKit
//
//  Created by MoLice on 2019/J/11.
//

#import "CIGAMConsole.h"
#import "CIGAMCore.h"
#import "NSParagraphStyle+CIGAM.h"
#import "UIView+CIGAM.h"
#import "UIWindow+CIGAM.h"
#import "UIColor+CIGAM.h"
#import "CIGAMTextView.h"

@interface CIGAMConsole ()

@property(nonatomic, strong) UIWindow *consoleWindow;
@property(nonatomic, strong) CIGAMConsoleViewController *consoleViewController;
@end

@implementation CIGAMConsole

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static CIGAMConsole *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
        instance.canShow = IS_DEBUG;
        instance.showConsoleAutomatically = YES;
        instance.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
        instance.textAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:12],
                                    NSForegroundColorAttributeName: [UIColor whiteColor],
                                    NSParagraphStyleAttributeName: ({
                                        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle cigam_paragraphStyleWithLineHeight:16];
                                        paragraphStyle.paragraphSpacing = 8;
                                        paragraphStyle;
                                    }),
                                    };
        instance.timeAttributes = ({
            NSMutableDictionary<NSAttributedStringKey, id> *attributes = instance.textAttributes.mutableCopy;
            attributes[NSForegroundColorAttributeName] = [attributes[NSForegroundColorAttributeName] cigam_colorWithAlpha:.6 backgroundColor:instance.backgroundColor];
            attributes.copy;
        });
        instance.searchResultHighlightedBackgroundColor = [UIColorBlue colorWithAlphaComponent:.8];
    });
    return instance;
}

+ (instancetype)appearance {
    return [self sharedInstance];
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

+ (void)logWithLevel:(NSString *)level name:(NSString *)name logString:(id)logString {
    CIGAMConsole *console = [CIGAMConsole sharedInstance];
    [console initConsoleWindowIfNeeded];
    [console.consoleViewController logWithLevel:level name:name logString:logString];
    if (console.showConsoleAutomatically) {
        [CIGAMConsole show];
    }
}

+ (void)log:(id)logString {
    [self logWithLevel:nil name:nil logString:logString];
}

+ (void)clear {
    [[CIGAMConsole sharedInstance].consoleViewController clear];
}

+ (void)show {
    CIGAMConsole *console = [CIGAMConsole sharedInstance];
    if (console.canShow) {
        
        if (!console.consoleWindow.hidden) return;
        
        // 在某些情况下 show 的时候刚好界面正在做动画，就可能会看到 consoleWindow 从左上角展开的过程（window 默认背景色是黑色的），所以这里做了一些小处理
        // https://github.com/Tencent/CIGAM_iOS/issues/743
        [UIView performWithoutAnimation:^{
            [console initConsoleWindowIfNeeded];
            console.consoleWindow.alpha = 0;
            console.consoleWindow.hidden = NO;
        }];
        [UIView animateWithDuration:.25 delay:.2 options:CIGAMViewAnimationOptionsCurveOut animations:^{
            console.consoleWindow.alpha = 1;
        } completion:nil];
    }
}

+ (void)hide {
    [CIGAMConsole sharedInstance].consoleWindow.hidden = YES;
}

- (void)initConsoleWindowIfNeeded {
    if (!self.consoleWindow) {
        self.consoleWindow = [[UIWindow alloc] init];
        self.consoleWindow.backgroundColor = nil;
        if (CIGAMCMIActivated) {
            self.consoleWindow.windowLevel = UIWindowLevelCIGAMConsole;
        } else {
            self.consoleWindow.windowLevel = 1;
        }
        self.consoleWindow.cigam_capturesStatusBarAppearance = NO;
        __weak __typeof(self)weakSelf = self;
        self.consoleWindow.cigam_hitTestBlock = ^__kindof UIView * _Nonnull(CGPoint point, UIEvent * _Nonnull event, __kindof UIView * _Nonnull originalView) {
            // 当显示 CIGAMConsole 时，点击空白区域，consoleViewController hitTest 会 return nil，从而将事件传递给 window，再由 window hitTest return  nil 来把事件传递给 UIApplication.delegate.window。但在 iPad 12-inch 里，当 consoleViewController hitTest return nil 后，事件会错误地传递给 consoleViewController.view.superview（而不是 consoleWindow），不清楚原因，暂时做一下保护
            // https://github.com/Tencent/CIGAM_iOS/issues/1169
            return originalView == weakSelf.consoleWindow || originalView == weakSelf.consoleViewController.view.superview ? nil : originalView;
        };
        
        self.consoleViewController = [[CIGAMConsoleViewController alloc] init];
        self.consoleWindow.rootViewController = self.consoleViewController;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.consoleViewController.backgroundColor = backgroundColor;
}

@end
