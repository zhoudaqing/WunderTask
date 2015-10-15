//
//  InvesetMoneyView.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/28.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseView.h"

@class InvesetMoneyView;

typedef void(^ButtonClickBlock)(InvesetMoneyView *);

@interface InvesetMoneyView : HTBaseView

@property (nonatomic, strong)   IBOutlet UITextField *investMoney;
@property (nonatomic, copy) ButtonClickBlock rechargeBlock;

//  设置可用金额
- (void)setAvaMoney:(NSString *)money;
//  设置预期收益
- (void)setInCoMoney:(NSString *)money;

@end
