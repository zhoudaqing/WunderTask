//
//  RedeenModel.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/7/20.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseModel.h"

@interface RedeenModel : HTBaseModel

@property (nonatomic, copy) NSString *abstract;

@property (nonatomic,copy)NSString *ipid;

@property (nonatomic,copy)NSString *pid;
/** 项目类型 */
@property (nonatomic ,copy)NSString *pro_type;
/** 完成时间 */
@property (nonatomic, copy)NSString *done_deal_time;
/** 担保方 */
@property (nonatomic, copy)NSString *mcc_name;
/** 项目总金额 */
@property (nonatomic, copy)NSString *loan_money;
/** 项目本金 */
@property (nonatomic, copy)NSString *reback_capital;
/** 当期收益 */
@property (nonatomic, copy)NSString *reback_interest;
/** 合同类型 */
@property (nonatomic, copy)NSString *agreement_type;
/** 为空则没有收购承诺书 */
@property (nonatomic, assign)BOOL isMcc_id;
/** 是否显示可赎回 i == 0 && can_redeem == 1 */
@property (nonatomic,assign)int i;
@property (nonatomic,assign)int can_redeem;
/** 字典赋值 */
- (void)setContentWithDic:(NSDictionary *)dic;

@end
