//
//  BalanceRuleViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/6/10.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "BalanceRuleViewController.h"

@interface BalanceRuleViewController ()

@end

@implementation BalanceRuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addScrollView];
}

- (void)addScrollView
{
    UIScrollView *view = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, APPScreenWidth,APPScreenHeight - 64)];
    UILabel *headLable1 = [self headlineWithString:@"1.转入资金"];
    headLable1.frame = CGRectMake(15, 8, APPScreenWidth - 30, 15);
    [view addSubview:headLable1];
    
    UILabel *contentLable1 = [self contentLableWithString:@"用户在A日15：00前存入的资金，该资金的申购日为当天，生息日为A+1，计息日为A+2；A日15：00后存入的资金，该资金的申购日为A+1，生息日为A+2，计息日为A+3。\n备注：A日包括工作日、周末、调休节假日"];
    contentLable1.frame = CGRectMake(15, headLable1.bottom, APPScreenWidth - 30, 0);
    [contentLable1 sizeToFit];
    [view addSubview:contentLable1];
    
    UILabel *headLable2 = [self headlineWithString:@"2.利息到账显示"];
    headLable2.frame = CGRectMake(15, contentLable1.bottom +6, APPScreenWidth - 15, 15);
    [view addSubview:headLable2];
    
    UILabel *contentLable2 = [self contentLableWithString:@"计息日16:00后"];
    contentLable2.frame = CGRectMake(15, headLable2.bottom, APPScreenWidth -15, 0);
    [contentLable2 sizeToFit];
    [view addSubview:contentLable2];
    
    UILabel *headLable3 = [self headlineWithString:@"3.转出资金"];
    headLable3.frame = CGRectMake(15, contentLable2.bottom+4 , APPScreenWidth - 15, 15);
    [view addSubview:headLable3];
    
    UILabel *contentLable3 = [self contentLableWithString:@"资金转出当天无收益。"];
    contentLable3.frame = CGRectMake(15, headLable3.bottom , APPScreenWidth -15, 0);
    [contentLable3 sizeToFit];
    [view addSubview:contentLable3];
    
    UILabel *headLable4 = [self headlineWithString:@"4.关闭余额生息功能"];
    headLable4.frame = CGRectMake(15, contentLable3.bottom+4, APPScreenWidth - 30, 15);
    [view addSubview:headLable4];
    
    UILabel *contentLable4 = [self contentLableWithString:@"关闭操作视为转出，与转出资金的计算逻辑一致。"];
    contentLable4.frame = CGRectMake(15, headLable4.bottom, APPScreenWidth -30, 0);
    [contentLable4 sizeToFit];
    [view addSubview:contentLable4];
    
    UILabel *headLable5 = [self headlineWithString:@"5.特殊情况"];
    headLable5.frame = CGRectMake(15, contentLable4.bottom+4, APPScreenWidth - 30, 15);
    [view addSubview:headLable5];
    
    UILabel *contentLable5 = [self contentLableWithString:@"用户在同一申购日（15:00:00 - 14:59:59）内，若既有支出又有转入操作时，先自行抵消此申购日内的支出存入金额。（存入支出不分先后，且只限于同时有相对的转入和支出，单方面的转入或支出按各自的规则计算）。\n即：用户做支出操作时，支出的资金优先从未生息的余额中扣除，不足时再从已生息的余额中扣除。所扣除资金的收益只结算到前一天，当天无收益。"];
    contentLable5.frame = CGRectMake(15, headLable5.bottom, APPScreenWidth - 30, 0);
    [contentLable5 sizeToFit];
    [view addSubview:contentLable5];
    
    UILabel *headLable6 = [self headlineWithString:@"6. 复利"];
    headLable6.frame = CGRectMake(15, contentLable5.bottom+6, APPScreenWidth -15, 15);
    [view addSubview:headLable6];
    
    UILabel *contentLable6 = [self contentLableWithString:@"如用户A日充值之后的三天均无任何转入转出操作。则A+2日当天显示【昨日收益】；A+3日当天显示的【昨日收益】金额为A+2日本利合计获得的收益，依此类推。"];
    contentLable6.frame = CGRectMake(15, headLable6.bottom, APPScreenWidth - 15, 0);
    [contentLable6 sizeToFit];
    [view addSubview:contentLable6];
    
    view.contentSize = CGSizeMake(APPScreenWidth, contentLable6.bottom + 10);
    
    [self.view addSubview:view];
}

- (UILabel *)headlineWithString:(NSString *)str
{
    UILabel *lable = [[UILabel alloc]init];
    lable.text = str;
    lable.font = [UIFont systemFontOfSize:15.0];
    lable.numberOfLines = 0;
    lable.text = str;
    lable.textColor = [UIColor jd_globleTextColor];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:lable.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:6];//调整行间距
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [lable.text length])];
    lable.attributedText = attributedString;
    return lable;
}

- (UILabel *)contentLableWithString:(NSString *)str
{
    UILabel *contentLable = [[UILabel alloc]init];
    
    contentLable.font = [UIFont systemFontOfSize:13.0];
    contentLable.numberOfLines = 0;
    contentLable.text = str;
    contentLable.textColor = [UIColor jd_globleTextColor];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:contentLable.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:6];//调整行间距
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [contentLable.text length])];
    contentLable.attributedText = attributedString;

    return contentLable;
}

@end
