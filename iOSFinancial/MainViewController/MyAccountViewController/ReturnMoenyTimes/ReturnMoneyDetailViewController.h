//
//  ReturnMoneyDetailViewController.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/29.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseTableViewController.h"
#import "RedeenModel.h"

@protocol ReturnMoneyDetailDelegate <NSObject>

- (void)selfDissMiss;

@end

@interface ReturnMoneyDetailViewController : HTBaseTableViewController

@property (nonatomic, strong)RedeenModel *redeenModel;

@property (nonatomic, weak)id<ReturnMoneyDetailDelegate>delegate;

@end
