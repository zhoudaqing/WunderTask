//
//  TotalIncomeHeader.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/6/1.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "TotalIncomeHeader.h"

@interface TotalIncomeHeader ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation TotalIncomeHeader

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.titleLabel.textColor = [UIColor jd_globleTextColor];
    
    self.totalIncomeLabel.textColor  = [UIColor jd_settingDetailColor];
    
}

@end
