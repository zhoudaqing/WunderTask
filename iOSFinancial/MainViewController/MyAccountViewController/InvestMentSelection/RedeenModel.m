//
//  RedeenModel.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/7/20.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "RedeenModel.h"

@implementation RedeenModel

- (void)setContentWithDic:(NSDictionary *)dic
{
    _ipid = [dic stringIntForKey:@"ipid"];
    _pid = [dic stringIntForKey:@"pid"];
    _pro_type = [dic stringIntForKey:@"pro_type"];
    _abstract = [NSString stringWithFormat:@"%@%@",_pro_type,_pid];
    _done_deal_time = [dic stringIntForKey:@"done_deal_time"];
    _mcc_name = [dic stringIntForKey:@"mcc_name"];
    _loan_money = [dic stringIntForKey:@"loan_money"];
    _reback_capital = [dic stringFloatForKey:@"reback_capital"];
    _reback_interest = [dic stringFloatForKey:@"reback_interest"];
    _isMcc_id = ([[dic stringIntForKey:@"mcc_id"] intValue] == 21) ;
    _agreement_type = [dic stringIntForKey:@"agreement_type"];
    _can_redeem = [[dic stringIntForKey:@"can_redeem"] intValue];
}

@end
