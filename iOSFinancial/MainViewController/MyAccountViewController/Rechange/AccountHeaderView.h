//
//  AccountHeaderView.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/29.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseView.h"

@class AccountHeaderView;

typedef void(^HeaderTouchBlock)(AccountHeaderView *) ;

@interface AccountHeaderView : HTBaseView

@property (nonatomic, strong)   IBOutlet UILabel *totalLabel;

/** 总资产 */
@property (nonatomic, strong)   IBOutlet UILabel *totalMoney;

@property (nonatomic, strong)   IBOutlet UIView *lineView1;
@property (nonatomic, strong)   IBOutlet UIView *lineView11;

@property (nonatomic, strong)   IBOutlet UIView *inComeView;
@property (nonatomic, strong)   IBOutlet UILabel *inComeLabel;

/** 投资中 */
@property (nonatomic, strong)   IBOutlet UILabel *inComeMoney;

@property (nonatomic, strong)   IBOutlet UIView *outView;
@property (nonatomic, strong)   IBOutlet UILabel *outLabel;

/** 提现中 */
@property (nonatomic, strong)   IBOutlet UILabel *outMoney;


@property (nonatomic, copy) HeaderTouchBlock leftViewBlock;
@property (nonatomic, copy) HeaderTouchBlock rightViewBlock;

@end
