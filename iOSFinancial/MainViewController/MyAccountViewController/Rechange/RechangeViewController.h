//
//  RechangeViewController.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseTableViewController.h"
#import "LLPaySdk.h"
#import "LLPayUtil.h"

/*!
 @header        RechangeViewController
 @abstract
 @discussion    我的账户--充值（账户余额--充值、投资页面--充值）
 */

typedef enum LLVerifyPayState{
    kLLQuickPay = 0, //快捷支付
    kLLVerifyPay = 1,  //认证支付
    kLLPreAuthorizePay = 2 //预授权
}LLVerifyPayState;

@interface RechangeViewController : HTBaseTableViewController

@property (nonatomic, retain) LLPaySdk *sdk;

@end
