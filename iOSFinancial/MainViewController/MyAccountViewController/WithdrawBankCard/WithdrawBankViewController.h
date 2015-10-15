//
//  WithdrawBankViewController.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/28.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseTableViewController.h"

/*!
 @header        WithdrawBankViewController
 @abstract      银行名称、银行卡号、开户城市、开户支行
 @discussion    我的账户--提现银行卡
 */

@protocol WithDrawBankDeleagte <NSObject>

- (void)selfHelpWithdraw;

@end



@interface WithdrawBankViewController : HTBaseTableViewController

@property (nonatomic ,weak) id<WithDrawBankDeleagte> Wdelegate;

- (void)clcikeditBtn:(UIButton *)btn;

@end
 