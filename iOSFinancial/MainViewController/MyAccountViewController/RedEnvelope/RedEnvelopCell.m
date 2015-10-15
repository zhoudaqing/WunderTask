//
//  RedEnvelopCell.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/3.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "RedEnvelopCell.h"

@implementation RedEnvelopCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addView];
    }
    return self;
}

// MARK:  Cell布局
- (void)addView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(19, 0, APPScreenWidth - 40,78.0)];
    view.backgroundColor = HTWhiteColor;
    [self addSubview:view];
    
    UIImageView *left = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"RedEnvelopCellLeft"]];
    left.frame = CGRectMake(15, 0, 4, 78.0);
    [self addSubview:left];
    
    UIImageView *right = [[UIImageView alloc]initWithFrame:CGRectMake(APPScreenWidth-105.5-19, 0, 105.5, 78.0)];
    [right setImage:[UIImage imageNamed:@"RedEnvelopCellRight"]];
    [self addSubview:right];
    
    UIView  *activityView = [[UIView alloc]initWithFrame:CGRectMake(0.5, 0,view.width - right.width+2, 78.0)];
    [view addSubview:activityView];
    
    for (int i= 0; i<2; i++) {
        UIView *rimline = [Sundry rimLine];
        rimline.frame = CGRectMake(0, i*77.5, activityView.width, 0.5);
        [activityView addSubview:rimline];
    }
    
    self.activityNameLable.frame = CGRectMake(0, 21.5, activityView.width, 20);
    [activityView addSubview:self.activityNameLable];
    
    self.timeLable.frame = CGRectMake(0, 52.5, activityView.width, 10);
    [activityView addSubview:self.timeLable];
    
    self.moneyLable .frame = CGRectMake(0, 26, right.width, 26);
    [right addSubview:self.moneyLable];
}


- (UILabel *)activityNameLable
{
    if (!_activityNameLable) {
        _activityNameLable = [[UILabel alloc]init];
        _activityNameLable.textColor = [UIColor jd_darkBlackTextColor];
        _activityNameLable.font = [UIFont systemFontOfSize:20.0];
        _activityNameLable.textAlignment = NSTextAlignmentCenter;
    }
    return _activityNameLable;
}

- (UILabel *)timeLable
{
    if (!_timeLable) {
        _timeLable = [[UILabel alloc]init];
        _timeLable.font = [UIFont systemFontOfSize:10.0];
        _timeLable.textColor = [UIColor jd_globleTextColor];
        _timeLable.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLable;
}

- (UILabel *)moneyLable
{
    if (!_moneyLable) {
        _moneyLable = [[UILabel alloc]init];
        _moneyLable.font = [UIFont systemFontOfSize:26.0];
        _moneyLable.textColor = HTWhiteColor;
        _moneyLable.textAlignment = NSTextAlignmentCenter;
    }
    return _moneyLable;
}


@end
