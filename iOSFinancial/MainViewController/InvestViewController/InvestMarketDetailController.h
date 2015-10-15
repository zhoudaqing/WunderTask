//
//  InvestMarketDetailController.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseTableViewController.h"
#import "P2CCellModel.h"



@interface InvestMarketDetailController : HTBaseTableViewController

//  是否是债券项目
@property (nonatomic, assign) BOOL isRedeem;

//  推送消息
@property (nonatomic, copy) NSString *projectID;

@property (nonatomic, strong)   P2CCellModel *detailModel;

//  请求的地址
- (NSString *)requestURL;

@end
