//
//  NSBundle+YZBundle.m
//  YZChat
//
//  Created by magic on 2020/12/13.
//

#import "NSBundle+YZBundle.h"
#import "YZBaseManager.h"

@implementation NSBundle (YZBundle)

+ (instancetype)yzBundle
{
    static NSBundle *yzBundle = nil;
    if (yzBundle == nil) {
        // 这里不使用mainBundle是为了适配pod 1.x和0.x
        yzBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[YZBaseManager class]] pathForResource:@"YZChatResource" ofType:@"bundle"]];
    }
    return yzBundle;
}

+ (instancetype)tUIkitBundle {
    static NSBundle *tUIkitBundle = nil;
    if (tUIkitBundle == nil) {
        // 这里不使用mainBundle是为了适配pod 1.x和0.x
        tUIkitBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[YZBaseManager class]] pathForResource:@"TUIKitResource" ofType:@"bundle"]];
    }
    return tUIkitBundle;
}


@end
