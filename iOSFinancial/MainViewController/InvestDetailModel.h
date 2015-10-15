//
//  InvestDetailModel.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/5/20.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseModel.h"
#import "P2CCellModel.h"

@class PersonalInfoModel;

@interface InvestDetailModel : HTBaseModel

//  项目基本信息
@property (nonatomic, assign) P2CCellModel *detailModel;

/*----------------------项目信息----------------------*/

//  项目用途
@property (nonatomic, strong)   NSString *loan_use;
//  项目用途类型
@property (nonatomic, strong)   NSString *loan_use_type;

//  还款来源
@property (nonatomic, strong)   NSString *repayment_source;


/*----------------------风控信息----------------------*/

//  担保公司审查
@property (nonatomic, strong)   NSString *counter_guarantee;
//  简单理财网审查
@property (nonatomic, strong)   NSString *jianDan_review;


/*----------------------企业信息----------------------*/

//  企业类型
@property (nonatomic, strong)   NSString *company_type;
//  企业性质
@property (nonatomic, strong)   NSString *company_nature;
//  企业简介
@property (nonatomic, strong)   NSString *introduction;
//  企业经营信息
@property (nonatomic, strong)   NSString *reputation;

/*----------------------个人信息----------------------*/

@property (nonatomic, strong)   PersonalInfoModel *personalModel;

/*----------------------抵押信息----------------------*/

//  抵押信息
@property (nonatomic, strong)   NSString *mortgage_house_con;
//  汽车抵押
@property (nonatomic, strong)   NSString *mortgage_car_con;

/*----------------------候选项目----------------------*/


@property (nonatomic, strong)   NSString *serverTime;
@property (nonatomic, strong)   NSString *online_end_time;

//  债券项目解析
- (void)parseWithRedeemDic:(NSDictionary *)detailDic;

@end

@interface PersonalInfoModel : HTBaseModel

//-------------基本信息

//  性别
@property (nonatomic, copy) NSString *sex;
//  年龄
@property (nonatomic, copy) NSString *age;
//  婚姻状况
@property (nonatomic, copy) NSString *marriage_info;
//  学历
@property (nonatomic, copy) NSString *education;
//  子女
@property (nonatomic, copy) NSString *children_count;
//  户籍所在地
@property (nonatomic, copy) NSString *hukou_city;

//-------------工作信息

//  工作所在地
@property (nonatomic, copy) NSString *work_place;
//  工作时间
@property (nonatomic, copy) NSString *cur_job_start_mon;
//  岗位
@property (nonatomic, copy) NSString *work_position;
//  公司行业
@property (nonatomic, copy) NSString *company_industry;
//  公司性质
@property (nonatomic, copy) NSString *company_type;
//  公司规模
@property (nonatomic, copy) NSString *company_size;


//-------------个人资产及征信信息

//  月收入水平
@property (nonatomic, copy) NSString *income_fee;
//  房产
@property (nonatomic, copy) NSString *if_has_house;
//  车产
@property (nonatomic, copy) NSString *if_has_vehicle;
//  其它信用贷款
@property (nonatomic, copy) NSString *if_has_other_loan;
//  未销户信用卡
@property (nonatomic, copy) NSString *if_has_uncancel_creditcard;
//  信用卡使用额度
@property (nonatomic, copy) NSString *credit_limit_used;


@end
