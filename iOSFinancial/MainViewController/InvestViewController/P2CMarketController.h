//
//  P2CMarketController.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/25.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTListTableViewController.h"
#import "P2CCellModel.h"

/*!
 @header P2CMarketController
 @abstract   项目列表 -- 安心、省心
 @discussion
 */

@interface P2CMarketController : HTListTableViewController

//  是否是债券项目
@property (nonatomic, assign) BOOL isRedeem;

//  项目列表URL
- (NSString *)projectListRequestURL;

//  数据解析
- (NSString *)datasKey;

//  投资账户信息
- (NSString *)investAccount:(NSString *)investID;

//  数据解析
- (void)parseProjectDic:(NSDictionary *)dic  andPaseModel:(P2CCellModel *)model;

//  刷新数据
- (void)refreshInvestDataList;

@end
