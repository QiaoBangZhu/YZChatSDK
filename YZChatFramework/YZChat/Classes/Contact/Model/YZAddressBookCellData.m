//
//  YZAddressBookCellData.m
//  YChat
//
//  Created by magic on 2020/12/29.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZAddressBookCellData.h"

@implementation YZAddressBookCellData

- (NSComparisonResult)compare:(YZAddressBookCellData *)data
{
    return [self.title localizedCompare:data.title];
}

@end
