//
//  InvestHeaderView.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/28.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseView.h"
#import "InvesetDetailHeaderView.h"

@interface InvestHeaderView : HTBaseView

@property (nonatomic, strong) IBOutlet  UILabel *titlLabel;

//  设置标题
- (void)setTitle:(NSString *)title;
//  设置年化收益率
- (void)setAnnualize:(NSString *)string;
//  设置项目期限
- (void)setReturnCycle:(NSString *)month;
//  设置可投金额
- (void)setInvesetMoney:(NSString *)invest;


@end
