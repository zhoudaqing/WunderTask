//
//  ReturnMoneyDetailViewCell.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/8.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "ReturnMoneyDetailViewCell.h"

@implementation ReturnMoneyDetailViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:NO];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
                
    }
    return self;
}


- (void)addView
{
    UILabel *timesLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, APPScreenWidth, 15)];
    timesLable.text = [NSString stringWithFormat:@"第%d期",self.times];
    timesLable.font = [UIFont systemFontOfSize:15.0];
    [self addSubview:timesLable];
    
    UILabel *returnMoneyLable = [[UILabel alloc]initWithFrame:CGRectMake(15, timesLable.bottom + 10, APPScreenWidth, 12)];
    returnMoneyLable.text = [NSString stringWithFormat:@"本金回款:%@元",self.returnMoney];
    returnMoneyLable.font = [UIFont systemFontOfSize:12.0];
    returnMoneyLable.textColor = [UIColor jd_globleTextColor];
    [self addSubview:returnMoneyLable];
    
    UILabel *interestsLable = [[UILabel alloc]initWithFrame:CGRectMake(15, returnMoneyLable.bottom + 10, APPScreenWidth, 12.0)];
    interestsLable.text = [NSString stringWithFormat:@"利息：%@",self.interests];
    interestsLable.font = [UIFont systemFontOfSize:13.0];
    interestsLable.textColor = [UIColor jd_globleTextColor];
    [self addSubview:interestsLable];
    
    UILabel *timeLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, APPScreenWidth-15, 12.0)];
    timeLable.text = [NSString stringWithFormat:@"还款日期：%@",self.time];
    timeLable.font = [UIFont systemFontOfSize:12.0];
    timeLable.textColor  = [UIColor jd_textGray2Color];
    timeLable.textAlignment = NSTextAlignmentRight;
    [self addSubview:timeLable];
    
    
    UIImageView *returnStatusView = [[UIImageView alloc]initWithFrame:CGRectMake(APPScreenWidth - 84, timeLable.bottom + 14.5, 64.5, 42)];
    [returnStatusView setImage:[UIImage imageNamed:self.returnStatus]];
    [self addSubview:returnStatusView];
}


@end
