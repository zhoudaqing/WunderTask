//
//  ReturnMoneyTableViewCell.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/29.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "ReturnMoneyTableViewCell.h"

@implementation ReturnMoneyTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = HTWhiteColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.colorLable];
    }
    return self;
}

- (AttributedLabel *)colorLable
{
    if (!_colorLable) {
        _colorLable = [[AttributedLabel alloc]initWithFrame:CGRectMake(15, (self.height-15)*.5, self.width, 18)];
    }
    return _colorLable;
}



- (void)setCellContentLableWithString:(NSString *)text
{
    self.colorLable.text = text;
    [self.colorLable setColor:[UIColor orangeColor] fromIndex:17 length:4];
    [self.colorLable setFont:[UIFont systemFontOfSize:14] fromIndex:0 length:text.length];
    self.colorLable.backgroundColor = [UIColor clearColor];
    
}

- (void)setCellMoneyLanleWithSring:(NSString *)text
{
    self.colorLable.text = text;
    [self.colorLable setColor:[UIColor orangeColor] fromIndex:3 length:text.length - 4];
    [self.colorLable setFont:[UIFont systemFontOfSize:14] fromIndex:0 length:text.length];
    self.colorLable.backgroundColor = [UIColor clearColor];
    
}



@end
