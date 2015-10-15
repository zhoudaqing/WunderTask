//
//  InvestListViewCell.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/7/17.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvestListViewCell.h"

@implementation InvestListViewCell

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
        [self loadSubViews];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)loadSubViews
{
    self.timeLable.frame = CGRectMake(15, 3.5,128, 19.5);
    [self addSubview:self.timeLable];
    
    self.moneyLable.frame = CGRectMake(0, 3.5, APPScreenWidth - 15, 19.5);
    [self addSubview:self.moneyLable];
    
    self.nameLable.frame = CGRectMake(APPScreenWidth *.5, 3.5, 128, 19.5);
    [self addSubview:self.nameLable];
}

- (UILabel *)timeLable
{
    if (!_timeLable) {
        _timeLable = [[UILabel alloc]init];
        _timeLable.font = [UIFont systemFontOfSize:13];
        _timeLable.textColor = [UIColor jd_globleTextColor];
    }
    return _timeLable;
}

- (UILabel *)nameLable
{
    if (!_nameLable) {
        _nameLable = [[UILabel alloc]init];
        _nameLable.font = [UIFont systemFontOfSize:13];
        _nameLable.textColor = [UIColor jd_globleTextColor];
    }
    return _nameLable;
}

-(UILabel *)moneyLable
{
    if (!_moneyLable) {
        _moneyLable = [[UILabel alloc]init];
        _moneyLable.font = [UIFont systemFontOfSize:13];
        _moneyLable.textColor = [UIColor jd_globleTextColor];
        _moneyLable.textAlignment = NSTextAlignmentRight;
    }
    return _moneyLable;
}
@end
