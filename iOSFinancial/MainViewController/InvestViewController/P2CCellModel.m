//
//  P2CCellModel.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "P2CCellModel.h"

@implementation P2CCellModel

- (NSString *)projectTitle
{
    return HTSTR(@"%@%@号", _title, _projectPid);
}

- (void)setUnfinishMoney:(NSString *)unfinishMoney
{
    if(![_unfinishMoney isEqualToString:unfinishMoney]) {
        _unfinishMoney = unfinishMoney;
        
        CGFloat totalMoney = [self.investMoney floatValue];
        CGFloat unfinish = [unfinishMoney floatValue];
        _invesetPersent = (totalMoney - unfinish) / totalMoney;
    }
}

- (void)parseUnionDic:(NSDictionary *)dic
{
    self.projectPid = [dic stringIntForKey:@"pid"];
    
    self.annualize = [[dic stringFloatForKey:@"money_rate"] stringByAppendingString:@"%"];
    self.invesetPersent = [[dic stringIntForKey:@"progress"] integerValue] / 100.0f;
    
    self.warrent = [dic stringFloatForKey:@"mcc_name"];
    
    self.redeemDurrationDate = [dic stringIntForKey:@"redeem_month_restriction"];
}

- (void)parseWithDictionary:(NSDictionary *)dic
{
    [self parseUnionDic:dic];
    
    self.loanID = [dic stringIntForKey:@"pid"];
    
    self.title = [dic stringForKey:@"loan_type"];
    
    //  存放项目类型
    self.loanType = [[dic stringIntForKey:@"loan_type_id"] integerValue];
    
    NSInteger months = [[dic stringIntForKey:@"repayment_deadline"] integerValue];

    if (0 != months) {
        //  项目是按月计算的
        self.returnCycleDescription = HTSTR(@"%ld个月", (long)months);
        self.returnCyleType = ReturnCyleTypeMonth;
        self.returnCycleNum = HTSTR(@"%ld", (long)months);
        
    }else {
        //  按天计算的
        NSInteger days = [[dic stringIntForKey:@"repayment_days"] integerValue];
        
        self.returnCycleDescription = HTSTR(@"%ld天", (long)days);
        self.returnCyleType = ReturnCyleTypeDay;
        self.returnCycleNum = HTSTR(@"%ld", (long)days);
    }
    
    self.loanState = [dic stringForKey:@"loan_status"];
    
    self.investMoney = [dic stringIntForKey:@"loan_money"];

    _unfinishMoney = [dic stringIntForKey:@"unfinish_money"];
    
    self.repayType = [dic stringForKey:@"repay_type"];
    
    self.min_invest_fee = [dic stringIntForKey:@"min_invest_fee"];
    
    //  专享标记
    self.channel_display_msg = [dic stringForKey:@"channel_display_msg"];
}

//  解析债券项目
- (void)parseRedeemDic:(NSDictionary *)dic
{
    [self parseUnionDic:dic];
    
    self.loanID = [dic stringIntForKey:@"rid"];
    
    self.title = [dic stringForKey:@"pro_type"];
    
    self.loanType = [[dic stringForKey:@"pro_type_id"] integerValue];
    
    self.loanState = [dic stringForKey:@"redeem_status"];
    
    self.investMoney = [dic stringIntForKey:@"redeem_fee"];
    
    self.transFee = [dic stringFloatForKey:@"transfer_fee"];
    
    self.repayType = [dic stringForKey:@"repay_type"];
    
    self.repayTypeId = [dic stringIntForKey:@"repay_type_id"];
    
    self.leftMonth = [dic stringIntForKey:@"left_mon"];
    
    self.leftDays = [dic stringIntForKey:@"left_days"];
    
    _unfinishMoney = [dic stringIntForKey:@"money_unfinish"];
    
    [self redeemMinInvestMoney:dic];
}

- (void)parseInvestDetailDic:(NSDictionary *)dic
{
    self.invesetPersent = [[dic stringIntForKey:@"progress"] integerValue] / 100.00f;
    _unfinishMoney = [dic stringIntForKey:@"unfinished"];
}

- (void)parseRedeemDetailDic:(NSDictionary *)dic
{
    _unfinishMoney = [dic stringIntForKey:@"unfinished"];
    
    [self redeemMinInvestMoney:dic];
}

- (void)redeemMinInvestMoney:(NSDictionary *)dic
{
    CGFloat minInvest = [[dic stringFloatForKey:@"min_invest_fee"] floatValue];
    CGFloat investMoney = [_unfinishMoney floatValue];
    if (minInvest > investMoney) {
        minInvest = investMoney;
    }
    
    self.min_invest_fee = HTSTR(@"%.2f", minInvest);
}

@end
