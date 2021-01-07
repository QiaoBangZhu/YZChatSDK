//
//  AddressBookCellData.m
//  YChat
//
//  Created by magic on 2020/12/29.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "AddressBookCellData.h"

@implementation AddressBookCellData

- (NSComparisonResult)compare:(AddressBookCellData *)data
{
    return [self.title localizedCompare:data.title];
}

@end
