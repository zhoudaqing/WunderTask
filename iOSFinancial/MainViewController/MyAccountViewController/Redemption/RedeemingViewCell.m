//
//  RedeemingViewCell.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/7/15.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "RedeemingViewCell.h"

@implementation RedeemingViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)addView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APPScreenWidth, 135)];
    [self addSubview:view];
    
    UIView *rimeLine = [Sundry  rimLine];
    rimeLine.frame = CGRectMake(15, view.height - 13, APPScreenWidth-30, 0.5);
    [view addSubview:rimeLine];
    
    [view addSubview:self.abstractLable];
    [view addSubview:self.timeLable];
    [view addSubview:self.moneyLable];
    [view addSubview:self.interestLable];
    [view addSubview:self.divestMoneyLable];
    [view addSubview:self.yieldLable];
    [view addSubview:self.expectMoneyLable];
    [view addSubview:self.returnTimeLable];
    [view addSubview:self.payOffLable];
}

- (UILabel *)abstractLable
{
    if (!_abstractLable) {
        _abstractLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, APPScreenWidth, 15)];
        _abstractLable.font = [UIFont systemFontOfSize:15.0];
    }
    return _abstractLable;
}

- (UILabel *)timeLable
{
    if (!_timeLable) {
        _timeLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 18, APPScreenWidth - 15, 12)];
        _timeLable.font = [UIFont systemFontOfSize:12.0];
        _timeLable.textColor = [UIColor jd_globleTextColor];
        _timeLable.textAlignment = NSTextAlignmentRight;
    }
    return _timeLable;
}

- (UILabel *)moneyLable
{
    if (!_moneyLable) {
        _moneyLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 45.5, APPScreenWidth, 15)];
        _moneyLable.textColor = [UIColor jd_barTintColor];
        _moneyLable.font = [UIFont systemFontOfSize:15];
    }
    return _moneyLable;
}

- (UILabel *)interestLable
{
    if (!_interestLable) {
        _interestLable = [[UILabel alloc]initWithFrame:CGRectMake(15, self.moneyLable.bottom + 10, APPScreenWidth, 15)];
        _interestLable.textColor = [UIColor jd_barTintColor];
        _interestLable.font = [UIFont systemFontOfSize:15];
    }
    return _interestLable;
}

- (UILabel *)divestMoneyLable
{
    if (!_divestMoneyLable) {
        _divestMoneyLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 93.5, APPScreenWidth, 18)];
        _divestMoneyLable.textColor = [UIColor jd_barTintColor];
        _divestMoneyLable.font = [UIFont systemFontOfSize:15];
    }
    return _divestMoneyLable;
}

- (UILabel *)yieldLable
{
    if (!_yieldLable) {
        _yieldLable = [[UILabel alloc]initWithFrame:CGRectMake(0, self.timeLable.bottom+15, APPScreenWidth -15, 18)];
        _yieldLable.font = [UIFont systemFontOfSize:13];
        _yieldLable.textColor = [UIColor jd_barTintColor];
        _yieldLable.textAlignment = NSTextAlignmentRight;
    }
    return _yieldLable;
}

- (UILabel *)expectMoneyLable
{
    if (!_expectMoneyLable) {
        _expectMoneyLable = [[UILabel alloc]initWithFrame:CGRectMake(0, self.yieldLable.bottom + 33, APPScreenWidth - 15, 15)];
        _expectMoneyLable.font = [UIFont systemFontOfSize:15.0];
        _expectMoneyLable.textAlignment = NSTextAlignmentRight;
        _expectMoneyLable.textColor = [UIColor jd_barTintColor];
    }
    return _expectMoneyLable;
}

- (UILabel *)returnTimeLable
{
    if (!_returnTimeLable) {
        _returnTimeLable = [[UILabel alloc]initWithFrame:CGRectMake(15, self.expectMoneyLable.bottom + 21, APPScreenWidth-30, 13)];
        _returnTimeLable.textColor = [UIColor jd_globleTextColor];
        _returnTimeLable.font = [UIFont systemFontOfSize:13.0];
    }
    return _returnTimeLable;
}

- (UILabel *)payOffLable
{
    if (!_payOffLable) {
        _payOffLable = [[UILabel alloc]initWithFrame:self.returnTimeLable.frame];
        _payOffLable.font = [UIFont systemFontOfSize:13.0];
        _payOffLable.textAlignment = NSTextAlignmentRight;
        _payOffLable.textColor = [UIColor jd_globleTextColor];
    }
    return _payOffLable;
}

@end
