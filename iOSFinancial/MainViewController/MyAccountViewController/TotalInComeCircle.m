//
//  TotalInComeCircle.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/6/1.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "TotalInComeCircle.h"

@implementation HTSubCircleView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _circleView = [[HTPromptCircle alloc] init];
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.circleView.frame = self.bounds;
}

@end


@interface TotalInComeCircle ()


@end

@implementation TotalInComeCircle

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.backgroundColor = [UIColor clearColor];
    
    self.totalLabel.textColor = [UIColor jd_darkBlackTextColor];
    
    _persentView.width = 120.0f;
    _persentView.height = 120.0f;
    _persentView.left = (self.width - _persentView.width ) / 2.0f;
    
    _persentView.top = 15.0f;
    
    [self.persentView setShowPromptlabel:YES];
    
    [self.persentView setpercent:.0f animated:NO];
    
}

@end
