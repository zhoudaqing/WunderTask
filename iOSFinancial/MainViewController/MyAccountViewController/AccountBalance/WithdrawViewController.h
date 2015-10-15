//
//  WithdrawViewController.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/2.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseTableViewController.h"

/*!
 @header WithdrawViewController
 @abstract      银行卡列表、账户余额、支付密码
 @discussion    我的账户--账户余额--提现页面
 */

@interface WithdrawViewController : HTBaseTableViewController

/** 银行卡数组 */
@property (nonatomic) NSArray *cardInfoArray;

/** 账户余额 */
@property (nonatomic , copy) NSString *money;

@end
