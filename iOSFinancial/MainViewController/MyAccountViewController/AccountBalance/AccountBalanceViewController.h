//
//  AccountBalanceViewController.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/30.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseTableViewController.h"
#import "DropDownChooseProtocol.h"

/*!
 @header AccountBalanceViewController
 @abstract      账户余额、交易记录
 @discussion    我的账户--账户余额
 */


@interface AccountBalanceViewController : HTBaseTableViewController<DropDownChooseDelegate,DropDownChooseDataSource>

/** 外在改变账户余额 */
- (void)changeAccountBalance;


@end
