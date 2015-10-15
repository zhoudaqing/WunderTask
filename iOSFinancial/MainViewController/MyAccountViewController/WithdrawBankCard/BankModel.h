//
//  BankModel.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/5/6.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseModel.h"

@interface BankModel : HTBaseModel

//  银行卡id
@property (nonatomic, copy) NSString *cardId;
//  银行卡卡号
@property (nonatomic, copy) NSString *cardNum;
//  银行卡类型 "BBC ICBC"
@property (nonatomic, copy) NSString *bankType;
//  银行卡的发卡城市
@property (nonatomic, copy) NSString *bankCity;
//  发卡支行
@property (nonatomic, copy) NSString *bankBranch;
//  银行编号
@property (nonatomic, copy) NSString *bankNum;
//  银行名称
@property (nonatomic, copy) NSString *bankName;


@property (nonatomic, assign)   BOOL isDefault;


@property (nonatomic, assign)   BOOL isUniq;

@end
