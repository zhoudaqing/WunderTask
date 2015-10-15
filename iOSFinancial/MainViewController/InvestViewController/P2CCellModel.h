//
//  P2CCellModel.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseModel.h"

@interface P2CCellModel : HTBaseModel

//  项目pid - 债券市场使用
@property (nonatomic, copy) NSString *projectPid;

//  项目类型
@property (nonatomic, assign) LoanType loanType;

@property (nonatomic, copy) NSString *loanID;
//  Cell的标示符
@property (nonatomic, copy) NSString *identifier;
//  项目标题
@property (nonatomic, copy) NSString *title;
//  年化收益 /'ænjʊəl/
@property (nonatomic, copy) NSString *annualize;

//  投资期限类型（天，还是月）
@property (nonatomic, assign) ReturnCyleType returnCyleType;

//  回款周期 描述
@property (nonatomic, copy) NSString *returnCycleDescription;
@property (nonatomic, copy) NSString *returnCycleNum;
//  投资状态
@property (nonatomic, copy) NSString *loanState;
//  可投金额 (设值当前值可影响 投资进度)
@property (nonatomic, copy) NSString *unfinishMoney;
//  担保方
@property (nonatomic, copy) NSString *warrent;
//  总投资金额
@property (nonatomic, copy) NSString *investMoney;
//  出让金额
@property (nonatomic, copy) NSString *transFee;
//  投资进度
@property (nonatomic, copy) NSString *investPersentStr;
//  投资进度
@property (nonatomic, assign)   CGFloat invesetPersent;
//  最少投资金额
@property (nonatomic, copy) NSString *min_invest_fee;

//  Detail
//  回款方式
@property (nonatomic, copy) NSString *repayType;
//  回款方式id
@property (nonatomic, copy) NSString *repayTypeId;

//  项目专项信息
@property (nonatomic, copy) NSString *channel_display_msg;

//  赎回周期(多长时间内不能赎回)
@property (nonatomic) NSString *redeemDurrationDate;
//  赎回项目所有的rid（）
@property (nonatomic) NSString *rid;

//--------------债券项目

//  剩余天数
@property (nonatomic, copy) NSString *leftDays;
//  剩余月数
@property (nonatomic, copy) NSString *leftMonth;

- (NSString *)projectTitle;

//  债券项目
- (void)parseRedeemDic:(NSDictionary *)dic;

//  投资项目详情页的 数据解析接口
- (void)parseInvestDetailDic:(NSDictionary *)dic;

//  债券项目详情页面
- (void)parseRedeemDetailDic:(NSDictionary *)dic;

@end
