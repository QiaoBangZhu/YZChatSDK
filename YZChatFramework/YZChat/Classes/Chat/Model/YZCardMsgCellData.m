//
//  YZCardMsgCellData.m
//  YChat
//
//  Created by magic on 2020/11/26.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZCardMsgCellData.h"
#import "CommonConstant.h"
@implementation YZCardMsgCellData

- (CGSize)contentSize
{
    CGRect rect = [self.title boundingRectWithSize:CGSizeMake(220, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:15] } context:nil];
    CGSize size = CGSizeMake(ceilf(rect.size.width)+1, ceilf(rect.size.height));
    
    // 加上气泡边距
    size.height += (IS_IPHONEX ? 90:75);
    size.width = 220+24;
    return size;
}

@end
