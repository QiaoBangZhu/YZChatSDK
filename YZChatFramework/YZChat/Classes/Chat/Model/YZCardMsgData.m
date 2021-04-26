//
//  YZCardMsgCellData.m
//  YChat
//
//  Created by magic on 2020/11/26.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZCardMsgData.h"

#import "THeader.h"
#import "TUICallUtils.h"

@implementation YZCardMsgData

- (instancetype)initWithTitle:(NSString *)title
                         desc:(NSString *)desc
                         logo:(NSString *)logo
                         link:(NSString *)link {
    if (self = [self init]) {
        _title = title;
        _desc = desc;
        _logo = logo;
        _link = link;
    }

    return self;
}

- (NSData *)data {
    return [TUICallUtils dictionary2JsonData: @{
        @"version": @(TextLink_Version),
        @"businessID": CardLink,
        @"title": self.title,
        @"link": self.link,
        @"desc": self.desc,
        @"logo": self.logo
    }];
}

- (NSString *)reuseIdentifier {
    return @"YZCardMsgCell";
}

- (CGSize)contentSize {
    CGRect rect = [self.title boundingRectWithSize:CGSizeMake(220, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:15] } context:nil];
    CGSize size = CGSizeMake(ceilf(rect.size.width)+1, ceilf(rect.size.height));

    // 加上气泡边距
    size.height += 75;
    size.width = 220+24;
    return size;
}

@end
