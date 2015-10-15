//
//  BankModel.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/5/6.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "BankModel.h"

@implementation BankModel


- (void)parseWithDictionary:(NSDictionary *)dic
{
    self.cardId = [dic stringIntForKey:@"id"];
    self.bankType = [dic stringForKey:@"bank_card_type"];
    self.cardNum = [dic stringIntForKey:@"bank_card_num"];
    self.bankCity = [dic stringForKey:@"bank_city"];
    self.bankBranch = [dic stringForKey:@"bank_branch"];
    self.bankNum = [dic stringIntForKey:@"bank_num"];
    self.bankName = [dic stringForKey:@"bank_name"];
    self.isDefault = [[dic stringIntForKey:@"is_default"] boolValue];
    self.isUniq = [[dic stringForKey:@"is_uniq"] boolValue];
}


@end
