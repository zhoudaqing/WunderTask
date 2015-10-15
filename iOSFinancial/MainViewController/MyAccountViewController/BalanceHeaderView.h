//
//  BalanceHeaderView.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/30.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseView.h"

@interface BalanceHeaderView : HTBaseView

//  昨日到账收益
- (void)setAnnualize:(NSString *)string;
//  累计余额收益
- (void)setReturnCycle:(NSString *)month;
//  7日年化收益率
- (void)setInvesetMoney:(NSString *)invest;
//  万份收益
- (void)setTimeLeft:(NSString *)timeLeft;

@end
