//
//  TargetDescriptionCell1.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/28.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "TargetDescriptionCell1.h"

@interface TargetDescriptionCell1 ()

@property (nonatomic, strong)   IBOutlet UIView *lineView;

@end


@implementation TargetDescriptionCell1

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.lineView.backgroundColor = [UIColor jd_settingDetailColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.titleLabel.backgroundColor = [UIColor clearColor];
}

+ (CGFloat)fixedHeight
{
    return 44.0f;
}

@end
