//
//  TitleView.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "TitleView.h"

@implementation TitleView

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.promptLabel.backgroundColor = [UIColor clearColor];
    
    self.titleLabel.textColor = [UIColor jd_settingDetailColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    
    self.promptLabel.textColor = [UIColor jd_globleTextColor];
    self.promptLabel.font = HTFont(13.0f);
}

@end
