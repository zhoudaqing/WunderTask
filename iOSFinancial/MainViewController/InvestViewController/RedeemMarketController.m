//
//  SecondMarketController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/25.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "RedeemMarketController.h"
#import "P2CCell.h"
#import "P2CDataSource.h"


@interface RedeemMarketController ()

@end

@implementation RedeemMarketController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.isRedeem = YES;
    }
    
    return self;
}

- (NSString *)projectListRequestURL
{
    return [NSString redeemList];
}

- (NSString *)datasKey
{
    return @"data";
}

- (NSString *)investAccount:(NSString *)investID
{
    return [NSString redeemAction:investID];
}

- (void)parseProjectDic:(NSDictionary *)dic andPaseModel:(P2CCellModel *)model
{
    [model parseRedeemDic:dic];
}


@end
