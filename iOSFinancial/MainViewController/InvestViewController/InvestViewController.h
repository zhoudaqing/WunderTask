//
//  InvestViewController.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/28.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseTableViewController.h"
#import "P2CCellModel.h"

@interface InvestViewController : HTBaseTableViewController

//  是否是债券项目
@property (nonatomic, assign) BOOL isRedeem;

//  推送消息的参数
@property (nonatomic, copy) NSString *projectId;

@property (nonatomic, strong)   P2CCellModel *detailModel;

@end
