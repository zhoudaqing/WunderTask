//
//  CardNumController.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseViewController.h"
#import "LLPaySdk.h"
#import "LLPayUtil.h"

typedef enum LLVerifyPayState{
    kLLQuickPay = 0, //快捷支付
    kLLVerifyPay = 1,  //认证支付
    kLLPreAuthorizePay = 2 //预授权
}LLVerifyPayState;
@interface CardNumController : HTBaseViewController

@property (nonatomic) NSDictionary *mDict;

@property (nonatomic, retain) LLPaySdk *sdk;

@property (nonatomic) UIViewController *popVC;

@end
