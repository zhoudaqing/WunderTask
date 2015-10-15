//
//  AccountBalanceTableViewCell.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/30.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "AccountBalanceTableViewCell.h"

@implementation AccountBalanceTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addLable];
    }
    return self;
}


- (void)addLable
{
    self.typeLable.frame = CGRectMake(15, 15, 180, 15);
    [self addSubview:self.typeLable];
    self.typeLable.text = @"回收收益";
    
    
    UILabel *blanceTitle = [[UILabel alloc]initWithFrame:CGRectMake(15,40,39, 13)];
    blanceTitle.text = @"余额：";
    blanceTitle.font = [UIFont systemFontOfSize:13.0];
    [self addSubview:blanceTitle];
    
    self.balanceLable.frame = CGRectMake(blanceTitle.right, 40,300, 13);
    self.balanceLable.text = @"1151531321.00";
    [self addSubview:self.balanceLable];
    
    //设计的线
    UIImageView *line = [Sundry rimLine];
    line.frame = CGRectMake(15, blanceTitle.bottom + 10, APPScreenWidth - 180 , 0.5);
    [self addSubview:line];
    
    
    UILabel *abstrancTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, line.bottom + 10, 65.0, 13)];
    abstrancTitle.text = @"业务摘要:";
    abstrancTitle.font = [UIFont systemFontOfSize:13.0];
    abstrancTitle.textColor = [UIColor jd_darkBlackTextColor];
    [self addSubview:abstrancTitle];
    
    self.abstractLable.frame = CGRectMake(abstrancTitle.right, abstrancTitle.origin.y, 200, 13);
    self.abstractLable.text  = @"安心计划3153213131号";
    [self addSubview:self.abstractLable];
    
    self.timeLable.frame = CGRectMake(self.typeLable.right, self.typeLable.bottom - 11, APPScreenWidth - self.typeLable.right - 15, 11);
    self.timeLable.text = @"2015-11-28 20:58:00";
    [self addSubview:self.timeLable];
    
    self.moneyLable.frame = CGRectMake(line.right, line.centerY - 13.5, APPScreenWidth-line.right-15, 24);
    self.moneyLable.text = @"+2885.00";
    [self addSubview:self.moneyLable];
    
}

- (UILabel *)typeLable
{
    if (!_typeLable) {
        _typeLable = [[UILabel alloc]init];
        _typeLable.font = [UIFont systemFontOfSize:15.0];
    }
    return _typeLable;
}

- (UILabel *)balanceLable
{
    if (!_balanceLable) {
        _balanceLable = [[UILabel alloc]init];
        _balanceLable.font = [UIFont systemFontOfSize:13.0];
        _balanceLable.textColor = [UIColor jd_globleTextColor];
    }
    return _balanceLable;
}

- (UILabel *)abstractLable
{
    if (!_abstractLable) {
        _abstractLable = [[UILabel alloc]init];
        _abstractLable.font = [UIFont systemFontOfSize:13.0];
        _abstractLable.textColor = [UIColor jd_globleTextColor];
    }
    return _abstractLable;
}

- (UILabel *)timeLable
{
    if (!_timeLable) {
        _timeLable = [[UILabel alloc]init];
        _timeLable.textAlignment = NSTextAlignmentRight;
        _timeLable.textColor = [UIColor jd_textGray2Color];
        _timeLable.font = [UIFont systemFontOfSize:11.0];
    }
    return _timeLable;
}

- (UILabel *)moneyLable
{
    if (!_moneyLable) {
        _moneyLable = [[UILabel alloc]init];
        _moneyLable.font = [UIFont systemFontOfSize:24.0];
        _moneyLable.textColor = [UIColor jd_barTintColor];
        _moneyLable.textAlignment = NSTextAlignmentRight;
    }
    return _moneyLable;
}
@end
