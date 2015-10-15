//
//  InvestDetailModel.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/5/20.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvestDetailModel.h"

@interface InvestDetailModel ()


@end

@implementation InvestDetailModel

- (void)parseWithDictionary:(NSDictionary *)detailDic
{
    //  解析基本项目信息
    [_detailModel parseInvestDetailDic:detailDic];
    
    [self parseUnionDictionary:detailDic];
}

- (void)parseWithRedeemDic:(NSDictionary *)detailDic
{
    //  解析基本项目信息
    [_detailModel parseRedeemDetailDic:detailDic];
    
    [self parseUnionDictionary:detailDic];
}

- (void)parseUnionDictionary:(NSDictionary *)detailDic
{
    NSDictionary *dic = [detailDic dictionaryForKey:@"project_info"];
    //  项目信息
    self.loan_use = [dic stringNoneForKey:@"loan_use"];
    self.loan_use_type = [dic stringNoneForKey:@"loan_use_type"];
    self.repayment_source = [dic stringNoneForKey:@"repayment_source"];
    
    //  风控信息
    dic = [detailDic dictionaryForKey:@"risk_info"];
    self.counter_guarantee = [dic stringNoneForKey:@"counter_guarantee"];
    self.jianDan_review = [dic stringNoneForKey:@"jdlc_suggestion"];
    
    //  企业信息
    dic = [detailDic dictionaryForKey:@"company_info"];
    self.company_type = [dic stringNoneForKey:@"company_type"];
    self.company_nature = [dic stringNoneForKey:@"company_nature"];
    self.introduction = [dic stringNoneForKey:@"introduction"];
    self.reputation = [dic stringNoneForKey:@"reputation"];
    
    //  个人信息
    dic = [detailDic dictionaryForKey:@"person_info"];
    if (dic.allKeys.count) {
        _personalModel = [[PersonalInfoModel alloc] init];
        [_personalModel parseWithDictionary:dic];
    }
    
    //  抵押信息
    dic = [detailDic dictionaryForKey:@"mortgage"];
    self.mortgage_house_con = [dic stringNoneForKey:@"mortgage_house_con"];
    self.mortgage_car_con = [dic stringNoneForKey:@"mortgage_car_con"];
    
    self.online_end_time = [dic stringIntForKey:@"online_end_time"];
}


@end


@implementation PersonalInfoModel


- (void)parseWithDictionary:(NSDictionary *)dic
{
    NSArray *array = [dic allKeys];
    
    for (NSString *key in array) {
        
        id value = [dic valueForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *subDic = (NSDictionary *)value;
            NSArray *subKeys = [subDic allKeys];
            
            for (NSString *subKey in subKeys) {
                 [self setValue:[subDic stringIntForKey:subKey] forKey:subKey];
            }
            
        }else {
            [self setValue:[dic stringIntForKey:key] forKey:key];
        }
    }
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"undifinedKey");
}

- (void)setNilValueForKey:(NSString *)key
{
    
}

@end
