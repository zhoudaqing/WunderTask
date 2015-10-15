//
//  InvestDetailTitleCell.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/5/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvestDetailTitleCell.h"

@implementation InvestDetailTitleCell


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.textLabel sizeToFit];
    self.textLabel.textAlignment = NSTextAlignmentLeft;
    
    self.detailTextLabel.left = self.textLabel.right + 3;
}

@end
