//
//  FlickerView.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/6/15.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "FlickerView.h"

@implementation FlickerView


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.numberLabel.backgroundColor = [UIColor clearColor];
    
    self.titleLabel.textColor = [UIColor whiteColor];
    self.numberLabel.textColor = [UIColor whiteColor];

}

@end
