//
//  InvestListViewController.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/7/15.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseTableViewController.h"
#import "P2CCellModel.h"

@interface InvestListViewController : HTBaseTableViewController

@property (nonatomic, copy)NSString *baseUrl;

@property (nonatomic, strong)   P2CCellModel *detailModel;

@end
