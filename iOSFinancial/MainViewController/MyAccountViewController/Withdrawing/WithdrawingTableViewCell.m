//
//  WithdrawingTableViewCell.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/30.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "WithdrawingTableViewCell.h"

@implementation WithdrawingTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _titleLabel.textColor = [UIColor jd_globleTextColor];
    _promptLabel.textColor = [UIColor jd_globleTextColor];
    _time.textColor = [UIColor jd_globleTextColor];
    _money.textColor = [UIColor jd_globleTextColor];
}

@end
